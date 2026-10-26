import assert from "node:assert/strict";
import { createCipheriv, createHash } from "node:crypto";
import fs from "node:fs";
import os from "node:os";
import path from "node:path";
import vm from "node:vm";
import childProcess from "node:child_process";
import { DatabaseSync } from "node:sqlite";
import { test } from "node:test";
import { setTimeout as delay } from "node:timers/promises";
import * as m from "../lib/helium-session.mjs";

const key = Buffer.from("0123456789abcdef");
const future = (BigInt(Date.now()) + 3600_000n) * 1000n + 11644473600_000000n;

// The commands supply real sites; this one keeps the core tests independent of them.
const site = {
  name: "Example",
  hosts: ["example.test", ".example.test"],
  cookieNames: /^session/,
  page: "https://example.test/",
  signedIn: (response, body) => response.status === 200 && body === "signed in",
};

function temporary(t) {
  const directory = fs.mkdtempSync(path.join(os.tmpdir(), "helium-js-fixture-"));
  t.after(() => fs.rmSync(directory, { recursive: true, force: true }));
  return directory;
}

function encrypted(domain, value, version = 24) {
  const plain = version >= 24 ? Buffer.concat([createHash("sha256").update(domain).digest(), Buffer.from(value)]) : Buffer.from(value);
  const cipher = createCipheriv("aes-128-cbc", key, Buffer.alloc(16, 32));
  return Buffer.concat([Buffer.from("v10"), cipher.update(plain), cipher.final()]);
}

function database(t, modify = () => {}) {
  const file = path.join(temporary(t), "Cookies");
  const db = new DatabaseSync(file);
  db.exec("CREATE TABLE meta (key TEXT, value TEXT); INSERT INTO meta VALUES ('version', '24'); CREATE TABLE cookies (host_key TEXT, name TEXT, path TEXT, value TEXT, encrypted_value BLOB, has_expires INTEGER, expires_utc INTEGER, is_httponly INTEGER, is_secure INTEGER, samesite INTEGER, top_frame_site_key TEXT)");
  const insert = db.prepare("INSERT INTO cookies VALUES (?, ?, '/', '', ?, 1, ?, 1, 1, 1, ?)");
  assert(future > BigInt(Number.MAX_SAFE_INTEGER));
  const rows = [
    [".example.test", "session_hint", "synthetic-hint", future, ""],
    ["example.test", "session", "synthetic-active-session", future, ""],
    ["other.test", "session", "synthetic-unrelated-session", future, ""],
    ["example.test", "preferences", "synthetic-preferences", future, ""],
    ["example.test", "session_expired", "synthetic-expired", 1n, ""],
    ["example.test", "session_partitioned", "synthetic-partitioned", future, "https://example.invalid"],
  ];
  for (const [domain, name, value, expires, partition] of rows) insert.run(domain, name, encrypted(domain, value), expires, partition);
  modify(db);
  db.close();
  return file;
}

function sitePage(signedIn) {
  return new Response(signedIn ? "signed in" : "signed out");
}

function cookie(name, value, domain = "example.test") {
  return { name, value, domain, path: "/", secure: true, httpOnly: true, expires: -1 };
}

const incoming = [cookie("session_hint", "synthetic-hint", ".example.test"), cookie("session", "synthetic-active-session"), cookie("introduced", "synthetic-new-cookie")];

