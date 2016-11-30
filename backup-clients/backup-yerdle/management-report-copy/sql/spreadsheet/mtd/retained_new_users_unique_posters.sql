SELECT
  TO_CHAR(DATE_TRUNC('month', a.day), 'YYYY-MM-DD') AS month,
  COUNT(DISTINCT a.user_id)
FROM (
       SELECT DISTINCT
         DATE_TRUNC('day', d.date) AS day,
         u.id AS user_id
       FROM etl_dates AS d
         LEFT JOIN mr_actives_vw AS a ON d.date = DATE_TRUNC('day', a.activity_timestamp)
         JOIN yerdle_users AS u ON a.user_id = u.id
       WHERE
         d.date >= TO_CHAR(CURRENT_DATE-1, 'YYYY-MM-01') AND d.date < CURRENT_DATE
         AND DATEDIFF(month, u.created_at, a.activity_timestamp) = 2
         AND DATEDIFF(month, d.date, a.activity_timestamp) = 0
       GROUP BY 1, 2
     ) AS a
  JOIN yerdle_postings AS p ON a.user_id = p.poster_id AND a.day = DATE_TRUNC('day', p.created_at) AND p.created_at >= TO_CHAR(CURRENT_DATE-1, 'YYYY-MM-01') AND p.created_at < CURRENT_DATE
GROUP BY 1
ORDER BY 1 DESC