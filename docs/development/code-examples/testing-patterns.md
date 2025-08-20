# Testing Patterns
## 🧪 Copy-Paste Ready Test Examples from Actual Codebase

## ⚡ **Quick Reference**
**Purpose:** Testing patterns for both frontend and backend  
**Source:** Real test patterns from Actual Budget codebase
**Use case:** Writing unit tests, integration tests, component tests

---

## ⚛️ **React Component Testing**

### **Basic Component Test**
```tsx
// Pattern: Testing component rendering and props
import React from 'react';
import { render, screen, fireEvent } from '@testing-library/react';
import { ExpenseCategory } from '../ExpenseCategory';

describe('ExpenseCategory', () => {
  const defaultProps = {
    categoryId: 'cat-1',
    name: 'Test Category',
    budgetAmount: 100,
    actualAmount: 50,
    isIncome: false,
    onEdit: jest.fn(),
    onShowActivity: jest.fn(),
  };

  beforeEach(() => {
    jest.clearAllMocks();
  });

  it('renders category information correctly', () => {
    render(<ExpenseCategory {...defaultProps} />);
    
    expect(screen.getByText('Test Category')).toBeInTheDocument();
    expect(screen.getByText('100')).toBeInTheDocument();
    expect(screen.getByText('50')).toBeInTheDocument();
  });

  it('calls onShowActivity when category name is clicked', () => {
    render(<ExpenseCategory {...defaultProps} />);
    
    fireEvent.click(screen.getByText('Test Category'));
    
    expect(defaultProps.onShowActivity).toHaveBeenCalledWith('cat-1');
    expect(defaultProps.onShowActivity).toHaveBeenCalledTimes(1);
  });

  it('calls onEdit when edit button is clicked', () => {
    render(<ExpenseCategory {...defaultProps} />);
    
    const editButton = screen.getByRole('button', { name: /edit/i });
    fireEvent.click(editButton);
    
    expect(defaultProps.onEdit).toHaveBeenCalledWith('cat-1');
  });

  it('stops event propagation on edit button click', () => {
    render(<ExpenseCategory {...defaultProps} />);
    
    const editButton = screen.getByRole('button', { name: /edit/i });
    fireEvent.click(editButton);
    
    // onEdit should be called but onShowActivity should not
    expect(defaultProps.onEdit).toHaveBeenCalled();
    expect(defaultProps.onShowActivity).not.toHaveBeenCalled();
  });
});
```

### **Component with State Testing**
```tsx
// Pattern: Testing component state changes
import React from 'react';
import { render, screen, fireEvent, waitFor } from '@testing-library/react';
import { BudgetGroup } from '../BudgetGroup';

// Mock the useLocalPref hook
jest.mock('@desktop-client/hooks/useLocalPref');
const mockUseLocalPref = useLocalPref as jest.MockedFunction<typeof useLocalPref>;

describe('BudgetGroup', () => {
  const mockCategories = [
    { id: 'cat-1', name: 'Category 1' },
    { id: 'cat-2', name: 'Category 2' },
  ];

  const defaultProps = {
    groupId: 'group-1',
    groupName: 'Test Group',
    categories: mockCategories,
    onCollapse: jest.fn(),
  };

  beforeEach(() => {
    jest.clearAllMocks();
    mockUseLocalPref.mockReturnValue([[], jest.fn()]);
  });

  it('shows categories when expanded', () => {
    render(<BudgetGroup {...defaultProps} />);
    
    expect(screen.getByText('Category 1')).toBeInTheDocument();
    expect(screen.getByText('Category 2')).toBeInTheDocument();
  });

  it('hides categories when collapsed', () => {
    // Mock collapsed state
    mockUseLocalPref.mockReturnValue([['group-1'], jest.fn()]);
    
    render(<BudgetGroup {...defaultProps} />);
    
    expect(screen.queryByText('Category 1')).not.toBeInTheDocument();
    expect(screen.queryByText('Category 2')).not.toBeInTheDocument();
  });

  it('toggles expansion when header is clicked', async () => {
    render(<BudgetGroup {...defaultProps} />);
    
    const header = screen.getByRole('button', { name: /test group/i });
    fireEvent.click(header);
    
    await waitFor(() => {
      expect(defaultProps.onCollapse).toHaveBeenCalledWith('group-1', true);
    });
  });
});
```

