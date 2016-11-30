SELECT
  TO_CHAR(DATE_TRUNC('day', u.created_at),'YYYY-MM-DD') AS day,
  COUNT(DISTINCT p.id)
FROM yerdle_users AS u
  JOIN yerdle_postings AS p ON u.id = p.poster_id AND DATE_TRUNC('day', u.created_at) = DATE_TRUNC('day', p.created_at)
WHERE
  u.created_at >= '2015-01-01' AND u.created_at < CURRENT_DATE
GROUP BY 1
ORDER BY 1 DESC


