# Searchable Code Reference System

## 🔍 Quick Navigation Commands

### Essential Search Patterns

```bash
# Find component definitions
rg "export.*=.*memo|export.*function.*Props" --type tsx -n

# Find API handlers  
rg "handlers\[.*\].*=" --type ts -n

# Find hooks usage
rg "const.*=.*use[A-Z]" --type tsx -n

# Find type definitions
rg "interface.*|type.*=" --type ts -n

# Find test patterns
rg "describe\(|it\(|test\(" --type ts -n
```

### Package-Specific Searches

```bash
# Frontend components
rg "pattern" packages/desktop-client --type tsx

# Backend logic
rg "pattern" packages/loot-core --type ts

# API definitions
rg "pattern" packages/api --type ts

# Testing utilities
rg "pattern" packages --type ts -g "*test*"
```

## 📚 Code Reference Index

### Frontend Components (`packages/desktop-client/`)

#### Core UI Components
```bash
# Button components
rg "Button.*=" packages/desktop-client/src/components --type tsx -A 3

# Form components  
rg "Input.*=|Select.*=|Checkbox.*=" packages/desktop-client/src/components --type tsx -A 3

# Layout components
rg "View.*=|Stack.*=|Flex.*=" packages/desktop-client/src/components --type tsx -A 3
```

**Key Files:**
- `src/components/common/Button.tsx` - Standard button component
- `src/components/common/Input.tsx` - Form input components
- `src/components/common/View.tsx` - Layout primitives

#### Page Components
```bash
# Budget pages
rg "Budget.*Page" packages/desktop-client/src/components --type tsx -l

# Account pages
rg "Account.*Page" packages/desktop-client/src/components --type tsx -l

# Settings pages
rg "Settings.*Page" packages/desktop-client/src/components --type tsx -l
```

**Key Directories:**
- `src/components/budget/` - Budget management UI
- `src/components/accounts/` - Account management UI  
- `src/components/settings/` - Application settings

#### Hooks & Utilities
```bash
# Custom hooks
rg "export.*function.*use[A-Z]" packages/desktop-client/src --type tsx -n

# Context providers
rg "Provider.*=" packages/desktop-client/src --type tsx -n

# Utility functions
rg "export.*function" packages/desktop-client/src/hooks --type ts -n
```

### Backend Logic (`packages/loot-core/`)

#### API Handlers
```bash
# Account handlers
rg "accounts-" packages/loot-core/src/server --type ts -B 1 -A 3

# Budget handlers  
rg "budget-" packages/loot-core/src/server --type ts -B 1 -A 3

# Transaction handlers
rg "transaction-" packages/loot-core/src/server --type ts -B 1 -A 3
```

**Key Files:**
- `src/server/accounts/` - Account management logic
- `src/server/budget/` - Budget calculations and rules
- `src/server/transactions/` - Transaction processing

#### Database Operations
```bash
# Database queries
rg "db\.all|db\.run|db\.get" packages/loot-core/src --type ts -B 1 -A 2

# Migration files
fd "migration" packages/loot-core/src --type f

# Schema definitions
rg "CREATE TABLE|ALTER TABLE" packages/loot-core/src --type ts -A 5
```

#### Business Logic
```bash
# Budget calculations
rg "calculate|compute" packages/loot-core/src/server/budget --type ts -n

# Rules engine
rg "rule|condition" packages/loot-core/src/server --type ts -n

# Sync logic
rg "sync|merge" packages/loot-core/src/server --type ts -n
```

## 🎯 Search by Use Case

### Finding Implementation Examples

#### "How do I create a new component?"
```bash
# Find recent component patterns
rg "export.*=.*memo" packages/desktop-client --type tsx -A 5 | head -20

# Find prop type patterns
rg "Props.*interface|Props.*type" packages/desktop-client --type tsx -A 3

# Find component usage examples
rg "import.*from.*components" packages/desktop-client --type tsx -B 1 -A 1
```

#### "How do I add a new API endpoint?"
```bash
# Find handler registration
rg "handlers\[.*\]" packages/loot-core/src/server --type ts -B 1 -A 3

# Find validation patterns
rg "validate|schema" packages/loot-core/src/server --type ts -A 2

# Find error handling
rg "error.*return|throw.*Error" packages/loot-core/src/server --type ts -B 1 -A 1
```

#### "How do I write tests for this?"
```bash
# Find similar test files
fd "$(basename $TARGET_FILE .tsx).test" packages --type f

# Find test utilities
rg "render|screen|fireEvent" packages --type ts -g "*test*" -B 1 -A 1

# Find mock patterns
rg "mock|jest\.fn|vi\.fn" packages --type ts -g "*test*" -A 2
```

#### "How do I handle state management?"
```bash
# Find useState patterns
rg "useState.*=" packages/desktop-client --type tsx -B 1 -A 1

# Find context usage
rg "useContext|createContext" packages/desktop-client --type tsx -B 1 -A 2

# Find reducer patterns
rg "useReducer|dispatch" packages/desktop-client --type tsx -B 1 -A 2
```

### Finding Architectural Patterns

#### Message Passing (Frontend ↔ Backend)
```bash
# Frontend send calls
rg "send\(" packages/desktop-client --type tsx -B 1 -A 1

# Backend handler definitions
rg "handlers\[.*\].*async" packages/loot-core --type ts -A 3

# Message type definitions
rg "interface.*Message|type.*Request" packages --type ts -A 3
```

