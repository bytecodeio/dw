
SELECT
  TO_CHAR(DATE_TRUNC('day', created_at), 'YYYY-MM-DD') AS day,
  COUNT(id)
FROM yerdle_users
WHERE
  created_at >= '2015-01-01' AND created_at < CURRENT_DATE
GROUP BY 1
ORDER BY 1 DESC
