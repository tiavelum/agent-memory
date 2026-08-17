#!/bin/bash
# install.sh — adopt the session convention in a repository.
#
#   ./install.sh /path/to/target-repo
#
# Copies the convention and a journal skeleton into the target, writes a
# config with the budgets, and prints the short loader text to paste into
# the assistant's project instructions.
#
# Idempotent: an existing CONVENTION.md is replaced (it is meant to be the
# upstream copy), an existing JOURNAL.md is never touched.

set -eu

SRC="$(cd "$(dirname "$0")" && pwd)"
TARGET="${1:?usage: ./install.sh /path/to/target-repo}"

[ -d "$TARGET" ] || { echo "no such directory: $TARGET" >&2; exit 2; }
cd "$TARGET"
git rev-parse --git-dir >/dev/null 2>&1 || echo "warning: $TARGET is not a git repo — the coverage check will be skipped" >&2

cp "$SRC/CONVENTION.md" ./CONVENTION.md
echo "wrote CONVENTION.md"

if [ -f JOURNAL.md ]; then
  echo "JOURNAL.md exists — left untouched"
else
  cp "$SRC/templates/JOURNAL.md" ./JOURNAL.md
  echo "wrote JOURNAL.md"
fi

if [ -f .agent-memory.conf ]; then
  echo ".agent-memory.conf exists — left untouched"
else
  cat > .agent-memory.conf <<'EOF'
# Budgets for check.sh. Shell syntax; sourced, so keep it simple.

CONVENTION_MAX_LINES=60      # the rule must stay readable in full
DOC_MAX_LINES=1500           # any single knowledge document
JOURNAL="JOURNAL.md"
DOCS="*.md"                  # glob(s) matching knowledge documents
IGNORE_DOCS="JOURNAL.md CONVENTION.md README.md"
WATCH="."                    # paths whose commits the journal must cover
EOF
  echo "wrote .agent-memory.conf"
fi

cp "$SRC/check.sh" ./check-memory.sh
chmod +x ./check-memory.sh
echo "wrote check-memory.sh"

cat <<'EOF'

Done. Two things left, both by hand:

1. Commit the four files.
2. Paste this into the assistant's project instructions — and nothing more.
   It is a pointer, not a manual: everything else is in CONVENTION.md, which
   is where it can be checked.

------------------------------------------------------------------------
Read CONVENTION.md in this repository before you finish any piece of work,
and follow it. It is short and it is the only copy of the rule.

Never push. Commit; the transport publishes.

Work interactively: diagnose, propose, verify, proceed.
------------------------------------------------------------------------

Then run ./check-memory.sh to see where the repository stands.
EOF
