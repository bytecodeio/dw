-- See reactivated_users.sql
SELECT
  TO_CHAR(DATE_TRUNC('month', a.day), 'YYYY-MM-DD') AS month,
  COUNT(DISTINCT p.id)
FROM (
      SELECT DISTINCT
        DATE_TRUNC('day', d.date) AS day,
        u.id                      AS user_id
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
        d.date >= TO_CHAR(CURRENT_DATE-1, 'YYYY-MM-01') AND d.date < CURRENT_DATE
        AND DATEDIFF(month, u.created_at, a.activity_timestamp) > 2
        AND DATEDIFF(month, d.date, a.activity_timestamp) = 0
        -- NOTE: Only count rows are in reactivated months for that user.
        AND t.month IS NULL -- NULL here means reactivated month
      ORDER BY 1 DESC
     ) AS a
  JOIN yerdle_postings AS p
    ON a.user_id = p.poster_id AND a.day = DATE_TRUNC('day', p.created_at) AND p.created_at >= TO_CHAR(CURRENT_DATE-1, 'YYYY-MM-01') AND
       p.created_at < CURRENT_DATE
GROUP BY 1
ORDER BY 1 DESC