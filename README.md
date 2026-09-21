# atil-prompts-skills

Private, version-controlled home for ATIL / ScaleSKUs **prompts** and **AI skills** — the reusable
assets our team runs on **Claude** and **ChatGPT** against the ScaleSKUs MCP. Managed by us; updated
via pull requests.

> Public repo — any ATIL employee can clone/download with **no GitHub login**. It holds internal
> tooling only: **no secrets, credentials, or client data** live here (sample data is fictional).
> Nothing here writes to Amazon directly — skills propose into the platform's human-gated tasks pipeline.

## Layout

```
skills/     # installable skills (SKILL.md + references/) — portable Claude + ChatGPT
  elevate-manager/     # Amazon Elevate cohort manager: EVALUATE → ANALYZE → BUILD + TRACK
prompts/    # standalone prompts you paste into an LLM
  elevate-task-generator.md        # single-prompt form of the Elevate task/rule generator (MCP)
  elevate-audit-report.design.md   # brief for the Claude Design agent — Elevate audit & action-plan page
```

## Install a skill

### Best for teams — install as a plugin (one command, any account)

This repo is a **Claude Code plugin marketplace**. On each machine, once:

```
/plugin marketplace add artallur-21/atil-prompts-skills
/plugin install elevate-manager@atil
```

That installs the skill (and auto-updates on `/plugin marketplace update atil`) — no
clone, no symlink, works the same on every employee's account. Confirm with `/plugin`
or a trigger phrase (`Elevate status`). Requires the ScaleSKUs MCP connected.

> Symlinking a skill folder (below) is **not** reliable — Claude often doesn't discover
> a symlinked `~/.claude/skills/<name>`. Use the plugin method above, or `cp -R` a real copy.

### Manual (single machine, fallback)


**Claude (private / personal — recommended):** clone this repo and symlink (or copy) the skill into
your personal skills dir so it's available in every project and never committed to a product repo:

```bash
# public repo — no login needed
git clone https://github.com/artallur-21/atil-prompts-skills.git ~/Projects/atil-prompts-skills
ln -s ~/Projects/atil-prompts-skills/skills/elevate-manager ~/.claude/skills/elevate-manager
# (symlink = it auto-updates on `git pull`; use `cp -R` instead if you prefer a fixed copy)
```

Then, with the ScaleSKUs MCP connected, type a trigger phrase (e.g. `Elevate status`) and Claude
loads it. Each skill's own `README.md` has the full command list.

**ChatGPT (Custom GPT):** create a GPT, paste the skill's `SKILL.md` as *Instructions*, upload its
`references/*.md` as *Knowledge*, connect the ScaleSKUs MCP as a Connector/Action, enable browsing.
See the skill's `README.md`.

## Use a prompt

Open the file under `prompts/`, fill any `⟪CONFIRM⟫` placeholders with the authoritative values, and
paste it into the assistant (Claude or ChatGPT) that's connected to the MCP.

## Managing this repo

- One folder per skill under `skills/`; one file per prompt under `prompts/`.
- Change anything via a PR so updates are reviewed and versioned.
- Keep the framework values (HVA rules, thresholds) in the skill's `references/hva-framework.md` as
  the single source of truth; prompts should reference the same numbers, not diverge.

## Install across accounts — claude.ai and ChatGPT

- **claude.ai (web):** skills are added under **Settings → Capabilities → Skills**. For a
  whole team, a **Claude for Work (Team/Enterprise) admin** deploys the skill org-wide from
  the admin console so every member gets it; individuals otherwise upload the skill folder
  themselves. (Download a zip of `skills/elevate-manager/` from this repo to upload.)
- **ChatGPT:** a Custom GPT lives in its creator's account. To share across employees, build
  it **once inside a ChatGPT Business/Enterprise workspace** and set sharing to *Anyone at
  <workspace>* — do **not** have each employee rebuild it. Without a shared workspace, a GPT
  can't be installed across accounts; each user recreates it from `skills/elevate-manager/`
  (SKILL.md → Instructions, references/*.md → Knowledge) + the ScaleSKUs MCP connector.

