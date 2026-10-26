# Refresh GitHub access in Helium

`helium-github-refresh` copies your GitHub session cookies from Chrome into your regular Helium profile, then opens the organization in Helium. ORG is the GitHub organization whose SSO session you want to refresh.

```sh
helium-github-refresh ORG
```

1. Complete the organization's SSO in the Chrome window that opens.
2. Return to the terminal and press Enter.
3. If macOS asks for Chrome Safe Storage access, allow it.

If Chrome already has an active SSO session for the organization, add `--ready` to skip the SSO step. To read a Chrome profile other than `Default`, add `--chrome-profile 'Profile 1'`.

The command needs macOS, Node.js 24.4 or later, `playwright-cli`, and `bin/pw-attach`.

## Refresh other sites in the same run

To refresh GitHub together with sites you keep out of this repository, write a private script outside it, for example in `~/.local/bin`. The script defines its own sites and passes them, with `target(ORG)` from `bin/helium-github-refresh`, to `refresh` in `bin/lib/helium-session.mjs`. The run opens Chrome once and asks for Chrome Safe Storage once. It checks every Chrome session before it changes Helium.

To run the tests:

```sh
node --test ~/.dotfiles/bin/tests/*.test.mjs
```
