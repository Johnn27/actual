# Integration Patterns (Frontend ↔ Backend)
## 🔗 Cross-Package Communication Examples

## ⚡ **Quick Reference**
**Purpose:** Frontend-backend integration patterns  
**Source:** Real communication patterns between desktop-client ↔ loot-core
**Use case:** Building full-stack features, API calls, data flow

---

## 📡 **API Communication Patterns**

### **Basic Frontend → Backend Call**
```tsx
// Frontend (desktop-client)
import { send } from 'loot-core/src/platform/client/fetch';

// Simple data fetch
const fetchCategories = async () => {
  try {
    const result = await send('get-categories');
    if (result.error) {
      console.error('Failed to fetch categories:', result.error);
      return [];
    }
    return result.data;
  } catch (error) {
    console.error('Network error:', error);
    return [];
  }
};

// Backend handler (loot-core)
handlers['get-categories'] = async function () {
  try {
    const categories = await db.all('SELECT * FROM categories ORDER BY sort_order');
    return { data: categories };
  } catch (error) {
    return { error: error.message };
  }
};
```

### **CRUD Operations Pattern**
```tsx
// Frontend: Complete CRUD operations
class CategoryService {
  static async getAll() {
    return await send('get-categories');
  }

  static async create(categoryData) {
    return await send('create-category', categoryData);
  }

  static async update(id, changes) {
    return await send('update-category', { id, changes });
  }

  static async delete(id) {
    return await send('delete-category', { id });
  }

  static async reorder(categoryIds) {
    return await send('reorder-categories', { categoryIds });
  }
}

// Backend: Corresponding handlers
handlers['get-categories'] = async function () {
  const categories = await getCategories();
  return { data: categories };
};

handlers['create-category'] = async function ({ name, groupId, isIncome = false }) {
  if (!name || !groupId) {
    return { error: 'Name and groupId are required' };
  }
  
  const category = await createCategory({
    name: name.trim(),
    cat_group: groupId,
    is_income: isIncome ? 1 : 0,
  });
  
  return { data: category };
};

handlers['update-category'] = async function ({ id, changes }) {
  await updateCategory(id, changes);
  return { success: true };
};

handlers['delete-category'] = async function ({ id }) {
  await deleteCategory(id);
  return { success: true };
};

handlers['reorder-categories'] = async function ({ categoryIds }) {
  // Batch update sort orders
  const updates = categoryIds.map((id, index) => ({
    id,
    changes: { sort_order: index }
  }));
  
  await updateMultipleCategories(updates);
  return { success: true };
};
```

### **Real-time Updates Pattern**
```tsx
// Frontend: Listen for real-time updates
import { listen } from 'loot-core/src/platform/client/fetch';

export const useLiveCategories = () => {
  const [categories, setCategories] = useState([]);

  useEffect(() => {
    // Initial load
    const loadCategories = async () => {
      const result = await send('get-categories');
      setCategories(result.data || []);
    };
    loadCategories();

    // Listen for real-time updates
    const unsubscribe = listen('categories-updated', (updatedCategories) => {
      setCategories(updatedCategories);
    });

    return unsubscribe;
  }, []);

  return categories;
};

// Backend: Emit updates to frontend
handlers['update-category'] = async function ({ id, changes }) {
  await updateCategory(id, changes);
  
  // Notify all clients of the update
  const updatedCategories = await getCategories();
  emit('categories-updated', updatedCategories);
  
  return { success: true };
};
```

## 🔄 **Data Flow Patterns**

### **Optimistic Updates**
```tsx
// Frontend: Optimistic UI updates
export const useOptimisticCategories = () => {
  const [categories, setCategories] = useState([]);
  const [pendingUpdates, setPendingUpdates] = useState(new Set());

  const updateCategoryOptimistic = async (id, changes) => {
    // Immediate UI update
    setCategories(prev => 
      prev.map(cat => cat.id === id ? { ...cat, ...changes } : cat)
    );
    
    // Track pending update
    setPendingUpdates(prev => new Set([...prev, id]));

    try {
      // Background API call
      const result = await send('update-category', { id, changes });
      
      if (result.error) {
        // Revert on error
        const original = await send('get-category', { id });
        setCategories(prev =>
          prev.map(cat => cat.id === id ? original.data : cat)
        );
        throw new Error(result.error);
      }
    } finally {
      // Remove from pending
      setPendingUpdates(prev => {
        const next = new Set(prev);
        next.delete(id);
        return next;
      });
    }
  };

  return {
    categories,
    updateCategory: updateCategoryOptimistic,
    pendingUpdates,
  };
};
```

