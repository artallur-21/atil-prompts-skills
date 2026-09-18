# atil-prompts-skills

Private, version-controlled home for ATIL / ScaleSKUs **prompts** and **AI skills** — the reusable
assets our team runs on **Claude** and **ChatGPT** against the ScaleSKUs MCP. Managed by us; updated
via pull requests.

> Private repo. Internal only. Nothing here writes to Amazon directly — skills propose into the
> platform's human-gated tasks pipeline.

## Layout

```
skills/     # installable skills (SKILL.md + references/) — portable Claude + ChatGPT
  elevate-manager/     # Amazon Elevate cohort manager: EVALUATE → ANALYZE → BUILD + TRACK
prompts/    # standalone prompts you paste into an LLM
  elevate-task-generator.md        # single-prompt form of the Elevate task/rule generator (MCP)
  elevate-audit-report.design.md   # brief for the Claude Design agent — Elevate audit & action-plan page
```

## Install a skill

**Claude (private / personal — recommended):** clone this repo and symlink (or copy) the skill into
your personal skills dir so it's available in every project and never committed to a product repo:

```bash
git clone git@github.com:artallur-21/atil-prompts-skills.git ~/Projects/atil-prompts-skills
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
