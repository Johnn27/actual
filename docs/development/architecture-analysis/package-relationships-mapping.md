# Package Relationships & Integration Mapping
## 🔗 How Actual Budget's Architecture Connects

## ⚡ **TL;DR - Quick Context Overview**
**Size:** ~2,800 words | **Read time:** 10-14 minutes
**Purpose:** Cross-package integration patterns, data flow, API communication
**Read this if:** Building full-stack features, debugging integration issues, understanding data flow
**Skip this if:** Working entirely within a single package

**Key takeaways:**
- **Message-based API** - `send('action', data)` pattern between frontend ↔ backend
- **Layered architecture** - Frontend → Business Logic → Database → Sync
- **Integration testing strategy** - Database → API → Frontend → E2E
- **C# analogy:** Clean architecture with clear separation of concerns

---

## 📊 **High-Level Data Flow Architecture**

```
┌─────────────────┐    ┌──────────────────┐    ┌─────────────────┐
│  desktop-client │────│    loot-core     │────│   SQLite DB     │
│   (Frontend)    │    │  (Business Logic)│    │  (Data Store)   │
│                 │    │                  │    │                 │
│ • React UI      │ ⟸⟹ │ • API Layer     │ ⟸⟹ │ • Categories    │
│ • User Events   │    │ • Budget Engine  │    │ • Transactions  │
│ • State Mgmt    │    │ • Calculations   │    │ • Accounts      │
│ • Components    │    │ • Business Rules │    │ • Budget Data   │
└─────────────────┘    └──────────────────┘    └─────────────────┘
         ▲                       ▲                       ▲
         │                       │                       │
         ▼                       ▼                       ▼
┌─────────────────┐    ┌──────────────────┐    ┌─────────────────┐
│  sync-server    │    │      crdt        │    │       api       │
│ (Multi-device)  │    │ (Sync Protocol)  │    │ (External API)  │
└─────────────────┘    └──────────────────┘    └─────────────────┘
```

## 🎯 **Core Package Integration**

### **1. desktop-client ↔ loot-core** (Primary Integration)

#### **Data Flow Direction:**
```
Frontend Request → API Call → loot-core Processing → Database → Response → Frontend Update
```

#### **Key Integration Points:**
```typescript
// desktop-client queries data from loot-core
// packages/desktop-client/src/queries/
const categories = await send('get-categories'); // Calls loot-core API

// loot-core handles request  
// packages/loot-core/src/server/api.ts
handlers['get-categories'] = () => {
  return db.getCategories(); // Database query
};

// desktop-client renders result
// packages/desktop-client/src/components/budget/BudgetCategories.jsx
function BudgetCategories({ categories }) {
  return categories.map(cat => <Category key={cat.id} {...cat} />);
}
```

#### **Communication Protocol:**
- **Message-based API** - `send('action', data)` pattern
- **Real-time updates** - WebSocket-like updates
- **Optimistic UI** - Frontend updates before server confirmation

### **2. loot-core ↔ Database** (Data Persistence)

#### **Database Operations:**
```typescript
// loot-core/src/server/db/index.ts
export function getCategories() {
  return db.all('SELECT * FROM categories ORDER BY sort_order');
}

export function updateCategory(id, changes) {
  return db.run('UPDATE categories SET ? WHERE id = ?', [changes, id]);
}

export function createCategory(data) {
  return db.run('INSERT INTO categories (?) VALUES (?)', data);
}
```

#### **Schema Management:**
- **Migration system** - `loot-core/migrations/`
- **CRDT integration** - Change tracking for sync
- **Validation layer** - Business rule enforcement

### **3. loot-core ↔ sync-server** (Multi-device Sync)

#### **Synchronization Flow:**
```
Local Changes → CRDT Encoding → Encryption → sync-server → Other Devices
```

#### **Integration Pattern:**
```typescript
// Changes are tracked via CRDT
// loot-core/src/server/sync/
export function syncCategories() {
  const localChanges = getCRDTChanges('categories');
  const remoteChanges = await syncServer.push(localChanges);
  await applyCRDTChanges(remoteChanges);
}
```

