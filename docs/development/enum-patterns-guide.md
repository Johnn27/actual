# Enum Patterns in Actual Budget

This document analyzes how enum-like values are handled in the Actual Budget codebase and provides guidelines for effective enum usage.

## Key Finding: Union Types Over Traditional Enums

**Actual Budget strongly favors union types over traditional TypeScript enums.** Only 2 traditional enums were found in the entire codebase, while hundreds of union types serve the same purpose.

## Current Enum Patterns Analysis

### 1. Traditional TypeScript Enums (Rare - Only 2 Found)

#### Pattern: String Enums
```typescript
// packages/component-library/src/tokens.ts
enum BreakpointNames {
  small = 'small',
  medium = 'medium',
  wide = 'wide',
}

// packages/desktop-client/src/auth/types.ts  
export enum Permissions {
  ADMINISTRATOR = 'ADMIN',
}
```

**Usage Context**: Only used for very specific, isolated cases where enum members need to be iterated or transformed.

### 2. Union Types (Primary Pattern - 200+ Instances)

#### Pattern: String Literal Unions
```typescript
// Authentication methods
export type AuthMethods = 'password' | 'openid';

// Theme options
export type Theme = 'light' | 'dark' | 'auto' | 'midnight' | 'development';
export type DarkTheme = 'dark' | 'midnight';

// Account sync sources
export type AccountSyncSource = 'simpleFin' | 'goCardless' | 'pluggyai';

// Rule condition operators
export type RuleConditionOp =
  | 'is'
  | 'isNot'
  | 'oneOf'
  | 'notOneOf'
  | 'isapprox'
  | 'isbetween'
  | 'gt'
  | 'gte'
  | 'lt'
  | 'lte'
  | 'contains'
  | 'doesNotContain'
  | 'hasTags'
  | 'and'
  | 'matches'
  | 'onBudget'
  | 'offBudget';

// Report balance types
export type balanceTypeOpType =
  | 'totalAssets'
  | 'totalDebts'
  | 'totalTotals'
  | 'netAssets'
  | 'netDebts';
```

**Benefits of This Approach:**
- **Type safety** without runtime overhead
- **Better tree-shaking** - no enum object to bundle
- **Simpler imports** - just use string literals directly
- **JSON serialization** works naturally
- **Better TypeScript inference** and completion

### 3. Const Assertions for Configuration Objects

#### Pattern: `as const` for Readonly Objects
```typescript
// packages/loot-core/src/shared/rules.ts
const TYPE_INFO = {
  date: {
    ops: ['is', 'isapprox', 'gt', 'gte', 'lt', 'lte'],
    nullable: false,
  },
  string: {
    ops: [
      'is',
      'contains', 
      'matches',
      'oneOf',
      'isNot',
      'doesNotContain',
      'notOneOf',
      'hasTags',
    ],
    nullable: true,
  },
  number: {
    ops: ['is', 'isapprox', 'isbetween', 'gt', 'gte', 'lt', 'lte'],
    nullable: false,
  },
} as const;

const FIELD_INFO = {
  imported_payee: {
    type: 'string',
    disallowedOps: new Set(['hasTags']),
  },
  payee: { type: 'id', disallowedOps: new Set(['onBudget', 'offBudget']) },
  date: { type: 'date' },
  notes: { type: 'string' },
  amount: { type: 'number' },
  account: { type: 'id' },
  cleared: { type: 'boolean' },
} as const satisfies FieldInfoConstraint;
```

**Benefits:**
- **Readonly at compile time** - prevents accidental mutations
- **Type inference** from values maintains exact types
- **Configuration objects** that serve as both types and runtime values
- **IDE completion** for nested properties

### 4. The `satisfies` Operator Pattern

#### Pattern: Type Checking Without Widening
```typescript
// Ensures type safety while preserving exact literal types
const FIELD_INFO = {
  payee: { type: 'id', disallowedOps: new Set(['onBudget', 'offBudget']) },
  date: { type: 'date' },
  notes: { type: 'string' },
} as const satisfies FieldInfoConstraint;
```

