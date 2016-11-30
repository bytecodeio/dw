-- retained-new (Joined 2 months ago, active this month)
SELECT
  TO_CHAR(DATE_TRUNC('day', a.day), 'YYYY-MM-DD') AS day,
  COUNT(DISTINCT pt.posting_id)
FROM (
       SELECT DISTINCT
         DATE_TRUNC('day', d.date) AS day,
         u.id AS user_id
       FROM etl_dates AS d
         LEFT JOIN mr_actives_vw AS a ON d.date = DATE_TRUNC('day', a.activity_timestamp)
         JOIN yerdle_users AS u ON a.user_id = u.id
       WHERE
         d.date >= '2015-01-01' AND d.date < CURRENT_DATE
         AND DATEDIFF(month, u.created_at, a.activity_timestamp) = 2
         AND DATEDIFF(month, d.date, a.activity_timestamp) = 0
       GROUP BY 1, 2
     ) AS a
  JOIN yerdle_posting_transitions AS pt ON a.user_id = pt.claimer_id
    AND a.day = DATE_TRUNC('day', pt.created_at)
    AND pt.to_state = 'claimed'
    AND pt.created_at >= '2015-01-01' AND pt.created_at < CURRENT_DATE
GROUP BY 1
ORDER BY 1 DESC
