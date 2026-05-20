#!/usr/bin/env bash
set -euo pipefail

# tests/run-all.sh — run all test files and print a PASS/FAIL summary

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TESTS_DIR="$ROOT_DIR/tests"

total_pass=0
total_fail=0
suite_results=()

run_suite() {
  local script="$1"
  local name
  name="$(basename "$script")"

  echo "════════════════════════════════════════════════════════"
  echo "Running: $name"
  echo "════════════════════════════════════════════════════════"

  set +e
  bash "$script"
  local exit_code=$?
  set -e

  if [[ "$exit_code" -eq 0 ]]; then
    suite_results+=("  PASS  $name")
  else
    suite_results+=("  FAIL  $name (exit $exit_code)")
    total_fail=$((total_fail + 1))
  fi

  echo ""
}

# Discover and run all test-*.sh files (sorted, excluding run-all.sh itself)
while IFS= read -r script; do
  run_suite "$script"
done < <(find "$TESTS_DIR" -maxdepth 1 -name 'test-*.sh' | sort)

echo "════════════════════════════════════════════════════════"
echo "Suite summary"
echo "════════════════════════════════════════════════════════"
for result in "${suite_results[@]}"; do
  echo "$result"
done

echo ""
total_suites="${#suite_results[@]}"
passed_suites=$(( total_suites - total_fail ))
echo "Suites: $total_suites total, $passed_suites passed, $total_fail failed"

if [[ "$total_fail" -gt 0 ]]; then
  echo ""
  echo "FAILED. Fix failures above before merging."
  exit 1
else
  echo ""
  echo "All suites passed."
fi
