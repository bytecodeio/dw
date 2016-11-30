SELECT
  TO_CHAR(DATE_TRUNC('month', u.created_at),'YYYY-MM-DD') AS month,
  COUNT(DISTINCT u.id)
FROM yerdle_users AS u
  JOIN yerdle_postings AS p ON u.id = p.poster_id
  AND DATEDIFF(day, u.created_at, p.created_at) >= 0 -- within 7 days
  AND DATEDIFF(day, u.created_at, p.created_at) <= 6
WHERE
  u.created_at >= '2015-01-01' AND u.created_at < TO_CHAR(CURRENT_DATE, 'YYYY-MM-01')
GROUP BY 1
ORDER BY 1 DESC
