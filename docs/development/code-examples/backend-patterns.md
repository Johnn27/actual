# Backend Code Patterns (loot-core)
## 🧠 Copy-Paste Ready Examples from Actual Codebase

## ⚡ **Quick Reference**
**Purpose:** Backend patterns for loot-core development  
**Source:** Real code patterns from packages/loot-core/src/server/
**Use case:** Building API endpoints, database operations, business logic

---

## 🌐 **API Handler Patterns**

### **Basic API Handler**
```typescript
// Pattern from: packages/loot-core/src/server/api.ts
handlers['api/load-budget'] = async function ({ id }) {
  const { error } = await handlers['load-budget']({ id });
  if (error) {
    return { error };
  }
  return { data: budgetData };
};
```

### **Batch Operations Handler**
```typescript
// Pattern from: packages/loot-core/src/server/api.ts
handlers['api/batch-budget-start'] = async function () {
  return { success: true };
};

handlers['api/batch-budget-end'] = async function () {
  return { success: true };
};
```

### **Handler with Validation**
```typescript
// Pattern: API handler with input validation
handlers['api/create-category'] = async function ({ name, groupId, isIncome = false }) {
  // Input validation
  if (!name || !groupId) {
    return { error: 'Name and groupId are required' };
  }

  try {
    const category = await createCategory({
      name: name.trim(),
      cat_group: groupId,
      is_income: isIncome ? 1 : 0,
      sort_order: await getNextSortOrder(groupId)
    });
    
    return { data: category };
  } catch (error) {
    return { error: error.message };
  }
};
```

## 🗄️ **Database Operation Patterns**

### **Basic CRUD Operations**
```typescript
// Pattern from: packages/loot-core/src/server/db/
export function getCategories(): Promise<CategoryEntity[]> {
  return db.all('SELECT * FROM categories ORDER BY sort_order');
}

export function updateCategory(id: string, changes: Partial<CategoryEntity>) {
  return db.run('UPDATE categories SET ? WHERE id = ?', [changes, id]);
}

export function createCategory(data: Partial<CategoryEntity>) {
  const id = uuidv4();
  return db.run('INSERT INTO categories (id, ?) VALUES (?, ?)', [id, data]);
}

export function deleteCategory(id: string) {
  return db.run('DELETE FROM categories WHERE id = ?', [id]);
}
```

### **Complex Query with Joins**
```typescript
// Pattern: Multi-table query with aggregation
export async function getCategoryStats(categoryId: string) {
  return db.first(`
    SELECT 
      c.name,
      c.id,
      COUNT(t.id) as transaction_count,
      SUM(t.amount) as total_amount,
      AVG(t.amount) as avg_amount
    FROM categories c
    LEFT JOIN transactions t ON t.category = c.id
    WHERE c.id = ?
    GROUP BY c.id
  `, [categoryId]);
}
```

### **Batch Database Operations**
```typescript
// Pattern: Efficient batch operations
export async function updateMultipleCategories(updates: Array<{ id: string, changes: Partial<CategoryEntity> }>) {
  const statements = updates.map(({ id, changes }) => ({
    query: 'UPDATE categories SET ? WHERE id = ?',
    params: [changes, id]
  }));
  
  return db.transaction(() => {
    return Promise.all(statements.map(stmt => db.run(stmt.query, stmt.params)));
  });
}
```

## 💰 **Budget Calculation Patterns**

### **Monthly Budget Calculation**
```typescript
// Pattern: Budget math operations
export function calculateBudgetSummary(categories: CategoryEntity[], month: string) {
  return categories.reduce((summary, category) => {
    const budgeted = getBudgetedAmount(category.id, month);
    const spent = getSpentAmount(category.id, month);
    const available = budgeted - spent;
    
    return {
      budgeted: summary.budgeted + budgeted,
      spent: summary.spent + spent, 
      available: summary.available + available
    };
  }, { budgeted: 0, spent: 0, available: 0 });
}
```

### **Category Rollover Logic**
```typescript
// Pattern: Envelope budgeting calculations
export async function calculateCategoryBalance(categoryId: string, month: string) {
  const previousMonth = monthUtils.subMonths(month, 1);
  const previousBalance = await getCategoryBalance(categoryId, previousMonth);
  const currentBudget = await getBudgetedAmount(categoryId, month);
  const currentSpending = await getSpentAmount(categoryId, month);
  
  // Envelope budgeting: previous balance + new budget - spending
  return previousBalance + currentBudget - currentSpending;
}
```

## 🔧 **Utility Function Patterns**

