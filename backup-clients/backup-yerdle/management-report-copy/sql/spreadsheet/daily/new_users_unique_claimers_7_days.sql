SELECT
  TO_CHAR(DATE_TRUNC('day', u.created_at),'YYYY-MM-DD') AS day,
  COUNT(DISTINCT u.id)
FROM yerdle_users AS u
  JOIN yerdle_posting_transitions AS pt ON u.id = pt.claimer_id
    AND DATEDIFF(day, u.created_at, pt.created_at) >= 0 -- within 7 days
    AND DATEDIFF(day, u.created_at, pt.created_at) <= 6
    AND pt.to_state = 'claimed'
WHERE
  u.created_at >= '2015-01-01' AND u.created_at < CURRENT_DATE
GROUP BY 1
ORDER BY 1 DESC
