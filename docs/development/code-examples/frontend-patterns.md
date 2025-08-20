# Frontend Code Patterns (desktop-client)
## 🖥️ Copy-Paste Ready React Examples from Actual Codebase

## ⚡ **Quick Reference**
**Purpose:** React component patterns for desktop-client development  
**Source:** Real code patterns from packages/desktop-client/src/
**Use case:** Building React components, hooks, state management

---

## ⚛️ **React Component Patterns**

### **Basic Functional Component with Props**
```tsx
// Pattern from: packages/desktop-client/src/components/budget/
import React, { memo } from 'react';
import { theme } from '@actual-app/components/theme';
import { View } from '@actual-app/components/view';

interface CategoryProps {
  categoryId: string;
  name: string;
  budgetAmount: number;
  actualAmount: number;
  isIncome: boolean;
  onEdit: (id: string) => void;
  onShowActivity: (id: string) => void;
}

export const ExpenseCategory = memo<CategoryProps>(({
  categoryId,
  name,
  budgetAmount,
  actualAmount,
  isIncome,
  onEdit,
  onShowActivity,
}) => {
  const handleClick = () => {
    onShowActivity(categoryId);
  };

  const handleEdit = (e: React.MouseEvent) => {
    e.stopPropagation();
    onEdit(categoryId);
  };

  return (
    <View
      style={{
        flexDirection: 'row',
        alignItems: 'center',
        padding: '8px 12px',
        backgroundColor: theme.tableBackground,
        borderBottom: `1px solid ${theme.tableBorder}`,
        cursor: 'pointer',
      }}
      onClick={handleClick}
    >
      <View style={{ flex: 1 }}>
        <span style={{ fontWeight: 500 }}>{name}</span>
      </View>
      
      <View style={{ width: 100, textAlign: 'right' }}>
        {budgetAmount}
      </View>
      
      <View style={{ width: 100, textAlign: 'right' }}>
        {actualAmount}
      </View>
      
      <button onClick={handleEdit} style={{ marginLeft: 8 }}>
        Edit
      </button>
    </View>
  );
});
```

### **Component with Local State and Effects**
```tsx
// Pattern: Component with useState and useEffect
import React, { useState, useEffect, memo } from 'react';
import { useLocalPref } from '@desktop-client/hooks/useLocalPref';

interface BudgetGroupProps {
  groupId: string;
  categories: CategoryEntity[];
  onCollapse: (groupId: string, collapsed: boolean) => void;
}

export const BudgetGroup = memo<BudgetGroupProps>(({
  groupId,
  categories,
  onCollapse,
}) => {
  const [collapsedGroups, setCollapsedGroups] = useLocalPref('budget.collapsed', []);
  const [isExpanded, setIsExpanded] = useState(!collapsedGroups.includes(groupId));

  // Sync with preference changes
  useEffect(() => {
    setIsExpanded(!collapsedGroups.includes(groupId));
  }, [collapsedGroups, groupId]);

  const handleToggle = () => {
    const newExpanded = !isExpanded;
    setIsExpanded(newExpanded);
    onCollapse(groupId, !newExpanded);
  };

  return (
    <View>
      <View 
        onClick={handleToggle}
        style={{ 
          display: 'flex', 
          alignItems: 'center',
          padding: '12px 16px',
          backgroundColor: theme.tableHeaderBackground,
          cursor: 'pointer',
        }}
      >
        <span style={{ marginRight: 8 }}>
          {isExpanded ? '▼' : '▶'}
        </span>
        <span style={{ fontWeight: 600 }}>Group Name</span>
      </View>
      
      {isExpanded && (
        <View>
          {categories.map(category => (
            <ExpenseCategory 
              key={category.id} 
              {...category}
              onEdit={handleEditCategory}
              onShowActivity={handleShowActivity}
            />
          ))}
        </View>
      )}
    </View>
  );
});
```

