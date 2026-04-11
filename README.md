# Wiki-Brain
### A Claude Code Skill by [@tenfoldmarc](https://www.instagram.com/tenfoldmarc)

Turn Claude Code into a knowledge base that *compounds.* Every conversation you have from now on feeds a personal wiki you browse in Obsidian. Claude gets smarter about YOUR stuff over time — and answers questions faster by querying a knowledge graph instead of re-reading files every time.

Built on Andrej Karpathy's [LLM Wiki pattern](https://gist.github.com/karpathy) and powered by [Graphify](https://github.com/tenfoldmarc/graphify-skill).

---

## What It Does

1. **Walks you through installing Obsidian + a vault** (or uses your existing one)
2. **Installs Graphify** — the tool that builds a knowledge graph from your notes so Claude can query it
3. **Creates your wiki structure** — `raw/` for sources, `wiki/` for Claude-maintained pages, `log.md` for a timeline
4. **Patches your CLAUDE.md** with instructions so Claude knows to use the wiki in every session
5. **Installs a SessionEnd hook** — automatically rebuilds your knowledge graph on a cadence you pick (3 days, 7 days, or manual only)
6. **Gives you commands** to ingest sources, query the wiki, health-check it, and recall recent activity

Every conversation becomes compound interest. Drop articles, transcripts, papers, screenshots into `raw/` — Claude reads them, extracts key info, writes wiki pages, cross-links everything, and keeps it all maintained. You browse the results in Obsidian with graph view.

---

## Requirements

- A Mac, Linux, or Windows computer
- [Claude Code](https://docs.anthropic.com/en/docs/claude-code) installed and working
- Python 3 (comes pre-installed on most systems)
- [Obsidian](https://obsidian.md) (free — the skill walks you through installing it if you don't have it)

Don't worry about connecting these manually — the skill walks you through everything on first run.

---

## Install

### Step 1 — Open your terminal

**Mac:** Press `Command + Space`, type **Terminal**, hit Enter.
**Windows:** Press `Win + R`, type **cmd**, hit Enter. (If you have Git Bash, use that instead.)
**Linux:** Open your terminal app.

### Step 2 — Run this command

Copy-paste this entire line and hit Enter:

```bash
git clone https://github.com/tenfoldmarc/wiki-brain-skill ~/.claude/skills/wiki-brain
```

You'll see some text scroll by. Wait until it finishes (takes a few seconds).

### Step 3 — Open Claude Code

In the same terminal window, type:

```bash
claude
```

Hit Enter. Claude Code will open.

### Step 4 — Run the skill

Type:

```
/wiki-brain
```

Hit Enter. On your first run, the skill will:
- Ask if you already use Obsidian (and walk you through installing it if not)
- Ask how often you want to rebuild your knowledge graph (recommended: every 7 days)
- Ask how often you want to health-check your wiki (recommended: monthly)
- Install Graphify
- Create your wiki folders
- Patch your CLAUDE.md
- Install a SessionEnd hook that keeps the graph fresh

Just follow the prompts. Setup takes about 5 minutes.

---

## Usage

### Ingest a new source

Drop any article, PDF, transcript, or screenshot into your vault's `raw/` folder. Then tell Claude:

```
/wiki-brain ingest raw/my-article.md
```

Claude reads the source, summarizes the takeaways with you, writes a wiki page (or updates existing ones), cross-links everything, and updates your index. A single source typically touches 3–10 wiki pages.

### Query your wiki

```
/wiki-brain query "what do I know about the LLM Wiki pattern?"
```

Claude queries the knowledge graph first, reads the relevant wiki pages, and gives you a synthesized answer with links to the pages.

### See recent activity

```
/recall
```

Shows your last 5 activities (ingests, queries, sessions) and offers to pull any of them fully into context.

### Health check

```
/wiki-brain lint
```

Claude scans the wiki for contradictions, stale claims, orphan pages, missing concepts, and broken links. Reports everything so you can decide what to fix.

### Force a graph rebuild

```
/wiki-brain rebuild
```

Rebuilds the Graphify knowledge graph manually. (Normally happens automatically on your chosen cadence.)

### Verify install

```
/wiki-brain doctor
```

Checks that every part of the install is healthy — config, folders, hook, CLAUDE.md, Graphify. Tells you exactly what to fix if anything's broken.

---

## How It's Different from Just Talking to Claude

Most Claude Code setups treat every conversation as throwaway. Claude reads your files, answers, and forgets. Next session, it's re-reading everything from scratch.

Wiki-Brain treats the *wiki itself* as the memory. Every conversation makes it richer. Every question gets answered from accumulated knowledge, not re-derived from raw files. The system gets smarter about *your* stuff the more you use it.

- **Your raw sources** stay untouched (in `raw/`)
- **Claude maintains** the wiki pages (in `wiki/`) — cross-linked, summarized, kept current
- **Graphify** builds a knowledge graph over the wiki so queries are fast and find unexpected connections
- **You browse it in Obsidian** — graph view, backlinks, full-text search
- **Everything is plain markdown** — version it in git, back it up, own it forever

---

## Updating

To get the latest version:

```bash
cd ~/.claude/skills/wiki-brain && git pull
```

---

## Uninstalling

Wiki-Brain adds three things to your system:

1. A block in your CLAUDE.md (global or project)
2. A SessionEnd hook in `~/.claude/settings.json`
3. The folders it creates inside your vault (which you can keep — they're just markdown)

To fully uninstall, remove those three things and delete `~/.claude/skills/wiki-brain/`.

---

## Built By

[@tenfoldmarc](https://www.instagram.com/tenfoldmarc) — Follow for daily AI automation walkthroughs. Real systems, not theory.
