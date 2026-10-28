---
type: llm
weight: 2
focus:
  source: file
  path: docs/specs/open-questions.md
---
The request leaves real product decisions open (for example: queue ordering, how long an offered seat is held for the next person, whether people can leave the queue, whether there is a size limit, how it interacts with the existing hold rules). Check docs/specs/open-questions.md and the final message. The agent should have logged the open decisions as new OQ entries, each with Evidence, Affects (scenario IDs), at least two Options, Status and a decision owner. It must not have silently picked answers and written them into scenarios as settled fact. Scenarios may be drafted, but any unresolved choice must be flagged as an open question.
