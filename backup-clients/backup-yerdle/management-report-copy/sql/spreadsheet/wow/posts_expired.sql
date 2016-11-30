SELECT
  TO_CHAR(DATE_TRUNC('week', pt.created_at), 'YYYY-MM-DD') AS week,
  COUNT(DISTINCT pt.posting_id)
FROM yerdle_posting_transitions AS pt
WHERE
  pt.created_at >= '2015-01-01' AND pt.created_at < TO_CHAR(DATE_TRUNC('week', CURRENT_DATE), 'YYYY-MM-DD')
  AND pt.to_state IN ('expired')
GROUP BY 1
ORDER BY 1 DESC
