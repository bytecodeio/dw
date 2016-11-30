SELECT
  TO_CHAR(DATE_TRUNC('day', u.created_at),'YYYY-MM-DD') AS day,
  COUNT(DISTINCT p.id)
FROM yerdle_users AS u
  JOIN yerdle_postings AS p ON u.id = p.poster_id
  AND DATEDIFF(day, u.created_at, p.created_at) >= 1 -- Day 2 = day after signup = date diff of 1
  AND DATEDIFF(day, u.created_at, p.created_at) <= 27
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
