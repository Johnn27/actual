# Loot-Core Deep Dive Analysis
## 🧠 The Business Logic Engine of Actual Budget

## ⚡ **TL;DR - Quick Context Overview**
**Size:** ~3,000 words | **Read time:** 10-15 minutes  
**Purpose:** Backend business logic, database operations, API endpoints
**Read this if:** Working on backend features, database changes, API modifications, business logic
**Skip this if:** Only doing frontend UI work

**Key takeaways:**
- **134 TypeScript files** across **6 major modules** (budget, db, transactions, api, accounts, sync)
- **Database-first development** - Start with `db/`, then business logic, then API
- **Functional programming** - No classes, service-like exported functions
- **C# analogy:** loot-core = Services Layer + Repository Pattern + Web API Controllers

---

## 📊 **Package Overview**
**loot-core** is the core business logic engine containing **134 TypeScript files** across **44 specialized modules**. This package acts as the **"Services Layer"** in traditional C# architecture.

## 🏗️ **Architecture Map**

### **Core Server Structure** (`packages/loot-core/src/server/`)
```
server/                           # Main business logic (134 TS files)
├── accounts/                    # 🏦 Account Management
│   ├── app.ts                  # Account CRUD operations (31K lines)
│   ├── sync.ts                 # Account synchronization (29K lines) 
│   ├── payees.ts               # Account-payee relationships
│   └── title/                  # Bank title processing
├── budget/                     # 💰 Budget Engine (19 files)
│   ├── actions.ts              # Budget manipulation actions
│   ├── app.ts                  # Core budget logic (13K lines)
│   ├── base.ts                 # Budget calculations (10K lines)
│   ├── envelope.ts             # Envelope budgeting logic
│   ├── goal-template.ts        # Goal templates & automation
│   ├── report.ts               # Budget reporting
│   └── category-template-context.ts # Category templating (23K lines)
├── transactions/               # 💳 Transaction Processing
│   ├── app.ts                  # Transaction CRUD
│   ├── index.ts                # Main transaction logic
│   ├── transaction-rules.ts    # Rules engine (25K lines)
│   ├── transfer.ts             # Transfer detection
│   ├── import/                 # Import subsystem
│   └── export/                 # Export subsystem
├── db/                         # 🗄️ Database Layer
│   ├── index.ts                # Main DB operations (23K lines)
│   ├── mappings.ts             # ORM-like mappings
│   ├── sort.ts                 # Query sorting
│   └── types/                  # Database type definitions
├── sync/                       # 🔄 Synchronization Engine
├── spreadsheet/                # 📊 Calculation Engine
├── reports/                    # 📈 Reporting System
├── api.ts                      # 🌐 API Endpoints (20K lines)
└── main.ts                     # 🚀 Server Bootstrap (7K lines)
```

## 🎯 **Domain-Specific Modules**

### **1. Budget Engine** (`server/budget/`)
**Purpose:** Core budgeting calculations and envelope budgeting logic

**Key Files:**
- `app.ts` (13,922 lines) - Main budget operations
- `base.ts` (10,210 lines) - Budget calculations & math
- `category-template-context.ts` (23,243 lines) - Category template system
- `envelope.ts` (12,080 lines) - Envelope budgeting implementation
- `goal-template.ts` - Goal-based budgeting automation

**C# Analogy:** Like a `BudgetService` with complex calculation logic

**Development Relevance:** ⭐⭐⭐ **HIGH** - Core budgeting business logic and calculations

### **2. Database Layer** (`server/db/`)
**Purpose:** Data access and persistence layer

**Key Files:**
- `index.ts` (23,273 lines) - Main database operations
- `types/` - Database schema definitions
- `mappings.ts` - Data transformation layer

**C# Analogy:** Combination of Entity Framework DbContext + Repository pattern

**Development Relevance:** ⭐⭐⭐ **HIGH** - All data persistence and schema management

### **3. Accounts Management** (`server/accounts/`)
**Purpose:** Bank account operations and synchronization

**Key Files:**
- `app.ts` (31,314 lines) - Account CRUD and business logic
- `sync.ts` (29,721 lines) - Bank synchronization
- `payees.ts` - Payee management

**C# Analogy:** `AccountService` + `BankSyncService`

**Development Relevance:** ⭐⭐ **MEDIUM** - Bank integration and account management features

### **4. Transaction Processing** (`server/transactions/`)
**Purpose:** Transaction management, rules, and categorization

**Key Files:**
- `transaction-rules.ts` (25,742 lines) - Automated transaction rules
- `app.ts` - Transaction CRUD operations  
- `index.ts` - Core transaction logic
- `import/` - Transaction import system

