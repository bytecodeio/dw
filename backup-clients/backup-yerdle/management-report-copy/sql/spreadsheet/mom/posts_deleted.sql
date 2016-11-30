SELECT
  TO_CHAR(DATE_TRUNC('month', pt.created_at), 'YYYY-MM-DD') AS month,
  COUNT(DISTINCT pt.posting_id)
FROM yerdle_posting_transitions AS pt
WHERE
  pt.created_at >= '2015-01-01' AND pt.created_at < TO_CHAR(CURRENT_DATE, 'YYYY-MM-01')
  AND pt.to_state IN ('user_pulled', 'admin_pulled')
GROUP BY 1
ORDER BY 1 DESC
