---
name: spec-change
description: Apply a change of product direction. Spec diff by scenario ID, impact analysis, ADR, ledger entry, then STOP for human validation before any code is planned or written.
disable-model-invocation: true
argument-hint: <description of the change>
---

# spec-change

Changing the spec and changing the code are two separate steps with a human gate between them.

Change requested: $ARGUMENTS

## Steps

1. **Diff.** Restate the change as a diff over scenario IDs: added, changed, removed. Use the existing IDs in `docs/specs/features/`. New scenarios take the next free number in their area.
   If the change cannot be expressed without guessing, add the unknown to `docs/specs/open-questions.md` and ask the user. Do not choose an interpretation.
2. **Impact.** Delegate to the `impact-analyst` subagent with the diff. It returns, per scenario ID: code touched, tests to revisit (`grep` on the ID), risks.
3. **Record.** Update the affected `features/*.md`. Write `decisions/NNNN-<slug>.md` from the template (before, after, why, who asked). Append a line to `LEDGER.md`. Never edit or delete past ledger lines.
4. **STOP.** Show the user: the spec diff, the impact report, the ADR, the open questions raised. Wait for explicit approval. Do not edit source files in this step or before it.
5. **After approval only.** Enter plan mode, propose the implementation plan, then implement and test. Test names must start with the scenario ID, for example `CNL-03: ...`.
6. **Close.** Mark affected scenarios `tested` once their tests pass. Update `INDEX.md`.

## Hard rules

- No source edits before step 5.
- Never renumber or reuse a scenario ID. A removed scenario is marked `retired`, with a pointer to the ADR.
- The ledger is append-only.
