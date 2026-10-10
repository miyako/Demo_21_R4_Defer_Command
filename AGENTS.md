# Demo_21_R4_Defer_Command

<!-- Describe what this repository is and its repository-specific rules here. -->

## Skills

Reusable 4D knowledge lives in the `.agents` submodule (`miyako/skills`, branch `dist`):

- Each skill is at `.agents/skills/<name>/SKILL.md`. Copilot, Codex and Claude Code discover them automatically.
- Read `.agents/AGENTS.md` first: it explains which skill to use for which 4D artifact
  (`.4DProject`, `.4DForm`, `.4DCatalog`, `.4DSettings`, `.4dm`, XLIFF …).
- Prefer the most specific skill over general knowledge of 4D.
- Never edit files under `.agents/`: they are overwritten by the weekly skills update.

## Setup

```sh
git submodule update --init .agents
```

If `.agents/` is empty, run the command above before doing anything else. `--recursive` is not needed.
Tools provisioned by the skills go to `tools/4dcatalog/`, `tools/4dform/`, `tools/4dlsp/`, `tools/4dlang/` and `tools/4dcli/`;
they are ignored by `.gitignore` and must not be committed.

## Instructions vs skills

- **Repository-specific rules** go in this file, or in `.github/instructions/*.instructions.md` with an
  `applyTo` glob when they only apply to some paths.
- **Reusable know-how** (4D language, forms, CSS, XLIFF, project settings …) goes to
  [miyako/skills](https://github.com/miyako/skills). Never copy a skill or its content into this repository;
  improve the skill there instead, and mention what you learnt to the user so it can be upstreamed.

## README

`README.md` is for developers. Never put Copilot model, mode, token or session content (usage tables,
model selection advice, session logs) in `README.md`.
