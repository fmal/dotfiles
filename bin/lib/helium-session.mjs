import childProcess from "node:child_process";
import { createDecipheriv, createHash, pbkdf2Sync } from "node:crypto";
import fs from "node:fs";
import { homedir, tmpdir } from "node:os";
import path from "node:path";
import readline from "node:readline/promises";
import { DatabaseSync } from "node:sqlite";
import { setTimeout as delay } from "node:timers/promises";
import { parseArgs } from "node:util";

// Copies sites' sessions from Chrome into the regular Helium profile. A site's session is
// the cookies on hosts whose names match cookieNames, and it works when signedIn(response,
// body) accepts the site's page. A target pairs a site with the URL Chrome signs in at and
// the sign-in task to show.

let activeCommand;

class RefreshError extends Error {}
class UsageError extends Error {}
class CancelledError extends Error {}

const attach = path.join(import.meta.dirname, "..", "pw-attach");

async function refresh(targets, { ready, chromeProfile, open }) {
  if (process.platform !== "darwin") throw new RefreshError("This command requires macOS.");
  if (!commandExists("playwright-cli") || !fs.existsSync(attach)) {
    throw new RefreshError("This command requires playwright-cli and pw-attach beside the script.");
  }
  if (!ready) {
    if (!process.stdin.isTTY) {
      throw new RefreshError("Run interactively to finish Chrome sign-in, or use --ready after confirming Chrome access.");
    }
    // -n hands the arguments to the running Chrome, which opens the URLs in that profile.
    await run([
      "open", "-na", "/Applications/Google Chrome.app", "--args", `--profile-directory=${chromeProfile}`,
      ...targets.map(target => target.signIn),
    ], homedir(), "Opening Chrome");
    for (const { task } of targets) console.log(`🌐 In Chrome, ${task}.`);
    await waitForChrome("Return here and press Enter once Chrome has finished: ");
  }
  const sites = targets.map(target => target.site);
  const names = new Intl.ListFormat("en").format(sites.map(site => site.name));
  console.log(`🔑 Reading and checking Chrome's sessions for ${names}. Approve Chrome Safe Storage if macOS asks.`);
  const sessions = await chromeSessions(sites, chromeProfile);
  using directory = fs.mkdtempDisposableSync(path.join(tmpdir(), "helium-session-"));
  await transfer(directory.path, sessions);
  console.log("🧹 Temporary cookie exports deleted.");
  if (open) await run(["open", "-a", "/Applications/Helium.app", open], homedir(), "Opening Helium");
}

// Parses the options every refresh command shares; the command checks its own positionals.
function options(argv) {
  let values, positionals;
  try {
    ({ values, positionals } = parseArgs({
      args: argv,
      allowPositionals: true,
      options: {
        ready: { type: "boolean", default: false },
        "chrome-profile": { type: "string", default: "Default" },
        help: { type: "boolean", short: "h", default: false },
      },
    }));
  } catch {
    throw new UsageError("Unknown or invalid options. Use --help.");
  }
  const profile = values["chrome-profile"];
  if (!profile || profile === "." || profile === ".." || path.basename(profile) !== profile) {
    throw new UsageError("--chrome-profile must be a directory name such as Default or 'Profile 1'.");
  }
  return { help: values.help, ready: values.ready, chromeProfile: profile, positionals };
}

const optionsHelp = `Options:
  --ready                 Use a working Chrome session without a sign-in prompt.
  --chrome-profile NAME   Chrome profile directory, such as Default or 'Profile 1'.
  -h, --help              Show this help.`;

function commandExists(command) {
  return (process.env.PATH || "").split(path.delimiter).some(directory => {
    try { fs.accessSync(path.join(directory, command), fs.constants.X_OK); return true; } catch { return false; }
  });
}

async function waitForChrome(prompt) {
  const terminal = readline.createInterface({ input: process.stdin, output: process.stdout });
  // Ctrl-C and Ctrl-D close the interface instead of raising SIGINT while it owns the TTY.
  terminal.once("close", cancel);
  try {
    await cancellable(signal => terminal.question(prompt, { signal }), "Chrome sign-in prompt");
  } finally {
    terminal.close();
  }
}

// Verifies every site before Helium changes, so one stale Chrome session leaves Helium untouched.
async function chromeSessions(sites, profile) {
  const directory = path.join(homedir(), "Library/Application Support/Google/Chrome", profile);
  const database = [path.join(directory, "Cookies"), path.join(directory, "Network/Cookies")]
    .find(file => fs.existsSync(file));
  if (!database) throw new RefreshError(`No cookie database exists in Chrome profile ${profile}.`);
  const key = await chromeKey();
  const sessions = [];
  // One site at a time: cancel() trips only the most recent cancellable().
  for (const site of sites) sessions.push({ site, cookies: await verifiedCookies(database, key, site) });
  return sessions;
}

