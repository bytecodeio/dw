SELECT
  TO_CHAR(DATE_TRUNC('day', u.created_at),'YYYY-MM-DD') AS day,
  COUNT(DISTINCT u.id)
FROM yerdle_users AS u
JOIN
  ( SELECT
       created_at,
       poster_id AS transactor_id
     FROM yerdle_postings
     WHERE
       created_at >= '2015-01-01' AND created_at < CURRENT_DATE
     UNION
     SELECT
       created_at,
       to_user_id AS transactor_id
     FROM yerdle_transfers
     WHERE
       created_at >= '2015-01-01' AND created_at < CURRENT_DATE
  ) AS t ON u.id = t.transactor_id
  AND DATEDIFF(day, u.created_at, t.created_at) = 0 -- 1 day = signup day
WHERE
u.created_at >= '2015-01-01' AND u.created_at < CURRENT_DATE
GROUP BY 1
ORDER BY 1 DESC