# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this is

`claude-switch` is a single-file Bash CLI (`bin/claude-switch`) that switches Claude Code
configuration profiles — to move between an Anthropic subscription, Amazon Bedrock, AWS, or
a custom provider (Kimi/Moonshot, etc.) when you run out of tokens on one.

There is no build step and no dependencies beyond Bash and `python3` (used only for safe JSON
read/merge — never hand-roll JSON parsing in shell here).

## Commands

```bash
bash -n bin/claude-switch     # syntax check (the only "lint"/"build")
./install.sh                  # symlink into ~/.local/bin (or /usr/local/bin)
./bin/claude-switch <cmd>     # run without installing
```

There is no test framework. To test safely **without touching the real ~/.claude config**,
override the three env vars and run against a temp sandbox:

```bash
T="$(mktemp -d)"
CLAUDE_HOME="$T/.claude" CLAUDE_PROFILES_DIR="$T/.claude-profiles" CLAUDE_JSON="$T/.claude.json" \
  ./bin/claude-switch <cmd>
```

`kc_*` (Keychain) helpers use the system `security` command and are **not** redirected by these
env vars — they always hit the real macOS Keychain. Avoid exercising `--account` / credential
paths in tests.

## Core model (the thing to understand before editing)

A "profile" = a saved `~/.claude/settings.json` (the `env` block selecting provider/model),
stored under `~/.claude-profiles/<name>/settings.json`.

What `use <name>` swaps is deliberately scoped:
- **Always:** `~/.claude/settings.json`.
- **Only with `--account` (macOS only):** the Keychain item `Claude Code-credentials` (OAuth
  token) and the `oauthAccount` field of `~/.claude.json`. These live *outside* settings.json,
  so they're the only things needed to switch between two distinct Anthropic subscriptions.
- **Never:** the rest of `~/.claude/` (history, projects, sessions, plugins, agents). That stays
  shared across profiles — do not add code that copies the whole directory.

`~/.claude.json` is large and mixes account identity with project history; it is edited
**surgically** (only the `oauthAccount` key, via `merge_oauth_account`), never wholesale.

`use` always calls `cmd_backup` first (timestamped dir under `.backups/`), so every switch is
reversible via `restore`. The active profile is tracked in `~/.claude-profiles/.active`.

## Conventions

- User-facing output, comments, and docs are in **English**.
- All filesystem/Keychain paths are overridable via `CLAUDE_HOME`, `CLAUDE_JSON`,
  `CLAUDE_PROFILES_DIR`, and `KC_SERVICE` — keep them overridable when adding features.
- Credential files are written `chmod 600`.
- New subcommands: add a `cmd_<name>` function and a `case` entry in `main`, and document it in
  both `cmd_help` and `README.md`.
