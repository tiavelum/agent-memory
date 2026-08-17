# agent-memory

A minimal convention that makes what an assistant session learns survive the
session — and that can be checked, so it cannot quietly stop being true.

Four files land in your repository. There is no service, no scheduler, no
transcript reading and no session identifier anywhere.

## The problem it solves

An assistant session produces knowledge and then disappears. The obvious fix
is a mechanism that reads finished conversations and files what it finds. That
mechanism is expensive to build, and it fails in a way that is hard to see:
some sessions cannot be re-read at all, so the safety net has holes exactly
where you cannot notice them.

The cheaper answer is to stop treating capture as something that happens
*after* the work. A session writes into the repository *while* it works, and
leaves one short journal entry before it finishes. Then the only thing anyone
has to read afterwards is the repository itself.

The second problem is subtler and is the reason this is a repo rather than a
paragraph: **a convention drifts from what actually happens, and nothing tells
you.** So the rule lives in exactly one file, that file is short enough to be
read in full every time, and a script verifies its observable consequences.

## What you get

| File | Role |
|---|---|
| `CONVENTION.md` | the rule — **the only copy**, capped at 60 lines |
| `JOURNAL.md` | append-only, one short entry per session |
| `.agent-memory.conf` | the budgets `check-memory.sh` enforces |
| `check-memory.sh` | audits the repository against the rule |

`check-memory.sh` verifies that the convention exists and is still short, that
the journal is genuinely append-only, that no document has outgrown its
budget, and — the one that earns its keep — that nothing has been committed
since the last journal entry without anyone writing it down.

## Adopt it

```bash
git clone git@github.com:tiavelum/agent-memory.git
cd agent-memory && chmod +x install.sh check-memory.sh
./install.sh /path/to/your-repo
```

It prints a short block to paste into your assistant's project instructions.
Paste that and nothing else: any rule you put in the instruction field is a
second copy of something, and it is the copy no script can check.

Then, from your repository:

```bash
./check-memory.sh
```

Run it when you finish a session, or from a pre-push hook, or from a weekly
job — it reads only the repository, so it works anywhere and needs no
credentials.

## What it deliberately does not do

- No transcript reading. Conversations are not a durable medium and half of
  them cannot be re-read anyway.
- No queue of sessions, no bookmarks, no reading state, no session ids.
- No scheduler. If a check never runs, the repository is still correct; you
  just find out later.
- No conflict handling. It assumes one writer at a time. Concurrent agents
  editing the same repository are a real problem and an explicitly separate
  one.

## Adapting it

Change `CONVENTION.md` and `check-memory.sh` together, or not at all. A rule that
nothing checks is decoration, and a check that enforces a rule nobody wrote
down is a trap. That pairing is the whole idea; everything else here is
plumbing.