### **Component with Async Data Testing**
```tsx
// Pattern: Testing components with async data loading
import React from 'react';
import { render, screen, waitFor } from '@testing-library/react';
import { CategoryManager } from '../CategoryManager';

// Mock the API calls
jest.mock('loot-core/src/platform/client/fetch');
const mockSend = send as jest.MockedFunction<typeof send>;

describe('CategoryManager', () => {
  beforeEach(() => {
    jest.clearAllMocks();
  });

  it('shows loading state initially', () => {
    mockSend.mockImplementation(() => new Promise(() => {})); // Never resolves
    
    render(<CategoryManager />);
    
    expect(screen.getByText(/loading/i)).toBeInTheDocument();
  });

  it('displays categories after successful load', async () => {
    mockSend.mockResolvedValue({
      data: [
        { id: '1', name: 'Groceries' },
        { id: '2', name: 'Gas' }
      ]
    });
    
    render(<CategoryManager />);
    
    await waitFor(() => {
      expect(screen.getByText('Groceries')).toBeInTheDocument();
      expect(screen.getByText('Gas')).toBeInTheDocument();
    });
    
    expect(screen.queryByText(/loading/i)).not.toBeInTheDocument();
  });

  it('displays error message on failed load', async () => {
    mockSend.mockResolvedValue({
      error: 'Failed to load categories'
    });
    
    render(<CategoryManager />);
    
    await waitFor(() => {
      expect(screen.getByText(/failed to load categories/i)).toBeInTheDocument();
    });
  });

  it('retries loading on retry button click', async () => {
    // First call fails
    mockSend.mockResolvedValueOnce({
      error: 'Network error'
    });
    
    // Second call succeeds
    mockSend.mockResolvedValueOnce({
      data: [{ id: '1', name: 'Test Category' }]
    });
    
    render(<CategoryManager />);
    
    // Wait for error state
    await waitFor(() => {
      expect(screen.getByText(/network error/i)).toBeInTheDocument();
    });
    
    // Click retry
    fireEvent.click(screen.getByRole('button', { name: /retry/i }));
    
    // Wait for success
    await waitFor(() => {
      expect(screen.getByText('Test Category')).toBeInTheDocument();
    });
    
    expect(mockSend).toHaveBeenCalledTimes(2);
  });
});
```

## 🎣 **Custom Hook Testing**

### **Data Fetching Hook Test**
```tsx
// Pattern: Testing custom hooks with async operations
import { renderHook, waitFor, act } from '@testing-library/react';
import { useCategories } from '../hooks/useCategories';

jest.mock('loot-core/src/platform/client/fetch');
const mockSend = send as jest.MockedFunction<typeof send>;

describe('useCategories', () => {
  beforeEach(() => {
    jest.clearAllMocks();
  });

  it('loads categories on mount', async () => {
    const mockCategories = [
      { id: '1', name: 'Category 1' },
      { id: '2', name: 'Category 2' }
    ];
    
    mockSend.mockResolvedValue({ data: mockCategories });
    
    const { result } = renderHook(() => useCategories());
    
    // Initially loading
    expect(result.current.loading).toBe(true);
    expect(result.current.categories).toEqual([]);
    expect(result.current.error).toBeNull();
    
    // After load completes
    await waitFor(() => {
      expect(result.current.loading).toBe(false);
    });
    
    expect(result.current.categories).toEqual(mockCategories);
    expect(result.current.error).toBeNull();
  });

  it('handles loading errors', async () => {
    mockSend.mockResolvedValue({ error: 'Loading failed' });
    
    const { result } = renderHook(() => useCategories());
    
    await waitFor(() => {
      expect(result.current.loading).toBe(false);
    });
    
    expect(result.current.categories).toEqual([]);
    expect(result.current.error).toBe('Loading failed');
  });

  it('refetches data when refetch is called', async () => {
    mockSend.mockResolvedValue({ data: [{ id: '1', name: 'Initial' }] });
    
    const { result } = renderHook(() => useCategories());
    
    await waitFor(() => {
      expect(result.current.categories).toHaveLength(1);
    });
    
    // Change mock response
    mockSend.mockResolvedValue({ data: [{ id: '2', name: 'Updated' }] });
    
    // Call refetch
    act(() => {
      result.current.refetch();
    });
    
    await waitFor(() => {
      expect(result.current.categories[0].name).toBe('Updated');
    });
    
    expect(mockSend).toHaveBeenCalledTimes(2);
  });
});
```

