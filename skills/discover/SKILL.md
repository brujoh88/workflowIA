---
name: discover
description: Conversational discovery — frames a new project and derives its stack, or thinks through a new feature on a running project. Run it as often as ideas show up.
allowed-tools: Read, Write, Edit, Glob, Grep, Bash(git:*), AskUserQuestion, WebSearch
---

# Discovery

Two jobs, one conversation shape — the mode is picked in Step 0:

| Mode | Situation | Produces |
|------|-----------|----------|
| **A** | Brand-new project | Stack recommendation + Business Context + ADR-001 + ROADMAP + BACKLOG + first ROUTE item |
| **B** | Running project, new feature or idea | BACKLOG items + ROADMAP placement + ROUTE position (+ a plan if it is big) |
| **C** | Running project, the product itself changed | Re-framed Business Context + new ADR + ROADMAP |

**Mode B is meant to be run constantly** — every time a feature idea appears. It is the cheap way
to find out that the thing you were about to build already has an owner, or breaks an invariant,
or should wait behind something else.

Mode A runs **before** `/setup`: `/setup` asks *how* the project is configured; this asks **what
is being built and why**, and derives the stack instead of assuming it is already decided.

## Rules for this conversation

1. **Ask about the business, never about technology.** The user describes the problem; you derive
   the stack. If they already have a stack in mind, record it and still ask the questions — the
   answers shape the architecture regardless.
2. **One round at a time.** Present a round, wait, then use what was said to sharpen the next one.
   Do not dump all questions at once.
3. **Use their words.** If they say "clienta", "turno", "cabina" — those are the entity names.
   Do not translate the domain into generic nouns (`User`, `Item`, `Resource`).
4. **Reflect back before moving on.** After each round, restate what you understood in one or two
   plain sentences. Misunderstandings are cheap here and expensive later.
5. **WF-R14 applies**: never invent a requirement the user did not state. If something is missing,
   ask or mark it `UNKNOWN` in the output.
6. **Do not write code, do not install anything.** This skill only produces documents.

## Step 0: Pick the Mode

Read `.claude/project.config.json` and `CLAUDE.md`.

**If `CLAUDE.md` still has `[placeholder]` markers** in `## Business Context` → **Mode A: first
framing**. Go to Step 1.

**Otherwise the project is already framed.** Ask which of these it is:

| Mode | When | What it touches |
|------|------|-----------------|
| **B — New feature or idea** | "I want to add X", "is it worth doing Y?", "how should Z work?" | BACKLOG, ROADMAP, ROUTE, maybe a plan. **Never** rewrites Business Context. |
| **C — Re-framing** | The product pivoted, or a whole new area opened up | Business Context + a new ADR + ROADMAP. Preserves prior decisions unless explicitly superseded. |
| **A — Start over** | Rebuilding from zero | Everything, as a first framing |

**Mode B is the common one** and it is meant to be run often — every time a feature idea shows
up. Go to **Step 1-B**. Mode C runs the full rounds below with existing answers pre-loaded, and
asks only what changed.

Also read (quietly, for continuity): `context/ROADMAP.md`, `context/BACKLOG.md`,
`context/ROUTE.md`, `.claude/MEMORY.md`.

## Step 1-B: Feature Discovery (project already running)

Short and concrete. Four rounds, no ceremony. The goal is to decide **whether it is worth doing,
where it belongs, and what it breaks** — not to re-describe the product.

### B1 — What problem does it solve, and for whom
- Who asked for this, and what were they trying to do when they hit the wall?
- What do they do **today** instead? (the workaround is the real measure of the pain)
- If this never gets built, what happens?

**Listen for**: a feature with no workaround behind it is usually a want, not a need. A feature
whose workaround is "they call me and I fix it by hand" is costing real time — that is the one
worth building.

### B2 — What it touches, and what could break
- Which existing entities and flows does it involve? Name them from `CLAUDE.md`.
- Does it change any invariant, or add a new one?
- **WF-R25 check**: does it introduce a new "can this be done?" question? Grep for who already
  answers something similar. If a rule already exists, this feature **imports** it.
- Who currently sees or does this, and does that change?

**Listen for**: a feature that adds a second answer to an existing question is the expensive kind.
Say so now, not in review.

### B3 — Where it belongs
Look at `context/ROADMAP.md`:
- Does it fit an existing module, or is it a new one?
- What does it depend on that is not built yet?
- What does it unblock?

If it is a new module, classify it: MVP / Post-MVP / Deferred.

### B4 — What it displaces
- What is in `ROUTE.md` → NOW and QUEUE right now?
- Does this go **before** any of it? Ask directly and make them choose — a queue where everything
  is urgent is not a queue.
- Rough size: small (one session) / medium / large (needs a plan first).

