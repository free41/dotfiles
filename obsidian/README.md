# Obsidian Configuration Sync

This directory contains synced Obsidian vault settings and templates.

## Directory Structure

```
obsidian/
├── .obsidian/     # Vault configuration files
│   ├── app.json
│   ├── appearance.json
│   ├── hotkeys.json
│   ├── core-plugins.json
│   └── community-plugins.json
└── templates/     # Note templates
    └── *.md
```

## Setup

Set your vault path in `config.mk` (defaults to `~/Vault`):
```makefile
OBSIDIAN_VAULT_PATH := ~/Vault
```

## Usage

### Initial Setup

Add placeholder files for the settings you want to track:
```bash
# Create .obsidian config files
touch obsidian/.obsidian/app.json
touch obsidian/.obsidian/appearance.json
touch obsidian/.obsidian/hotkeys.json
touch obsidian/.obsidian/core-plugins.json
touch obsidian/.obsidian/community-plugins.json

# Create template files
touch obsidian/templates/meeting-note.md
touch obsidian/templates/daily-note.md
```

### Syncing

**Fetch from vault to repo** (only syncs files that already exist in repo):
```bash
make obsidian-fetch
```

**Push from repo to vault** (copies all files from repo to vault):
```bash
make obsidian-push
```

## Important Notes

- `obsidian-fetch` **only syncs files that already exist** in the repo (prevents accidentally tracking unwanted files)
- `obsidian-push` copies all files from repo to vault (overwrites vault files)
- Always backup your vault before using `obsidian-push`
- The `.obsidian/` folder is vault-specific configuration
- Templates are plain markdown files stored in `templates/`