function browserFixture(t, { loginFailure = false, requestFailure = false, partial = false, cancelImport = false, cancelMidImport = false, cancelRequest = false, cancelRestore = false, restoreFailure = false } = {}) {
  const directory = temporary(t);
  const initial = [
    cookie("session_hint", "synthetic-old-hint", ".example.test"),
    cookie("session", "synthetic-old-session"),
    cookie("preferences", "synthetic-preferences"),
    cookie("unrelated", "synthetic-preserve-me", "other.test"),
  ];
  const store = new Map(initial.map(c => [m.cookieKey(c), { ...c }]));
  const logs = [];
  const operations = [];
  const requests = [];
  const cookieHeaders = [];
  let imports = 0;
  let detachments = 0;
  const context = {
    cookies: async urls => [...store.values()].filter(c => [urls].flat().some(raw => {
      const url = new URL(raw);
      return (url.hostname === c.domain.replace(/^\./, "") || url.hostname.endsWith(c.domain)) && url.pathname.startsWith(c.path);
    })),
    addCookies: async cookies => {
      imports++;
      if (imports === 2 && cancelRestore) m.cancel();
      if (imports === 2 && restoreFailure) throw new Error("synthetic-restore-failure");
      for (const c of cookies) {
        store.set(m.cookieKey(c), { ...c });
        if (imports === 1 && c.name === "session") {
          if (partial) throw new Error("synthetic-sensitive-browser-error");
          // Cancelled here, Helium still stores the remaining cookies a moment later.
          if (cancelMidImport) { m.cancel(); await delay(50); }
        }
      }
    },
    clearCookies: async filter => {
      assert.deepEqual(Object.keys(filter).sort(), ["domain", "name", "path"]);
      for (const [key, c] of store) if (c.name === filter.name && c.domain === filter.domain && c.path === filter.path) store.delete(key);
    },
    setStorageState: () => { throw new Error("Whole-storage replacement is forbidden"); },
    get request() { throw new Error("Helium's request jar is forbidden: late responses would overwrite the rollback"); },
  };
  const page = { context: () => context };
  t.mock.method(globalThis, "fetch", async (url, options) => {
    requests.push(url);
    cookieHeaders.push(options.headers.cookie);
    if (requestFailure) throw new TypeError("synthetic-network-failure");
    if (cancelRequest) {
      // Ends only if the script wires cancellation into the request itself.
      queueMicrotask(() => m.cancel());
      await new Promise((_, reject) => options.signal.addEventListener("abort", () => reject(options.signal.reason), { once: true }));
    }
    return sitePage(!loginFailure);
  });
  t.mock.method(console, "log", message => logs.push(message));
  t.mock.method(console, "error", message => logs.push(message));
  t.mock.method(childProcess, "execFile", (command, args, options, callback) => {
    operations.push(Promise.resolve().then(async () => {
      if (path.basename(command) === "pw-attach") return callback(null, "");
      assert.equal(command, "playwright-cli");
      if (args.includes("detach")) { detachments++; return callback(null, ""); }
      const filename = args.find(arg => arg.startsWith("--filename="));
      assert(filename, "Helium code must arrive through a file, never on argv");
      const file = filename.slice("--filename=".length);
      assert.equal(fs.statSync(file).mode & 0o777, 0o600);
      assert(!args.some(arg => arg.includes("synthetic-")));
      const operation = vm.runInNewContext(`(${fs.readFileSync(file, "utf8")})`);
      // A killed client reports the abort at once; Helium runs the operation to completion regardless.
      options.signal.addEventListener("abort", () => callback(Object.assign(new Error("synthetic-aborted-secret"), { code: "ABORT_ERR" }), ""), { once: true });
      const result = await operation(page);
      if (options.signal.aborted) return;
      if (cancelImport && imports === 1) m.cancel();
      callback(null, JSON.stringify(result));
    }).catch(error => callback(error, "synthetic-sensitive-browser-output")));
    return {};
  });
  return {
    logs,
    requests,
    cookieHeaders,
    get imports() { return imports; },
    transfer: (sessions = [{ site, cookies: incoming }]) => m.transfer(directory, sessions),
    cookieValue: (name, domain) => store.get(m.cookieKey(cookie(name, "", domain)))?.value,
    assertCleanedUp() {
      assert.equal(detachments, 1);
      assert.deepEqual(fs.readdirSync(directory), []);
      assert(!logs.join("\n").includes("synthetic-"));
    },
    // Helium finishes every operation it received, even after the client died.
    async assertPreserved() {
      await Promise.all(operations);
      assert.deepEqual(store, new Map(initial.map(c => [m.cookieKey(c), c])));
    },
  };
}

test("parses the shared options and rejects unknown flags and unsafe profiles", () => {
  assert.deepEqual(m.options(["--ready", "example-org", "--chrome-profile", "Profile 1"]), { help: false, ready: true, chromeProfile: "Profile 1", positionals: ["example-org"] });
  assert.deepEqual(m.options([]), { help: false, ready: false, chromeProfile: "Default", positionals: [] });
  assert.equal(m.options(["--help"]).help, true);
  assert.throws(() => m.options(["--bogus"]), m.UsageError);
  assert.throws(() => m.options(["--chrome-profile", "../Default"]), m.UsageError);
});

