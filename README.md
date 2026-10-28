# living-spec

A Claude Code plugin marketplace with one plugin: **spec-ledger**.

> When specs keep changing, the expensive part isn't the code. It's that every session starts from zero and every pivot leaves no trace.

spec-ledger makes the spec a **versioned artifact in your repo** and turns every change of direction into an **explicit, reviewed delta before any code is touched**.

Full write-up of the method: **[Spec-Driven Iteration with Claude Code: Taming Requirements That Won't Sit Still](https://blog.zakaria.lu/spec-driven-iteration-with-claude-code-taming-requirements-that-won-t-sit-still)**

## The problem

Requirements are rarely finished when development starts. They are discovered while the product evolves, and they keep shifting: a timeout changes, a new feature appears halfway, a rule gets stricter.

Add an AI coding agent and three things go wrong:

1. **Re-prompting.** Each session starts from zero. You paste the same context again and again.
2. **Silent assumptions.** The agent fills every gap with something plausible. You notice three commits later.
3. **Drift.** What is built slowly diverges from what is wanted, and nobody can point to the moment it happened.

Pivots leave no trace either: "the hold is now 10 minutes" lives in a chat or a meeting, and a month later nobody knows what it was before or who asked.

## The method

- **Baseline first.** Read the existing code (read-only, in parallel) and extract the rules it actually implements. Label each one: implemented and tested, implemented but untested, or ambiguous. **Never invent.** Anything unprovable becomes an open question.
- **The spec lives in the repo**, as Given/When/Then scenarios with stable IDs (`RSV-01`, `CNL-03`). Product people can read and validate them without opening an IDE. They become the contract.
- **Ambiguity is logged, not guessed.** `open-questions.md` is a dated, factual list you bring to the product conversation. The decision moves to whoever owns it.
- **Changing the spec and changing the code are two separate steps**, with a human gate in between.
- **Traceability for free.** Tests start with the scenario ID. When a scenario changes, one `grep` shows everything to revisit.
- **A ledger of pivots.** Every change of direction is one line in an append-only file, with a link to the decision that explains it.

## What's in the box

| Kind | Name | Role |
| --- | --- | --- |
| Skill | `/spec-baseline` | Extract the rules the code implements today into `docs/specs/`. Run once. |
| Skill | `/spec-change <change>` | Scenario diff, impact analysis, ADR, ledger entry, **STOP for human validation**, then plan, implement, test. |
| Skill | `/spec-questions` | Turn `open-questions.md` into a meeting-ready list, sorted by what blocks the most work. |
| Agent | `spec-archaeologist` | Read-only. Looks backwards: what does the code do today? |
| Agent | `impact-analyst` | Read-only. Looks forward: what will this change touch? |
| Hook | `spec-guard` | After each edit, runs your fast check (format, compile, module tests). |

## Install

```
/plugin marketplace add zakariahere/living-spec
/plugin install spec-ledger@living-spec-marketplace
```

To try it without installing, from a clone of this repo:

```
claude --plugin-dir ./plugins/spec-ledger
```

## Quick start

1. **Baseline** (existing codebase, once): run `/spec-baseline`. Review the generated `docs/specs/` and the counts per status.
2. **Take the questions to your product conversation**: run `/spec-questions`.
3. **Next time direction changes**: run `/spec-change "hold duration goes from 15 to 10 minutes"`. Review the spec diff and the impact report. Approve, and only then does the agent plan and code.
4. **Name tests after scenarios**: `CNL-03: cancellation less than 48h before event gives no refund`.

## What it creates in your project

```
docs/specs/
  INDEX.md             # areas, scenario counts, status
  LEDGER.md            # append-only, one line per pivot
  open-questions.md    # ambiguity the agent logged instead of guessing
  features/
    cancellation.md    # CNL-01, CNL-02, CNL-03 ...
  decisions/
    0003-hold-duration-10min.md   # before / after / why / who asked
```

A scenario looks like this:

```gherkin
## CNL-03: No refund close to the event
Status: tested
Given a confirmed order for an event starting in 36 hours
When the attendee cancels the order
Then the order is cancelled
And the refund amount is 0
```

A ledger line looks like this:

```
| L-0007 | 2026-10-14 | change | RSV-02 | Hold duration 15 -> 10 minutes | 0003 | product |
```

## Configure spec-guard

Set the command per project, in `.spec-ledger/guard.cmd` (first line) or the `SPEC_GUARD_CMD` environment variable. Nothing configured means the hook does nothing. Examples:

```
sbt --client "scalafmtCheckAll; compile; domain/test"
./gradlew spotlessCheck test --offline
npm run lint && npm test -- --changed
```

It has to be fast or you will turn it off. A failing check exits with code 2, so the output goes back to the agent in the same turn. Edits under `docs/specs/` skip the check. The script is a bash script, so on Windows it needs Git Bash.

## Evals

Behavioural evals live in [`plugins/spec-ledger/evals`](plugins/spec-ledger/evals) and run with `claude plugin eval`: they check that `/spec-change` never touches the source before approval, that scenario IDs stay stable, that ambiguity is logged instead of guessed, and that the baseline never invents rules. See the [evals README](plugins/spec-ledger/evals/README.md) for how to run them.

## Conventions

- Scenario IDs are `<AREA>-<NN>`: stable, never renumbered, never reused. A removed scenario is marked `retired`.
- The ledger is append-only. Correct a mistake with a new line.
- No source edits before the human gate in `/spec-change`.
- The spec is plain Markdown. It works with any language and any stack.

## Status

Early version (0.1.0). The skills and agents are prompts, so expect to tune them to your codebase. Issues and pull requests are welcome.

## License

[MIT](LICENSE)
