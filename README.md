# claude-switch

A tiny, zero-dependency CLI to switch between **Claude Code** configuration profiles —
so you can move between an Anthropic subscription, Amazon Bedrock, AWS, Kimi/Moonshot, or
any custom provider when you run out of tokens on one and want to switch to another.

## Idea

A **profile** is, at minimum, a saved `~/.claude/settings.json` (the `env` block that selects
provider and model), stored under `~/.claude-profiles/<name>/`. Optionally a profile can also
carry the **OAuth credential** (macOS Keychain) and the `oauthAccount` field of
`~/.claude.json`, so you can switch between **two distinct Anthropic subscriptions**.

### What gets swapped

| | File / resource | When |
|---|---|---|
| ✅ always | `~/.claude/settings.json` | every `use` |
| ✅ optional (`--account`, macOS only) | Keychain `Claude Code-credentials` (OAuth token) | if the profile has `credentials.json` |
| ✅ optional (`--account`) | `oauthAccount` field in `~/.claude.json` | if the profile has `oauthAccount.json` |
| ❌ **never touched** | the rest of `~/.claude/`: history, plugins, agents, sessions, `projects/` | — |

### Why the whole `.claude/` directory is NOT swapped

`~/.claude/` holds `history.jsonl`, `projects/`, `sessions/`, `plugins/`, agents and commands —
things you want **shared** across every profile. Swapping the directory on each switch would
mean losing your history and working setup.

- **Bedrock / AWS / Kimi** → only `settings.json` (the `env` block) changes. No credentials.
- **Two Anthropic subscriptions** → you also need the OAuth token (Keychain) + `oauthAccount`,
  because they live *outside* `settings.json`. Use `--account`.

## Install

One line, no clone needed:

```bash
curl -fsSL https://raw.githubusercontent.com/pippolino/claude-switch/main/install.sh | bash
```

This downloads `claude-switch` into the first writable PATH dir it finds
(`~/.local/bin`, `/usr/local/bin`, or `/opt/homebrew/bin`). Override with
`PREFIX=/usr/local/bin`.

From a clone (symlinks the binary, so your edits take effect immediately):

```bash
./install.sh
```

Or just run it in place: `./bin/claude-switch help`.

## Usage

```bash
claude-switch import                       # import your existing settings_*.json files
claude-switch save default --account \      # save the current state as "default"
              --desc "Anthropic subscription"
claude-switch list                         # list profiles (● = active)
claude-switch use bedrock                  # switch to Bedrock (auto-backup first)
claude-switch current                      # show the active profile
claude-switch diff bedrock kimi            # compare two profiles
claude-switch backups                      # list automatic backups
claude-switch restore 20260615-193026      # restore a backup
```

> After every `use`, **restart Claude Code**: the `env` block of `settings.json` is read at
> session startup.

## On-disk layout

```
~/.claude-profiles/
  .active                 # name of the active profile
  .backups/<timestamp>/   # automatic backups taken before each switch
  default/
    settings.json
    credentials.json      # only if saved with --account (mode 600)
    oauthAccount.json     # only with --account
    desc
  bedrock/
    settings.json
  kimi/
    settings.json
```

## Requirements

- Bash and `python3` (used only for safe JSON read/merge).
- macOS for the `--account` credential features (uses the system Keychain). On Linux the
  `settings.json` switching still works; credential handling is skipped.

## Environment overrides

`CLAUDE_HOME`, `CLAUDE_JSON`, `CLAUDE_PROFILES_DIR`, `KC_SERVICE` — handy for testing against a
sandbox without touching your real config.

## License

MIT
