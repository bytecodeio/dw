-- Pull data from summary table
SELECT TO_CHAR(DATE_TRUNC('month', month), 'YYYY-MM-01'), count -- Assign to first day of the month in the spreadsheet
FROM mr_inventory_daily
  JOIN  (
          SELECT DISTINCT DATE_TRUNC('month', date)::DATE - 1  AS month -- end of last day of the month.
          FROM etl_dates
          WHERE date >= TO_CHAR(CURRENT_DATE-1, 'YYYY-MM-01')
                AND date < CURRENT_DATE
          ORDER BY month
        ) AS month_dates
    ON month_dates.month = mr_inventory_daily.date
ORDER BY 1 DESC;