### **Form Hook Testing**
```tsx
// Pattern: Testing form management hooks
import { renderHook, act } from '@testing-library/react';
import { useCategoryForm } from '../hooks/useCategoryForm';

describe('useCategoryForm', () => {
  it('initializes with default values', () => {
    const { result } = renderHook(() => useCategoryForm());
    
    expect(result.current.data).toEqual({
      name: '',
      groupId: null,
      isIncome: false
    });
    expect(result.current.errors).toEqual({});
    expect(result.current.isDirty).toBe(false);
  });

  it('updates field values and marks as dirty', () => {
    const { result } = renderHook(() => useCategoryForm());
    
    act(() => {
      result.current.setValue('name', 'New Category');
    });
    
    expect(result.current.data.name).toBe('New Category');
    expect(result.current.isDirty).toBe(true);
  });

  it('validates required fields', () => {
    const { result } = renderHook(() => useCategoryForm());
    
    let isValid;
    act(() => {
      isValid = result.current.validate();
    });
    
    expect(isValid).toBe(false);
    expect(result.current.errors).toEqual({
      name: 'Name is required',
      groupId: 'Group is required'
    });
  });

  it('clears field errors when value is updated', () => {
    const { result } = renderHook(() => useCategoryForm());
    
    // Set initial error state
    act(() => {
      result.current.validate();
    });
    
    expect(result.current.errors.name).toBe('Name is required');
    
    // Update field
    act(() => {
      result.current.setValue('name', 'Valid Name');
    });
    
    expect(result.current.errors.name).toBeUndefined();
    expect(result.current.errors.groupId).toBe('Group is required'); // Other errors remain
  });

  it('resets form to initial state', () => {
    const initialData = { name: 'Initial', groupId: 'group-1', isIncome: true };
    const { result } = renderHook(() => useCategoryForm(initialData));
    
    // Make changes
    act(() => {
      result.current.setValue('name', 'Changed');
    });
    
    expect(result.current.data.name).toBe('Changed');
    expect(result.current.isDirty).toBe(true);
    
    // Reset
    act(() => {
      result.current.reset();
    });
    
    expect(result.current.data).toEqual(initialData);
    expect(result.current.isDirty).toBe(false);
    expect(result.current.errors).toEqual({});
  });
});
```

## 🗄️ **Backend API Testing**

