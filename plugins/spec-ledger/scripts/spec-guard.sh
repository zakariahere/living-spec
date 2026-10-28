#!/usr/bin/env bash
# spec-guard: run the project's fast check (format, compile, module tests) after an edit.
# The command comes from $SPEC_GUARD_CMD or the first line of .spec-ledger/guard.cmd.
# No command configured: do nothing. Failure: exit 2 so the output reaches the agent.
set -u

cmd="${SPEC_GUARD_CMD:-}"
if [ -z "$cmd" ] && [ -f ".spec-ledger/guard.cmd" ]; then
  cmd="$(head -n 1 .spec-ledger/guard.cmd)"
fi
[ -z "$cmd" ] && exit 0

# Spec files do not need a compile; skip when only docs/specs changed.
payload="$(cat)"
case "$payload" in
  *'"file_path"'*docs/specs/*) exit 0 ;;
esac

out="$(bash -c "$cmd" 2>&1)"
status=$?
if [ $status -ne 0 ]; then
  printf 'spec-guard failed (%s):\n%s\n' "$cmd" "$out" | tail -n 60 >&2
  exit 2
fi
exit 0
