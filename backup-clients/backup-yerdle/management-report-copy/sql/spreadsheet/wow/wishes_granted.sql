SELECT
  TO_CHAR(DATE_TRUNC('week', updated_at), 'YYYY-MM-DD') AS week, -- NOTE: using updated_at
  COUNT(id)
FROM yerdle_wishes
WHERE
  created_at >= '2015-01-01' AND updated_at < TO_CHAR(DATE_TRUNC('week', CURRENT_DATE), 'YYYY-MM-DD')
  AND granted = TRUE
GROUP BY 1
ORDER BY 1 DESC