### **Batch Operations Pattern**
```tsx
// Frontend: Batch multiple operations
export const useBatchCategoryOperations = () => {
  const [batchQueue, setBatchQueue] = useState([]);
  const [isBatching, setIsBatching] = useState(false);

  const startBatch = () => {
    setIsBatching(true);
    setBatchQueue([]);
  };

  const queueOperation = (operation) => {
    if (isBatching) {
      setBatchQueue(prev => [...prev, operation]);
    } else {
      // Execute immediately if not batching
      return executeOperation(operation);
    }
  };

  const commitBatch = async () => {
    if (batchQueue.length === 0) return;

    try {
      const result = await send('batch-category-operations', {
        operations: batchQueue
      });
      
      if (result.error) {
        throw new Error(result.error);
      }
      
      return result.data;
    } finally {
      setBatchQueue([]);
      setIsBatching(false);
    }
  };

  return {
    startBatch,
    queueOperation,
    commitBatch,
    batchQueue,
    isBatching,
  };
};

// Backend: Process batch operations
handlers['batch-category-operations'] = async function ({ operations }) {
  return db.transaction(async () => {
    const results = [];
    
    for (const operation of operations) {
      switch (operation.type) {
        case 'create':
          results.push(await createCategory(operation.data));
          break;
        case 'update':
          results.push(await updateCategory(operation.id, operation.changes));
          break;
        case 'delete':
          results.push(await deleteCategory(operation.id));
          break;
      }
    }
    
    return { data: results };
  });
};
```

## 📊 **State Synchronization Patterns**

### **Redux + API Integration**
```tsx
// Frontend: Redux thunks for API integration
import { createAsyncThunk, createSlice } from '@reduxjs/toolkit';

// Async thunks
export const fetchCategories = createAsyncThunk(
  'categories/fetchCategories',
  async (_, { rejectWithValue }) => {
    try {
      const result = await send('get-categories');
      if (result.error) {
        return rejectWithValue(result.error);
      }
      return result.data;
    } catch (error) {
      return rejectWithValue(error.message);
    }
  }
);

export const updateCategory = createAsyncThunk(
  'categories/updateCategory',
  async ({ id, changes }, { rejectWithValue }) => {
    try {
      const result = await send('update-category', { id, changes });
      if (result.error) {
        return rejectWithValue(result.error);
      }
      return { id, changes };
    } catch (error) {
      return rejectWithValue(error.message);
    }
  }
);

// Slice
const categoriesSlice = createSlice({
  name: 'categories',
  initialState: {
    items: [],
    loading: false,
    error: null,
  },
  reducers: {
    // Optimistic updates
    updateCategoryOptimistic: (state, action) => {
      const { id, changes } = action.payload;
      const category = state.items.find(cat => cat.id === id);
      if (category) {
        Object.assign(category, changes);
      }
    },
  },
  extraReducers: (builder) => {
    builder
      .addCase(fetchCategories.pending, (state) => {
        state.loading = true;
        state.error = null;
      })
      .addCase(fetchCategories.fulfilled, (state, action) => {
        state.items = action.payload;
        state.loading = false;
      })
      .addCase(fetchCategories.rejected, (state, action) => {
        state.error = action.payload;
        state.loading = false;
      })
      .addCase(updateCategory.fulfilled, (state, action) => {
        const { id, changes } = action.payload;
        const category = state.items.find(cat => cat.id === id);
        if (category) {
          Object.assign(category, changes);
        }
      });
  },
});

// Component usage
export const CategoryList = () => {
  const dispatch = useDispatch();
  const { items: categories, loading, error } = useSelector(state => state.categories);

  useEffect(() => {
    dispatch(fetchCategories());
  }, [dispatch]);

  const handleUpdateCategory = (id, changes) => {
    // Optimistic update
    dispatch(updateCategoryOptimistic({ id, changes }));
    // API call
    dispatch(updateCategory({ id, changes }));
  };

  if (loading) return <Loading />;
  if (error) return <Error message={error} />;

  return (
    <div>
      {categories.map(category => (
        <CategoryItem
          key={category.id}
          category={category}
          onUpdate={handleUpdateCategory}
        />
      ))}
    </div>
  );
};
```

