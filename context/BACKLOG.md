# Backlog

Single source of pending items for the project.

## In Progress

_None currently_

## Next (Prioritized)

<!-- Add items with format:
- [ ] **[SCOPE]** Brief description
  - Context: why it's needed
  - Acceptance criteria: what defines "done"
-->

## Completed (Recent)

<!-- Items completed in recent sessions. Moved here by /finish.
Format: - [x] **[scope]** Description *(session-ID)*
Rotated to archive/COMPLETED.md when section grows large.
-->

## Ideas / Future

<!-- Items without defined priority -->

---

## Item Format

```markdown
- [ ] **[scope]** Descriptive title
  - Context: Why it's needed
  - Criteria: What defines "done"
  - Notes: Technical considerations
```

## Completion Markers

| Marker | Meaning |
|--------|---------|
| `[ ]` | Pending - not started |
| `[~]` | Partially completed - work in progress |
| `[x]` | Fully completed |

Completed items include session reference: `*(session-YYYYMMDD-HHMM-name)*`

## How to Use

1. **Add**: New items go to "Ideas / Future"
2. **Prioritize**: Move to "Next" when priority is defined
3. **Start**: `/start` moves item to "In Progress"
4. **Partial**: `/finish` marks as `[~]` if not fully done
5. **Complete**: `/finish` marks as `[x]` and moves to "Completed (Recent)"
6. **Archive**: Rotated to `archive/COMPLETED.md` when section grows large