**Benefits:**
- **Type validation** at compile time
- **Preserves literal types** (doesn't widen to `string`)
- **Catches typos** in object keys and values
- **Maintains IntelliSense** for exact values

## Recommended Patterns for New Code

### ✅ DO: Use Union Types for Simple Enums

```typescript
// Good: Simple, type-safe, no runtime overhead
export type Priority = 'low' | 'medium' | 'high';
export type Status = 'pending' | 'completed' | 'failed';

// Usage is clean and natural
function setStatus(status: Status) {
  if (status === 'completed') {
    // TypeScript knows this is valid
  }
}
```

### ✅ DO: Use Const Assertions for Configuration

```typescript
// Good: For complex configurations that need both types and runtime access
const TRANSACTION_TYPES = {
  INCOME: { 
    label: 'Income',
    sign: 1,
    color: '#green'
  },
  EXPENSE: {
    label: 'Expense', 
    sign: -1,
    color: '#red'
  },
  TRANSFER: {
    label: 'Transfer',
    sign: 0,
    color: '#blue'
  }
} as const;

type TransactionType = keyof typeof TRANSACTION_TYPES;
```

### ✅ DO: Use `satisfies` for Type Safety

```typescript
// Good: Ensures type safety while preserving exact types
type ApiEndpoint = {
  method: 'GET' | 'POST' | 'PUT' | 'DELETE';
  path: string;
  authRequired: boolean;
};

const API_ENDPOINTS = {
  getUser: { method: 'GET', path: '/users', authRequired: true },
  createUser: { method: 'POST', path: '/users', authRequired: false },
  updateUser: { method: 'PUT', path: '/users', authRequired: true },
} as const satisfies Record<string, ApiEndpoint>;
```

### ❌ AVOID: Traditional TypeScript Enums

```typescript
// Avoid: Creates runtime overhead and larger bundles
enum Priority {
  LOW = 'low',
  MEDIUM = 'medium', 
  HIGH = 'high'
}

// Problems:
// - Generates runtime enum object
// - Larger bundle size
// - More complex imports
// - Harder to tree-shake
```

## Migration Strategies

### When You Have an Existing Enum

If you encounter existing enums in the codebase:

#### Before (Traditional Enum):
```typescript
enum Status {
  PENDING = 'pending',
  COMPLETED = 'completed', 
  FAILED = 'failed'
}
```

#### After (Union Type):
```typescript
export type Status = 'pending' | 'completed' | 'failed';
```

#### Migration Steps:
1. **Replace enum declaration** with union type
2. **Update imports** to remove enum references  
3. **Use string literals** directly instead of enum members
4. **Update tests** to use string literals
5. **Verify no runtime enum usage** (like Object.values(Status))

## Advanced Patterns

### Pattern: Computed Types from Const Objects

```typescript
// Define configuration object
const USER_ROLES = {
  ADMIN: { permissions: ['read', 'write', 'delete'], level: 10 },
  USER: { permissions: ['read'], level: 1 },
  GUEST: { permissions: [], level: 0 },
} as const;

// Extract types automatically
type UserRole = keyof typeof USER_ROLES;  // 'ADMIN' | 'USER' | 'GUEST'
type Permission = typeof USER_ROLES[UserRole]['permissions'][number]; // 'read' | 'write' | 'delete'
```

### Pattern: Template Literal Types for Dynamic Enums

```typescript
// Used in preferences system
type AccountPreference = `show-balances-${string}` | `hide-cleared-${string}`;
type CsvMapping = `csv-mappings-${string}` | `csv-delimiter-${string}`;
```

## Performance Considerations

### Bundle Size Impact

**Union Types**: ✅ Zero runtime overhead
```typescript
type Theme = 'light' | 'dark';  // Compiles to nothing
```

**Traditional Enums**: ❌ Runtime object overhead
```typescript
enum Theme { Light = 'light', Dark = 'dark' }  
// Compiles to: var Theme = { Light: 'light', Dark: 'dark' };
```

### Tree Shaking

- **Union types**: Perfect tree-shaking (nothing to shake)
- **Const assertions**: Only used properties included
- **Traditional enums**: Entire enum object included even if partially used

## Testing Patterns

### Testing Union Types
```typescript
// Good: Direct value testing
describe('theme handling', () => {
  it('should accept valid themes', () => {
    expect(isValidTheme('light')).toBe(true);
    expect(isValidTheme('dark')).toBe(true);
    expect(isValidTheme('invalid')).toBe(false);
  });
});
```

### Testing Const Objects
```typescript
// Good: Test both types and runtime values
describe('transaction types', () => {
  it('should have correct configuration', () => {
    expect(TRANSACTION_TYPES.INCOME.sign).toBe(1);
    expect(TRANSACTION_TYPES.EXPENSE.sign).toBe(-1);
  });
  
  it('should include all expected types', () => {
    const types: TransactionType[] = ['INCOME', 'EXPENSE', 'TRANSFER'];
    types.forEach(type => {
      expect(TRANSACTION_TYPES[type]).toBeDefined();
    });
  });
});
```

## Best Practices Summary

### 1. **Default to Union Types**
Use string literal union types for simple enumerations.

### 2. **Use Const Assertions for Complex Config**
When you need both type safety and runtime access to structured data.

### 3. **Apply `satisfies` for Validation**
Ensures type correctness while preserving exact literal types.

### 4. **Avoid Traditional Enums**
Unless you specifically need enum-specific features like iteration or reverse mapping.

### 5. **Consider Template Literals**
For dynamic enum patterns based on string interpolation.

### 6. **Prioritize Type Safety**
All patterns should provide compile-time type checking and IDE support.

### 7. **Minimize Runtime Overhead**
Choose patterns that compile to minimal or zero JavaScript runtime code.

## Tools and IDE Support

### TypeScript Configuration
Ensure your `tsconfig.json` supports these patterns:
```json
{
  "compilerOptions": {
    "strict": true,
    "exactOptionalPropertyTypes": true,
    "noUncheckedIndexedAccess": true
  }
}
```

### ESLint Rules
Consider these rules to enforce consistent enum patterns:
```json
{
  "rules": {
    "@typescript-eslint/prefer-enum-initializers": "off",
    "@typescript-eslint/prefer-literal-enum-member": "off",
    "prefer-const-assertions": "error"
  }
}
```

---

**Following these patterns keeps the Actual Budget codebase consistent, performant, and maintainable while leveraging TypeScript's most powerful type system features.**