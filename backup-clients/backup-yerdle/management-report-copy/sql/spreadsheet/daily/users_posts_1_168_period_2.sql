SELECT
  TO_CHAR(day,'YYYY-MM-DD') AS day,
  COUNT(DISTINCT user_id)
FROM (
  SELECT
    DATE_TRUNC('day', u.created_at) AS day,
    u.id AS user_id
  FROM yerdle_users AS u
    JOIN yerdle_postings AS p ON u.id = p.poster_id
     AND DATEDIFF(day, u.created_at, p.created_at) >= 0 -- 1 day = signup day
     AND DATEDIFF(day, u.created_at, p.created_at) <= 167
  WHERE
    u.created_at >= '2015-01-01' AND u.created_at < CURRENT_DATE
  GROUP BY 1, 2
  HAVING COUNT(*) >= 2
) AS multiple_postings
GROUP BY 1
ORDER BY 1 DESC