**C# Analogy:** `TransactionService` + `RulesEngine`

**Development Relevance:** ⭐⭐⭐ **HIGH** - Transaction rules, categorization, and import/export

### **5. API Layer** (`server/api.ts`)
**Purpose:** REST API endpoints and external interface

**Details:**
- **20,668 lines** of API definitions
- RESTful endpoints for all major operations
- Input validation and serialization

**C# Analogy:** Web API Controllers consolidated into single file

**Development Relevance:** ⭐⭐⭐ **HIGH** - External API interface for all operations

### **6. Synchronization** (`server/sync/`)
**Purpose:** Multi-device data synchronization

**Features:**
- CRDT-based conflict resolution
- End-to-end encryption
- Real-time updates

**Development Relevance:** ⭐⭐⭐ **HIGH** - Critical for multi-device functionality

## 🔧 **Technical Architecture Patterns**

### **1. Domain-Driven Design**
- Each folder represents a bounded context
- Clear separation of concerns
- Rich domain models

### **2. Repository Pattern** (Database Layer)
```typescript
// db/index.ts acts like repository
export function getCategories() { /* ... */ }
export function updateCategory(id, changes) { /* ... */ }
export function deleteCategory(id) { /* ... */ }
```

### **3. Service Layer Pattern**
```typescript
// Each module exports service-like functions
export async function createBudget(data) { /* ... */ }
export async function calculateBudgetSummary() { /* ... */ }
```

### **4. Rules Engine** (Transactions)
- Pattern matching system
- Automated categorization
- Conditional logic processing

## 📈 **Module Complexity Analysis**

| Module | Lines of Code | Complexity | Business Impact | Development Focus |
|--------|---------------|------------|-----------------|------------------|
| **budget/** | ~60,000 | 🔴 Very High | Critical | Core budgeting logic |
| **db/** | ~25,000 | 🔴 High | Critical | Data persistence |
| **accounts/** | ~45,000 | 🟡 Medium | High | Bank integration |
| **transactions/** | ~35,000 | 🟡 Medium | High | Transaction processing |
| **api.ts** | ~20,000 | 🟡 Medium | High | External interface |
| **sync/** | ~15,000 | 🔴 High | Medium | Multi-device sync |

## 🎯 **General Development Approach**

### **For New Features:**
1. **Database First** - Schema changes in `db/`
2. **Business Logic** - Core logic in relevant domain modules
3. **API Updates** - Endpoints in `api.ts` 
4. **Testing** - Unit and integration tests

## 🔍 **Key Integration Points**

### **Database → Budget**
```typescript
// db/index.ts provides data
const categories = getCategories();

// budget/app.ts processes it  
const budgetData = calculateBudget(categories);
```

### **API → Services**
```typescript
// api.ts receives requests
app.post('/categories', (req, res) => {
  // Calls service layer
  const result = await createCategory(req.body);
});
```

### **Budget ← Transactions**
```typescript
// Transactions affect budget calculations
const spending = getSpendingByCategory(categoryId);
const budgetStatus = calculateBudgetStatus(spending);
```

## 🚀 **Development Workflow**

### **For New Features:**

**1. Database Schema** (`db/index.ts`)
- Add/modify schema via migrations
- Update core queries
- Test data integrity

**2. Business Logic** (`budget/`, `transactions/`, etc.)
- Implement core functionality
- Update calculations/processing
- Maintain business rule consistency

**3. API Interface** (`api.ts`)
- Add new endpoints
- Update existing endpoints
- Ensure proper validation

**4. Integration Testing**
- Run existing test suites
- Add feature-specific tests
- Verify no regressions

## 💡 **Development Tips**

### **C# Developer Guidance:**
- **No classes** - Everything is functional/modular
- **Async/await** - Similar to C# async patterns
- **Modules** - Like C# namespaces but file-based
- **Interfaces** - Similar to C# interfaces but structural typing

### **Testing Strategy:**
- Each module has `__snapshots__/` for snapshot testing
- `.test.ts` files for unit tests
- Integration tests in `tests/` directory

### **Code Navigation:**
```bash
# Find budget-related functions
rg "budget.*function" packages/loot-core/src/server --type ts

# Find database operations  
rg "export.*function" packages/loot-core/src/server/db --type ts

# Find API endpoints
rg "handlers\[" packages/loot-core/src/server/api.ts
```

---

## 📋 **Summary**
**loot-core** is a sophisticated business logic engine with clear domain separation. The functional programming approach and TypeScript interfaces make it similar to modern C# development patterns but with more emphasis on immutability and functional composition. Key development areas are **budget/** and **db/** for core functionality, **api.ts** for external interfaces, and **transactions/** for data processing.