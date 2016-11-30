SELECT
  TO_CHAR(DATE_TRUNC('month', pt.created_at), 'YYYY-MM-DD') AS month,
  COUNT(DISTINCT pt.posting_id)
FROM yerdle_posting_transitions AS pt
WHERE
  pt.created_at >= TO_CHAR(CURRENT_DATE-1, 'YYYY-MM-01') AND pt.created_at < CURRENT_DATE
  AND pt.to_state IN ('expired')
GROUP BY 1
ORDER BY 1 DESC
