#!/bin/bash
# check-memory.sh — audit a repository against its session convention.
#
#   ./check-memory.sh [path-to-repo]   (default: current directory)
#
# Exits non-zero if any check fails. Reads .agent-memory.conf if present.
#
# Every rule in CONVENTION.md that can be checked is checked here, and
# nothing here checks a rule that is not written there. If the two ever
# disagree, one of them is wrong on purpose — fix it, do not tolerate it.

set -u

REPO="${1:-.}"
cd "$REPO" || { echo "no such directory: $REPO" >&2; exit 2; }

# --- config -------------------------------------------------------------
CONVENTION_MAX_LINES=60
DOC_MAX_LINES=1500
JOURNAL="JOURNAL.md"
WATCH="."                     # space-separated paths the journal must cover
DOCS="*.md"                   # glob(s) for knowledge documents
IGNORE_DOCS="$JOURNAL CONVENTION.md README.md"

# shellcheck disable=SC1091
[ -f .agent-memory.conf ] && . ./.agent-memory.conf

fail=0
note() { printf '  %-4s %s\n' "$1" "$2"; }
bad()  { note "FAIL" "$1"; fail=1; }
ok()   { note "ok" "$1"; }

echo "==> agent-memory check: $(pwd)"

# --- 1. the rule exists and is small ------------------------------------
if [ ! -f CONVENTION.md ]; then
  bad "CONVENTION.md is missing — the rule has no home"
else
  n=$(wc -l < CONVENTION.md | tr -d ' ')
  if [ "$n" -gt "$CONVENTION_MAX_LINES" ]; then
    bad "CONVENTION.md is $n lines (budget $CONVENTION_MAX_LINES) — it is meant to be read in full, every time"
  else
    ok "CONVENTION.md: $n lines"
  fi
fi

# --- 2. the journal exists and is append-only ---------------------------
if [ ! -f "$JOURNAL" ]; then
  bad "$JOURNAL is missing"
else
  entries=$(grep -c '^## [0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9]' "$JOURNAL" || true)
  ok "$JOURNAL: $entries entries"
  if git rev-parse --git-dir >/dev/null 2>&1; then
    # An entry that was rewritten rather than appended shows up as a deletion.
    removed=$(git log -p --follow -- "$JOURNAL" 2>/dev/null \
              | grep -c '^-## [0-9][0-9][0-9][0-9]-' || true)
    if [ "${removed:-0}" -gt 0 ]; then
      bad "$JOURNAL has had $removed entr(y|ies) removed or rewritten — it is append-only"
    else
      ok "$JOURNAL is append-only"
    fi
  fi
fi

# --- 3. document budget -------------------------------------------------
# shellcheck disable=SC2086
for f in $DOCS; do
  [ -f "$f" ] || continue
  case " $IGNORE_DOCS " in *" $f "*) continue ;; esac
  n=$(wc -l < "$f" | tr -d ' ')
  if [ "$n" -gt "$DOC_MAX_LINES" ]; then
    bad "$f is $n lines (budget $DOC_MAX_LINES) — split it or cut it"
  fi
done
ok "document budget: $DOC_MAX_LINES lines"

# --- 4. work without a journal entry ------------------------------------
# The only check that costs anything, and the one worth having: has anything
# been committed since the last journal entry that nobody wrote down?
if git rev-parse --git-dir >/dev/null 2>&1 && [ -f "$JOURNAL" ]; then
  last_entry_commit=$(git log -1 --format=%H -- "$JOURNAL" 2>/dev/null || true)
  if [ -z "$last_entry_commit" ]; then
    note "----" "$JOURNAL is not committed yet — skipping the coverage check"
  else
    # shellcheck disable=SC2086
    since=$(git log --oneline "$last_entry_commit"..HEAD -- $WATCH 2>/dev/null | wc -l | tr -d ' ')
    if [ "$since" -gt 0 ]; then
      bad "$since commit(s) since the last journal entry — write one before you finish"
      # shellcheck disable=SC2086
      git log --format='       %h %s' "$last_entry_commit"..HEAD -- $WATCH 2>/dev/null | head -10
    else
      ok "every commit since the last journal entry is accounted for"
    fi
  fi
fi

# --- 5. uncommitted work ------------------------------------------------
if git rev-parse --git-dir >/dev/null 2>&1; then
  dirty=$(git status --porcelain | wc -l | tr -d ' ')
  [ "$dirty" -gt 0 ] && note "----" "$dirty uncommitted change(s) in the working tree"
fi

echo
if [ "$fail" -ne 0 ]; then
  echo "==> FAILED"
  exit 1
fi
echo "==> OK"
