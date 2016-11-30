SELECT
  TO_CHAR(DATE_TRUNC('day', u.created_at),'YYYY-MM-DD') AS day,
  COUNT(DISTINCT u.id)
FROM yerdle_users AS u
  JOIN yerdle_posting_transitions AS pt ON u.id = pt.claimer_id
    AND DATEDIFF(day, u.created_at, pt.created_at) >= 28
    AND DATEDIFF(day, u.created_at, pt.created_at) <= 167
    AND pt.to_state = 'claimed'
  JOIN -- paid signups are from localytics
    (   SELECT customer_id
        FROM localytics_ios
        WHERE
        acquire_source IN ('Facebook-External', 'Facebook')
        AND LEN(customer_id) < 18 -- filter out non-yerdle user ids
      UNION -- ios and android
        SELECT customer_id
        FROM localytics_android
        WHERE
          acquire_source IN ('Facebook-External', 'Facebook')
          AND LEN(customer_id) < 18 -- filter out non-yerdle user ids
    ) AS sign_up ON u.id = sign_up.customer_id
WHERE
  u.created_at >= '2015-01-01' AND u.created_at < CURRENT_DATE
GROUP BY 1
ORDER BY 1 DESC