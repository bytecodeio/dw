
SELECT
  TO_CHAR(DATE_TRUNC('month', created_at), 'YYYY-MM-DD') AS month,
  COUNT(id)
FROM yerdle_users
WHERE
  created_at >= TO_CHAR(CURRENT_DATE-1, 'YYYY-MM-01') AND created_at < CURRENT_DATE
GROUP BY 1
ORDER BY 1 DESC