### Output for Mode B

Present the recommendation in plain language, one screen, no tables:
- what the feature actually solves, in the user's words
- what it touches and the one thing most likely to break
- where it goes in the queue, and what it pushes down
- the size, and whether it needs a plan first

Then, with confirmation:
1. **`context/BACKLOG.md`** — add the item(s) in standard format (Context / Criteria / Notes),
   under "Next (Prioritized)" or "Ideas / Future" per B4.
2. **`context/ROADMAP.md`** — new module if applicable, or update an existing module's scope and
   dependency lines.
3. **`context/ROUTE.md`** — only if it earned a place in the queue. Insert at the agreed position,
   one line, with the `file:line` pointers found in B2.
4. **`.claude/plan/YYYY-MM-DD-{description}.md`** — only if B4 said **large**. Otherwise skip;
   a plan for a one-session item is overhead.
5. **`docs/adr/{n}-{slug}.md`** — only if an architectural decision was actually made (a new
   invariant, a new integration, a data model change).

**Never** touch `CLAUDE.md`'s Business Context in Mode B. If the conversation reveals that the
product itself changed shape, stop and say: "this is bigger than a feature — worth running Mode C."

Skip Steps 1 through 4 below (those are for first framing).

## Step 1: The Rounds (Modes A and C)

### Round 1 — What happens today without the system

Goal: find the **real problem**, not the requested feature.

Ask, in the user's own domain:
- How is this handled today? (spreadsheet, WhatsApp, paper, another app, not at all)
- What breaks? Ask for the last time it broke and what it cost.
- What does a normal day look like when everything goes fine?

**What to listen for**: the failure they describe first is usually the one the app must solve
before anything else. It becomes the first ROADMAP module, not a nice-to-have.

Reflect back: "So the thing that actually hurts is {X} — everything else is secondary. Right?"

### Round 2 — Who touches it

Goal: roles, screens and permissions.

