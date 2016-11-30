SELECT
  TO_CHAR(DATE_TRUNC('month', a.day), 'YYYY-MM-DD') AS month,
  COUNT(DISTINCT pt.posting_id)
FROM (
       SELECT DISTINCT
         DATE_TRUNC('day', d.date) AS day,
         u.id AS user_id
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
         d.date >= '2015-01-01' AND d.date < CURRENT_DATE
         AND DATEDIFF(month, u.created_at, a.activity_timestamp) > 2
         AND DATEDIFF(month, d.date, a.activity_timestamp) = 0
         -- NOTE: Only count rows are retained ongoing for user
         AND t.month IS NOT NULL -- NOT NULL here means active this and last month
       GROUP BY 1, 2
     ) AS a
  JOIN yerdle_posting_transitions AS pt ON a.user_id = pt.claimer_id
    AND a.day = DATE_TRUNC('day', pt.created_at)
    AND pt.to_state = 'claimed'
    AND pt.created_at >= '2015-01-01' AND pt.created_at < TO_CHAR(DATE_TRUNC('month', CURRENT_DATE), 'YYYY-MM-DD')
GROUP BY 1
ORDER BY 1 DESC
