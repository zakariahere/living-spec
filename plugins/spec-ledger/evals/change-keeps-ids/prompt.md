---
description: 'Scenario IDs stay stable: a dropped rule is retired, not renumbered or deleted.'
tags: [change, ids]
max_turns: 30
timeout_seconds: 600
allowed_tools: [Read, Glob, Grep, Skill, Agent, Edit, Write]
---
/spec-ledger:spec-change We are dropping the half-refund tier. Inside 7 days of the event there is no refund at all.
