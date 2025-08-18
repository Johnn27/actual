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

## 📋 Current Work: Sub-Categories Feature

**Active Branch:** `feat/sub-categories-johnn27`
**PR:** [#5268](https://github.com/actualbudget/actual/pull/5268) 

**Context:**
- Building on UnderKoen's [original implementation](https://github.com/actualudget/actual/blob/9988c6e805e7b029885d71f0aa1fcd0402d783e2/packages/loot-core/src/server/db/index.ts)
- Compare with [current master](https://github.com/actualbudget/actual/blob/master/packages/loot-core/src/server/db/index.ts)
- Focus: hierarchical category management system

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