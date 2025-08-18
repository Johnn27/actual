import { useEffect, useMemo } from 'react'; // Added useMemo

import { useInitialMount } from './useInitialMount';

import { getCategories } from '@desktop-client/queries/queriesSlice';
import { useSelector, useDispatch } from '@desktop-client/redux';
import { buildCategoryHierarchy } from '@desktop-client/components/util/BuildCategoryHierarchy'; // Import our new utility

export function useCategories() {
  const dispatch = useDispatch();
  const categoriesLoaded = useSelector(state => state.queries.categoriesLoaded); 
  const isInitialMount = useInitialMount();

  useEffect(() => {
    if (isInitialMount && !categoriesLoaded) {
      dispatch(getCategories());
    }
  }, [categoriesLoaded, dispatch, isInitialMount]);

  const selector = useSelector(state => state.queries.categories);

  // Use useMemo to build the hierarchy only when categories.list changes
  // This is like a computed property in a C# ViewModel that's cached.
  return useMemo(
    () => ({
      ...selector,
      hierarchical: buildCategoryHierarchy(selector.list), // Build the hierarchy from the flat list
    }),
    [selector.list], // Re-run memoization only when the flat list changes
  );
}
