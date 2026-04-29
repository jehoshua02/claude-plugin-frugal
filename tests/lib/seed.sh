#!/bin/bash
# Test environment seeding helpers

new_test_dir() {
  local dir
  dir=$(mktemp -d "${TMPDIR:-/tmp}/frugal-test-XXXXXX")
  echo "$dir"
}

remove_test_dir() {
  local dir="$1"
  if [[ -d "$dir" && "$dir" == *frugal-test-* ]]; then
    rm -rf "$dir"
  fi
}
