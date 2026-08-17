# Session convention

**This file is the only copy of the rule.** Nothing restates it — not the
README, not a project instruction field, not another document. A second copy
drifts, and the drift is invisible until it has already cost something.

Everything below is either checked by `check-memory.sh` or dropped. A rule that
cannot be checked is not adopted.

## What a session does

1. **One topic per session.** A session takes one subject and finishes it.
2. **Write as you work.** Knowledge goes into the repository while the work
   happens, not at the end. A session can end without warning — a closed tab,
   an outage, a used-up budget — and a session whose transcript cannot be
   re-read afterwards is the normal case, not the exception.
3. **One journal entry before you finish.** Append to `JOURNAL.md`:
   the date, one line on what changed, one line on what stayed open.
   One entry per session, appended, never edited.
4. **Open things go to the backlog**, never into a knowledge document.
   A knowledge document describes how things *are*.
5. **Why goes in the commit message.** Rationale, alternatives considered and
   corrections belong to the history, not to the document a person reads to
   get something done.
6. **A fact lives in exactly one place.** Everywhere else links to it.

## What the journal is not

Not a transcript, not a log of runs, not a queue. It carries no session
identifiers, no bookmarks and no reading state. Nothing has to be able to
re-read a past conversation for this to work, which is the whole point:
the mechanism depends only on the repository's own contents.

## Budgets

Checked by `check-memory.sh`, configured in `.agent-memory.conf`:

- this file: at most 60 lines
- any single knowledge document: at most the configured line budget
- every day with commits to watched paths has a journal entry, and every
  journal entry has commits

## Rules of this project

A project adds its own under a `## Project rules` heading here, each checked
by a `check-memory-local.sh` beside this file. Same standard: a rule nothing
checks does not belong.

## When the rule and the behaviour disagree

The rule loses. Change this file, or change `check-memory.sh` so the new behaviour
is what is verified. Do not leave a rule in place that nothing enforces —
that is how a convention becomes decoration.
