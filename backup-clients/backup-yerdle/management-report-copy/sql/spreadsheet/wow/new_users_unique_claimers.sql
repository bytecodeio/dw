SELECT
  TO_CHAR(DATE_TRUNC('week', u.created_at),'YYYY-MM-DD') AS week,
  COUNT(DISTINCT u.id)
FROM yerdle_users AS u
  JOIN yerdle_posting_transitions AS pt ON u.id = pt.claimer_id
    AND DATE_TRUNC('day', u.created_at) = DATE_TRUNC('day', pt.created_at)
    AND pt.to_state = 'claimed'
WHERE
  u.created_at >= '2015-01-01' AND u.created_at < TO_CHAR(DATE_TRUNC('week', CURRENT_DATE), 'YYYY-MM-DD')
GROUP BY 1
ORDER BY 1 DESC