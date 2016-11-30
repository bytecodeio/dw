SELECT week, sum FROM (
  SELECT
    week,
    SUM(count) OVER (ORDER BY week ROWS UNBOUNDED PRECEDING) AS sum FROM (
      SELECT
      TO_CHAR(DATE_TRUNC('week', created_at)::date, 'YYYY-MM-DD') AS week,
      COUNT(id) AS count
      FROM yerdle_users
        WHERE created_at < TO_CHAR(DATE_TRUNC('week', CURRENT_DATE), 'YYYY-MM-DD')
      GROUP BY 1
      ORDER BY 1 DESC
      ) AS users_day_count
      ORDER BY week DESC
  ) AS users_sum
WHERE week >= '2015-01-01' AND week < TO_CHAR(DATE_TRUNC('week', CURRENT_DATE), 'YYYY-MM-DD')
