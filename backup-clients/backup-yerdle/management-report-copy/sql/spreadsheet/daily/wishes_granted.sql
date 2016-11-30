SELECT
  TO_CHAR(DATE_TRUNC('day', updated_at), 'YYYY-MM-DD') AS day, -- NOTE: using updated_at
  COUNT(id)
FROM yerdle_wishes
WHERE
  created_at >= '2015-01-01' AND updated_at < CURRENT_DATE
  AND granted = TRUE
GROUP BY 1
ORDER BY 1 DESC;