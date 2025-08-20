# Code Examples Library
## 📚 Copy-Paste Ready Patterns from Actual Budget

## ⚡ **Quick Navigation**
**Purpose:** Real code patterns extracted from Actual Budget codebase  
**Value:** Reduce AI hallucination, speed development, ensure consistency
**Usage:** Copy-paste starting points for common development tasks

---

## 📁 **Available Pattern Libraries**

### **🧠 Backend Patterns** (`backend-patterns.md`)
**Size:** ~4,500 words | **Examples:** 25+ patterns  
**Focus:** loot-core development - API handlers, database operations, business logic

**Key Patterns:**
- API handler creation (`handlers['api/action']`)
- Database CRUD operations
- Budget calculation functions  
- Error handling and validation
- Testing backend APIs

**When to use:** Building backend features, API endpoints, database operations

### **⚛️ Frontend Patterns** (`frontend-patterns.md`)  
**Size:** ~5,000 words | **Examples:** 30+ patterns
**Focus:** desktop-client development - React components, hooks, state management

**Key Patterns:**
- Functional component structures
- Custom hook creation (`useData`, `useForm`)
- Redux state management
- Theme-based styling
- Mobile/responsive patterns

**When to use:** Building React components, frontend features, UI interactions

### **🔗 Integration Patterns** (`integration-patterns.md`)
**Size:** ~3,500 words | **Examples:** 20+ patterns
**Focus:** Frontend ↔ Backend communication and data flow

**Key Patterns:**
- API call patterns (`send('action', data)`)
- Real-time updates and WebSocket-like communication
- Optimistic UI updates
- CRDT synchronization
- Cross-package data flow

**When to use:** Full-stack features, API integration, data synchronization

### **🧪 Testing Patterns** (`testing-patterns.md`)
**Size:** ~4,000 words | **Examples:** 25+ patterns  
**Focus:** Unit testing, component testing, integration testing

**Key Patterns:**
- React component testing with React Testing Library
- Custom hook testing
- Backend API handler testing
- Database operation testing
- Full-stack integration tests

**When to use:** Writing tests, ensuring code quality, debugging

---

## 🎯 **Quick Decision Guide**

### **What are you building?**

**🌐 API Endpoint?**  
→ `backend-patterns.md` → "API Handler Patterns" section  
→ Copy handler template, add validation, connect to database

**⚛️ React Component?**  
→ `frontend-patterns.md` → "React Component Patterns" section  
→ Copy component structure, add props interface, implement logic

**🔄 Frontend ↔ Backend Feature?**  
→ `integration-patterns.md` → "API Communication Patterns"  
→ Copy send/handler pair, add state management

**📊 Database Operation?**  
→ `backend-patterns.md` → "Database Operation Patterns"  
→ Copy CRUD functions, add transactions for complex operations

**🎣 Custom Hook?**  
→ `frontend-patterns.md` → "Custom Hook Patterns"  
→ Copy hook structure, add state management and effects

**🧪 Test for Feature?**  
→ `testing-patterns.md` → Choose component/API/integration pattern  
→ Copy test structure, customize assertions

---

## 🚀 **Usage Examples**

### **Example 1: Adding a New API Endpoint**

**Step 1:** Copy from `backend-patterns.md`:
```typescript
// Basic API Handler template
handlers['api/your-action'] = async function ({ param1, param2 }) {
  if (!param1) {
    return { error: 'param1 is required' };
  }
  
  try {
    const result = await yourDatabaseOperation(param1, param2);
    return { data: result };
  } catch (error) {
    return { error: error.message };
  }
};
```

**Step 2:** Customize for your needs  
**Step 3:** Add frontend call from `integration-patterns.md`

### **Example 2: Creating a Component**

**Step 1:** Copy from `frontend-patterns.md`:
```tsx
interface YourComponentProps {
  // Define your props
}

export const YourComponent = memo<YourComponentProps>(({ 
  // Destructure props
}) => {
  // Copy relevant hooks and state management
  
  return (
    // Copy JSX structure
  );
});
```

**Step 2:** Customize props and logic  
**Step 3:** Add styling and event handlers

### **Example 3: Adding Tests**

**Step 1:** Copy test structure from `testing-patterns.md`  
**Step 2:** Customize test data and assertions  
**Step 3:** Add edge cases and error scenarios

---

## 💡 **Best Practices for Using Patterns**

### **✅ Do:**
- **Copy structure, customize content** - Use patterns as starting points
- **Update imports** - Adjust import paths for your specific files
- **Maintain consistency** - Follow existing naming and style conventions
- **Add error handling** - Include proper validation and error responses
- **Write tests** - Use testing patterns to ensure quality

### **❌ Don't:**
- **Copy without understanding** - Make sure you understand what the code does
- **Skip validation** - Always validate inputs and handle errors
- **Ignore TypeScript** - Update types and interfaces for your use case
- **Forget testing** - Include appropriate test patterns
- **Mix patterns incorrectly** - Ensure frontend/backend patterns match

### **🔍 Pattern Validation Checklist:**
- [ ] Imports updated for your file structure
- [ ] TypeScript interfaces defined for your data
- [ ] Error handling appropriate for your use case
- [ ] Tests added using testing patterns
- [ ] Consistent with existing codebase style
- [ ] Performance considerations addressed

---

## 🧠 **AI Development Tips**

### **For Claude/AI Assistants:**
When using these patterns with AI:

1. **Provide context:** "Using the API handler pattern from backend-patterns.md..."
2. **Specify customizations:** "Adapt this for category management with validation..."  
3. **Reference related patterns:** "Also use the integration pattern for frontend calls..."
4. **Request tests:** "Include the corresponding test pattern from testing-patterns.md..."

### **Pattern Combination Examples:**
- **Backend API + Frontend Call + Test** = Full feature implementation
- **Component + Hook + Styling** = Complete UI component
- **Database + API + Integration** = Data operation with frontend access

### **Common AI Prompts:**
- "Use the React component pattern to create a CategoryRow component..."
- "Adapt the API handler pattern for managing budget categories..."  
- "Following the integration pattern, create frontend calls for this API..."
- "Add tests using the component testing pattern for this feature..."

---

## 📊 **Pattern Coverage Matrix**

| Development Task | Backend | Frontend | Integration | Testing |
|-----------------|---------|----------|-------------|---------|
| API Endpoints | ✅ | ❌ | ✅ | ✅ |
| React Components | ❌ | ✅ | ❌ | ✅ |
| Database Operations | ✅ | ❌ | ❌ | ✅ |
| Custom Hooks | ❌ | ✅ | ✅ | ✅ |
| State Management | ❌ | ✅ | ✅ | ✅ |
| Full-Stack Features | ✅ | ✅ | ✅ | ✅ |

---

## 🔄 **Keeping Patterns Updated**

### **Pattern Maintenance:**
- **Review quarterly** - Check patterns match current codebase
- **Add new patterns** - When you discover useful patterns, document them
- **Update examples** - Keep imports and syntax current
- **Validate functionality** - Ensure copy-paste examples work

### **Contributing New Patterns:**
When you find a useful pattern not covered:
1. Extract the reusable structure
2. Remove specific implementation details  
3. Add clear comments and usage notes
4. Include TypeScript types
5. Add to appropriate pattern file

---

**💡 Remember:** These patterns are living examples from the actual codebase. They represent battle-tested approaches that maintain consistency and quality in Actual Budget development.