---
name: spec-baseline
description: Reverse-engineer the business rules the code implements today into docs/specs/. Run once on an existing codebase, before the first /spec-change.
disable-model-invocation: true
---

# spec-baseline

Goal: a factual baseline of what the code does now. Not what it should do.

## Rules

- Read-only on source code. The only files you may create are under `docs/specs/`.
- Never invent. A rule you cannot prove from code or a test becomes an entry in `open-questions.md`.
- Scenario IDs are stable: `<AREA>-<NN>` (for example `RSV-01`). Never renumber.

## Steps

1. If `docs/specs/` already exists, stop and ask: this skill is for the first baseline.
2. Identify feature areas from the code layout (commands, handlers, modules). Ask the user to confirm the list.
3. Launch one `spec-archaeologist` subagent per area, in parallel. Each returns rules with evidence (file:line, test name).
4. Classify every rule:
   - **tested**: implemented and asserted by a test
   - **untested**: implemented, nothing asserts it
   - **ambiguous**: several readings, or two places disagree
5. Create the tree from `${CLAUDE_PLUGIN_ROOT}/templates/`:
   `INDEX.md`, `LEDGER.md`, `open-questions.md`, `features/<area>.md`, `decisions/`.
6. Write each rule as a Given/When/Then scenario with its ID and status. Put every `ambiguous` item and every unprovable claim in `open-questions.md`.
7. Add a `LEDGER.md` entry `L-0001` of kind `baseline`.
8. Report counts per status and the top open questions. Do not touch source code.
