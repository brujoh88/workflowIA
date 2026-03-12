---
name: ui-design-system-ref
description: UI design system rules and patterns reference
---

# UI Design System Reference

Auto-loaded reference for frontend UI decisions, patterns, and consistency rules.

## Quick Decision Rules

| Scenario | Use | Don't Use |
|----------|-----|-----------|
| 3+ items to switch between | Tabs | Multiple buttons |
| Filtering list/table data | Filter bar / chips | Tabs |
| Step-by-step process | Stepper / wizard | Tabs |
| Binary toggle | Switch | Checkbox (for settings) |
| Multiple selections | Checkboxes | Multi-select dropdown |
| Single selection (>5 options) | Select/dropdown | Radio buttons |
| Single selection (2-5 options) | Radio buttons / segmented control | Dropdown |
| Destructive action | Confirmation dialog | Inline action |
| Non-critical info | Toast notification | Dialog |
| Critical info/error | Alert banner or dialog | Toast |

## Page Layout Variants

### Layout A: List/Table View
```
┌─────────────────────────────┐
│ Header: Title + Actions     │
├─────────────────────────────┤
│ Filters / Search Bar        │
├─────────────────────────────┤
│ Table / List                │
│ ┌───┬───────┬──────┬──────┐ │
│ │   │ Col 1 │ Col 2│ Acts │ │
│ ├───┼───────┼──────┼──────┤ │
│ │   │       │      │      │ │
│ └───┴───────┴──────┴──────┘ │
├─────────────────────────────┤
│ Pagination                  │
└─────────────────────────────┘
```

### Layout B: Detail View
```
┌─────────────────────────────┐
│ Header: Back + Title + Acts │
├──────────┬──────────────────┤
│ Sidebar  │ Main Content     │
│ (nav/    │ ┌──────────────┐ │
│  meta)   │ │ Section 1    │ │
│          │ ├──────────────┤ │
│          │ │ Section 2    │ │
│          │ └──────────────┘ │
└──────────┴──────────────────┘
```

### Layout C: Form/Editor
```
┌─────────────────────────────┐
│ Header: Title + Save/Cancel │
├─────────────────────────────┤
│ Form Content                │
│ ┌─────────────────────────┐ │
│ │ Field Group 1           │ │
│ ├─────────────────────────┤ │
│ │ Field Group 2           │ │
│ ├─────────────────────────┤ │
│ │ Field Group 3           │ │
│ └─────────────────────────┘ │
├─────────────────────────────┤
│ Footer: Actions             │
└─────────────────────────────┘
```

## Dark Mode Rules

1. **Never hardcode colors** — Always use CSS variables or theme tokens
2. **Use framework utilities** — Tailwind: `dark:bg-gray-800`, CSS: `var(--bg-primary)`
3. **Test both modes** — Every component must render correctly in light and dark
4. **Shadows adapt** — Use softer/darker shadows in dark mode
5. **Borders adapt** — Lighter borders in dark mode for contrast
6. **Images** — Consider `filter: brightness(0.9)` for images in dark mode
7. **Focus rings** — Must be visible in both modes

## Spacing and Consistency

### Spacing Scale
Use consistent spacing tokens (not magic numbers):
- `xs`: 4px (0.25rem)
- `sm`: 8px (0.5rem)
- `md`: 16px (1rem)
- `lg`: 24px (1.5rem)
- `xl`: 32px (2rem)
- `2xl`: 48px (3rem)

### Component Spacing
| Context | Spacing |
|---------|---------|
| Between form fields | `md` (16px) |
| Between sections | `xl` (32px) |
| Inside cards | `lg` (24px) |
| Between buttons | `sm` (8px) |
| Page padding | `lg` to `xl` |

## Pre-Commit UI Checklist

Before committing any frontend change:

- [ ] **Accessibility**: Semantic HTML, ARIA labels, keyboard nav
- [ ] **Dark mode**: Renders correctly in both modes
- [ ] **Responsive**: Works at mobile (320px), tablet (768px), desktop (1024px+)
- [ ] **States**: Loading, empty, error states handled
- [ ] **Focus**: Visible focus ring on interactive elements
- [ ] **Spacing**: Consistent with spacing scale (no magic numbers)
- [ ] **Typography**: Follows project's type scale
- [ ] **Hover/Active**: Interactive elements have hover and active states
- [ ] **Size**: Component is within size limits (see feature-architect)

## Color Usage Guidelines

| Purpose | Light Mode | Dark Mode |
|---------|-----------|-----------|
| Background (primary) | White / Gray-50 | Gray-900 / Gray-950 |
| Background (secondary) | Gray-100 | Gray-800 |
| Text (primary) | Gray-900 | Gray-100 |
| Text (secondary) | Gray-600 | Gray-400 |
| Border | Gray-200 | Gray-700 |
| Accent | Brand color | Brand color (lighter variant) |
| Error | Red-600 | Red-400 |
| Success | Green-600 | Green-400 |
| Warning | Yellow-600 | Yellow-400 |

**Note**: These are guidelines. Use the project's actual design tokens if defined.
