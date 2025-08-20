# Actual Budget - Claude Instructions

## 🎯 Developer Profile & Learning Goals
**Background:** 5+ years C# development | Learning TypeScript/React | New to open source contribution

**Learning Approach:**
- 🔄 Relate React patterns to .NET/MVC concepts (Props = DTOs, Hooks = DI, State = EF Context)
- 📚 Provide detailed explanations with C# analogies for new concepts
- 🧩 Prefer small incremental changes over major refactors
- ✅ Always confirm before making codebase changes
- 🚫 Avoid regression by not refactoring existing functions
- 📊 Match line numbers for easier diff reviews

## 🏗️ Project Architecture

**Actual Budget** - Local-first personal finance tool (100% free, open-source)

**Monorepo Structure (yarn workspaces):**
```
├── packages/
│   ├── loot-core         # Core logic (Business Layer like C# Services)  
│   ├── desktop-client    # React UI (Presentation Layer like MVC Views)
│   ├── desktop-electron  # Desktop wrapper
│   ├── api              # Public API for integrations  
│   ├── sync-server      # Synchronization server
│   ├── component-library # Shared UI components
│   └── crdt             # Conflict-free replicated data types
```

**Key Architecture Patterns (C# MVC Analogies):**
- `loot-core` = Business Logic Layer (like C# Services)
- `desktop-client` = Presentation Layer (like MVC Views)  
- Props = DTOs (data transfer between components)
- React State = Entity Framework context
- Hooks = Dependency Injection pattern

## 🛠️ Development Environment

**Requirements:**
- Node.js >=20, Yarn 4.9.1
- Uses workspaces pattern for monorepo

**Key Scripts:**
- `yarn test --watch=false` - All workspace tests (never use watch mode)
- `yarn lint` - ESLint + Prettier (max 0 warnings enforced)
- `yarn typecheck` - TypeScript + strict mode checking
- `yarn workspace <package> run test <path>` - Package-specific tests

**Development Modes:**
- `yarn start:browser` - Browser development server
- `yarn start:desktop` - Desktop development
- `yarn build:browser` - Production browser build

**Essential CLI Tools for AI-Enhanced Development:**
- `rg` (ripgrep) - Ultra-fast code search across entire codebase
- `jq` - JSON processing for API responses and config manipulation
- `gh` - GitHub CLI for issue analysis and PR management
- `tree` - Directory structure visualization
- `bat` - Enhanced file viewer with syntax highlighting
- `fd` - Modern alternative to find with better performance
- `find` - Standard file search utility
- `curl` - HTTP requests for API testing

## 📋 Previous Work: Sub-Categories Feature

**Completed PR:** [#5268](https://github.com/actualbudget/actual/pull/5268) - Sub-categories implementation (hierarchical category management system)

**Key Architecture Understanding:**
- **loot-core** - Business logic engine with budget calculations, database operations, and API endpoints
- **desktop-client** - React frontend with component-based UI and state management
- **Integration patterns** - Message-based API communication between frontend and backend

## 📝 Code Standards & Patterns

**TypeScript/React Guidelines:**
- Use functional/declarative patterns (avoid classes - no C# class equivalents)
- Prefer `interface` over `type` definitions
- Avoid `any`/`unknown` - use existing codebase types
- Descriptive names with auxiliary verbs (`isLoaded`, `hasError`)
- Named exports for components/utilities
- Use `function` keyword for pure functions
- Minimal, readable JSX

**Testing with Vitest:**
- Always include `--watch=false` flag
- Minimize mocked dependencies for reliability
- Test command: `yarn workspace <package> run test <path>`

**Code Review Principles:**
- Follow existing file structure/format
- Provide file links for context
- Add comments for complex React/TS concepts
- Avoid scope creep for easier PR acceptance

## 🗄️ Database & Architecture

**Database:** Local SQLite with CRDT (Conflict-free Replicated Data Types)
**Sync:** Optional server sync for multi-device support
**Philosophy:** Local-first (offline primary, sync secondary)

**Resources:**
- [Database Details](https://actualbudget.org/docs/contributing/project-details/database)
- [Architecture Guide](https://actualbudget.org/docs/contributing/project-details/architecture)
- [Project Structure](https://actualbudget.org/docs/contributing/project-details/)

## 🌐 Key Resources & Community

**Codebase Focus Areas:**
- [desktop-client](https://github.com/actualbudget/actual/tree/master/packages/desktop-client) - Main React UI code
- [loot-core](https://github.com/actualbudget/actual/tree/master/packages/loot-core) - Backend logic

**Community:**
- GitHub: [actualbudget/actual](https://github.com/actualbudget/actual)
- Discord community support
- Documentation: [actualbudget.org/docs](https://actualbudget.org/docs)
- Uses envelope budgeting methodology

## 🎨 Development Philosophy

- **Local-first:** Offline functionality prioritized
- **Privacy-focused:** Personal finance data stays local
- **Community-driven:** Open source with collaborative development
- **Learning-focused:** Detailed explanations for React/TS transitions
- **Incremental:** Small, focused improvements over large changes
- **Quality:** Strict linting, TypeScript, and testing standards

## 🤖 AI-Enhanced Development Workflow

**Maximize AI Coding Efficiency with Strategic Tool Usage:**

### 📊 Data-Driven Analysis
- `rg "useEffect.*\[\]" --type tsx` - Find potential infinite render issues
- `jq '.scripts' package.json` - Extract available npm/yarn commands
- `gh issue list --label "good first issue" --json title,number` - Analyze GitHub issues systematically
- `fd -e tsx -x wc -l` - Count lines of code by file type for complexity assessment

### 🔍 Contextual Codebase Understanding
- `tree -I node_modules -L 3` - Get high-level project structure for AI context
- `rg "interface.*Props" --type ts -A 5` - Understand component prop patterns
- `bat src/components/Button.tsx` - View files with syntax highlighting for better AI analysis
- `fd "test|spec" -t f -x grep -l "describe\|it\|test"` - Find test files and patterns

### 🚀 Rapid Development Commands
```bash
# Quick codebase exploration for AI context
rg "export.*function" --type ts -n | head -20

# Find similar implementations for pattern matching
rg "useState.*boolean" --type tsx -B 2 -A 2

# Analyze import patterns for consistency
rg "^import.*from" --type ts | sort | uniq -c | sort -nr | head -10

# Check for common React anti-patterns
rg "useEffect.*().*=>" --type tsx -n

# Find TODO/FIXME comments for contribution opportunities
rg "(TODO|FIXME)" --type ts --type tsx -n
```

### 🎯 AI Prompt Optimization Strategies

**Provide Maximum Context:**
1. **File Structure**: Use `tree` to show AI the project layout
2. **Similar Code**: Use `rg` to find existing patterns before asking for new implementations
3. **Dependencies**: Use `jq '.dependencies' package.json` to show what libraries are available
4. **Test Patterns**: Use `fd test` to understand testing conventions

**Effective Prompt Templates:**
```
Context: [paste tree output and relevant rg search results]
Goal: Implement [specific feature] following existing patterns
Constraints: [TypeScript strict mode, existing component patterns, test coverage]
Reference: [paste similar existing code found via rg]
```

### 🔧 Tool-Assisted Problem Solving

**Before Asking AI for Help:**
1. `rg "error_keyword_from_message"` - Search for similar errors in codebase
2. `gh issue list --search "error_message"` - Check if others encountered this issue
3. `fd "*.md" -x grep -l "troubleshooting\|known.*issue"` - Check documentation

**When Implementing Features:**
1. `rg "similar_feature_name" --type tsx` - Find existing implementations
2. `fd "*test*" -e ts -e tsx | grep component_name` - Locate relevant tests
3. `tree src/components | grep -i feature_name` - Understand component organization

### 📈 Workflow Memory Integration

**Build Institutional Knowledge:**
- Use `jq` to maintain JSON-based pattern databases (as per workflow-learning-system.md)
- Leverage `rg` for semantic code search and pattern recognition
- Apply `gh` CLI for systematic GitHub issue analysis
- Employ `tree` and `fd` for rapid codebase navigation and understanding

**Example Workflow Memory Commands:**
```bash
# Update pattern memory after successful analysis
echo '{"pattern": "useEffect missing dependency", "solution": "Add to deps array"}' | jq '.' >> docs/development/memory/patterns.json

# Search historical solutions
jq '.solution_templates[] | select(.pattern | contains("react"))' docs/development/memory/patterns.json

# Log successful discoveries
gh issue view 1234 --json title,body | jq '.title' >> docs/development/memory/discoveries.json
```

**Pro Tips for AI Collaboration:**
- Always include file paths and line numbers in requests
- Use `rg -n` to get line numbers for precise references
- Combine multiple tool outputs for comprehensive context
- Save successful command patterns for reuse