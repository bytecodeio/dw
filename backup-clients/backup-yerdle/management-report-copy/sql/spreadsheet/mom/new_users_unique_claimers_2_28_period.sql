SELECT
  TO_CHAR(DATE_TRUNC('month', u.created_at),'YYYY-MM-DD') AS month,
  COUNT(DISTINCT u.id)
FROM yerdle_users AS u
  JOIN yerdle_posting_transitions AS pt ON u.id = pt.claimer_id
  AND DATEDIFF(day, u.created_at, pt.created_at) >= 1 -- Day 2 = day after signup = date diff of 1
  AND DATEDIFF(day, u.created_at, pt.created_at) <= 27
  AND pt.to_state = 'claimed'
WHERE
  u.created_at >= '2015-01-01' AND u.created_at < TO_CHAR(CURRENT_DATE, 'YYYY-MM-01')
GROUP BY 1
ORDER BY 1 DESC