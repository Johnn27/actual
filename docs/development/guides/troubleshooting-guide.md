# Development Troubleshooting Guide

## 🚨 Common Issues & Solutions

### Build & Development Server Issues

#### `yarn start:browser` fails
**Symptoms:** Server won't start, port conflicts, build errors
```bash
# Check for port conflicts
netstat -tulpn | grep :3001  # Linux/Mac
netstat -ano | findstr :3001  # Windows

# Kill existing processes
pkill -f "node.*3001"  # Linux/Mac
taskkill /F /IM node.exe  # Windows

# Clear cache and restart
yarn clean
rm -rf node_modules/.cache
yarn start:browser
```

#### Build fails with TypeScript errors
**Symptoms:** `tsc` compilation errors, type mismatches
```bash
# Check TypeScript version consistency
yarn workspace loot-core run tsc --version
yarn workspace desktop-client run tsc --version

# Clear TypeScript cache
rm -rf packages/*/tsconfig.tsbuildinfo
yarn typecheck

# Check for missing dependencies
yarn install --check-files
```

#### Hot reload not working
**Symptoms:** Changes not reflected, manual refresh needed
```bash
# Check file watchers (Linux)
echo fs.inotify.max_user_watches=524288 | sudo tee -a /etc/sysctl.conf
sudo sysctl -p

# Restart with clean cache
yarn start:browser --reset-cache
```

### Testing Issues

#### Tests failing after changes
**Symptoms:** Test suite errors, snapshot mismatches
```bash
# Update snapshots if expected
yarn test --watch=false --updateSnapshot

# Run specific test file
yarn workspace loot-core run test src/server/accounts/sync.test.ts

# Clear test cache
yarn test --clearCache
yarn test --watch=false
```

#### Mock function errors
**Symptoms:** `jest.fn()` or `vi.fn()` not working
```typescript
// Correct Vitest mocking
import { vi } from 'vitest';

// Mock module
vi.mock('../utils', () => ({
  validateData: vi.fn(() => true),
  formatDate: vi.fn((date) => date.toISOString())
}));

// Mock implementation
const mockSend = vi.fn();
vi.mocked(send).mockImplementation(mockSend);
```

#### Test timeout issues
**Symptoms:** Tests hanging, async operations not completing
```typescript
// Increase timeout for slow tests
test('complex operation', async () => {
  // ... test code
}, 10000); // 10 second timeout

// Properly handle async operations
await waitFor(() => {
  expect(element).toBeInTheDocument();
}, { timeout: 5000 });
```

### Package Management Issues

#### Workspace dependency conflicts
**Symptoms:** Module resolution errors, version mismatches
```bash
# Check dependency tree
yarn why package-name

# Reinstall from scratch
rm -rf node_modules yarn.lock
yarn install

# Check for duplicate dependencies
yarn dedupe
```

#### Import resolution failures
**Symptoms:** `Cannot resolve module` errors
```bash
# Check workspace configuration
cat package.json | jq '.workspaces'

# Verify package.json exports
cat packages/loot-core/package.json | jq '.exports'

# Clear module resolution cache
rm -rf node_modules/.cache
```

### Database & Sync Issues

#### SQLite connection errors
**Symptoms:** Database locked, corruption, migration failures
```bash
# Check database file permissions
ls -la ~/.local/share/Actual/  # Linux/Mac
dir %APPDATA%\Actual\  # Windows

# Reset database (CAUTION: Data loss)
rm ~/.local/share/Actual/app.db
yarn start:browser  # Will create fresh DB
```

#### Migration failures
**Symptoms:** Database schema mismatches, migration rollback errors
```typescript
// Check migration status
// In browser console or test:
import { send } from 'loot-core/src/platform/client/fetch';
const result = await send('get-migration-status');
console.log(result);

// Manual migration (development only)
// packages/loot-core/src/server/migrate/migrations.ts
```

#### Sync conflicts
**Symptoms:** Sync server connection failures, merge conflicts
```bash
# Check sync server status
curl -I http://localhost:5006/health  # Local sync server

# Reset sync state (CAUTION)
# Delete sync metadata in user data directory
```

### React Component Issues

#### Infinite re-renders
**Symptoms:** Browser freezing, "Maximum update depth exceeded"
```typescript
// Problem: Missing dependencies
useEffect(() => {
  fetchData(params);
}, []); // Missing 'params' dependency

// Solution: Add all dependencies
useEffect(() => {
  fetchData(params);
}, [params, fetchData]);

// Or use useCallback
const memoizedFetchData = useCallback(() => {
  fetchData(params);
}, [params]);
```

#### State update warnings
**Symptoms:** "Cannot update component while rendering another component"
```typescript
// Problem: State update in render
function Component() {
  const [data, setData] = useState(null);
  
  if (!data) {
    fetchData().then(setData); // ❌ Wrong
  }
  
  return <div>{data}</div>;
}

// Solution: Use useEffect
function Component() {
  const [data, setData] = useState(null);
  
  useEffect(() => {
    fetchData().then(setData); // ✅ Correct
  }, []);
  
  return <div>{data}</div>;
}
```

#### Context value issues
**Symptoms:** Components not re-rendering on context changes
```typescript
// Problem: New object on every render
function Provider({ children }) {
  const value = { user, settings }; // ❌ New object every render
  return <Context.Provider value={value}>{children}</Context.Provider>;
}

// Solution: Memoize context value
function Provider({ children }) {
  const value = useMemo(() => ({ user, settings }), [user, settings]);
  return <Context.Provider value={value}>{children}</Context.Provider>;
}
```

