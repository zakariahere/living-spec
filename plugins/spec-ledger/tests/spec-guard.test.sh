#!/usr/bin/env bash
# Tests for scripts/spec-guard.sh. Run: bash plugins/spec-ledger/tests/spec-guard.test.sh
set -u
guard="$(cd "$(dirname "$0")/.." && pwd)/scripts/spec-guard.sh"
work="$(mktemp -d)"; trap 'rm -rf "$work"' EXIT
cd "$work" || exit 1
fail=0

check() { # name, expected exit, actual exit
  if [ "$2" = "$3" ]; then echo "ok   $1"; else echo "FAIL $1 (expected exit $2, got $3)"; fail=1; fi
}

echo '{}' | bash "$guard"; check "no command configured: does nothing" 0 $?

echo '{"tool_input":{"file_path":"src/A.scala"}}' | SPEC_GUARD_CMD='true' bash "$guard"; check "passing check" 0 $?

echo '{"tool_input":{"file_path":"src/A.scala"}}' | SPEC_GUARD_CMD='echo boom; exit 1' bash "$guard" 2>err.txt
check "failing check exits 2" 2 $?
grep -q boom err.txt; check "failure output reaches stderr" 0 $?

echo '{"tool_input":{"file_path":"docs/specs/x.md"}}' | SPEC_GUARD_CMD='exit 1' bash "$guard"; check "edits under docs/specs skip the check" 0 $?

mkdir .spec-ledger && echo 'exit 1' > .spec-ledger/guard.cmd
echo '{"tool_input":{"file_path":"src/A.scala"}}' | bash "$guard" 2>/dev/null; check "command read from .spec-ledger/guard.cmd" 2 $?

exit $fail