## 🔄 **Sub-Categories Feature Integration Map**

### **Database Schema Changes** (loot-core/db/)
```sql
-- Current schema
CREATE TABLE categories (
  id TEXT PRIMARY KEY,
  name TEXT,
  is_income INTEGER,
  sort_order INTEGER
);

-- Sub-categories schema
CREATE TABLE categories (
  id TEXT PRIMARY KEY,
  name TEXT,
  is_income INTEGER,
  sort_order INTEGER,
  parent_id TEXT REFERENCES categories(id), -- NEW: Hierarchy support
  depth INTEGER DEFAULT 0,                  -- NEW: Depth tracking
  is_hidden INTEGER DEFAULT 0               -- NEW: Collapsed state
);
```

### **Business Logic Updates** (loot-core/server/)

#### **Budget Engine Changes:**
```typescript
// loot-core/src/server/budget/app.ts
function calculateBudgetWithHierarchy(categories) {
  // Group categories by parent
  const categoryTree = buildCategoryTree(categories);
  
  // Calculate parent totals from children
  return categoryTree.map(parent => ({
    ...parent,
    budgetAmount: sumChildBudgets(parent.children),
    actualAmount: sumChildActuals(parent.children)
  }));
}
```

#### **API Endpoint Extensions:**
```typescript
// loot-core/src/server/api.ts
handlers['get-categories-tree'] = () => {
  const categories = db.getCategories();
  return buildHierarchy(categories);
};

handlers['move-category'] = ({ categoryId, newParentId }) => {
  return db.updateCategory(categoryId, { parent_id: newParentId });
};
```

### **Frontend Component Updates** (desktop-client/components/)

#### **Budget Interface Changes:**
```tsx
// desktop-client/src/components/budget/ExpenseGroup.tsx
function ExpenseGroup({ group, depth = 0 }) {
  const [isExpanded, setIsExpanded] = useState(true);
  
  return (
    <div style={{ paddingLeft: depth * 20 }}>
      <div onClick={() => setIsExpanded(!isExpanded)}>
        {group.hasChildren && (
          <Icon name={isExpanded ? 'chevron-down' : 'chevron-right'} />
        )}
        {group.name}
      </div>
      {isExpanded && group.children?.map(child => 
        <ExpenseCategory key={child.id} category={child} depth={depth + 1} />
      )}
    </div>
  );
}
```

#### **State Management Changes:**
```typescript
// desktop-client/src/redux/categories.ts
interface CategoryState {
  items: Category[];
  tree: CategoryTree;        // NEW: Hierarchical structure
  expandedIds: Set<string>;  // NEW: UI state tracking
}

function categoryReducer(state, action) {
  switch (action.type) {
    case 'MOVE_CATEGORY':
      return moveInTree(state, action.categoryId, action.newParentId);
    case 'TOGGLE_CATEGORY':
      return toggleExpansion(state, action.categoryId);
  }
}
```

## 🚀 **Integration Testing Strategy**

### **1. Database Integration Tests**
```typescript
// Test hierarchy constraints
describe('Category Hierarchy', () => {
  it('prevents circular references', async () => {
    const parent = await createCategory({ name: 'Parent' });
    const child = await createCategory({ name: 'Child', parent_id: parent.id });
    
    // Should fail: can't make parent a child of its own child
    await expect(
      updateCategory(parent.id, { parent_id: child.id })
    ).rejects.toThrow('Circular reference');
  });
});
```

### **2. API Integration Tests**
```typescript
// Test category tree endpoints
describe('Category Tree API', () => {
  it('returns properly nested category tree', async () => {
    const response = await send('get-categories-tree');
    expect(response).toHaveProperty('tree');
    expect(response.tree[0].children).toBeDefined();
  });
});
```

