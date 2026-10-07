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

## Quick Actions

### Defer tasks to next weekly note

Command palette: **QuickAdd: Defer tasks to next weekly note**

Highlight one or more tasks (or just put the cursor on one), run the command, and
each open task is marked `- [>]` in place, then re-added as `- [ ]` in next week's
weekly note under the same heading it was already under.

Pieces:

| File | Role |
| --- | --- |
| `scripts/deferTasks.js` | Marks the selected tasks `[>]`, reads the heading above them, works out which weekly note is "next", sets the QuickAdd variables below. |
| `.obsidian/plugins/quickadd/data.json` | The macro: the script above, then a Capture step that does the file work. |
| `templates/weekly.template.md` | Used to create next week's note when it does not exist yet. |

Variables passed from the script to the Capture step:

| Variable | Example | Used as |
| --- | --- | --- |
| `deferTarget` | `2026/Weeks/2026-W40.md` | Capture to |
| `deferHeading` | `### Admin Stuff` | Insert after |
| `deferTasks` | `- [ ] add miles to VW lease` | Captured text |

Behavior notes:

- Finished tasks are skipped. Which statuses count as finished is read from the
  Tasks plugin's own settings (any status typed `DONE`, `CANCELLED` or `NON_TASK`
  — currently `[x]` and `[-]`), so adding a custom status there is picked up
  automatically. `[>]` is skipped too, so re-running is safe. Statuses that are
  still open work — `[/]` In Progress, `[!]` Important, `[?]` Question, `[r]`
  Review — do get deferred.
- Run from a weekly note, "next" means the week after *that* note; run from a daily
  note, it means the week after today.
- The heading is created at the bottom of next week's note if it isn't there yet;
  with no heading above the selection at all, `## Weekly Tasks` is used.
- Metadata on the task line (priority, `⏳` dates, tags) is carried over untouched.
- The tasks' shared indentation is stripped, so a nested task deferred on its own
  lands at the left margin.

Only the two things no built-in command can do live in the script: the Tasks plugin's
`[>]` command changes just the cursor's line, and QuickAdd exposes the current
section only as a link, not as heading text. Finding next week's note, creating it
from the template, and finding or adding the heading are all the Capture step.
