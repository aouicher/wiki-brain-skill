---
name: wiki-brain
description: "Turn Claude Code into a knowledge base that compounds. Every conversation ingests into a personal wiki you browse in Obsidian. Based on Andrej Karpathy's LLM Wiki pattern, powered by Graphify."
---

# /wiki-brain — A Compounding Knowledge Base for Claude Code

Turn Claude Code into a system that *remembers*. Every conversation feeds an ever-growing personal wiki you browse in Obsidian. Claude queries a knowledge graph before reading raw files, so answers are faster, smarter, and cheaper over time.

Based on [Andrej Karpathy's LLM Wiki pattern](https://gist.github.com/karpathy) and powered by [Graphify](https://github.com/safishamsi/graphify).

---

## Invocation

```
/wiki-brain                        # first run: setup wizard · after: show status menu
/wiki-brain ingest <file-or-url>   # ingest a new source into the wiki
/wiki-brain query "<question>"     # query the knowledge graph + wiki
/wiki-brain lint                   # health check the wiki
/wiki-brain rebuild                # force a graphify rebuild
/wiki-brain doctor                 # verify install health
/recall                            # show last 5 sessions + read linked pages
```

---

## Step 0 — First-Time Setup

**Check for config** at `~/.claude/skills/wiki-brain/config.json`. If it exists with `setupComplete: true`, skip to Step 1 (status menu).

**If no config, run the setup wizard.**

### 0.1 — Greet the user

```
Welcome to /wiki-brain!

This turns Claude Code into a knowledge base that compounds. Every
conversation you have from now on can feed a personal wiki you'll
browse in Obsidian. Claude gets smarter about YOUR stuff over time,
and answers questions faster by querying a knowledge graph instead
of re-reading files.

Setup takes about 5 minutes. Let's go.
```

### 0.2 — Ask about Obsidian

```
Question 1 of 4: Do you already use Obsidian?

Obsidian is a free app for browsing markdown notes with backlinks
and graph view. Your wiki lives inside an Obsidian "vault" (just a
folder on your computer).

  1. Yes — I already have Obsidian installed and a vault set up
  2. No  — I need to install it and create a vault
```

**If answer is 1:**
```
Great. What's the full path to the vault you want to use?

Example: /Users/yourname/Documents/MyVault

(Tip: in Obsidian, right-click your vault name in the sidebar and
choose "Reveal in Finder/Explorer" to see the path.)
```

Read the path, verify it exists and is writable. If not, ask again.

**If answer is 2:**
```
No problem. Here's how to install Obsidian and create a vault:

STEP 1 — Download Obsidian
  • Go to https://obsidian.md
  • Click "Download" and pick your operating system
  • Open the downloaded file and install it (drag to Applications on
    Mac, run the installer on Windows)

STEP 2 — Create a vault
  • Open Obsidian
  • Click "Create new vault"
  • Name it something like "Brain" or "Wiki"
  • Pick a location (Documents folder is a good default)
  • Click "Create"

STEP 3 — Find the vault path
  • In Obsidian, right-click your vault name in the top-left sidebar
  • Click "Reveal in Finder" (Mac) or "Show in Explorer" (Windows)
  • Copy the full path from the Finder/Explorer address bar

Come back here when you've done all three steps. Paste the full
path to your vault and hit Enter.
```

Wait for the path. Verify it exists and is a directory.

### 0.3 — Ask about Graphify rebuild cadence

```
Question 2 of 4: How often should we rebuild your knowledge graph?

WHAT THIS IS:
Graphify reads all your wiki notes and builds a "map" of how
everything connects — which topics relate to which, what links
to what. When you ask Claude a question, it queries this map
first instead of opening every file one by one. This makes
Claude faster, smarter, and cheaper because it doesn't have
to re-read your notes every time.

WHY IT NEEDS REBUILDING:
Every time you finish a Claude conversation, your wiki gets
updated with new info. The map gets a little out of date.
A "rebuild" tells Graphify to re-scan your wiki and update
the map so Claude is working with current information.

IMPORTANT:
A rebuild only runs if your wiki has actually changed since
last time. If nothing's new, it skips. You never burn compute
for nothing.

PICK ONE:
  1. Aggressive  — every 3 days
     Best if you're in Claude Code daily and want the freshest map.

  2. Balanced    — every 7 days          ← recommended
     Good for most people. Stays current week to week.

  3. Manual only — no auto rebuild
     You run /wiki-brain rebuild yourself. Full control, zero
     background activity.
```

### 0.4 — Ask about lint cadence

```
Question 3 of 4: How often should we health-check your wiki?

WHAT THIS IS:
Over time, your wiki accumulates pages. Some get out of date.
Some end up disconnected from everything (orphans). Some say
one thing on page A and the opposite on page B (contradictions).
A "lint" is Claude doing a health check on your wiki — it reads
through, looks for problems, and reports them so you can fix
or ignore them.

WHY IT MATTERS:
A wiki you don't maintain rots. Lint catches rot early. It
doesn't auto-fix anything — you stay in control.

WHAT LINT CHECKS:
  • Contradictions — page A says X, page B says the opposite
  • Stale claims — info that newer notes have superseded
  • Orphan pages — notes nothing else links to
  • Missing pages — concepts mentioned everywhere with no
                    dedicated page
  • Broken links — [[references]] to pages that don't exist

PICK ONE:
  1. Weekly       — for fast-growing wikis
  2. Monthly      — recommended for most people
  3. Manual only  — you run /wiki-brain lint yourself
```

### 0.5 — Ask about CLAUDE.md location

```
Question 4 of 4: Where should I add the wiki-brain instructions?

I need to add a short block of instructions to your CLAUDE.md
so Claude knows how to use your wiki. You can put these in:

  1. Your GLOBAL CLAUDE.md (~/.claude/CLAUDE.md)
     Wiki-brain will work in every project.

  2. A specific project's CLAUDE.md
     Only that project will use the wiki. Paste the path when
     asked.

Pick one:
```

If `2`, ask for the path. Verify the file exists (or offer to create it).

### 0.6 — Check Graphify is installed

Run:
```bash
which graphify 2>/dev/null && echo "GRAPHIFY_OK" || echo "GRAPHIFY_MISSING"
```

If missing, install using the first method that works:

```bash
# Method 1 — pipx (recommended on macOS/Linux, cleanest isolation)
pipx install graphifyy 2>&1 | tail -3
```

```bash
# Method 2 — pip user install (fallback if pipx not available)
python3 -m pip install --user graphifyy 2>&1 | tail -3
```

```bash
# Method 3 — system pip with override (last resort, e.g. some Linux distros)
python3 -m pip install graphifyy --break-system-packages 2>&1 | tail -3
```

After each attempt, verify with:
```bash
which graphify && echo "OK" || echo "STILL MISSING"
```

If all three fail, show the error and stop — tell the user to install manually and retry `/wiki-brain`.

> **Note:** The PyPI package is named `graphifyy` (double-y). The CLI command is still `graphify` (single y). This is expected.

### 0.7 — Create the vault structure

Inside the user's vault path, create:

```
<vault>/
├── raw/                    # drop source files here
├── wiki/                   # Claude-maintained pages
│   └── index.md            # catalog of all wiki pages
└── log.md                  # chronological record
```

Use Bash:
```bash
VAULT="<user-provided-path>"
mkdir -p "$VAULT/raw" "$VAULT/wiki"
[ ! -f "$VAULT/wiki/index.md" ] && cat ~/.claude/skills/wiki-brain/templates/index.md > "$VAULT/wiki/index.md"
[ ! -f "$VAULT/log.md" ] && cat ~/.claude/skills/wiki-brain/templates/log.md > "$VAULT/log.md"
```

### 0.8 — Preview the CLAUDE.md patch

Show the user exactly what will be added to their CLAUDE.md BEFORE writing anything. Read `~/.claude/skills/wiki-brain/templates/claude-md-patch.md`, substitute `{{VAULT_PATH}}` with the user's vault path, and display:

```
Here's what I'll add to <CLAUDE.md path>:

---
<rendered patch>
---

Want me to append this? (yes/no)
```

If no, stop and tell the user they can re-run `/wiki-brain` later.

If yes, append to the CLAUDE.md file (never overwrite). If the file already has `## Wiki-Brain` or `## Context Navigation` headers, warn the user and ask before appending to avoid duplicates.

### 0.9 — Install the SessionEnd hook

Read `~/.claude/settings.json` (create it as `{}` if missing). Add a SessionEnd hook entry that runs the wiki-brain hook script. The hook script path is `~/.claude/skills/wiki-brain/hooks/session-end.sh`.

Use this JSON merge pattern (preserve any existing hooks):

```json
{
  "hooks": {
    "SessionEnd": [
      {
        "matcher": "*",
        "hooks": [
          {
            "type": "command",
            "command": "~/.claude/skills/wiki-brain/hooks/session-end.sh"
          }
        ]
      }
    ]
  }
}
```

Make the hook script executable: `chmod +x ~/.claude/skills/wiki-brain/hooks/session-end.sh`.

### 0.10 — Save config

Write `~/.claude/skills/wiki-brain/config.json`:

```json
{
  "setupComplete": true,
  "setupDate": "<YYYY-MM-DD>",
  "vaultPath": "<user-provided-path>",
  "claudeMdPath": "<path-they-picked>",
  "rebuildCadenceDays": 3 | 7 | 0,
  "lintCadenceDays": 7 | 30 | 0,
  "lastRebuild": null,
  "lastLint": null
}
```

`0` means manual only.

### 0.11 — First build

Tell the user to run the first Graphify build from Claude Code to prime the output directory:

```
Run this in Claude Code (not in a terminal):
  /graphify ./wiki
```

It's OK if the wiki is empty — this just ensures `graphify-out/` exists for future queries.

> **Important:** `/graphify` is a Claude Code slash command. It cannot be run in a terminal directly — the build requires Claude subagents and runs inside Claude Code only.

### 0.12 — Confirm and end setup

```
All set. Here's what just happened:

  ✓ Obsidian vault: <path>
  ✓ Folders created: raw/, wiki/, log.md
  ✓ Graphify installed
  ✓ CLAUDE.md patched
  ✓ SessionEnd hook installed
  ✓ Cadence: rebuild every <N> days, lint every <N> days

WHAT TO DO NEXT:
  1. Open Obsidian and point it at your vault
  2. Drop any source (article, PDF, transcript) into <vault>/raw/
  3. Tell Claude: "Ingest the new file in raw/"
  4. Watch your wiki fill up with interlinked pages
  5. Use /recall anytime to see what you've been working on

Your wiki will get richer with every conversation from now on.
Welcome to compounding knowledge.
```

---

## Step 1 — After Setup: The Status Menu

When `/wiki-brain` is called with no arguments AND config exists, load the config and show:

```
Wiki-Brain — <vault-path>

  Pages in wiki:        <count>
  Sources in raw/:      <count>
  Last rebuild:         <date> (next due in N days)
  Last lint:            <date> (next due in N days)
  Log entries:          <count>

WHAT WOULD YOU LIKE TO DO?
  1. Ingest a source        (/wiki-brain ingest <file>)
  2. Query the wiki         (/wiki-brain query "<question>")
  3. Health check           (/wiki-brain lint)
  4. Force rebuild          (/wiki-brain rebuild)
  5. Show recent activity   (/recall)
  6. Diagnose setup         (/wiki-brain doctor)
  7. Exit
```

---

## Step 2 — Ingest

`/wiki-brain ingest <file-or-url>`

1. If it's a URL: fetch content and save as `<vault>/raw/<slug>-<date>.md`. If it's a local file: copy it into `<vault>/raw/` (never modify the original).
2. **Read the source in full.**
3. **Summarize the key takeaways** for the user (bullet list, 5–10 points). Ask if you should emphasize anything specific.
4. **Write/update wiki pages:**
   - Create a new page `<vault>/wiki/<topic-slug>.md` if this is a new topic
   - Update existing pages that this source touches
   - Add cross-links using `[[Other Page]]` Obsidian syntax
   - Use YAML frontmatter: `---\ndate: <YYYY-MM-DD>\nsources:\n  - <filename>\ntags: [...]\n---`
5. **Update `<vault>/wiki/index.md`** — add the new page with a one-line summary.
6. **Append to `<vault>/log.md`:**
   ```
   ## [YYYY-MM-DD HH:MM] ingest | <source title>
   Touched: wiki/page-a.md, wiki/page-b.md, wiki/page-c.md
   ```
7. Report back: which pages were created, which updated, how many cross-links added.

**Be thorough.** A single source should typically touch 3–10 wiki pages. That's how the wiki compounds — don't be lazy.

---

## Step 3 — Query

`/wiki-brain query "<question>"`

1. Run `graphify query "<question>" --graph graphify-out/graph.json` from the vault directory. This returns a graph-based answer.
2. If `graphify-out/graph.json` does not exist, skip to step 3 and note that the graph hasn't been built yet.
3. Read `<vault>/wiki/index.md` to find any directly relevant pages the graph query might have missed.
4. Read those pages.
5. Synthesize an answer that cites the wiki pages (with `[[Page Name]]` links).
6. **If the answer itself is valuable**, ask: "Want me to file this answer back into the wiki as a new page?" If yes, create `<vault>/wiki/<topic>-analysis-<date>.md` and update the index.
7. Append to log:
   ```
   ## [YYYY-MM-DD HH:MM] query | "<question>"
   Answered from: <pages>
   ```

---

## Step 4 — Lint

`/wiki-brain lint`

A health-check pass. Claude reads the wiki and reports problems.

1. Read `<vault>/wiki/index.md` to get all pages.
2. Sample up to 30 pages (or all, if fewer).
3. Check for:
   - **Contradictions** — pages that assert incompatible facts
   - **Stale claims** — older pages superseded by newer ones
   - **Orphans** — pages with zero inbound `[[links]]`
   - **Missing pages** — concepts referenced across 3+ pages with no dedicated page
   - **Broken links** — `[[Target]]` where `Target` doesn't exist
   - **Gaps** — topics where a web search or new source would add value
4. Write a report to `<vault>/lint-reports/<YYYY-MM-DD>.md`.
5. Display a summary: counts per category + top 5 issues.
6. Ask which issues (if any) to fix now. Do NOT auto-fix.
7. Update `lastLint` in config.
8. Append to log.

---

## Step 5 — Rebuild

`/wiki-brain rebuild`

Force a Graphify rebuild. Graphify extracts concepts and relationships from all `.md` files in `wiki/` using Claude subagents, then builds `graphify-out/graph.json`.

Tell the user to run from Claude Code (not in a terminal):

- **Incremental rebuild** (skips unchanged files — use when graph already exists):
  ```
  /graphify ./wiki --update
  ```

- **Full first build** (use when `graphify-out/graph.json` does not exist yet):
  ```
  /graphify ./wiki
  ```

After the build completes, update `lastRebuild` in config. Report success or failure.

> **Important:** `/graphify` is a Claude Code slash command — it cannot be run in a terminal. The shell SessionEnd hook only sends a notification; the actual rebuild must be triggered manually in Claude Code using `/wiki-brain rebuild`.

---

## Step 6 — Doctor

`/wiki-brain doctor`

Verify install health. Run these checks and report pass/fail for each:

1. `config.json` exists and is valid JSON
2. Vault path exists and is writable
3. `raw/`, `wiki/`, `wiki/index.md`, `log.md` all exist
4. `graphify` is importable (`python3 -c "import graphify"`)
5. SessionEnd hook is in `~/.claude/settings.json`
6. `session-end.sh` is executable
7. CLAUDE.md contains the wiki-brain block
8. `graphify-out/graph.json` exists (warn if not — rebuild needed)
9. Last rebuild was within `rebuildCadenceDays × 2` (warn if older)
10. `log.md` has at least one entry in the last 30 days (warn if not)

Display results as a checklist. For any failure, show the exact fix.

---

## Step 7 — Recall

`/recall`

1. Run `tail -20 "<vault>/log.md"` to get recent entries.
2. Parse the last 5 session/ingest/query entries.
3. For each, read the wiki pages it touched (linked in the log line).
4. Display a summary:
   ```
   Last 5 activities:

   1. [2026-04-11 15:45] ingest | "The LLM Wiki Pattern"
      Touched: [[LLM Wikis]], [[Karpathy Principles]], [[Graphify]]

   2. [2026-04-10 09:12] query | "how do we ingest conversations?"
      Answered from: [[LLM Wikis]], [[SessionEnd Hooks]]
   ...
   ```
5. Ask: "Want me to load the full content of any of these into context?"

---

## Session-End Behavior (What Claude Must Do Before Ending a Session)

When the user ends a Claude Code session and this skill is active, Claude must:

1. **Append one line to `<vault>/log.md`** in the format:
   ```
   ## [YYYY-MM-DD HH:MM] session | <3-8 word session title>
   Touched: <comma-separated wiki pages OR "none">
   ```
2. **If anything durable happened** (decisions made, things learned, project state changed, problems solved): update or create relevant wiki pages with that knowledge. Same rules as `/wiki-brain ingest` — cross-link, update the index, be thorough.
3. **If nothing durable happened** (trivial task, one-off question): skip the wiki update. Just log the line.

This is instructed in the CLAUDE.md patch. The SessionEnd hook runs AFTER this and handles Graphify rebuild cadence checks.

---

## Rules

1. **Never modify files in `raw/`.** Sources are immutable.
2. **Claude owns `wiki/` entirely.** The user doesn't edit it (except for the occasional correction).
3. **Always update `wiki/index.md`** when creating or renaming a page.
4. **Always append to `log.md`** on ingest, query, lint, rebuild, and session end.
5. **Cross-link aggressively.** Use `[[Page Name]]` Obsidian syntax. A page with no links is a dead-end.
6. **Short pages are fine.** A wiki page can be 3 lines. What matters is the links, not the length.
7. **Contradictions get flagged, not silently resolved.** If a new source contradicts an existing page, note it in the page with `> Contradicts: <older claim, source>` and let the user decide.
8. **Never auto-fix during lint.** Report issues, ask before fixing.
9. **Respect cadence-manual.** If the user picked "manual only" for rebuild or lint, the hook must skip it.
10. **Privacy:** `config.json` is gitignored. The vault is the user's private space — never commit it or send it anywhere.

---

Built by [@tenfoldmarc](https://instagram.com/tenfoldmarc). Follow for daily AI automation builds — real systems, not theory.