### **3. Frontend Integration Tests**
```typescript
// Test component hierarchy
describe('Budget Category Display', () => {
  it('renders category hierarchy with proper indentation', () => {
    render(<BudgetCategories categories={mockHierarchy} />);
    
    expect(screen.getByText('Parent Category')).toBeInTheDocument();
    expect(screen.getByText('Child Category')).toHaveStyle({
      paddingLeft: '20px'
    });
  });
});
```

## 🔧 **Development Workflow Integration**

### **Cross-Package Development Process:**

#### **1. Schema-First Approach**
```bash
# 1. Update database schema
vim packages/loot-core/migrations/add-category-hierarchy.sql

# 2. Update TypeScript types
vim packages/loot-core/src/types/categories.ts

# 3. Test database operations
yarn workspace loot-core test db/categories
```

#### **2. API-Driven Development**
```bash
# 1. Add API endpoints
vim packages/loot-core/src/server/api.ts

# 2. Test API contracts
yarn workspace loot-core test api/categories

# 3. Update frontend queries
vim packages/desktop-client/src/queries/categories.ts
```

#### **3. Component-Last Implementation**
```bash
# 1. Update component props
vim packages/desktop-client/src/components/budget/ExpenseCategory.tsx

# 2. Test component rendering  
yarn workspace desktop-client test components/budget

# 3. Integration testing
yarn test --watch=false
```

## 📊 **Performance Integration Considerations**

### **Database Query Optimization:**
```typescript
// Efficient hierarchy queries
function getCategoryTree() {
  // Single query with recursive CTE
  return db.all(`
    WITH RECURSIVE category_tree AS (
      SELECT id, name, parent_id, 0 as depth 
      FROM categories WHERE parent_id IS NULL
      UNION ALL
      SELECT c.id, c.name, c.parent_id, ct.depth + 1
      FROM categories c
      JOIN category_tree ct ON c.parent_id = ct.id
    )
    SELECT * FROM category_tree ORDER BY depth, sort_order
  `);
}
```

### **Frontend Rendering Optimization:**
```tsx
// Virtualization for large category trees
import { FixedSizeList as List } from 'react-window';

function CategoryTree({ categories }) {
  return (
    <List height={600} itemCount={categories.length} itemSize={35}>
      {({ index, style }) => (
        <div style={style}>
          <CategoryRow category={categories[index]} />
        </div>
      )}
    </List>
  );
}
```

### **State Management Optimization:**
```typescript
// Normalized state structure
interface CategoryState {
  byId: Record<string, Category>;
  hierarchy: {
    roots: string[];
    children: Record<string, string[]>;
  };
  ui: {
    expanded: Set<string>;
  };
}
```

## 🔍 **Debugging Integration Points**

### **Cross-Package Debugging Commands:**
```bash
# Trace API calls from frontend to backend
rg "send.*categories" packages/desktop-client/src --type tsx

# Find database operations
rg "categories.*table" packages/loot-core/src/server/db --type ts

# Check CRDT integration
rg "categories.*sync" packages/loot-core/src/server/sync --type ts
```

### **Integration Logging:**
```typescript
// Add logging at integration boundaries
// Frontend → API
console.log('Frontend: Calling get-categories-tree');

// API → Database  
console.log('API: Querying category hierarchy');

// Database → CRDT
console.log('CRDT: Recording category change');
```

---

## 📋 **Summary**

The **package relationships** in Actual Budget follow a clean **layered architecture**:

**Presentation** (`desktop-client`) → **Business Logic** (`loot-core`) → **Data** (`SQLite`) → **Sync** (`crdt` + `sync-server`)

For **sub-categories implementation**:
1. **Start with database schema** in `loot-core/migrations/`
2. **Update business logic** in `loot-core/server/budget/` and `loot-core/server/api.ts`  
3. **Modify frontend components** in `desktop-client/components/budget/`
4. **Test integration** across all layers

The **message-based communication** between packages provides clean separation while the **CRDT synchronization** ensures data consistency across devices.