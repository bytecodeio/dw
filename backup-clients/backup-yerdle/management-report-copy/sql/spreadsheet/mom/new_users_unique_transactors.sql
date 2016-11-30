SELECT
  TO_CHAR(DATE_TRUNC('month', u.created_at),'YYYY-MM-DD') AS month,
  COUNT(DISTINCT u.id)
FROM yerdle_users AS u
  JOIN
  ( SELECT
      created_at,
      poster_id AS transactor_id
    FROM yerdle_postings
    WHERE
      created_at >= '2015-01-01' AND created_at < TO_CHAR(CURRENT_DATE, 'YYYY-MM-01')
    UNION
    SELECT
      created_at,
      to_user_id AS transactor_id
    FROM yerdle_transfers
    WHERE
      created_at >= '2015-01-01' AND created_at < TO_CHAR(CURRENT_DATE, 'YYYY-MM-01')
  ) AS t ON u.id = t.transactor_id
WHERE
  u.created_at >= '2015-01-01' AND u.created_at < TO_CHAR(CURRENT_DATE, 'YYYY-MM-01')
  AND DATEDIFF(month, u.created_at, t.created_at) = 0 -- same month
GROUP BY 1
ORDER BY 1 DESC