#### Database Patterns
```bash
# Query patterns
rg "SELECT.*FROM|INSERT.*INTO|UPDATE.*SET" packages/loot-core --type ts -A 2

# Transaction handling
rg "transaction|commit|rollback" packages/loot-core --type ts -B 1 -A 2

# Connection management
rg "database|db.*=|openDatabase" packages/loot-core --type ts -A 2
```

#### Error Handling
```bash
# Error boundaries (React)
rg "ErrorBoundary|componentDidCatch" packages/desktop-client --type tsx -A 3

# Backend error handling
rg "try.*{|catch.*{" packages/loot-core --type ts -B 1 -A 3

# Error message patterns
rg "error.*message|Error\(" packages --type ts -A 1
```

## 🛠️ Advanced Search Techniques

### Semantic Code Search
```bash
# Find similar implementations by pattern
rg "function.*calculate.*\(" packages --type ts -A 5

# Find related functionality
rg "$(basename $CURRENT_FILE .tsx)" packages --type tsx -l | head -5

# Find import dependencies
rg "import.*from.*$(dirname $CURRENT_FILE)" packages --type tsx -n
```

### Cross-Package Analysis
```bash
# Find package dependencies
rg "import.*@actual|import.*loot-core" packages --type ts -n

# Find shared utilities
rg "export.*function" packages/*/src/shared --type ts -n

# Find type exports
rg "export.*interface|export.*type" packages/*/src --type ts -n
```

### Git-Based Searches
```bash
# Find recent changes to area
git log --oneline --since="1 month ago" -- packages/desktop-client/src/components/

# Find files changed with specific pattern
git log --name-only --grep="pattern" | grep "\.tsx\?"

# Find who last modified similar code
git blame $(rg "similar_pattern" --files-with-matches | head -1)
```

## 📖 Reference Quick Links

### Component Architecture
```bash
# Component hierarchy
tree packages/desktop-client/src/components -I "*.test.*" -L 3

# Shared components
ls packages/desktop-client/src/components/common/

# Page components  
ls packages/desktop-client/src/components/*/ | grep -E "(Page|Screen)"
```

### API Structure
```bash
# Handler organization
tree packages/loot-core/src/server -I "*.test.*" -L 2

# Available endpoints
rg "handlers\[.*\]" packages/loot-core/src/server --type ts | cut -d: -f2 | cut -d= -f1
```

### Testing Structure
```bash
# Test file organization
find packages -name "*.test.*" -type f | head -20

# Test utilities
ls packages/*/src/**/*test* 2>/dev/null
```

## 🎪 Smart Search Scripts

### Find Similar Components
```bash
find_similar_component() {
    local component_name="$1"
    echo "=== Similar Components ==="
    rg "export.*${component_name}" packages/desktop-client --type tsx -l
    
    echo -e "\n=== Usage Examples ==="
    rg "<${component_name}" packages/desktop-client --type tsx -B 1 -A 1 | head -10
    
    echo -e "\n=== Props Patterns ==="
    rg "${component_name}Props" packages/desktop-client --type tsx -A 3
}
```

### Find Related Backend Logic
```bash
find_backend_logic() {
    local feature_name="$1"
    echo "=== Handlers ==="
    rg "${feature_name}" packages/loot-core/src/server --type ts -l
    
    echo -e "\n=== Database ==="
    rg "${feature_name}" packages/loot-core/src/server --type ts -B 1 -A 3 | grep -E "(SELECT|INSERT|UPDATE|CREATE)"
    
    echo -e "\n=== Types ==="
    rg "${feature_name}.*interface|${feature_name}.*type" packages/loot-core --type ts -A 2
}
```

### Context-Aware Search
```bash
contextual_search() {
    local current_file="$1"
    local search_term="$2"
    
    # Get current directory context
    local current_dir=$(dirname "$current_file")
    local package_name=$(echo "$current_dir" | cut -d/ -f2)
    
    echo "=== Context: $package_name ==="
    rg "$search_term" "packages/$package_name" --type ts --type tsx -B 1 -A 1
    
    echo -e "\n=== Related Files ==="
    rg "$search_term" --files-with-matches | grep "$(basename ${current_file%.*})"
    
    echo -e "\n=== Import Patterns ==="
    rg "import.*$search_term" "packages/$package_name" --type ts --type tsx -n
}
```

## 🎯 IDE Integration

### VS Code Search Patterns
```json
// .vscode/settings.json
{
  "search.include": {
    "**/packages/desktop-client/src/**/*.{ts,tsx}": true,
    "**/packages/loot-core/src/**/*.ts": true
  },
  "search.exclude": {
    "**/node_modules": true,
    "**/*.test.*": false,
    "**/__snapshots__": true
  }
}
```

### Workspace Search Shortcuts
- `Ctrl+Shift+F` - Global search across workspace
- `Ctrl+T` - Go to file by name
- `Ctrl+Shift+O` - Go to symbol in file
- `Ctrl+P` - Quick file open with fuzzy matching

## 📊 Search Performance Tips

### Optimize Large Searches
```bash
# Use type filters for speed
rg "pattern" --type tsx  # Faster than no filter

# Limit context lines
rg "pattern" -A 2 -B 1   # Instead of -A 10 -B 10

# Use file globbing
rg "pattern" -g "*.tsx"  # Target specific files

# Exclude unnecessary directories
rg "pattern" --glob="!**/node_modules/**"
```

### Build Search Index (Future Enhancement)
```bash
# Create searchable index for complex queries
rg "export.*function|export.*interface|export.*type" --type ts --type tsx -n > code_index.txt

# Search the index
grep "pattern" code_index.txt
```

---

*This searchable reference system provides comprehensive code discovery capabilities. Combine with the AI context builder from `docs/development/prompt-engineering/` for maximum development efficiency.*