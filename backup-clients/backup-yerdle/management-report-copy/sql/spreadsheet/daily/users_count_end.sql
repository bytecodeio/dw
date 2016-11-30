SELECT day, sum FROM (
  SELECT
    day,
    SUM(count) OVER (ORDER BY day ROWS UNBOUNDED PRECEDING) AS sum FROM (
      SELECT
      TO_CHAR(DATE_TRUNC('day', created_at)::date, 'YYYY-MM-DD') AS day,
      COUNT(id) AS count
      FROM yerdle_users
        WHERE created_at < CURRENT_DATE
      GROUP BY 1
      ORDER BY 1 DESC
      ) AS users_day_count
      ORDER BY day DESC
  ) AS users_sum
WHERE day >= '2015-01-01' AND day < CURRENT_DATE
