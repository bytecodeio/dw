-- Pull data from summary table
SELECT TO_CHAR(DATE_TRUNC('week', week-1), 'YYYY-MM-DD'), count
FROM mr_inventory_daily
JOIN  (
        SELECT DISTINCT DATE_TRUNC('week', date)::DATE - 1 AS week -- end of last day of the week.
        FROM etl_dates
        WHERE date >= '2015-01-01'
              AND date <= TO_CHAR(DATE_TRUNC('week', CURRENT_DATE), 'YYYY-MM-DD')
        ORDER BY week ) AS week_dates
  ON week_dates.week = mr_inventory_daily.date
ORDER BY 1 DESC;