test("decrypts current domain-bound and legacy Chrome cookie formats", () => {
  assert.equal(m.decryptCookie(encrypted("example.test", "synthetic-value"), "example.test", key, 24), "synthetic-value");
  assert.equal(m.decryptCookie(encrypted("example.test", "synthetic-value", 23), "example.test", key, 23), "synthetic-value");
});

test("rejects mismatched domain hashes and unsupported encryption versions", () => {
  assert.throws(() => m.decryptCookie(encrypted("wrong.example", "synthetic-value"), "example.test", key, 24), m.RefreshError);
  assert.throws(() => m.decryptCookie(Buffer.from("v99synthetic"), "example.test", key, 24), m.RefreshError);
});

test("reads unsafe-width Chromium timestamps and exports only the site's active session cookies", t => {
  const cookies = m.readCookies(database(t), key, site);
  assert.deepEqual(cookies.map(c => c.name), ["session_hint", "session"]);
  assert.deepEqual(cookies.map(c => c.value), ["synthetic-hint", "synthetic-active-session"]);
  assert(cookies.every(c => c.expires > Date.now() / 1000));
});

for (const [state, modify] of [
  ["stale", () => {}],
  ["expired", db => db.exec("UPDATE cookies SET expires_utc = 1 WHERE host_key = 'example.test' AND name = 'session'")],
]) {
  test(`rereads Chrome's cookies while the saved session is ${state}`, async t => {
    const file = database(t, modify);
    t.mock.method(console, "log", () => {});
    const fetch = t.mock.method(globalThis, "fetch", async (_, options) => {
      const fresh = options.headers.cookie.includes("session=synthetic-fresh-session");
      if (!fresh) {
        // Chrome saves the session that sign-in issued only after the first check.
        const db = new DatabaseSync(file);
        db.prepare("UPDATE cookies SET encrypted_value = ?, expires_utc = ? WHERE host_key = 'example.test' AND name = 'session'").run(encrypted("example.test", "synthetic-fresh-session"), future);
        db.close();
      }
      return sitePage(fresh);
    });
    const cookies = await m.verifiedCookies(file, key, site, { interval: 1 });
    assert.equal(cookies.find(c => c.name === "session").value, "synthetic-fresh-session");
    assert.equal(fetch.mock.callCount(), 2);
  });
}

test("gives up when Chrome's saved session never verifies", async t => {
  t.mock.method(console, "log", () => {});
  const fetch = t.mock.method(globalThis, "fetch", async () => sitePage(false));
  await assert.rejects(m.verifiedCookies(database(t), key, site, { interval: 1 }), m.RefreshError);
  assert.equal(fetch.mock.callCount(), 10);
});

test("checks sessions without following redirects", async t => {
  t.mock.method(console, "log", () => {});
  const fetch = t.mock.method(globalThis, "fetch", async (_, options) => {
    assert.equal(options.redirect, "manual");
    return sitePage(true);
  });
  assert.equal((await m.verifiedCookies(database(t), key, site, { interval: 1 })).length, 2);
  assert.equal(fetch.mock.callCount(), 1);
});

test("successful import verifies the login and preserves unrelated cookies", async t => {
  const fixture = browserFixture(t);
  await fixture.transfer();
  assert.deepEqual(fixture.requests, ["https://example.test/"]);
  assert(fixture.cookieHeaders.every(header => header.includes("session=synthetic-active-session") && !header.includes("synthetic-preserve-me")));
  assert.equal(fixture.cookieValue("session"), "synthetic-active-session");
  assert.equal(fixture.cookieValue("unrelated", "other.test"), "synthetic-preserve-me");
  assert.equal(fixture.cookieValue("preferences"), "synthetic-preferences");
  fixture.assertCleanedUp();
});