### **Complex Component with Multiple Hooks**
```tsx
// Pattern from: packages/desktop-client/src/components/budget/BudgetCategories.jsx
import React, { memo, useState, useMemo, useCallback } from 'react';
import { useLocalPref } from '@desktop-client/hooks/useLocalPref';
import { useFeatureFlag } from '@desktop-client/hooks/useFeatureFlag';

export const BudgetCategories = memo(({
  categoryGroups,
  editingCell,
  onBudgetAction,
  onShowActivity,
  onEditName,
  onSaveCategory,
  onDeleteCategory,
  onReorderCategory,
}) => {
  // Local preferences
  const [collapsedGroupIds, setCollapsedGroupIds] = useLocalPref('budget.collapsed', []);
  const [showHiddenCategories] = useLocalPref('budget.showHiddenCategories');
  
  // Feature flags
  const isGoalTemplatesEnabled = useFeatureFlag('goalTemplatesEnabled');
  
  // Local state
  const [isAddingGroup, setIsAddingGroup] = useState(false);
  const [newCategoryForGroup, setNewCategoryForGroup] = useState(null);

  // Memoized computations
  const processedItems = useMemo(() => {
    return categoryGroups
      .filter(group => showHiddenCategories || !group.hidden)
      .map(group => ({
        ...group,
        categories: group.categories.filter(cat => 
          showHiddenCategories || !cat.hidden
        )
      }));
  }, [categoryGroups, showHiddenCategories]);

  // Callback handlers
  const handleCollapse = useCallback((groupId, collapsed) => {
    setCollapsedGroupIds(prev => 
      collapsed 
        ? [...prev, groupId]
        : prev.filter(id => id !== groupId)
    );
  }, [setCollapsedGroupIds]);

  const handleAddCategory = useCallback((groupId) => {
    setNewCategoryForGroup(groupId);
  }, []);

  return (
    <View>
      {processedItems.map(group => (
        <BudgetGroup
          key={group.id}
          group={group}
          collapsed={collapsedGroupIds.includes(group.id)}
          onCollapse={handleCollapse}
          onAddCategory={handleAddCategory}
          {...otherProps}
        />
      ))}
    </View>
  );
});
```

## 🎣 **Custom Hook Patterns**

### **Data Fetching Hook**
```tsx
// Pattern: Custom hook for API data
import { useState, useEffect } from 'react';
import { send } from 'loot-core/src/platform/client/fetch';

export function useCategories() {
  const [categories, setCategories] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);

  useEffect(() => {
    const loadCategories = async () => {
      try {
        setLoading(true);
        const result = await send('get-categories');
        if (result.error) {
          setError(result.error);
        } else {
          setCategories(result.data);
        }
      } catch (err) {
        setError(err.message);
      } finally {
        setLoading(false);
      }
    };

    loadCategories();
  }, []);

  const refetch = useCallback(() => {
    loadCategories();
  }, []);

  return { categories, loading, error, refetch };
}
```

### **Form State Hook**
```tsx
// Pattern: Form management hook
import { useState, useCallback } from 'react';

export function useCategoryForm(initialData = {}) {
  const [data, setData] = useState({
    name: '',
    groupId: null,
    isIncome: false,
    ...initialData
  });
  const [errors, setErrors] = useState({});
  const [isDirty, setIsDirty] = useState(false);

  const setValue = useCallback((field, value) => {
    setData(prev => ({ ...prev, [field]: value }));
    setIsDirty(true);
    
    // Clear field error when user starts typing
    if (errors[field]) {
      setErrors(prev => {
        const newErrors = { ...prev };
        delete newErrors[field];
        return newErrors;
      });
    }
  }, [errors]);

  const validate = useCallback(() => {
    const newErrors = {};
    
    if (!data.name?.trim()) {
      newErrors.name = 'Name is required';
    }
    
    if (!data.groupId) {
      newErrors.groupId = 'Group is required';
    }

    setErrors(newErrors);
    return Object.keys(newErrors).length === 0;
  }, [data]);

  const reset = useCallback(() => {
    setData(initialData);
    setErrors({});
    setIsDirty(false);
  }, [initialData]);

  return {
    data,
    errors,
    isDirty,
    setValue,
    validate,
    reset
  };
}
```

## 🔄 **State Management Patterns**

### **Redux Action Pattern**
```tsx
// Pattern: Redux actions and reducers
import { createSlice, PayloadAction } from '@reduxjs/toolkit';

interface CategoryState {
  categories: CategoryEntity[];
  loading: boolean;
  error: string | null;
  editingId: string | null;
}

const initialState: CategoryState = {
  categories: [],
  loading: false,
  error: null,
  editingId: null,
};

const categorySlice = createSlice({
  name: 'categories',
  initialState,
  reducers: {
    fetchCategoriesStart: (state) => {
      state.loading = true;
      state.error = null;
    },
    fetchCategoriesSuccess: (state, action: PayloadAction<CategoryEntity[]>) => {
      state.categories = action.payload;
      state.loading = false;
    },
    fetchCategoriesError: (state, action: PayloadAction<string>) => {
      state.error = action.payload;
      state.loading = false;
    },
    updateCategory: (state, action: PayloadAction<{ id: string; changes: Partial<CategoryEntity> }>) => {
      const { id, changes } = action.payload;
      const index = state.categories.findIndex(cat => cat.id === id);
      if (index !== -1) {
        state.categories[index] = { ...state.categories[index], ...changes };
      }
    },
    setEditingCategory: (state, action: PayloadAction<string | null>) => {
      state.editingId = action.payload;
    },
  },
});

export const {
  fetchCategoriesStart,
  fetchCategoriesSuccess, 
  fetchCategoriesError,
  updateCategory,
  setEditingCategory,
} = categorySlice.actions;

export default categorySlice.reducer;
```

