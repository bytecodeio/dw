
SELECT
  TO_CHAR(DATE_TRUNC('day', created_at),'YYYY-MM-DD') AS day,
  COUNT(DISTINCT posting_id)
FROM yerdle_posting_transitions
WHERE
  created_at >= '2015-01-01' AND created_at < CURRENT_DATE
  AND to_state in ('claimed')
GROUP BY 1
ORDER BY 1 DESC