### **Export Function Pattern**
```typescript
// Pattern from: packages/loot-core/src/server/util/budget-name.ts
export async function uniqueBudgetName(baseName: string): Promise<string> {
  const existing = await db.all('SELECT name FROM budgets WHERE name LIKE ?', [`${baseName}%`]);
  const existingNames = new Set(existing.map(b => b.name));
  
  if (!existingNames.has(baseName)) {
    return baseName;
  }
  
  let counter = 1;
  let uniqueName: string;
  do {
    uniqueName = `${baseName} ${counter}`;
    counter++;
  } while (existingNames.has(uniqueName));
  
  return uniqueName;
}

export async function validateBudgetName(name: string): Promise<{ valid: boolean; error?: string }> {
  if (!name || name.trim().length === 0) {
    return { valid: false, error: 'Budget name is required' };
  }
  
  if (name.length > 255) {
    return { valid: false, error: 'Budget name too long' };
  }
  
  const existing = await db.first('SELECT id FROM budgets WHERE name = ?', [name]);
  if (existing) {
    return { valid: false, error: 'Budget name already exists' };
  }
  
  return { valid: true };
}
```

### **Date/Time Utilities**
```typescript
// Pattern: Month handling utilities
import * as monthUtils from '../../shared/months';

export function getCurrentMonthBounds() {
  const currentMonth = monthUtils.currentMonth();
  return {
    start: monthUtils.getMonthStart(currentMonth),
    end: monthUtils.getMonthEnd(currentMonth)
  };
}

export function getDateRange(startMonth: string, endMonth: string) {
  const months = monthUtils.rangeInclusive(startMonth, endMonth);
  return {
    months,
    startDate: monthUtils.getMonthStart(startMonth),
    endDate: monthUtils.getMonthEnd(endMonth)
  };
}
```

## 🔄 **Error Handling Patterns**

### **Standard Error Response**
```typescript
// Pattern: Consistent error handling
export async function handleDatabaseOperation<T>(operation: () => Promise<T>): Promise<{ data?: T; error?: string }> {
  try {
    const data = await operation();
    return { data };
  } catch (error) {
    console.error('Database operation failed:', error);
    return { error: error.message || 'Unknown database error' };
  }
}

// Usage:
handlers['api/update-category'] = async function ({ id, changes }) {
  return handleDatabaseOperation(async () => {
    return await updateCategory(id, changes);
  });
};
```

### **Validation with Multiple Errors**
```typescript
// Pattern: Comprehensive validation
export function validateCategoryData(data: Partial<CategoryEntity>): { valid: boolean; errors: string[] } {
  const errors: string[] = [];
  
  if (!data.name || data.name.trim().length === 0) {
    errors.push('Category name is required');
  }
  
  if (data.name && data.name.length > 100) {
    errors.push('Category name too long (max 100 characters)');
  }
  
  if (!data.cat_group) {
    errors.push('Category group is required');
  }
  
  if (data.sort_order !== undefined && data.sort_order < 0) {
    errors.push('Sort order must be non-negative');
  }
  
  return {
    valid: errors.length === 0,
    errors
  };
}
```

## 📊 **Testing Patterns**

### **API Handler Test**
```typescript
// Pattern: Testing API handlers
describe('Category API', () => {
  beforeEach(async () => {
    await setupTestDatabase();
  });
  
  afterEach(async () => {
    await cleanupTestDatabase();
  });
  
  it('creates category successfully', async () => {
    const result = await handlers['api/create-category']({
      name: 'Test Category',
      groupId: 'group-1',
      isIncome: false
    });
    
    expect(result.error).toBeUndefined();
    expect(result.data).toMatchObject({
      name: 'Test Category',
      cat_group: 'group-1',
      is_income: 0
    });
  });
  
  it('validates required fields', async () => {
    const result = await handlers['api/create-category']({
      name: '',
      groupId: null
    });
    
    expect(result.error).toBe('Name and groupId are required');
  });
});
```

### **Database Operation Test**
```typescript
// Pattern: Database testing
describe('Category Database Operations', () => {
  it('gets categories in sort order', async () => {
    // Arrange
    await createCategory({ name: 'Category B', sort_order: 2 });
    await createCategory({ name: 'Category A', sort_order: 1 });
    
    // Act
    const categories = await getCategories();
    
    // Assert
    expect(categories).toHaveLength(2);
    expect(categories[0].name).toBe('Category A');
    expect(categories[1].name).toBe('Category B');
  });
});
```

## 🔍 **Common File Locations**

```bash
# API handlers
packages/loot-core/src/server/api.ts

# Database operations  
packages/loot-core/src/server/db/index.ts

# Business logic modules
packages/loot-core/src/server/budget/
packages/loot-core/src/server/accounts/
packages/loot-core/src/server/transactions/

# Utilities
packages/loot-core/src/server/util/
packages/loot-core/src/shared/

# Types
packages/loot-core/src/types/models.ts
packages/loot-core/src/types/handlers.ts
```

## 💡 **Development Tips**

### **C# Developer Notes:**
- **No classes** - Use exported functions instead of class methods
- **Async/await** - Similar to C# async patterns
- **Error handling** - Return `{ error }` objects instead of throwing
- **Database** - More like Dapper than Entity Framework
- **API handlers** - Similar to Web API action methods but functional

### **Common Patterns:**
- Always return `{ data }` or `{ error }` from handlers
- Use `uuidv4()` for generating IDs
- Prefer `db.transaction()` for multi-step operations
- Use type imports: `import { type CategoryEntity }`
- Include `@ts-strict-ignore` when needed for gradual TypeScript migration