SELECT
  TO_CHAR(DATE_TRUNC('month', coalesce(closed_at, deleted_at, suspended_at)), 'YYYY-MM-DD') AS month,
  COUNT(id)
FROM yerdle_users
WHERE
  created_at >= '2015-01-01' AND created_at < TO_CHAR(CURRENT_DATE, 'YYYY-MM-01')
  AND TO_CHAR(coalesce(closed_at, deleted_at, suspended_at), 'YYYY-MM-01') < CURRENT_DATE
  AND (closed_at IS NOT NULL OR deleted_at IS NOT NULL OR suspended_at IS NOT NULL)
GROUP BY 1
ORDER BY 1 DESC

/*
SELECT
  TO_CHAR(DATE_TRUNC('day', etl_dates.date), 'YYYY-MM-DD') AS day,
  COUNT(yerdle_users.id)
FROM etl_dates
LEFT JOIN yerdle_users ON DATE(etl_dates.date) = DATE(yerdle_users.created_at)
                          AND (yerdle_users.deleted_at IS NOT NULL OR yerdle_users.suspended_at IS NOT NULL)
WHERE
  etl_dates.date::DATE < TRUNC(GETDATE())
GROUP BY 1
ORDER BY 1 DESC
 */