// Chrome writes cookie changes to disk about every 30 seconds, so the file can lag behind the
// session that sign-in just issued. Reread it until the site accepts it.
async function verifiedCookies(database, key, site, { interval = 5_000 } = {}) {
  for (let attempt = 1; ; attempt++) {
    const cookies = readCookies(database, key, site);
    // Without cookies the site can only answer signed out, so skip the request.
    if (cookies.length && await sessionWorks(site, cookies)) return cookies;
    if (attempt === 10) {
      throw new RefreshError(`Chrome's saved ${site.name} login could not be verified. Sign in to ${site.name} in Chrome and retry. Helium was not changed.`);
    }
    if (attempt === 1) console.log(`⏳ Waiting for Chrome to save its ${site.name} session...`);
    await cancellable(signal => delay(interval, undefined, { signal }), "Waiting for Chrome");
  }
}

async function chromeKey() {
  const password = await run(
    ["security", "find-generic-password", "-s", "Chrome Safe Storage", "-a", "Chrome", "-w"],
    homedir(), "Chrome Keychain access",
  );
  return pbkdf2Sync(password.replace(/\n$/, ""), "saltysalt", 1003, 16, "sha1");
}

function readCookies(database, key, site) {
  using connection = new DatabaseSync(database, { readOnly: true });
  const version = Number(connection.prepare("SELECT value FROM meta WHERE key='version'").get()?.value);
  if (!Number.isInteger(version)) throw new RefreshError("Chrome cookie database version is unavailable.");
  const statement = connection.prepare(
    "SELECT host_key, name, path, value, encrypted_value, has_expires, expires_utc, " +
    "is_httponly, is_secure, samesite FROM cookies " +
    `WHERE host_key IN (${site.hosts.map(() => "?").join(", ")}) AND top_frame_site_key = ''`,
  );
  statement.setReadBigInts(true);
  const cookies = [];
  for (const row of statement.all(...site.hosts)) {
    if (!site.cookieNames.test(row.name)) continue;
    const expires = row.has_expires ? Number(row.expires_utc) / 1_000_000 + Date.UTC(1601, 0, 1) / 1000 : -1;
    if (expires !== -1 && expires <= Date.now() / 1000) continue;
    const encrypted = Buffer.from(row.encrypted_value);
    const cookie = {
      name: row.name,
      value: encrypted.length ? decryptCookie(encrypted, row.host_key, key, version) : row.value,
      domain: row.host_key,
      path: row.path,
      expires,
      httpOnly: Boolean(row.is_httponly),
      secure: Boolean(row.is_secure),
    };
    const sameSite = ["None", "Lax", "Strict"][Number(row.samesite)];
    if (sameSite) cookie.sameSite = sameSite;
    cookies.push(cookie);
  }
  return cookies;
}

function decryptCookie(encrypted, domain, key, version) {
  if (!encrypted.subarray(0, 3).equals(Buffer.from("v10"))) {
    throw new RefreshError("Chrome uses an unsupported cookie encryption format.");
  }
  let plain;
  try {
    const decipher = createDecipheriv("aes-128-cbc", key, Buffer.alloc(16, 32));
    plain = Buffer.concat([decipher.update(encrypted.subarray(3)), decipher.final()]);
  } catch {
    throw new RefreshError("Chrome cookie decryption failed.");
  }
  if (version >= 24) {
    const hash = createHash("sha256").update(domain).digest();
    if (!plain.subarray(0, hash.length).equals(hash)) {
      throw new RefreshError("Chrome cookie domain verification failed.");
    }
    plain = plain.subarray(hash.length);
  }
  return new TextDecoder("utf-8", { fatal: true }).decode(plain);
}

async function transfer(directory, sessions) {
  console.log("🔗 Connecting to your regular Helium profile...");
  try {
    await run([attach, "about:blank"], directory, "Helium attachment");
    for (const { site, cookies } of sessions) {
      await transferSite(directory, site, cookies);
      console.log(`✅ Verified your ${site.name} login in Helium.`);
    }
  } finally {
    await run(["playwright-cli", "detach"], directory, "Helium detachment").catch(() => {});
  }
}

// A failure rolls back this site only; sites copied before it keep their verified sessions.
async function transferSite(directory, site, cookies) {
  const urls = [...new Set(cookies.map(cookie => `https://${cookie.domain.replace(/^\./, "")}${cookie.path}`))];
  const current = await evaluate(directory, `async page => page.context().cookies(${JSON.stringify(urls)})`);
  const keys = new Set(cookies.map(cookieKey));
  const original = current.filter(cookie => keys.has(cookieKey(cookie)));
  console.log(`🍪 Copying ${site.name} cookies and checking the login...`);
  try {
    const jar = await loadCookies(directory, site, cookies);
    if (!await sessionWorks(site, jar)) {
      throw new RefreshError(`The ${site.name} login copied to Helium could not be verified. Retry the refresh.`);
    }
  } catch (error) {
    await restoreCookies(directory, site, cookies, original);
    throw error;
  }
}

