# Mini Easy Fix Analysis - Help Wanted Issues

This document analyzes simple bug fixes from "help wanted" labeled issues that are not already documented in the main easy-fixes-analysis.

## Issue [#5547](https://github.com/actualbudget/actual/issues/5547): Tag names are difficult to read in dark mode when using bright background colors

**Priority: ⭐⭐ (Easy)**  
**Labels:** bug, help wanted, user interface  
**Opened:** Aug 12, 2025 (4 days old)

### Problem
Tag text remains white when using bright background colors in dark mode, creating poor readability with bright colored tags.

### Technical Analysis
- **File affected:** `packages/desktop-client/src/style/tags.ts:46`
- **Current code:** `themeStyle.noteTagText` (always white in dark mode)
- **Issue:** No contrast calculation for custom tag colors in dark mode

### Root Cause
The `getTagCSSColors` function uses a fixed white text color (`themeStyle.noteTagText`) for all custom colored tags in dark mode, regardless of background brightness.

```typescript
// In dark mode, line 46:
return [
  themeStyle.noteTagText,  // Always white text
  color ?? themeStyle.noteTagBackground,
  color ? `color-mix(in srgb, ${color} 85%, white)` : themeStyle.noteTagBackgroundHover,
];
```

### Solution
Add brightness-based text color calculation for dark mode:

```typescript
// Before (line 44-52)
} else {
  return [
    themeStyle.noteTagText,
    color ?? themeStyle.noteTagBackground,
    color
      ? `color-mix(in srgb, ${color} 85%, white)`
      : themeStyle.noteTagBackgroundHover,
  ];
}

// After - Add contrast calculation
} else {
  const textColor = color ? getContrastColor(color) : themeStyle.noteTagText;
  return [
    textColor,
    color ?? themeStyle.noteTagBackground,
    color
      ? `color-mix(in srgb, ${color} 85%, white)`
      : themeStyle.noteTagBackgroundHover,
  ];
}

// Helper function to add above getTagCSSColors:
function getContrastColor(backgroundColor: string): string {
  // Simple brightness calculation for hex colors
  if (backgroundColor.startsWith('#')) {
    const hex = backgroundColor.replace('#', '');
    const r = parseInt(hex.substr(0, 2), 16);
    const g = parseInt(hex.substr(2, 2), 16);
    const b = parseInt(hex.substr(4, 2), 16);
    const brightness = (r * 299 + g * 587 + b * 114) / 1000;
    return brightness > 128 ? '#000000' : '#ffffff';
  }
  return '#ffffff'; // fallback to white
}
```

### Code Areas Affected
- `packages/desktop-client/src/style/tags.ts:44-52`

### Complexity Rating: 3/10
- Simple brightness calculation algorithm
- Single function modification
- Clear visual improvement

---

## Issue [#5560](https://github.com/actualbudget/actual/issues/5560): Automatic scrolling on mobile makes it hard to fill out split transactions

**Priority: ⭐⭐ (Easy)**  
**Labels:** bug, help wanted, user interface, responsive, split transactions  
**Opened:** Aug 15, 2025 (1 day old)

### Problem
Mobile split transaction editing auto-scrolls to first zero-amount split when tapping any field, disrupting user input.

### Technical Analysis
- **File affected:** `packages/desktop-client/src/components/mobile/transactions/TransactionEdit.jsx:796-802`
- **Current code:** useEffect that auto-scrolls to first zero-amount child transaction
- **Issue:** Effect triggers on any interaction, not just when adding new splits

### Root Cause
The useEffect automatically scrolls whenever `childTransactions` changes, even when user is manually editing existing splits:

```javascript
useEffect(() => {
  const noAmountChildTransaction = childTransactions.find(
    t => t.amount === 0,
  );
  if (noAmountChildTransaction) {
    scrollChildTransactionIntoView(noAmountChildTransaction.id);
  }
}, [childTransactions, scrollChildTransactionIntoView]);
```

### Solution
Add condition to prevent scrolling when user is actively editing:

```javascript
// Before (lines 795-802)
useEffect(() => {
  const noAmountChildTransaction = childTransactions.find(
    t => t.amount === 0,
  );
  if (noAmountChildTransaction) {
    scrollChildTransactionIntoView(noAmountChildTransaction.id);
  }
}, [childTransactions, scrollChildTransactionIntoView]);

// After - Only scroll when adding new splits, not editing existing ones
useEffect(() => {
  const noAmountChildTransaction = childTransactions.find(
    t => t.amount === 0,
  );
  // Only auto-scroll if this is a newly added split (no focus on existing fields)
  if (noAmountChildTransaction && !document.activeElement?.closest('[data-split-item]')) {
    scrollChildTransactionIntoView(noAmountChildTransaction.id);
  }
}, [childTransactions, scrollChildTransactionIntoView]);
```

### Code Areas Affected
- `packages/desktop-client/src/components/mobile/transactions/TransactionEdit.jsx:795-802`

### Complexity Rating: 2/10
- Single condition addition
- Clear fix for specific mobile UX issue
- Low regression risk

---

## Issue [#5163](https://github.com/actualbudget/actual/issues/5163): Incorrect date range and filtered balance showing in reports

**Priority: ⭐⭐⭐ (Very Easy)**  
**Labels:** bug, good first issue, help wanted, reports  
**Opened:** Jun 14, 2025 (2+ months old)

### Problem
Reports with "Live" date ranges save the current date instead of dynamically updating, causing stale date filters when viewed days later.

### Technical Analysis  
- **Files likely affected:** Report configuration and date range handling
- **Issue:** "Live" date ranges are computed once and stored statically instead of being recalculated on each view
- **Root cause:** Date computation happens during report creation rather than display

### Investigation Required
Need to examine:
- Report date range configuration storage
- Live date range calculation logic
- When date ranges get resolved (creation vs display time)

### Code Areas to Investigate
- `packages/desktop-client/src/components/reports/` (report configuration)
- Date range utility functions for "Year to Date" calculations
- Report filter state management

### Complexity Rating: 4/10
- Requires understanding report architecture
- Clear reproduction steps provided
- Well-defined expected behavior

---

## Skipped (Too Complex)
- **Issue [#5525](https://github.com/actualbudget/actual/issues/5525):** Shift-click selection totals with splits - Race condition mentioned, requires complex selection logic debugging
- **Issue [#5320](https://github.com/actualbudget/actual/issues/5320):** Mobile notes slow loading - Performance issue requiring deeper investigation

---

## Summary and Recommendations

### Immediate Quick Wins (Complexity 1-3)
1. **Issue #5547** - Tag contrast in dark mode (3/10 complexity)
2. **Issue #5560** - Mobile split transaction scrolling (2/10 complexity)

### Investigation Required (Complexity 4)
3. **Issue #5163** - Report date range persistence (4/10 complexity)

### Development Approach
**Start here for maximum impact:**
- **#5560**: Quick mobile UX fix with clear before/after behavior
- **#5547**: Visual improvement with straightforward contrast calculation

**Second tier:**
- **#5163**: Requires codebase investigation but has clear reproduction steps

**Why these are ideal:**
- Clear technical problems with specific code locations identified
- Well-defined expected behavior from user reports
- Low risk of introducing regressions
- Good learning opportunities for different parts of the codebase (mobile, styling, reports)

**Development notes:**
- Tag contrast issue demonstrates CSS color manipulation
- Mobile scrolling issue teaches React useEffect dependencies and mobile UX patterns
- Report date issue introduces report architecture understanding