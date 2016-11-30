SELECT
  TO_CHAR(DATE_TRUNC('month', updated_at), 'YYYY-MM-DD') AS month, -- NOTE: using updated_at
  COUNT(id)
FROM yerdle_wishes
WHERE
  created_at >= TO_CHAR(CURRENT_DATE-1, 'YYYY-MM-01') AND updated_at < CURRENT_DATE
  AND granted = TRUE
GROUP BY 1
ORDER BY 1 DESC;