### **CRDT Integration Pattern**
```tsx
// Frontend: CRDT-aware updates
export const useCRDTCategories = () => {
  const [categories, setCategories] = useState([]);
  const [lastSyncTime, setLastSyncTime] = useState(null);

  const updateCategoryWithCRDT = async (id, changes) => {
    // Include timestamp for CRDT
    const timestamp = Date.now();
    const update = {
      id,
      changes: {
        ...changes,
        _timestamp: timestamp,
        _clientId: getClientId(),
      }
    };

    // Optimistic update
    setCategories(prev =>
      prev.map(cat =>
        cat.id === id ? { ...cat, ...changes } : cat
      )
    );

    // Send to backend with CRDT metadata
    const result = await send('update-category-crdt', update);
    
    if (result.conflict) {
      // Handle CRDT conflict resolution
      const resolved = await send('resolve-category-conflict', {
        id,
        clientUpdate: update,
        serverState: result.serverState
      });
      
      setCategories(prev =>
        prev.map(cat =>
          cat.id === id ? resolved.data : cat
        )
      );
    }
  };

  return {
    categories,
    updateCategory: updateCategoryWithCRDT,
    lastSyncTime,
  };
};

// Backend: CRDT conflict resolution
handlers['update-category-crdt'] = async function ({ id, changes }) {
  const current = await getCategory(id);
  
  // Check for conflicts based on timestamps
  if (current._timestamp > changes._timestamp) {
    return {
      conflict: true,
      serverState: current
    };
  }

  // Apply update with CRDT timestamp
  await updateCategory(id, changes);
  
  // Broadcast to other clients
  broadcastUpdate('category-updated', { id, changes });
  
  return { success: true };
};
```

## 🧪 **Testing Integration Patterns**

### **Frontend-Backend Integration Tests**
```tsx
// Test: Full integration flow
import { render, screen, fireEvent, waitFor } from '@testing-library/react';
import { setupServer } from 'msw/node';
import { rest } from 'msw';
import { CategoryManager } from '../CategoryManager';

// Mock server for backend API
const server = setupServer(
  rest.post('/api/get-categories', (req, res, ctx) => {
    return res(ctx.json({
      data: [
        { id: '1', name: 'Groceries', cat_group: 'group-1' },
        { id: '2', name: 'Gas', cat_group: 'group-1' }
      ]
    }));
  }),
  
  rest.post('/api/update-category', async (req, res, ctx) => {
    const { id, changes } = await req.json();
    return res(ctx.json({ success: true }));
  })
);

beforeAll(() => server.listen());
afterEach(() => server.resetHandlers());
afterAll(() => server.close());

describe('Category Integration', () => {
  it('loads and updates categories', async () => {
    render(<CategoryManager />);
    
    // Wait for initial load
    await waitFor(() => {
      expect(screen.getByText('Groceries')).toBeInTheDocument();
    });
    
    // Test update
    fireEvent.click(screen.getByText('Edit'));
    fireEvent.change(screen.getByDisplayValue('Groceries'), {
      target: { value: 'Food Shopping' }
    });
    fireEvent.click(screen.getByText('Save'));
    
    // Verify optimistic update
    expect(screen.getByText('Food Shopping')).toBeInTheDocument();
    
    // Verify API call was made
    await waitFor(() => {
      // API mock should have been called
    });
  });
});
```

### **API Handler Testing**
```tsx
// Backend: Test API handlers with database
describe('Category API Handlers', () => {
  beforeEach(async () => {
    await setupTestDatabase();
  });

  afterEach(async () => {
    await cleanupTestDatabase();
  });

  it('creates category with proper validation', async () => {
    const handler = handlers['create-category'];
    
    // Test successful creation
    const result = await handler({
      name: 'Test Category',
      groupId: 'group-1',
      isIncome: false
    });
    
    expect(result.data).toMatchObject({
      name: 'Test Category',
      cat_group: 'group-1',
      is_income: 0
    });
    
    // Verify database state
    const categories = await getCategories();
    expect(categories).toHaveLength(1);
    expect(categories[0].name).toBe('Test Category');
  });

  it('validates required fields', async () => {
    const handler = handlers['create-category'];
    
    const result = await handler({
      name: '',
      groupId: null
    });
    
    expect(result.error).toBe('Name and groupId are required');
  });
});
```

## 🔍 **Common Integration Files**

```bash
# Frontend API calls
packages/desktop-client/src/queries/
packages/desktop-client/src/hooks/use*.ts

# Backend API handlers  
packages/loot-core/src/server/api.ts

# Shared types
packages/loot-core/src/types/models.ts
packages/loot-core/src/types/handlers.ts

# Platform abstraction
packages/loot-core/src/platform/client/fetch/
```

## 💡 **Integration Best Practices**

### **Error Handling:**
- Always return `{ data }` or `{ error }` from backend
- Handle network errors in frontend gracefully
- Provide user-friendly error messages
- Log detailed errors for debugging

### **Performance:**
- Use optimistic updates for better UX
- Batch operations when possible  
- Implement proper loading states
- Cache frequently accessed data

### **Type Safety:**
- Share TypeScript interfaces between frontend/backend
- Validate API inputs and outputs
- Use type-safe API client wrappers

### **Testing:**
- Mock backend APIs for frontend tests
- Test API handlers with real database
- Write integration tests for critical flows
- Use MSW for realistic API mocking