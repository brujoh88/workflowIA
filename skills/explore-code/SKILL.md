---
name: explore-code
description: Methodical codebase exploration and understanding
argument-hint: [what to explore]
context: fork
agent: Explore
---

# Explore: $ARGUMENTS

## Step 1: Parse Query Type

Classify the exploration request into one of these categories:

| Query Type | Examples | Primary Tools |
|-----------|---------|---------------|
| **File search** | "where is the auth module?", "find all controllers" | Glob |
| **Flow trace** | "how does login work?", "what happens when a user signs up?" | Read, Grep |
| **Pattern search** | "where do we use Redis?", "find all API endpoints" | Grep |
| **Dependency map** | "what depends on UserService?", "what does this module import?" | Grep, Read |
| **Architecture overview** | "how is the project structured?", "explain the folder layout" | Glob, Read |

## Step 2: Tool Strategy

### For File Search
1. Glob with broad patterns: `src/**/*{keyword}*`
2. If no results: try alternative naming conventions (kebab-case, camelCase, PascalCase)
3. Narrow down with more specific patterns

### For Flow Trace
1. Grep for the entry point (route, handler, controller)
2. Read the entry point file
3. Follow imports/calls to services and repositories
4. Read each layer until the flow is complete
5. Note branching points and error handling

### For Pattern Search
1. Grep with regex for the pattern across `src/`
2. Group results by file/module
3. Read context around key matches (use -C flag for context lines)

### For Dependency Map
1. Grep for imports/requires of the target module
2. Read the target module's own imports
3. Build upstream (who uses it) and downstream (what it uses) lists

### For Architecture Overview
1. Glob `src/**/*` to see folder structure
2. Read key files: `package.json`, config files, main entry point
3. Identify patterns: layered, feature-based, DDD, etc.

## Step 3: Progressive Exploration

Start broad, then narrow down:

```
Round 1: Wide search → identify relevant areas
Round 2: Focused reads → understand specific files
Round 3: Cross-references → trace connections between files
```

**Stop criteria**:
- The question is fully answered
- All relevant code paths have been traced
- No more useful connections to follow

**Depth limits**:
- File search: stop after finding primary matches (max 20 files)
- Flow trace: max 5 layers deep (controller → service → repo → DB → response)
- Pattern search: group results if more than 10 matches
- Dependency map: max 2 levels of transitive dependencies

## Step 4: Output

### File Search Output
```markdown
### Files Found: {query}

| # | File | Purpose | Last Modified |
|---|------|---------|---------------|
| 1 | `{path}` | {brief description} | {date} |
| 2 | `{path}` | {brief description} | {date} |

**Key file**: `{path}:{line}` — {why this is the main one}
```

### Flow Trace Output
```markdown
### Flow: {description}

**Entry point**: `{file}:{line}`

{step1} → {step2} → {step3} → {step4}

#### Step-by-step
1. **{layer}** — `{file}:{line}`: {what happens}
2. **{layer}** — `{file}:{line}`: {what happens}
3. **{layer}** — `{file}:{line}`: {what happens}

#### Data transformations
- Input: `{type/shape}`
- Processing: `{key transformations}`
- Output: `{type/shape}`

#### Error handling
- `{file}:{line}`: {what errors are caught and how}
```

### Pattern Search Output
```markdown
### Pattern: {query}

**Total matches**: {N} across {M} files

| # | File | Line | Match Context |
|---|------|------|---------------|
| 1 | `{path}` | {line} | `{matched code snippet}` |

#### Grouped by module
- **{module}**: {N} occurrences — {pattern description}
```

### Dependency Map Output
```markdown
### Dependencies: {module}

#### Upstream (uses {module})
| File | How it's used |
|------|---------------|
| `{path}:{line}` | {import/usage description} |

#### Downstream ({module} depends on)
| Dependency | Purpose |
|-----------|---------|
| `{module}` | {why it's needed} |

#### Dependency diagram
{module A} ──→ **{target}** ──→ {module B}
                    ↑               ↓
              {module C}      {module D}
```

## Tips for Effective Exploration

- **Be specific**: "how does the JWT validation middleware work?" > "how does auth work?"
- **Name files**: include `file:line` references for every finding
- **Follow imports**: the import graph reveals architecture
- **Check tests**: test files often document intended behavior
- **Read configs**: configuration files reveal feature flags and environment differences
- **Check git blame**: for understanding why code is the way it is
