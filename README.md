# Dotfiles

## Installation

```bash
git clone https://github.com/fmal/dotfiles.git ~/.dotfiles
cd ~/.dotfiles
chmod +x install.sh
./install.sh
```

`install.sh` symlinks all `*.symlink` files to `~/.<name>`, links configs into
`~/.config` and app support dirs, then runs the `*.install` scripts. It is
idempotent and prompts before touching existing files.

## Manual steps not covered by install.sh

- Restore the fnox age key to `~/.config/fnox/age.txt` (`chmod 600`). It is
  machine-local and never committed.
- Restore SSH keys and `~/.ssh/config.local` (host blocks; included by the
  tracked `ssh/config`).
- After iCloud has synced, run `mackup restore` to bring back app settings
  (see `mackup/mackup.cfg.symlink`).
