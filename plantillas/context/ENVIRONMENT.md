# ENVIRONMENT — operational data for working

> Practical reference: how to bring the app up, how to reach the database, and the traps that
> waste time when rediscovered. It carries no project state (that lives in [ROUTE.md](ROUTE.md))
> and no conventions (those live in `CLAUDE.md`).
>
> **Rule of thumb**: anything you had to ask or look up twice belongs here.

**Updated**: -

---

## Access

| What | Where |
|---|---|
| Frontend (local) | - |
| Backend (local) | - |
| Staging | - |
| Test users | - |

<!-- Note any user that does NOT work for a given check (e.g. an admin that bypasses all
     permission checks is useless for testing roles). -->

---

## Bringing it up

```bash
# dev server / containers
```

<!-- Include the recovery command for whatever tends to fall over. -->

---

## Database

**Local**:

```bash
# connection command
```

- Table naming gotchas (singular vs plural, unexpected names):
- The human-readable identifier of the main entity is:

**Remote / staging**: <!-- Note if it is unreachable from this machine and what the error
disguises itself as. Say how to query it instead. -->

---

## API traps

<!-- Endpoints that behave unlike expected. Each one costs an hour the first time.
- ⚠️ `GET /x` does NOT return Y unless `?include=true` (opt-in, `file.ts:49`).
- ⚠️ Rate limiting: max N parallel requests.
- ⚠️ `POST /z` no longer exists (removed in TICKET-xx): returns 404.
-->

---

## Tests

| What | Command |
|---|---|
| Full suite | - |
| A single spec | - |
| Coverage | - |

<!-- Note anything that must NOT be done (e.g. running the full suite in parallel saturates
     the machine — see WF-R19). -->

---

## Deploy

| Environment | How | Who triggers it |
|---|---|---|
| - | - | - |