### API & Backend Issues

#### Handler registration errors
**Symptoms:** API endpoints not responding, handler not found
```typescript
// Check handler registration
// packages/loot-core/src/server/main.ts
console.log(Object.keys(handlers));

// Verify handler export
// packages/loot-core/src/server/accounts/sync.ts
export const handlers = {
  'accounts-sync': async () => { ... }
};
```

#### Database query errors
**Symptoms:** SQL syntax errors, type mismatches
```typescript
// Check query syntax
import { db } from '../db';

// Use parameterized queries
const result = await db.all(
  'SELECT * FROM transactions WHERE account_id = ?',
  [accountId]
);

// Check database schema
const schema = await db.all(
  "SELECT sql FROM sqlite_master WHERE type='table'"
);
```

#### Message passing failures
**Symptoms:** Frontend-backend communication errors
```typescript
// Check message format
import { send } from 'loot-core/src/platform/client/fetch';

// Correct usage
const result = await send('budgets-get-budget', { budgetId });

// Debug message handling
// Add logging in packages/loot-core/src/server/main.ts
```

### Performance Issues

#### Slow component renders
**Symptoms:** UI lag, poor responsiveness
```typescript
// Use React DevTools Profiler
// Check for unnecessary re-renders

// Optimize with memoization
const ExpensiveComponent = memo(({ data }) => {
  const processedData = useMemo(() => {
    return expensiveCalculation(data);
  }, [data]);
  
  return <div>{processedData}</div>;
});

// Virtualize large lists
import { FixedSizeList as List } from 'react-window';

const ItemRenderer = ({ index, style }) => (
  <div style={style}>Item {index}</div>
);

<List height={600} itemCount={1000} itemSize={35}>
  {ItemRenderer}
</List>
```

#### Memory leaks
**Symptoms:** Increasing memory usage, browser slowdown
```typescript
// Cleanup subscriptions
useEffect(() => {
  const subscription = eventEmitter.on('data', handleData);
  
  return () => {
    subscription.unsubscribe(); // ✅ Cleanup
  };
}, []);

// Cleanup timers
useEffect(() => {
  const timer = setInterval(updateData, 1000);
  
  return () => {
    clearInterval(timer); // ✅ Cleanup
  };
}, []);
```

### Development Environment Issues

#### Git conflicts in generated files
**Symptoms:** Merge conflicts in snapshots, lock files
```bash
# Reset snapshots
yarn test --watch=false --updateSnapshot
git add packages/**/__snapshots__/**

# Resolve yarn.lock conflicts
rm yarn.lock
yarn install
```

#### IDE TypeScript errors
**Symptoms:** VS Code showing errors that don't exist in build
```bash
# Restart TypeScript service
# VS Code: Ctrl+Shift+P -> "TypeScript: Restart TS Server"

# Check workspace TypeScript version
npx tsc --version

# Clear IDE cache
# VS Code: Delete .vscode folder, restart
```

#### Windows path issues
**Symptoms:** Build scripts failing on Windows
```bash
# Use Git Bash or WSL
# Or run through dev-single.bat

# Check line endings
git config core.autocrlf true
```

## 🔧 Diagnostic Commands

### Quick Health Check
```bash
# Project health check
echo "=== Node Version ==="
node --version

echo "=== Yarn Version ==="
yarn --version

echo "=== Git Status ==="
git status --porcelain

echo "=== Dependencies ==="
yarn install --check-files

echo "=== TypeScript ==="
yarn typecheck

echo "=== Tests ==="
yarn test --watch=false --passWithNoTests

echo "=== Build ==="
yarn build:browser
```

### Detailed Diagnostics
```bash
# Dependency analysis
yarn why react
yarn list --pattern="@types/*"

# Bundle analysis
yarn workspace desktop-client run build --analyze

# Test coverage
yarn test --coverage --watch=false

# Performance profiling
NODE_OPTIONS="--max-old-space-size=4096" yarn start:browser
```

## 🆘 Emergency Procedures

### Complete Reset (Nuclear Option)
```bash
# ⚠️  WARNING: This will delete all local changes and dependencies
git stash
rm -rf node_modules yarn.lock packages/*/node_modules
git clean -fdx
yarn install
yarn build
```

### Backup & Recovery
```bash
# Backup user data
cp -r ~/.local/share/Actual/ ~/actual-backup/  # Linux/Mac
xcopy "%APPDATA%\Actual" "C:\actual-backup" /E  # Windows

# Restore from backup
rm -rf ~/.local/share/Actual/
cp -r ~/actual-backup/ ~/.local/share/Actual/
```

## 📞 Getting Help

### Community Resources
- **GitHub Issues**: Search existing issues before creating new ones
- **Discord**: Real-time community support
- **Documentation**: https://actualbudget.org/docs

### Debugging Information Template
```
**Environment:**
- OS: [Windows/Mac/Linux]
- Node version: [output of `node --version`]
- Yarn version: [output of `yarn --version`]
- Branch: [current git branch]

**Issue:**
[Describe the problem]

**Steps to reproduce:**
1. [First step]
2. [Second step]
3. [Error occurs]

**Expected behavior:**
[What should happen]

**Actual behavior:**
[What actually happens]

**Console output:**
```
[Paste relevant console output]
```

**Additional context:**
[Any other relevant information]
```

---

*This troubleshooting guide covers common development scenarios. For complex issues, consider using the AI context builder in `docs/development/prompt-engineering/` to generate specific debugging context.*