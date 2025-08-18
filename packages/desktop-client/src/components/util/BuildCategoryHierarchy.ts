import memoizeOne from 'memoize-one';

import {
  type CategoryEntity,
} from 'loot-core/types/models';

/**
 * @interface HierarchicalCategory
 * @extends CategoryEntity
 * @description Represents a category in a hierarchical structure, including its subcategories.
 *              This is similar to a ViewModel in C# that aggregates data for UI display.
 */
export interface HierarchicalCategory extends CategoryEntity {
  subcategories?: HierarchicalCategory[];
}

/**
 * @function buildCategoryHierarchy
 * @param {CategoryEntity[]} categories - A flat list of category entities, potentially including parent_id.
 * @returns {HierarchicalCategory[]} A hierarchical (tree-like) structure of categories.
 * @description This function transforms a flat list of categories into a nested structure.
 *              It's like an in-memory "automapper" that builds a complex object graph
 *              from a simpler, flat data source, without modifying the original data.
 */
export const buildCategoryHierarchy = memoizeOne(
  (categories: CategoryEntity[]): HierarchicalCategory[] => {
    if (!categories) {
      return [];
    }

    const categoryMap = new Map<string, HierarchicalCategory>();
    const rootCategories: HierarchicalCategory[] = [];

    // First pass: Populate the map and initialize subcategories array
    // This is similar to iterating through a collection of DTOs to prepare them
    // for mapping into a more complex model.
    categories.forEach(category => {
      const hierarchicalCategory: HierarchicalCategory = {
        ...category,
        subcategories: [], // Initialize subcategories array
      };
      categoryMap.set(category.id, hierarchicalCategory);
    });

    // Second pass: Build the hierarchy
    // Here, we're establishing the parent-child relationships, much like
    // setting up navigation properties in an ORM.
    categoryMap.forEach(category => {
      if (category.parent_id) {
        const parent = categoryMap.get(category.parent_id);
        if (parent) {
          // Add the current category as a subcategory to its parent
          parent.subcategories?.push(category);
        } else {
          // If parent_id exists but parent is not found, treat as a root category
          // This handles potential data inconsistencies or orphaned subcategories
          rootCategories.push(category);
        }
      } else {
        // This is a top-level category (no parent_id)
        rootCategories.push(category);
      }
    });

    // Sort root categories and their subcategories
    // Sorting ensures a consistent display order, similar to applying an
    // OrderBy clause in a SQL query or LINQ expression.
    rootCategories.sort((a, b) => (a.sort_order || 0) - (b.sort_order || 0));
    rootCategories.forEach(cat => {
      cat.subcategories?.sort((a, b) => (a.sort_order || 0) - (b.sort_order || 0));
    });

    return rootCategories;
  },
);
