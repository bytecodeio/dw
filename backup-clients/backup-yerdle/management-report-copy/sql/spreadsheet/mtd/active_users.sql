SELECT
  TO_CHAR(DATE_TRUNC('month', activity_timestamp), 'YYYY-MM-DD') AS month,
  COUNT(DISTINCT user_id)
FROM mr_actives_vw
WHERE
  activity_timestamp >= TO_CHAR(CURRENT_DATE-1, 'YYYY-MM-01') AND activity_timestamp < CURRENT_DATE
GROUP BY 1
ORDER BY 1 DESC;
