# spec-ledger evals

Behavioural evals for the plugin, run with `claude plugin eval`. They check what the skills **do** under constraint, not how well they write.

| Case | What it proves |
| --- | --- |
| `change-stops-at-gate` | `/spec-change` updates the spec, writes an ADR, appends to the ledger, never edits `src/`, and stops for approval |
| `change-keeps-ids` | Dropping a rule keeps scenario IDs stable: nothing renumbered, nothing silently deleted |
| `change-logs-ambiguity` | A vague request produces open questions with evidence and options instead of a guessed design |
| `baseline-never-invents` | `/spec-baseline` documents only what the code proves and logs the rest as open questions |
| `questions-sorted` | `/spec-questions` is read-only and produces a sorted, factual list |

Each case builds a small invented ticketing project (`setup.sh`, plain Scala sources and, for most cases, an existing `docs/specs/`). Cases use deterministic graders where possible (tool calls, file contents) and an LLM judge for the rest.

## Run

```powershell
claude plugin eval . --scaffold --allow-tools Edit Write --ablation none --runs 3 -j 3 --max-cost-usd 10 --threshold 0.7 --no-publish
```

- `--scaffold` is required: it runs each `setup.sh`. Only use it on files you trust.
- `--ablation none`: the slash commands only exist with the plugin, so a no-plugin baseline arm has nothing to compare.
- `--allow-tools Edit Write` lets the agent write the spec files. "No source edits" is enforced by graders on the `file_path` of each Edit/Write call.
- On Windows the scaffold runs with `bash` from the PATH. If that resolves to WSL without a distro, put Git Bash first: `$env:PATH='C:\Program Files\Git\usr\bin;'+$env:PATH`.

## Notes from the first runs

- A slash command is expanded into the prompt, so the `Skill` tool is never called. The cases check effects (files, `impact-analyst` delegation) instead of `tool_used: Skill`.
- `/spec-baseline` asks you to confirm the feature areas before extracting. The eval prompt confirms them up front.
- `change-logs-ambiguity` is the noisiest case: the LLM judge sometimes fails a run whose open questions look fine to a human. Read the report before concluding the skill regressed.

## Hook test

`spec-guard` is plain bash and has its own test: `bash tests/spec-guard.test.sh`.
