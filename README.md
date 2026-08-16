# Layman

**Plain language, without dumbing down.**

Layman is a Claude Code skill that changes how the assistant talks to you: jargon gets
explained rather than avoided, assumptions get said out loud, and every reference carries its
name before its identifier.

It is the complement to [Caveman](https://github.com/JuliusBrussee/caveman), which compresses
output for a reader who already knows the domain. Layman is for the case where they shouldn't
have to. Different axes — you can run both.

---

## Who it's for: the reader who just got back

You have four sessions open. One is running a test suite, one is halfway through a migration,
one you started yesterday and half-forgot. You switch to the second and read:

> *"Rolled back — the constraint fires on the backfill. Same as before. Retrying with the flag."*

Every word is accurate, and you understood all of it. You still don't know **which** constraint,
**which** backfill, what "same as before" refers to, or which flag. Not because the writing is
bad — because it was written for a reader with the last twenty minutes loaded, and you were
somewhere else.

That is the cost this skill targets, and it isn't comprehension. It's **re-entry**. Agents now
run long enough that waiting on one is dead time, so people run several in parallel and switch
between them. Every switch dumps the context the previous message quietly assumed. The
expensive part is rarely reading the sentence — it's reconstructing *which thing it is about*.

So the design goal is not "simpler". It is:

> **Every message should stand on its own when you come back to it cold.**

That reframes the whole rule set:

| Rule | What it costs to write | What it saves on re-entry |
|---|---|---|
| Name it, then number it | a few words | not having to work out which ticket, host, or branch |
| Assumptions stated out loud | one sentence | not having to remember what was assumed |
| Numbers with units and a verdict | a clause | not having to re-derive whether it's good news |
| Plain sentence before the artifact | reordering | not having to reload the specialism first |

None of that is about how much you know. It's about how much you are currently **holding**.
Which is why the default is `plain` rather than `zero`, and why the skill argues so hard
against over-explaining: the reader is an expert. They're just an expert who was somewhere else
ninety seconds ago.

The same problem at a longer timescale is the transcript you reopen in three weeks, or the
colleague you paste it to. Same fix.

This is also the cleanest way to see how it sits next to
[Caveman](https://github.com/JuliusBrussee/caveman): **Caveman optimises for the reader who is
*in* the session. Layman optimises for the reader who is *returning to* it.** Both are real,
they're not in tension, and you can run both.

---

## The idea: two dials, not one

Most "talk to me differently" tooling has a single verbosity slider. That conflates two
unrelated things, and the conflation is why the output is usually wrong in one direction or the
other:

| | Caveman's axis | Layman's axis |
|---|---|---|
| Reduces | **words** | **assumed knowledge** |
| Optimizes for a reader who | already knows the domain | shouldn't have to |
| Effect on length | shorter | often *longer* |

They are orthogonal. Terse **and** jargon-free is not a contradiction — it's the sweet spot,
and a single slider can't reach it:

> *"Login is broken. The password check compares the wrong two values. Fixing now."*

So Layman ships two independent dials:

| Dial | Levels | Default |
|---|---|---|
| **Plainness** — how much knowledge is assumed | `expert` · `plain` · `zero` | `plain` |
| **Density** — how many words | `lite` · `full` · `ultra` · `wenyan-*` | `lite` |

The density dial, its level names, and the `wenyan-*` Classical Chinese registers come from
Caveman, so muscle memory transfers. See [NOTICE](NOTICE).

Where they conflict — `ultra` compresses by abbreviating, and abbreviation *is* jargon —
**plainness wins**.

---

## What it actually changes

### Plain sentence first, exact artifact second

> ❌ "The worker pool saturated on the N+1 in `OrderSerializer`, p99 blew past the SLO."
>
> ✅ "Every order on the page triggered its own database query, so the workers were all busy
> waiting and the slowest 1% of requests broke our latency target. The cause is the N+1 query
> in `OrderSerializer`."

Note what *stayed*: `OrderSerializer`, N+1, the SLO. Nothing was dumbed down — the sentence was
reordered so the event leads and the identifiers support it.

### Name it, then number it

A reference fails in two directions, and both are failures:

- **Too vague** — "the ticket", "that server", "the config". Nothing to look up.
- **Too opaque** — a bare `PROJ-142`, `#4471`, `c3f9a1b`. Precise and completely uninformative.

An identifier is an *address*, not an *identity*. Nobody remembers what a number was about, so
meaning leads and the address follows:

> the checkout-timeout ticket (`PROJ-142`) · the commit that pinned the driver (`c3f9a1b`)

This one matters most weeks later, when you reopen a transcript with none of the context.

### Assumptions out loud

> "I'm assuming you mean the staging database, since that's what we've been working in."

Stated when made, not buried in a closing caveat. If being wrong would waste real work, it asks
instead.

### Things it will never simplify

Exact identifiers stay verbatim — a paraphrased command is a wrong command. Risk gets blunter,
not gentler (*"This deletes all 40,000 rows. There is no undo."*). Uncertainty stays visible at
every level, because simple language must never read as more confident than the evidence.

---

## Calibration: the part everyone gets wrong

The most likely way to misuse a skill like this is to over-apply it. What counts as jargon is a
property of the **reader**, not of the word. Layman calibrates in three steps:

**1. Words you have used are words you know.** The strongest signal, and it needs no setup. If
you wrote *"just bump the replica count in the StatefulSet"*, then replica, StatefulSet, and
Kubernetes are your working vocabulary — explaining them back to you is condescending. This
covers the whole conversation, including files and errors you paste.

**2. Your domain's daily vocabulary is not jargon.** Inferred from what you're working on. Only
the genuinely niche gets a gloss: a specific algorithm, an obscure flag, a term from a
*neighbouring* specialism you haven't shown fluency in.

**3. An explicit list wins over both** — see [Configuration](#configuration).

It will not explain what a file, a server, or a database is. **When in doubt it pitches up, not
down.** Only `zero` assumes no technical background, and only when you ask for it.

---

## Install

Two paths. They are alternatives, not steps.

### Skill only — `/layman` works, you invoke it per session

```bash
git clone https://github.com/yevgenyt/layman.git
cd layman && ./install.sh
```

Symlinks `skills/layman` into `~/.claude/skills/` and writes default levels. Nothing runs in
the background.

### Plugin — adds always-on

Install as a Claude Code plugin so the bundled `SessionStart` hook runs. That hook injects the
condensed rules at the start of every session, so the mode is live before the skill is loaded.

The hook is ~40 lines of POSIX `sh` with no dependencies — a communication-style plugin has no
business dragging in a language runtime. It reads your config and writes nothing.

> **Why a hook instead of editing your `CLAUDE.md`?** Because that file is yours. A distributed
> skill that rewrites it is being presumptuous. If you *prefer* that approach, the snippet is
> in [Always-on without the plugin](#always-on-without-the-plugin) below.

---

## Usage

| You type | What happens |
|---|---|
| `/layman` | Shows your current levels, then offers the alternatives as a picker |
| `/layman zero` | Sets plainness, leaves density alone |
| `/layman full` | Sets density, leaves plainness alone |
| `/layman zero ultra` | Sets both |
| `/layman wenyan-full` | Classical Chinese register (not in the picker — see below) |
| "layman off" / "normal mode" | `expert` + `lite` |
| "be brief" / "caveman mode" | Density only; plainness untouched |

Both dials are listed in **intensifying order** — `expert` → `plain` → `zero`, and `lite` →
`full` → `ultra` — never reordered to float your current choice to the top. They're points on a
scale, and a fixed direction is what lets you see where you sit and which way to move.

The `wenyan-*` registers are reachable by typing but deliberately absent from the picker:
`wenyan-lite` is less compressed than `ultra`, so the six levels don't form one ordered scale,
and listing them together would break the very ordering the picker exists to show.

---

## Configuration

Everything lives in `$XDG_CONFIG_HOME/layman/` (default `~/.config/layman/`).

**`levels`** — written by `/layman`, read by the hook:

```
plainness=plain
density=lite
```

**`known-vocabulary`** *(optional)* — terms never to explain to you, one per line. This
overrides the automatic calibration above, so it's worth filling in for anything you use daily
that a general reader wouldn't:

```
# infrastructure
VRAM
systemd
podman

# our stack
Temporal
pgbouncer
```

### Always-on without the plugin

Prefer to keep it in your own instructions rather than run a hook? Drop this into
`~/.claude/CLAUDE.md`:

```markdown
## Communication default: Layman mode is ON

- Plain sentence first, exact command second.
- Jargon is glossed, not avoided — gloss what is niche to me, never what I have used myself.
  A gloss or two per reply, not a glossary.
- Name it, then number it. A bare PROJ-142 is as useless as "that ticket".
- State assumptions out loud. Numbers get units, scale, and a verdict.
- Never simplify an exact identifier, a risk warning, or a caveat. Plain is not soft.
- Not a third-grader conversation: assume general competence, just not this specialism's
  vocabulary. Pitch up, not down.

Full rules and level changes: /layman
```

---

## What this is not

- **Not a token-saving tool.** Plainness often makes replies *longer*. If you want fewer
  tokens, that's the density dial, and [Caveman](https://github.com/JuliusBrussee/caveman) is
  the specialist.
- **Not an ELI5 mode.** That's `zero`, it's opt-in, and the skill is explicitly instructed
  never to drift toward it.
- **Not a politeness filter.** It makes warnings blunter, not softer.

---

## License

MIT — see [LICENSE](LICENSE).

Derived from [Caveman](https://github.com/JuliusBrussee/caveman) by Julius Brussee (MIT). Only
its MIT-licensed `skills/` content informed this project; nothing under its BSL-1.1 paths was
copied or reimplemented. Full attribution in [NOTICE](NOTICE).
