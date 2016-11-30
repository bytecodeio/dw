-- Joined 3+ months ago, active this month, weren't active last month
-- NOTE: test sql with user_id = 74
SELECT
  TO_CHAR(DATE_TRUNC('month', d.date), 'YYYY-MM-DD') AS month,
  COUNT(DISTINCT u.id)
FROM etl_dates AS d
  LEFT JOIN mr_actives_vw AS a ON d.date = DATE_TRUNC('day', a.activity_timestamp)
  JOIN yerdle_users AS u ON a.user_id = u.id
  LEFT JOIN (
      SELECT p0.user_id AS user_id, p0.month AS month -- Join two mr_actives_vw tables with same data
      FROM (
             SELECT user_id, DATE_TRUNC('month', activity_timestamp) AS month
             FROM mr_actives_vw
             GROUP BY 1, 2
           ) AS p0
        JOIN (
               SELECT user_id, DATE_TRUNC('month', activity_timestamp) AS month
               FROM mr_actives_vw
               GROUP BY 1, 2
             ) AS p1
        ON p0.user_id = p1.user_id
          AND p0.month > p1.month -- Order
          AND datediff(month, p0.month, p1.month) = -1 -- 1 month apart
    ) AS t
  ON a.user_id = t.user_id AND t.month = DATE_TRUNC('month', a.activity_timestamp)
WHERE
  d.date >= '2015-01-01' AND d.date < TO_CHAR(DATE_TRUNC('month', CURRENT_DATE), 'YYYY-MM-DD')
  AND DATEDIFF(month, u.created_at, a.activity_timestamp) > 2
  AND DATEDIFF(month, d.date, a.activity_timestamp) = 0
  -- NOTE: Only count rows are in reactivated months for that user.
  AND t.month IS NULL -- NULL here means reactivated month
GROUP BY 1
ORDER BY 1 DESC
