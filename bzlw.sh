#!/bin/bash

set -eou pipefail

COMMIT_RANGE=$(git merge-base origin/master HEAD^)".." && readonly COMMIT_RANGE

AFFECTED="$(cat "$(pwd)"/affected)" && readonly AFFECTED

query_affected() {
  local affected && affected=$(
    git diff --name-only --diff-filter=d "$COMMIT_RANGE" | tr '\n' ' '
  )

  local files && files=$(npx bazelisk query --keep_going "set($FILES)" || true)

  echo "${files[*]}" | tr '\n' ' ' > affected
}

query_rule() {
  npx bazelisk query --keep_going --noshow_progress "attr(name, $rule, rdeps(//..., set($AFFECTED)))" | tr '\n' ' '
}

main() {
  local IFS && IFS=' '

  read -r -a rules <<< "$(bazel_query "${AFFECTED[@]}")"

  for rule in "${rules[@]}"; do
    npx bazel $command "$rule"
  done
}