### **Context Provider Pattern**
```tsx
// Pattern: Context for shared state
import React, { createContext, useContext, useReducer, ReactNode } from 'react';

interface BudgetContextState {
  currentMonth: string;
  categories: CategoryEntity[];
  isEditing: boolean;
}

interface BudgetContextActions {
  setCurrentMonth: (month: string) => void;
  updateCategory: (id: string, changes: Partial<CategoryEntity>) => void;
  toggleEditing: () => void;
}

const BudgetContext = createContext<BudgetContextState & BudgetContextActions | null>(null);

interface BudgetProviderProps {
  children: ReactNode;
}

export const BudgetProvider: React.FC<BudgetProviderProps> = ({ children }) => {
  const [state, dispatch] = useReducer(budgetReducer, initialState);

  const contextValue = {
    ...state,
    setCurrentMonth: (month: string) => dispatch({ type: 'SET_MONTH', payload: month }),
    updateCategory: (id: string, changes: Partial<CategoryEntity>) => 
      dispatch({ type: 'UPDATE_CATEGORY', payload: { id, changes } }),
    toggleEditing: () => dispatch({ type: 'TOGGLE_EDITING' }),
  };

  return (
    <BudgetContext.Provider value={contextValue}>
      {children}
    </BudgetContext.Provider>
  );
};

export const useBudgetContext = () => {
  const context = useContext(BudgetContext);
  if (!context) {
    throw new Error('useBudgetContext must be used within BudgetProvider');
  }
  return context;
};
```

## 🎨 **Styling Patterns**

### **Theme-Based Styling**
```tsx
// Pattern: Using theme for consistent styling
import { theme } from '@actual-app/components/theme';
import { styles } from '@actual-app/components/styles';

const componentStyles = {
  container: {
    backgroundColor: theme.tableBackground,
    border: `1px solid ${theme.tableBorder}`,
    borderRadius: theme.borderRadius,
    padding: theme.spacingMedium,
  },
  header: {
    ...styles.text,
    fontSize: theme.fontSizeLarge,
    fontWeight: 600,
    color: theme.pageTextDark,
    marginBottom: theme.spacingSmall,
  },
  row: {
    display: 'flex',
    alignItems: 'center',
    padding: `${theme.spacingSmall}px ${theme.spacingMedium}px`,
    '&:hover': {
      backgroundColor: theme.tableRowBackgroundHover,
    },
  },
};

export const StyledComponent = () => (
  <View style={componentStyles.container}>
    <View style={componentStyles.header}>Header</View>
    <View style={componentStyles.row}>Content</View>
  </View>
);
```

### **CSS-in-JS with Emotion**
```tsx
// Pattern: Using @emotion/css for complex styling
import { css } from '@emotion/css';
import { theme } from '@actual-app/components/theme';

const dynamicStyles = {
  categoryRow: (isIncome: boolean, isSelected: boolean) => css`
    display: flex;
    align-items: center;
    padding: 8px 12px;
    background-color: ${isSelected ? theme.tableRowBackgroundSelected : theme.tableBackground};
    border-left: 4px solid ${isIncome ? theme.positiveColor : theme.negativeColor};
    transition: all 0.2s ease;
    
    &:hover {
      background-color: ${theme.tableRowBackgroundHover};
      cursor: pointer;
    }
    
    &.editing {
      background-color: ${theme.tableRowBackgroundEditing};
      box-shadow: 0 0 0 2px ${theme.focusColor};
    }
  `,
};

export const CategoryRow = ({ isIncome, isSelected, isEditing }) => (
  <div 
    className={`
      ${dynamicStyles.categoryRow(isIncome, isSelected)}
      ${isEditing ? 'editing' : ''}
    `}
  >
    Content
  </div>
);
```

## 📱 **Mobile/Responsive Patterns**

### **Responsive Hook Usage**
```tsx
// Pattern: Responsive design with useResponsive
import { useResponsive } from '@actual-app/components/hooks/useResponsive';

export const ResponsiveComponent = () => {
  const { isNarrowWidth } = useResponsive();

  return (
    <View style={{
      flexDirection: isNarrowWidth ? 'column' : 'row',
      padding: isNarrowWidth ? 8 : 16,
    }}>
      {isNarrowWidth ? (
        <MobileLayout />
      ) : (
        <DesktopLayout />
      )}
    </View>
  );
};
```

