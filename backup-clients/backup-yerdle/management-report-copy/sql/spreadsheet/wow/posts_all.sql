
SELECT
  TO_CHAR(DATE_TRUNC('week', created_at),'YYYY-MM-DD') AS week,
  COUNT(id)
FROM yerdle_postings
WHERE
  created_at >= '2015-01-01' AND created_at < TO_CHAR(DATE_TRUNC('week', CURRENT_DATE), 'YYYY-MM-DD')
GROUP BY 1
ORDER BY 1 DESC
