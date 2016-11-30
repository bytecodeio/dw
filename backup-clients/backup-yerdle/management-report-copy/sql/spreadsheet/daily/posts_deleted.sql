SELECT
  TO_CHAR(DATE_TRUNC('day', pt.created_at), 'YYYY-MM-DD') AS day,
  COUNT(DISTINCT pt.posting_id)
FROM yerdle_posting_transitions AS pt
WHERE
  pt.created_at >= '2015-01-01' AND pt.created_at < CURRENT_DATE
  AND pt.to_state IN ('user_pulled', 'admin_pulled')
GROUP BY 1
ORDER BY 1 DESC