function cookieKey(cookie) {
  return JSON.stringify([cookie.domain, cookie.path, cookie.name]);
}

// Returns Helium's resulting jar so the verification request sends exactly what Helium would.
function loadCookies(directory, site, cookies, clear = []) {
  return evaluate(directory, `async page => {
    for (const cookie of ${JSON.stringify(clear)}) await page.context().clearCookies(cookie);
    await page.context().addCookies(${JSON.stringify(cookies)});
    return page.context().cookies(${JSON.stringify(site.page)});
  }`, `${site.name} cookie import`);
}

// The request runs here, not in Helium: cancelling or timing out really stops it,
// and its Set-Cookie headers can never land in Helium after a rollback.
function sessionWorks(site, cookies) {
  return cancellable(async signal => {
    const response = await fetch(site.page, {
      headers: { cookie: cookies.map(({ name, value }) => `${name}=${value}`).join("; ") },
      // A redirect means the site wants a sign-in.
      redirect: "manual",
      signal,
    });
    // Reading the body lets the connection serve the next attempt.
    return site.signedIn(response, await response.text());
  }, `${site.name} verification`, { timeout: 30_000 });
}

async function restoreCookies(directory, site, incoming, original) {
  const changed = incoming.map(({ name, domain, path }) => ({ name, domain, path }));
  try {
    await loadCookies(directory, site, original, changed);
  } catch (error) {
    // The restore is uninterruptible, so a cancel surfaces only once it has succeeded.
    if (!(error instanceof CancelledError)) {
      console.error("⚠️ Could not restore the replaced cookies. Reconnect Helium and rerun the refresh.");
      return;
    }
  }
  console.log(`🔄 Restored the ${site.name} cookies that the command replaced.`);
}

// Code reaches Helium through a private file so cookie values never appear in the process list.
// The playwright-cli daemon runs it to completion even if this client dies, so neither cancel()
// nor a deadline abandons it: a rollback must see the import's result, not race it.
async function evaluate(directory, code, stage = "Helium operation") {
  const file = path.join(directory, "helium-operation.js");
  let output;
  try {
    fs.writeFileSync(file, code, { mode: 0o600 });
    output = await run(["playwright-cli", "--raw", "run-code", `--filename=${file}`], directory, stage, { interruptible: false });
  } finally {
    fs.rmSync(file, { force: true });
  }
  try {
    return JSON.parse(output);
  } catch {
    throw new RefreshError("Helium returned an unexpected response.");
  }
}

function run(command, directory, stage, options) {
  return cancellable(signal => new Promise((resolve, reject) => {
    childProcess.execFile(command[0], command.slice(1), {
      cwd: directory,
      maxBuffer: 16 * 1024 * 1024,
      signal,
    }, (error, stdout) => (error ? reject(error) : resolve(stdout)));
  }), stage, { timeout: 55_000, ...options });
}

// Every await in this module goes through here, so cancel() always has a signal to trip.
// Uninterruptible work gets no signal and no deadline: a cancel() surfaces only once it
// succeeds, so it never hides the work's own failure. Raw errors never escape: child output
// and response bodies may hold session values.
async function cancellable(work, stage, { timeout, interruptible = true } = {}) {
  const controller = new AbortController();
  activeCommand = controller;
  const reasons = interruptible ? [controller.signal] : [];
  if (timeout && interruptible) reasons.push(AbortSignal.timeout(timeout));
  const signal = AbortSignal.any(reasons);
  let result;
  try {
    result = await work(signal);
  } catch {
    if (interruptible && controller.signal.aborted) throw new CancelledError();
    throw new RefreshError(`${stage} ${signal.aborted ? "timed out" : "failed"}.`);
  } finally {
    activeCommand = undefined;
  }
  if (controller.signal.aborted) throw new CancelledError();
  return result;
}

function cancel() {
  activeCommand?.abort();
}

// Runs a command's main with shared cancellation and error reporting.
function runMain(main) {
  process.on("SIGINT", cancel);
  process.on("SIGTERM", cancel);
  main().catch(error => {
    if (error instanceof CancelledError) {
      console.error("🛑 Cancelled.");
      process.exitCode = 130;
    } else if (error instanceof UsageError || error instanceof RefreshError) {
      console.error(`❌ Error: ${error.message}`);
      process.exitCode = error instanceof UsageError ? 2 : 1;
    } else {
      console.error("❌ Error: Unexpected failure.");
      process.exitCode = 1;
    }
  });
}

export {
  RefreshError, UsageError, CancelledError, refresh, options, optionsHelp, runMain, run, decryptCookie,
  readCookies, verifiedCookies, cookieKey, transfer, cancel,
};
