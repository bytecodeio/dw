SELECT
  TO_CHAR(DATE_TRUNC('week', u.created_at), 'YYYY-MM-DD') AS week,	 
  COUNT(DISTINCT u.id)
FROM yerdle_users AS u
  JOIN mr_actives_vw AS a ON a.user_id = u.id
WHERE
  a.activity_timestamp >= '2015-01-01' AND a.activity_timestamp < CURRENT_DATE
  AND u.created_at >= '2015-01-01' AND u.created_at < TO_CHAR(DATE_TRUNC('week', CURRENT_DATE), 'YYYY-MM-DD')
  AND DATEDIFF(minute, u.created_at, a.activity_timestamp) >= 15
GROUP BY 1
ORDER BY 1 DESC