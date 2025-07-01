# Claude Code Installation Guide: Global vs Local

## Original Global Installation (Standard Method)

The typical way to install Claude Code globally using npm:

```bash
# Standard global installation
npm install -g @anthropic-ai/claude-code

# Complete OAuth setup
claude
```

## Migrating to Local Installation

If you already have Claude Code installed globally and want to migrate to local:

```bash
# Start Claude Code
claude

# Use the migrate installer command
/migrate-installer
```

**What `/migrate-installer` does:**

- Creates a local installation in your user directory
- Avoids npm permission issues
- Enables proper auto-updates
- Maintains your existing configuration

## Verification Commands

```bash
# Check which claude installation is active
which claude

# Verify version
claude --version

# Run health check
claude doctor
```
