SELECT
  TO_CHAR(DATE_TRUNC('month', activity_timestamp), 'YYYY-MM-DD') AS month,
  COUNT(DISTINCT user_id)
FROM mr_actives_vw
WHERE
  activity_timestamp >= '2015-01-01' AND activity_timestamp < TO_CHAR(CURRENT_DATE, 'YYYY-MM-01')
GROUP BY 1
ORDER BY 1 DESC;
