SELECT
  TO_CHAR(DATE_TRUNC('day', u.created_at), 'YYYY-MM-DD') AS day,
  COUNT(DISTINCT u.id)
FROM yerdle_users AS u
  JOIN mr_actives_vw AS a ON a.user_id = u.id
WHERE
  a.activity_timestamp >= '2015-01-01' AND a.activity_timestamp < CURRENT_DATE
  AND u.created_at >= '2015-01-01' AND u.created_at < CURRENT_DATE
  AND DATEDIFF(day, u.created_at, a.activity_timestamp) = 1 -- Day 2 = day after signup = date diff of 1
GROUP BY 1
ORDER BY 1 DESC