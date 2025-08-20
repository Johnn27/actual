# Simple Workflow Memory System
## Core Learning Features for Issue Analysis

A lightweight memory system that learns patterns and shares knowledge between analysis sessions.

## Memory Components

### 1. Pattern Memory
**File:** `docs/development/memory/patterns.json`

```json
{
  "skip_patterns": [
    "sync server timing",
    "multiple components interact", 
    "async race condition",
    "performance optimization"
  ],
  "easy_patterns": [
    "typo in variable name",
    "missing null check",
    "incorrect import path",
    "missing export statement"
  ],
  "solution_templates": [
    {
      "pattern": "useEffect missing dependency",
      "solution": "Add {variable} to dependency array",
      "files_usually": "*.tsx components"
    },
    {
      "pattern": "undefined variable",
      "solution": "Add import statement or check spelling",
      "files_usually": "Any TypeScript file"
    }
  ]
}
```

### 2. Codebase Knowledge
**File:** `docs/development/memory/codebase-insights.json`

```json
{
  "easy_areas": [
    "packages/desktop-client/src/components/",
    "packages/loot-core/src/shared/"
  ],
  "complex_areas": [
    "packages/loot-core/src/server/sync/",
    "packages/loot-core/src/server/db/"
  ],
  "common_fixes": [
    {
      "location": "React components",
      "issue": "Missing key prop",
      "fix": "Add unique key to mapped elements"
    },
    {
      "location": "TypeScript files", 
      "issue": "Type import missing",
      "fix": "Add type import from correct package"
    }
  ]
}
```

### 3. Agent Discoveries
**File:** `docs/development/memory/discoveries.json`

```json
{
  "recent_findings": [
    {
      "agent": "agent_1",
      "date": "2025-01-15",
      "discovery": "Translation issues are usually just missing keys in locale files",
      "example_issue": "#5432"
    },
    {
      "agent": "agent_2", 
      "date": "2025-01-14",
      "discovery": "Button styling issues often fixed by checking existing button variants",
      "example_issue": "#5398"
    }
  ],
  "useful_search_patterns": [
    "Search 'useEffect' when issue mentions 'infinite render'",
    "Search component name when issue mentions 'component not updating'",
    "Search 'translation' when issue has non-English text problems"
  ]
}
```

## How Memory Works

### Before Analysis: Load Memory
```bash
# Simple command to show current patterns
cat docs/development/memory/patterns.json | jq '.skip_patterns[]'

# Show recent discoveries  
cat docs/development/memory/discoveries.json | jq '.recent_findings[]'
```

### During Analysis: Use Patterns
When analyzing an issue, check if description matches known patterns:

- **Skip if matches:** "sync server timing" → Known complex
- **Prioritize if matches:** "typo in variable" → Known easy  
- **Apply template if matches:** "useEffect missing dependency" → Use solution template

### After Analysis: Update Memory
When you find something useful, add it:

```bash
# Add new skip pattern (manual edit)
# Edit docs/development/memory/patterns.json
# Add "browser compatibility issue" to skip_patterns

# Add new discovery (manual edit)  
# Edit docs/development/memory/discoveries.json
# Add your finding to recent_findings
```

## Enhanced Agent Prompt

```markdown
MEMORY LOADING: Before starting analysis, quickly review:
1. Skip patterns: `cat docs/development/memory/patterns.json | jq '.skip_patterns'`
2. Easy patterns: `cat docs/development/memory/patterns.json | jq '.easy_patterns'`  
3. Recent discoveries: `cat docs/development/memory/discoveries.json | jq '.recent_findings'`

MEMORY USAGE: During analysis, apply learned patterns:
- Skip issues matching known complex patterns
- Prioritize issues matching known easy patterns
- Use solution templates when applicable

MEMORY CONTRIBUTION: After analysis, if you discover something useful:
- Add new patterns to appropriate category
- Document discoveries for other agents
- Note which file areas tend to be easy/complex
```

## Simple Workflow Integration

### Step 2: Quick Complexity Filtering (Memory-Enhanced)

**Skip issues that match learned patterns:**
- Load current skip patterns: `cat docs/development/memory/patterns.json | jq '.skip_patterns[]'`
- Apply standard filters PLUS memory patterns
- Prioritize issues matching easy patterns

### Step 3: Codebase Investigation (Memory-Guided)  

**Use codebase knowledge:**
- Check if issue is in known easy/complex area
- Apply relevant solution templates if pattern matches
- Use discovered search patterns for faster investigation

### Step 5: Documentation (Memory-Contributing)

**Add memory section to analysis:**
```markdown
### Memory Contribution
- **New Pattern Learned:** "Component prop validation missing" → Easy fix
- **Solution Template:** Check existing prop validation patterns in similar components  
- **Codebase Insight:** Validation issues in /components usually have nearby examples
```

## Memory Files Structure

```
docs/development/memory/
├── patterns.json           # Skip/easy patterns + solution templates
├── codebase-insights.json  # Areas that tend to be easy/complex
└── discoveries.json        # Recent agent findings and search tips
```

## Simple Usage Examples

### Loading Memory Before Analysis
```bash
echo "Skip these patterns:"
cat docs/development/memory/patterns.json | jq -r '.skip_patterns[]'

echo "Look for these easy patterns:"  
cat docs/development/memory/patterns.json | jq -r '.easy_patterns[]'
```

### Checking Solution Templates
```bash
echo "Known solution templates:"
cat docs/development/memory/patterns.json | jq -r '.solution_templates[].pattern'
```

### Adding New Discovery
```json
// Edit docs/development/memory/discoveries.json
// Add to recent_findings array:
{
  "agent": "agent_3",
  "date": "2025-01-16", 
  "discovery": "CSS issues in mobile components usually need @media query fixes",
  "example_issue": "#5445"
}
```

## Benefits

- **Faster filtering:** Skip known complex patterns immediately
- **Better prioritization:** Focus on known easy patterns  
- **Reusable solutions:** Apply templates to similar issues
- **Cross-agent learning:** Share discoveries between agents
- **Codebase familiarity:** Build knowledge of easy/complex areas

This simple system captures the core value of learning and memory without complex analytics - just practical pattern recognition and knowledge sharing.