### **API Handler Testing**
```tsx
// Pattern: Testing backend API handlers
import { handlers } from '../api';
import { setupTestDatabase, cleanupTestDatabase } from '../test-helpers';

describe('Category API Handlers', () => {
  beforeEach(async () => {
    await setupTestDatabase();
  });

  afterEach(async () => {
    await cleanupTestDatabase();
  });

  describe('get-categories', () => {
    it('returns categories in sort order', async () => {
      // Setup test data
      await createCategory({ name: 'Category B', sort_order: 2 });
      await createCategory({ name: 'Category A', sort_order: 1 });
      
      const handler = handlers['get-categories'];
      const result = await handler();
      
      expect(result.data).toHaveLength(2);
      expect(result.data[0].name).toBe('Category A');
      expect(result.data[1].name).toBe('Category B');
    });

    it('handles database errors gracefully', async () => {
      // Mock database error
      jest.spyOn(db, 'all').mockRejectedValue(new Error('Database connection failed'));
      
      const handler = handlers['get-categories'];
      const result = await handler();
      
      expect(result.error).toBe('Database connection failed');
      expect(result.data).toBeUndefined();
    });
  });

  describe('create-category', () => {
    it('creates category with valid data', async () => {
      const handler = handlers['create-category'];
      const result = await handler({
        name: 'New Category',
        groupId: 'group-1',
        isIncome: false
      });
      
      expect(result.data).toMatchObject({
        name: 'New Category',
        cat_group: 'group-1',
        is_income: 0
      });
      expect(result.data.id).toBeDefined();
      
      // Verify in database
      const categories = await getCategories();
      expect(categories).toHaveLength(1);
      expect(categories[0].name).toBe('New Category');
    });

    it('validates required fields', async () => {
      const handler = handlers['create-category'];
      
      const result = await handler({
        name: '',
        groupId: null
      });
      
      expect(result.error).toBe('Name and groupId are required');
      expect(result.data).toBeUndefined();
    });

    it('trims category name', async () => {
      const handler = handlers['create-category'];
      const result = await handler({
        name: '  Spaced Category  ',
        groupId: 'group-1'
      });
      
      expect(result.data.name).toBe('Spaced Category');
    });
  });

  describe('update-category', () => {
    it('updates existing category', async () => {
      const category = await createCategory({
        name: 'Original Name',
        cat_group: 'group-1'
      });
      
      const handler = handlers['update-category'];
      const result = await handler({
        id: category.id,
        changes: { name: 'Updated Name' }
      });
      
      expect(result.success).toBe(true);
      
      // Verify update
      const updated = await getCategory(category.id);
      expect(updated.name).toBe('Updated Name');
    });

    it('handles non-existent category', async () => {
      const handler = handlers['update-category'];
      const result = await handler({
        id: 'non-existent-id',
        changes: { name: 'New Name' }
      });
      
      expect(result.error).toBeDefined();
    });
  });
});
```

### **Database Operation Testing**
```tsx
// Pattern: Testing database operations directly
import { 
  getCategories, 
  createCategory, 
  updateCategory, 
  deleteCategory 
} from '../db';

describe('Category Database Operations', () => {
  beforeEach(async () => {
    await setupTestDatabase();
  });

  afterEach(async () => {
    await cleanupTestDatabase();
  });

  describe('getCategories', () => {
    it('returns empty array when no categories exist', async () => {
      const categories = await getCategories();
      expect(categories).toEqual([]);
    });

    it('returns categories sorted by sort_order', async () => {
      await createCategory({ name: 'Third', sort_order: 3 });
      await createCategory({ name: 'First', sort_order: 1 });
      await createCategory({ name: 'Second', sort_order: 2 });
      
      const categories = await getCategories();
      
      expect(categories.map(c => c.name)).toEqual(['First', 'Second', 'Third']);
    });
  });

  describe('createCategory', () => {
    it('creates category with generated ID', async () => {
      const data = {
        name: 'Test Category',
        cat_group: 'group-1',
        is_income: 0
      };
      
      const category = await createCategory(data);
      
      expect(category.id).toBeDefined();
      expect(category.name).toBe('Test Category');
      expect(category.cat_group).toBe('group-1');
    });

    it('sets default values for optional fields', async () => {
      const category = await createCategory({
        name: 'Basic Category',
        cat_group: 'group-1'
      });
      
      expect(category.is_income).toBe(0);
      expect(category.sort_order).toBeDefined();
    });
  });

  describe('updateCategory', () => {
    it('updates specified fields only', async () => {
      const original = await createCategory({
        name: 'Original',
        cat_group: 'group-1',
        is_income: 0
      });
      
      await updateCategory(original.id, { name: 'Updated' });
      
      const updated = await getCategory(original.id);
      expect(updated.name).toBe('Updated');
      expect(updated.cat_group).toBe('group-1'); // Unchanged
      expect(updated.is_income).toBe(0); // Unchanged
    });
  });

  describe('deleteCategory', () => {
    it('removes category from database', async () => {
      const category = await createCategory({
        name: 'To Delete',
        cat_group: 'group-1'
      });
      
      await deleteCategory(category.id);
      
      const categories = await getCategories();
      expect(categories).toHaveLength(0);
    });

    it('handles deletion of non-existent category', async () => {
      await expect(deleteCategory('non-existent')).rejects.toThrow();
    });
  });
});
```

