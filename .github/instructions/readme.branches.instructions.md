---
description: "Rules for the branches table under '## Modernisation notes' in README.md -- fixed format, one row per real remote branch (never fabricated), and a Guidance column linking the 4D skill or the repository instruction file that guided the effort"
applyTo: "README.md"
---

# README branches table

## Overview

HDI repositories document their modernisation history in `README.md`: under the `## Modernisation notes`
heading, a table lists one row per modernisation branch, describes the effort, and links the guidance that
drove it -- a skill in [miyako/skills](https://github.com/miyako/skills) or an instruction file of this
repository.

The **format** of the table is the same in every repository. Its **contents** are always rebuilt from real,
verifiable data for this repository -- never copied, guessed, or carried over from another project or an
earlier draft.

Token counts, model names, session names, session summaries and interaction-mode advice never appear in a
README (see `readme.structure.instructions.md`).

## Rule: every row is sourced, not remembered

Before writing or updating the table:

1. List the branches that really exist on the remote (`git fetch --all && git branch -r`). A working branch
   may have been renamed before it was pushed.
2. Check that every Guidance link resolves: a repository instruction file exists at
   `.github/instructions/<file>`, or a skill exists at `.agents/skills/<name>/SKILL.md` (and therefore at
   `https://github.com/miyako/skills/tree/main/4d-skills/skills/<name>`).
3. If a branch cannot be found on the remote, do not list it.

**Fabricated history is worse than no history.** It looks authoritative, erodes trust in the README, and
cannot be reproduced or audited.

## Table format

Keep the intro sentence and the header row exactly as below; only the body rows change per repository:

```markdown
## Modernisation notes

Each branch represents a distinct modernisation effort, guided by a 4D skill or a repository instruction file.

| Branch | Description | Guidance |
|--------|-------------|----------|
| [`<branch-name>`](../../tree/<branch-name>) | <one-line description of the effort> | [`<skill>`](https://github.com/miyako/skills/tree/main/4d-skills/skills/<skill>) |
```

Rules:

- One row per feature / modernisation branch, in **chronological order** (oldest first) by branch creation
  date.
- Leave out transient branches (README-only edits, sync / merge branches, housekeeping) unless the repository
  deliberately documents every branch; ask the user when the scope is unclear.
- Description: one sentence saying what changed and why, not an implementation log.
- Guidance links -- fixed formats:
  - skill: ``[`<skill>`](https://github.com/miyako/skills/tree/main/4d-skills/skills/<skill>)``
    (label = the skill name in backticks);
  - repository instruction file: `[<file>.instructions.md](.github/instructions/<file>.instructions.md)`.
- When several skills or instruction files guided the branch, list all of them, comma-separated, in the same
  cell.
- Branch link: ``[`<branch-name>`](../../tree/<branch-name>)``.

## Which guidance for which effort

| Effort | Guidance |
|---|---|
| `C_*` → `var` / `#DECLARE`, `Compiler_*` cleanup, deprecated `_o_` commands | `4dmodernise` |
| Splash / startup window (`CALL WORKER`, `DIALOG(...; *)`, window reuse) | `4dstartup`, `hdi.startup.instructions.md` |
| Menu wrapper methods → standard actions in `menus.json` | `4dproject` |
| Method visibility (`invisible`) | `4dmethods` |
| XLIFF localisation | `4dlocalise` |
| Dark mode, `automatic` colours, Liquid Glass / Fluent UI form themes | `4dcss` |
| List box defaults (`truncateMode`, `resizingMode`) | `4dform` |
| 4D AI Kit async / streaming | `4daikit` |
| README rewrite | `readme.structure.instructions.md` |

### Updating an older table

Older READMEs link instruction files that have since become skills, use an `Instructions` header, or sit
under a separate `## Branches` heading. When you touch such a table:

- put it directly under `## Modernisation notes` with the intro sentence and header row above;
- replace each link to a legacy instruction file with its guidance:

| Legacy file | Guidance |
|---|---|
| `variable.declarations.instructions.md`, `deprecated.commands.instructions.md` | skill `4dmodernise` |
| `method.visibility.instructions.md` | skill `4dmethods` |
| `menu.instructions.md` | skill `4dproject` |
| `listbox.instructions.md` | skill `4dform` |
| `css.instructions.md`, `tahoe.css.instructions.md` | skill `4dcss` |
| `localisation.instructions.md` | skill `4dlocalise` |
| `aikit.async.instructions.md` | skill `4daikit` |
| `startup.instructions.md` | skill `4dstartup` and `hdi.startup.instructions.md` |
| `readme.hdi.instructions.md` | `readme.structure.instructions.md` |

The authoritative mapping is `.agents/MIGRATION.json`.

## When the user supplies explicit content

If the user gives exact branch names, descriptions or rows, use them as given -- do not re-verify them
against the remote. The workflow below applies only when the table is rebuilt from scratch.

## Workflow for rebuilding the table

1. `git fetch --all` and list the real remote branches.
2. For each branch, find what it changed (diff against the default branch, or the merged PR title and body)
   and write a one-sentence description.
3. Identify the skill(s) or instruction file(s) that governed the change (tables above).
4. Rebuild the table from that data, keeping the intro sentence, header row and link formats above.
5. Do not touch any other section of the README.
6. Commit with a message saying what was corrected or updated.
