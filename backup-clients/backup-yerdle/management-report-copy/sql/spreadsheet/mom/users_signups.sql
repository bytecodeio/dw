
SELECT
  TO_CHAR(DATE_TRUNC('month', created_at), 'YYYY-MM-DD') AS month,
  COUNT(id)
FROM yerdle_users
WHERE
  created_at >= '2015-01-01' AND created_at < TO_CHAR(CURRENT_DATE, 'YYYY-MM-01')
GROUP BY 1
ORDER BY 1 DESC