## 🔗 **Integration Testing Patterns**

### **Full Stack Integration Test**
```tsx
// Pattern: Testing complete frontend-backend flow
import { render, screen, fireEvent, waitFor } from '@testing-library/react';
import { setupServer } from 'msw/node';
import { rest } from 'msw';
import { Provider } from 'react-redux';
import { store } from '../store';
import { CategoryManager } from '../CategoryManager';

// Mock API server
const server = setupServer(
  rest.post('/api/get-categories', (req, res, ctx) => {
    return res(ctx.json({
      data: [
        { id: '1', name: 'Groceries', cat_group: 'group-1' },
        { id: '2', name: 'Gas', cat_group: 'group-1' }
      ]
    }));
  }),
  
  rest.post('/api/create-category', async (req, res, ctx) => {
    const body = await req.json();
    return res(ctx.json({
      data: {
        id: '3',
        ...body,
        cat_group: body.groupId
      }
    }));
  }),
  
  rest.post('/api/update-category', async (req, res, ctx) => {
    return res(ctx.json({ success: true }));
  })
);

beforeAll(() => server.listen());
afterEach(() => server.resetHandlers());
afterAll(() => server.close());

describe('Category Management Integration', () => {
  const renderWithProvider = (component) => {
    return render(
      <Provider store={store}>
        {component}
      </Provider>
    );
  };

  it('completes full CRUD workflow', async () => {
    renderWithProvider(<CategoryManager />);
    
    // Load initial data
    await waitFor(() => {
      expect(screen.getByText('Groceries')).toBeInTheDocument();
      expect(screen.getByText('Gas')).toBeInTheDocument();
    });
    
    // Create new category
    fireEvent.click(screen.getByRole('button', { name: /add category/i }));
    
    fireEvent.change(screen.getByLabelText(/category name/i), {
      target: { value: 'Restaurants' }
    });
    
    fireEvent.click(screen.getByRole('button', { name: /save/i }));
    
    // Verify optimistic update
    await waitFor(() => {
      expect(screen.getByText('Restaurants')).toBeInTheDocument();
    });
    
    // Edit existing category
    const editButton = screen.getAllByRole('button', { name: /edit/i })[0];
    fireEvent.click(editButton);
    
    fireEvent.change(screen.getByDisplayValue('Groceries'), {
      target: { value: 'Food Shopping' }
    });
    
    fireEvent.click(screen.getByRole('button', { name: /save/i }));
    
    // Verify update
    await waitFor(() => {
      expect(screen.getByText('Food Shopping')).toBeInTheDocument();
      expect(screen.queryByText('Groceries')).not.toBeInTheDocument();
    });
  });

  it('handles network errors gracefully', async () => {
    // Mock network error
    server.use(
      rest.post('/api/get-categories', (req, res, ctx) => {
        return res.networkError('Network connection failed');
      })
    );
    
    renderWithProvider(<CategoryManager />);
    
    await waitFor(() => {
      expect(screen.getByText(/network error/i)).toBeInTheDocument();
    });
    
    // Test retry functionality
    server.resetHandlers();
    
    fireEvent.click(screen.getByRole('button', { name: /retry/i }));
    
    await waitFor(() => {
      expect(screen.queryByText(/network error/i)).not.toBeInTheDocument();
    });
  });
});
```

## 📊 **Test Utilities and Helpers**

