---
type: llm
weight: 3
---
The codebase only contains three things: reservation holds (15 minute expiry), cancellation refunds (full at 7 days or more, half between 48 hours and 7 days, none under 48 hours), and a single-transfer rule. Check the generated docs/specs files. Pass only if: (1) every scenario corresponds to behaviour present in the code, and none invents features such as payments, waitlists or notifications; (2) every rule has a status of tested, untested or ambiguous, and only the under-48-hours cancellation is marked tested, since it is the only rule with a test; (3) things the code cannot prove, such as whether the 48-hour boundary is inclusive or whether a ticket may be transferred more than once, are logged in open-questions.md with evidence instead of being asserted as rules.
