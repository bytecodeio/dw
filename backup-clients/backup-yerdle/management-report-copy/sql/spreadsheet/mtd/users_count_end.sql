SELECT month, sum FROM (
  SELECT
    month,
    SUM(count) OVER (ORDER BY month ROWS UNBOUNDED PRECEDING) AS sum FROM (
      SELECT
      TO_CHAR(DATE_TRUNC('month', created_at)::date, 'YYYY-MM-DD') AS month,
      COUNT(id) AS count
      FROM yerdle_users
        WHERE created_at < CURRENT_DATE
      GROUP BY 1
      ORDER BY 1 DESC
      ) AS users_day_count
      ORDER BY month DESC
  ) AS users_sum
WHERE month >= TO_CHAR(CURRENT_DATE-1, 'YYYY-MM-01') AND month < CURRENT_DATE