### **Test Database Setup**
```typescript
// Pattern: Database test utilities
import { Database } from '@jlongster/sql.js';
import { schema } from '../aql';

let testDb: Database;

export async function setupTestDatabase() {
  testDb = new Database();
  
  // Create schema
  for (const table of schema.tables) {
    await testDb.exec(table.createSQL);
  }
  
  // Insert test data if needed
  await seedTestData();
}

export async function cleanupTestDatabase() {
  if (testDb) {
    testDb.close();
  }
}

export async function seedTestData() {
  // Create test category groups
  await testDb.run(`
    INSERT INTO category_groups (id, name, sort_order) 
    VALUES 
      ('group-1', 'Monthly Expenses', 1),
      ('group-2', 'Income', 2)
  `);
  
  // Create test categories
  await testDb.run(`
    INSERT INTO categories (id, name, cat_group, sort_order) 
    VALUES 
      ('cat-1', 'Groceries', 'group-1', 1),
      ('cat-2', 'Gas', 'group-1', 2),
      ('cat-3', 'Salary', 'group-2', 1)
  `);
}

// Test-specific database operations
export async function createTestCategory(data) {
  const id = `test-${Date.now()}`;
  await testDb.run(
    'INSERT INTO categories (id, name, cat_group, sort_order) VALUES (?, ?, ?, ?)',
    [id, data.name, data.cat_group, data.sort_order || 0]
  );
  return { id, ...data };
}

export async function getTestCategories() {
  const results = await testDb.all('SELECT * FROM categories ORDER BY sort_order');
  return results;
}
```

### **Component Test Utilities**
```tsx
// Pattern: React testing utilities
import React from 'react';
import { render, RenderOptions } from '@testing-library/react';
import { Provider } from 'react-redux';
import { createStore } from '@reduxjs/toolkit';
import { BrowserRouter } from 'react-router-dom';
import { ThemeProvider } from '@actual-app/components/theme';

// Mock store for testing
export function createTestStore(initialState = {}) {
  return createStore((state = initialState) => state);
}

// Wrapper component with providers
interface TestWrapperProps {
  children: React.ReactNode;
  initialState?: any;
  theme?: any;
}

export const TestWrapper: React.FC<TestWrapperProps> = ({
  children,
  initialState = {},
  theme = defaultTheme
}) => {
  const store = createTestStore(initialState);
  
  return (
    <Provider store={store}>
      <BrowserRouter>
        <ThemeProvider theme={theme}>
          {children}
        </ThemeProvider>
      </BrowserRouter>
    </Provider>
  );
};

// Custom render with providers
interface CustomRenderOptions extends RenderOptions {
  initialState?: any;
  theme?: any;
}

export function renderWithProviders(
  ui: React.ReactElement,
  options: CustomRenderOptions = {}
) {
  const { initialState, theme, ...renderOptions } = options;
  
  return render(ui, {
    wrapper: (props) => (
      <TestWrapper {...props} initialState={initialState} theme={theme} />
    ),
    ...renderOptions
  });
}

// Mock implementations for common hooks
export const mockUseLocalPref = (defaultValue: any) => {
  const [value, setValue] = React.useState(defaultValue);
  return [value, setValue];
};

export const mockUseBudgetContext = () => ({
  currentMonth: '2024-01',
  categories: [],
  isEditing: false,
  setCurrentMonth: jest.fn(),
  updateCategory: jest.fn(),
  toggleEditing: jest.fn(),
});
```

## 💡 **Testing Best Practices**

### **Component Testing:**
- Test behavior, not implementation details
- Use `screen.getByRole()` over `getByTestId()` when possible
- Test user interactions and edge cases
- Mock external dependencies and API calls

### **Hook Testing:**
- Use `renderHook()` for isolated hook testing
- Test state changes with `act()`
- Verify side effects and cleanup
- Mock external dependencies

### **API Testing:**
- Test both success and error scenarios
- Validate input/output contracts
- Use real database for integration tests
- Mock external services and network calls

### **Common Patterns:**
- Always clean up after tests (database, mocks)
- Use descriptive test names
- Group related tests with `describe()`
- Set up common test data in `beforeEach()`