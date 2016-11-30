SELECT
  TO_CHAR(DATE_TRUNC('day', created_at), 'YYYY-MM-DD') AS day,
  COUNT(DISTINCT customer_id)
FROM (
    SELECT customer_id, min(at) AS created_at
    FROM localytics_ios
    WHERE
      acquire_source IN ('Facebook-External', 'Facebook')
      AND LEN(customer_id) < 18 -- filter out non-yerdle user ids
    GROUP BY customer_id
  UNION -- ios and android
    SELECT customer_id, min(at) AS created_at
    FROM localytics_android
    WHERE
      acquire_source IN ('Facebook-External', 'Facebook')
      AND LEN(customer_id) < 18 -- filter out non-yerdle user ids
    GROUP BY customer_id
) AS sign_up
WHERE
  created_at >= '2015-01-01' AND created_at < CURRENT_DATE
GROUP BY 1
ORDER BY 1 DESC
