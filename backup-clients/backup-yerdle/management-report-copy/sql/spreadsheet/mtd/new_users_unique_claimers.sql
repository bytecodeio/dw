SELECT
  TO_CHAR(DATE_TRUNC('month', u.created_at),'YYYY-MM-DD') AS month,
  COUNT(DISTINCT u.id)
FROM yerdle_users AS u
  JOIN yerdle_posting_transitions AS pt ON u.id = pt.claimer_id
    AND DATE_TRUNC('day', u.created_at) = DATE_TRUNC('day', pt.created_at)
    AND pt.to_state = 'claimed'
WHERE
  u.created_at >= TO_CHAR(CURRENT_DATE-1, 'YYYY-MM-01') AND u.created_at < CURRENT_DATE
GROUP BY 1
ORDER BY 1 DESC