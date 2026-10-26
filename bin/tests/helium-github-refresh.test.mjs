import assert from "node:assert/strict";
import childProcess from "node:child_process";
import path from "node:path";
import { test } from "node:test";
import * as m from "../lib/helium-session.mjs";
import * as github from "../helium-github-refresh";

test("accepts exactly one well-formed organization name and preserves its case", () => {
  assert.equal(github.organization(["Example-Org"]), "Example-Org");
  for (const positionals of [[], ["another-org", "example-org"], ["../example-org"], ["https://github.com/example-org"], ["-example-org"], ["example-org-"], ["example-org/project"]]) {
    assert.throws(() => github.organization(positionals), m.UsageError);
  }
});

test("missing target exits before reading credentials or opening browsers", () => {
  const result = childProcess.spawnSync(process.execPath, [path.resolve(import.meta.dirname, "../helium-github-refresh"), "--ready"], {
    encoding: "utf8",
    env: { ...process.env, PATH: "" },
  });
  assert.equal(result.status, 2);
  assert.match(result.stderr, /Supply one ORG/);
  assert.equal(result.stdout, "");
});

test("copies only GitHub's session cookies", () => {
  for (const name of ["user_session", "__Host-user_session_same_site", "logged_in", "dotcom_user"]) assert(github.site.cookieNames.test(name), name);
  for (const name of ["saved_user_sessions", "_gh_sess", "_device_id", "tz"]) assert(!github.site.cookieNames.test(name), name);
});

test("treats only a 200 page that names the user as signed in", () => {
  const signedIn = (login, status = 200) => github.site.signedIn(new Response(null, { status }), `<meta name="user-login" content="${login}">`);
  assert.equal(signedIn("octocat"), true);
  assert.equal(signedIn(""), false);
  assert.equal(signedIn("octocat", 302), false);
});