- Who uses it, and what does each one need to *see* on their screen?
- Which of them are outside the organization (customers) vs inside (staff, admin)?
- Is there anyone who must **not** see something? (prices, other people's data, reports)

**What to listen for**: three different "what do I see when I open it" answers means three
distinct surfaces. Any "must not see" answer means authorization is a day-1 concern, not a later
add-on.

Reflect back: the list of roles with one line each.

### Round 3 — The rule that can never be broken

Goal: the invariants — these decide the data layer.

- What must never happen, ever? (double-booking, negative stock, charging twice)
- If two people do the same thing at the same second, who wins and how do they find out?
- What has to be exact vs what can be approximate? (money and inventory are exact)
- Is there anything you must be able to reconstruct afterwards? (who changed what, when)

**What to listen for**: this round is what actually picks the database. Real invariants under
concurrency need transactions and constraints. "Reconstruct afterwards" means audit fields or an
event log from the start.

Reflect back: the invariants as a numbered list. These become the **critical flows** in CLAUDE.md.

### Round 4 — The edges that change everything

Goal: catch the day-1 decisions that are painful to retrofit.

- One organization or several? (multi-tenant is cheap on day 1, brutal on month 6)
- Does money move through it? Who charges, who refunds?
- Does it need to work offline, or on a phone in someone's hand while they work?
- Does it talk to anything else? (accounting, government API, payment gateway, existing DB)
- Is there data that already exists somewhere and has to come in?

**What to listen for**: any yes here is an architectural constraint, not a feature. Record it as
such.

### Round 5 — Scope and horizon

- Who is the first real user, and when do they need to use it?
- What is the smallest version that is genuinely useful to that person? (not a demo — useful)
- What is explicitly **out** of scope for now?

**What to listen for**: the answer to "smallest useful version" is the MVP module set. The "out of
scope" list is as valuable as the in-scope one — write it down verbatim.

## Step 2: Derive the Stack

Do **not** ask "which framework do you want?". Propose, with the reasoning tied to their answers.

Build the recommendation from the constraints collected:

| Answer from the rounds | What it forces |
|---|---|
| Real invariants under concurrency (round 3) | Relational DB with transactions and unique constraints — not eventually-consistent storage |
| Must reconstruct history (round 3) | Audit fields or event log from schema v1 |
| Several organizations (round 4) | Multi-tenant isolation designed in, not bolted on |
| Money moves (round 4) | Exact decimal types, idempotent operations, immutable ledger |
| Used on a phone while working (round 4) | Mobile-first UI, offline tolerance, few taps per action |
| Talks to an external system (round 4) | Anti-corruption layer; that integration is its own module |
| Data already exists (round 4) | Migration/import is a first-class module, not a script |
| Roles with "must not see" (round 2) | Authorization at the data layer, not just the UI |

If the user already named a stack, check it against this table. If it conflicts with an invariant,
say so plainly, in one or two sentences, with the concrete failure it would cause — then let them
decide (WF-R11: their call, not yours).

Use **WebSearch** if a technology choice depends on current state (maintenance status, a major
version released recently). Do not rely on memory for "what is current".

Present the recommendation as:

```
Recommended stack: {stack}

Why, tied to what you told me:
- {constraint from a round} → {technical consequence}
- {constraint} → {consequence}

Ruled out:
- {alternative}: {the specific thing it would break}

Open question: {anything that needs an answer before this is settled}
```

Confirm with `AskUserQuestion` before writing anything.

## Step 3: Write the Context

Only after the stack is confirmed. Write these files — never leave a `[placeholder]` behind; use
`UNKNOWN — to be defined` when something genuinely was not covered.

### 3.1 `CLAUDE.md`

Fill in, using the user's own vocabulary:
- `## Architecture` → Stack line
- `## Business Context`:
  - **What it does**: one plain sentence — the problem from round 1, not a feature list
  - **Main entities**: the nouns from round 2 and 3, in the user's language
  - **Critical flows**: the invariants from round 3, phrased as flows
- `## Required Patterns` → add anything the edges demand (tenant scoping, exact decimals,
  audit fields, idempotency)

### 3.2 `docs/adr/001-stack.md`

```markdown
# ADR-001: Technology Stack

- **Status**: Accepted
- **Date**: {today}
- **Context**: {the problem from round 1, and the constraints from rounds 3 and 4}
- **Decision**: {the stack}
- **Consequences**:
  - Positive: {what this makes easy}
  - Negative: {what this makes harder — always fill this in}
- **Alternatives considered**: {each one, with the specific reason it was ruled out}
```

Create `docs/adr/` if missing.

### 3.3 `context/ROADMAP.md`

One module per coherent area from the rounds. For each: status `Not Started`, progress 0%,
dependencies, and the classification **MVP / Post-MVP / Deferred** from round 5.

Draw the dependency map. Set "Next Suggested Session" to the module that unblocks the most.

### 3.4 `context/BACKLOG.md`

Seed **Next (Prioritized)** with the first module broken into items, using the standard format
(Context / Criteria / Notes). Put everything from round 5's out-of-scope list under
**Ideas / Future** — verbatim, so it is not silently lost.

### 3.5 `context/ROUTE.md`

Set `## NOW` to the single first item, and `## QUEUE` to the next few in order. Update the header
date and "Next session".

The first item is usually the smallest thing that proves the riskiest invariant from round 3 —
not the login screen.

### 3.6 `context/ENVIRONMENT.md`

Fill in what is already known; leave the rest as `UNKNOWN`. It gets completed as the project runs.

### 3.7 `.claude/project.config.json`

Set only what discovery established: `project.name`, `project.description`, `project.stack`.
Leave everything else to `/setup`.

## Step 4: Hand Off

Present a summary:

```
Framed: {project name}

The problem: {one sentence, round 1}
Who uses it: {roles}
What can never break: {invariants}
Stack: {stack} — see docs/adr/001-stack.md

Written:
- CLAUDE.md (business context filled in)
- docs/adr/001-stack.md
- context/ROADMAP.md ({N} modules, {M} in MVP)
- context/BACKLOG.md ({K} items seeded)
- context/ROUTE.md (first item: {item})
- context/ENVIRONMENT.md (skeleton)

Still open: {UNKNOWN items, if any}

Next: run /setup to configure commands, branches and hooks.
```

Ask whether to chain into `/setup` now.

## Error Recovery

| Problem | Action |
|---------|--------|
| User does not know the answer to a round-3 question | Mark the invariant `UNKNOWN`, flag it as a blocker in ROADMAP, keep going. Do not guess an invariant. |
| User wants a stack that conflicts with an invariant | State the concrete failure in two sentences, then follow their decision (WF-R11) and record the disagreement in the ADR |
| User abandons mid-conversation | Write nothing. Partial framing is worse than none. |
| Domain is unfamiliar | Ask more round-1 questions. Never fill gaps with generic assumptions about how "these systems usually work". |
| **Mode B**: the feature turns out to already exist | Say so with the `file:line`, and ask whether the real request is to change its behaviour. Do not queue a duplicate. |
| **Mode B**: the feature duplicates an existing rule (WF-R25) | Reframe the item as "extract the rule + make all consumers import it", which is a different and usually smaller job |
| **Mode B**: it is really three features | Split into separate BACKLOG items with their own sizes. Only the first one enters ROUTE. |
| **Mode B**: the idea grows past a feature mid-conversation | Stop and offer Mode C. Do not silently rewrite the Business Context. |
