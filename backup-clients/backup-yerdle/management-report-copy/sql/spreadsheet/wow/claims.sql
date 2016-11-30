
SELECT
  TO_CHAR(DATE_TRUNC('week', created_at),'YYYY-MM-DD') AS week,
  COUNT(DISTINCT posting_id)
FROM yerdle_posting_transitions
WHERE
  created_at >= '2015-01-01' AND created_at < TO_CHAR(DATE_TRUNC('week', CURRENT_DATE), 'YYYY-MM-DD')
  AND to_state in ('claimed')
GROUP BY 1
ORDER BY 1 DESC
