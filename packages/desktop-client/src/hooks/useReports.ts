import { useMemo } from 'react';

import { q } from 'loot-core/shared/query';
import {
  type CustomReportData,
  type CustomReportEntity,
} from 'loot-core/types/models';

import { useQuery } from './useQuery';

function toJS(rows: CustomReportData[]) {
  const reports: CustomReportEntity[] = rows.map(row => {
    const report: CustomReportEntity = {
      id: row.id,
      name: row.name,
      startDate: row.start_date,
      endDate: row.end_date,
      isDateStatic: row.date_static === 1,
      dateRange: row.date_range,
      mode: row.mode,
      groupBy: row.group_by,
      sortBy: row.sort_by,
      interval: row.interval,
      balanceType: row.balance_type,
      showEmpty: row.show_empty === 1,
      showOffBudget: row.show_offbudget === 1,
      showHiddenCategories: row.show_hidden === 1,
      includeCurrentInterval: row.include_current === 1,
      showUncategorized: row.show_uncategorized === 1,
      graphType: row.graph_type,
      ...(row.conditions && { conditions: row.conditions }),
      conditionsOp: row.conditions_op ?? 'and',
      ...(row.metadata && { metadata: row.metadata }),
    };
    return report;
  });
  return reports;
}

export function useReports() {
  const { data: queryData, isLoading } = useQuery<CustomReportData>(
    () => q('custom_reports').select('*'),
    [],
  );

  // Sort reports by alphabetical order
  function sort(reports: CustomReportEntity[]) {
    return reports.sort((a, b) =>
      a.name && b.name
        ? a.name.trim().localeCompare(b.name.trim(), undefined, {
            ignorePunctuation: true,
          })
        : 0,
    );
  }

  return useMemo(
    () => ({
      isLoading,
      data: sort(toJS(queryData ? [...queryData] : [])),
    }),
    [isLoading, queryData],
  );
}