test("copies several sites under one Helium attachment", async t => {
  const fixture = browserFixture(t);
  const other = { ...site, name: "Other", hosts: ["other.test"], page: "https://other.test/" };
  await fixture.transfer([{ site, cookies: incoming }, { site: other, cookies: [cookie("session", "synthetic-other-session", "other.test")] }]);
  assert.deepEqual(fixture.requests, ["https://example.test/", "https://other.test/"]);
  assert.equal(fixture.cookieValue("session"), "synthetic-active-session");
  assert.equal(fixture.cookieValue("session", "other.test"), "synthetic-other-session");
  assert.equal(fixture.cookieValue("unrelated", "other.test"), "synthetic-preserve-me");
  fixture.assertCleanedUp();
});

test("failed login verification restores exactly replaced keys and removes introduced cookies", async t => {
  const fixture = browserFixture(t, { loginFailure: true });
  await assert.rejects(fixture.transfer(), m.RefreshError);
  assert.equal(fixture.imports, 2);
  await fixture.assertPreserved();
  fixture.assertCleanedUp();
});

test("a failed verification request rolls back", async t => {
  const fixture = browserFixture(t, { requestFailure: true });
  await assert.rejects(fixture.transfer(), m.RefreshError);
  assert.deepEqual(fixture.requests, ["https://example.test/"]);
  await fixture.assertPreserved();
  fixture.assertCleanedUp();
});

test("partial import failure rolls back without exposing child output", async t => {
  const fixture = browserFixture(t, { partial: true });
  await assert.rejects(fixture.transfer(), error => error instanceof m.RefreshError && !error.message.includes("synthetic-"));
  await fixture.assertPreserved();
  fixture.assertCleanedUp();
});

test("cancellation unwinds through rollback, detachment and export cleanup", async t => {
  const fixture = browserFixture(t, { cancelImport: true });
  await assert.rejects(fixture.transfer(), m.CancelledError);
  assert.equal(fixture.imports, 2);
  await fixture.assertPreserved();
  fixture.assertCleanedUp();
});

test("cancellation during an unfinished import also rolls back the cookies Helium stored afterwards", async t => {
  const fixture = browserFixture(t, { cancelMidImport: true });
  await assert.rejects(fixture.transfer(), m.CancelledError);
  assert.deepEqual(fixture.requests, []);
  assert.equal(fixture.imports, 2);
  await fixture.assertPreserved();
  fixture.assertCleanedUp();
});

test("cancellation stops an in-flight verification request before rollback", { timeout: 5000 }, async t => {
  const fixture = browserFixture(t, { cancelRequest: true });
  await assert.rejects(fixture.transfer(), m.CancelledError);
  assert.deepEqual(fixture.requests, ["https://example.test/"]);
  await fixture.assertPreserved();
  fixture.assertCleanedUp();
});

test("cancelling the rollback lets it finish and reports the restore", async t => {
  const fixture = browserFixture(t, { loginFailure: true, cancelRestore: true });
  await assert.rejects(fixture.transfer(), m.RefreshError);
  assert(fixture.logs.some(line => line.includes("Restored")));
  assert(!fixture.logs.some(line => line.includes("Could not restore")));
  await fixture.assertPreserved();
  fixture.assertCleanedUp();
});

test("a rollback that fails while cancelled still warns", async t => {
  const fixture = browserFixture(t, { loginFailure: true, cancelRestore: true, restoreFailure: true });
  await assert.rejects(fixture.transfer(), m.RefreshError);
  assert(fixture.logs.some(line => line.includes("Could not restore")));
  assert(!fixture.logs.some(line => line.includes("Restored")));
  fixture.assertCleanedUp();
});

test("lets uninterruptible work outlive its deadline", async t => {
  const script = "setTimeout(() => process.stdout.write('done'), 100)";
  assert.equal(await m.run([process.execPath, "-e", script], temporary(t), "Fixture operation", { timeout: 30, interruptible: false }), "done");
});

test("reports actual subprocess timeouts without dumping stdout or stderr", async t => {
  await assert.rejects(m.run([process.execPath, "-e", "setTimeout(() => {}, 5000)"], temporary(t), "Fixture operation", { timeout: 30 }), error => error instanceof m.RefreshError && error.message === "Fixture operation timed out.");
});
