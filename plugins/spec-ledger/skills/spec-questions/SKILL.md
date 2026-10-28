---
name: spec-questions
description: Turn docs/specs/open-questions.md into a meeting-ready list for the product owner, sorted by how much work each question blocks.
disable-model-invocation: true
---

# spec-questions

Read-only. Produce the list; do not answer the questions yourself.

## Steps

1. Read `docs/specs/open-questions.md` and the feature files it references.
2. Keep only entries with status `open`.
3. For each, compute what it blocks: the scenario IDs affected and, from the code, how many handlers or tests depend on them (use `Grep` on the IDs).
4. Sort by blocked scope, descending. Break ties by age.
5. Output, per question: ID, one-line question, evidence, affected scenario IDs, options with the consequence of each, and who owns the decision.
6. End with a one-line summary: N open, M blocking implementation, oldest dated D.

Keep it factual and dated. No recommendations unless the user asks for them.
Answers go back through `/spec-change`, never straight into code.
