SELECT
  TO_CHAR(DATE_TRUNC('day', pt.created_at),'YYYY-MM-DD') AS day,
  COUNT(DISTINCT pt.posting_id)
FROM yerdle_posting_transitions AS pt
  LEFT JOIN yerdle_echelon_transitions AS et
    ON pt.claimer_id = et.user_id
WHERE
  pt.created_at >= '2015-01-01' AND pt.created_at < CURRENT_DATE
  AND pt.to_state in ('claimed')
  AND et.to_state in ('pro')
  AND et.created_at <= pt.created_at
GROUP BY 1
ORDER BY 1 DESC