### **Touch-Friendly Mobile Component**
```tsx
// Pattern: Mobile-optimized component
export const MobileBudgetCategory = ({ category, onEdit, onShowActivity }) => {
  const [showActions, setShowActions] = useState(false);

  return (
    <View
      style={{
        padding: 16,
        borderBottom: `1px solid ${theme.tableBorder}`,
        position: 'relative',
      }}
      onTouchStart={() => setShowActions(true)}
      onTouchEnd={() => setTimeout(() => setShowActions(false), 2000)}
    >
      <View style={{ display: 'flex', justifyContent: 'space-between' }}>
        <View style={{ flex: 1 }}>
          <Text style={{ fontSize: 16, fontWeight: 500 }}>
            {category.name}
          </Text>
          <Text style={{ fontSize: 14, color: theme.pageTextSubdued }}>
            Budget: {category.budgeted} | Spent: {category.spent}
          </Text>
        </View>
        
        {showActions && (
          <View style={{ display: 'flex', gap: 8 }}>
            <TouchableOpacity onPress={() => onEdit(category.id)}>
              <Text style={{ color: theme.linkColor }}>Edit</Text>
            </TouchableOpacity>
            <TouchableOpacity onPress={() => onShowActivity(category.id)}>
              <Text style={{ color: theme.linkColor }}>Activity</Text>
            </TouchableOpacity>
          </View>
        )}
      </View>
    </View>
  );
};
```

## 🧪 **Testing Patterns**

### **Component Testing with React Testing Library**
```tsx
// Pattern: Component unit tests
import React from 'react';
import { render, screen, fireEvent, waitFor } from '@testing-library/react';
import { ExpenseCategory } from '../ExpenseCategory';

describe('ExpenseCategory', () => {
  const mockProps = {
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

  it('renders category information', () => {
    render(<ExpenseCategory {...mockProps} />);
    
    expect(screen.getByText('Test Category')).toBeInTheDocument();
    expect(screen.getByText('100')).toBeInTheDocument();
    expect(screen.getByText('50')).toBeInTheDocument();
  });

  it('calls onShowActivity when clicked', () => {
    render(<ExpenseCategory {...mockProps} />);
    
    fireEvent.click(screen.getByText('Test Category'));
    
    expect(mockProps.onShowActivity).toHaveBeenCalledWith('cat-1');
  });

  it('calls onEdit when edit button clicked', () => {
    render(<ExpenseCategory {...mockProps} />);
    
    fireEvent.click(screen.getByText('Edit'));
    
    expect(mockProps.onEdit).toHaveBeenCalledWith('cat-1');
  });
});
```

### **Hook Testing**
```tsx
// Pattern: Custom hook testing
import { renderHook, act } from '@testing-library/react';
import { useCategoryForm } from '../hooks/useCategoryForm';

describe('useCategoryForm', () => {
  it('initializes with default values', () => {
    const { result } = renderHook(() => useCategoryForm());
    
    expect(result.current.data).toEqual({
      name: '',
      groupId: null,
      isIncome: false,
    });
    expect(result.current.isDirty).toBe(false);
    expect(result.current.errors).toEqual({});
  });

  it('updates values and marks as dirty', () => {
    const { result } = renderHook(() => useCategoryForm());
    
    act(() => {
      result.current.setValue('name', 'New Category');
    });
    
    expect(result.current.data.name).toBe('New Category');
    expect(result.current.isDirty).toBe(true);
  });

  it('validates required fields', () => {
    const { result } = renderHook(() => useCategoryForm());
    
    const isValid = act(() => result.current.validate());
    
    expect(isValid).toBe(false);
    expect(result.current.errors.name).toBe('Name is required');
  });
});
```

## 🔍 **Common File Locations**

```bash
# React components
packages/desktop-client/src/components/budget/
packages/desktop-client/src/components/accounts/ 
packages/desktop-client/src/components/modals/

# Custom hooks
packages/desktop-client/src/hooks/

# Redux state
packages/desktop-client/src/redux/

# Utilities  
packages/desktop-client/src/util/

# Types (shared with backend)
packages/loot-core/src/types/models.ts
```

## 💡 **Development Tips**

### **C# Developer Notes:**
- **No classes** - Everything is functional components and hooks
- **Props = DTOs** - Component props are like data transfer objects
- **Hooks = DI** - Custom hooks provide dependency injection-like functionality  
- **State management** - Redux similar to MediatR + CQRS patterns
- **Styling** - CSS-in-JS instead of separate stylesheets

### **React Best Practices:**
- Always use `memo()` for expensive components
- Prefer `useCallback()` for event handlers passed to children
- Use `useMemo()` for expensive calculations
- Keep components small and focused on single responsibility
- Extract custom hooks for reusable logic