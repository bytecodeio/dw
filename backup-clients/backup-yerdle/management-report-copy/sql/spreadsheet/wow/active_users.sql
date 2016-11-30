SELECT
  TO_CHAR(DATE_TRUNC('week', activity_timestamp), 'YYYY-MM-DD') AS week,
  COUNT(DISTINCT user_id)
FROM mr_actives_vw
WHERE
  activity_timestamp >= '2015-01-01' AND activity_timestamp < TO_CHAR(DATE_TRUNC('week', CURRENT_DATE), 'YYYY-MM-DD')
GROUP BY 1
ORDER BY 1 DESC;
