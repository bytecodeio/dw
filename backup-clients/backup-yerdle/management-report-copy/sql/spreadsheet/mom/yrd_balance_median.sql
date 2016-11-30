-- First find list of all active users for each month
WITH  users_per_month AS
(
SELECT
      DISTINCT user_id,
      TO_CHAR(DATE_TRUNC('month', activity_timestamp), 'YYYY-MM-DD') AS active_month
FROM
      mr_actives_vw
WHERE
      activity_timestamp >= '2015-01-01'
      AND activity_timestamp < TO_CHAR(CURRENT_DATE, 'YYYY-MM-01')
),
-- Second, get the running total of each user in each month in which they were active.
-- NOTE 1: We do a DATEADD since we want the book_entries rows till the *end* of the active_month, OR
--       < than the first of next month
-- NOTE 2: We are not excluding book_entries < '2015-01-01' since this is a running total from Day 1.
users_running_total_by_month AS
(
SELECT
       u.user_id AS user_id,
       u.active_month AS active_month,
	   SUM(b.yrd) AS yrd_total
FROM
       yerdle_book_entries b
  JOIN users_per_month u
    ON b.user_id = u.user_id
WHERE
       b.created_at < DATEADD(month, 1, TO_DATE(u.active_month, 'YYYY-MM-DD'))
   AND b.type = 'UserBookEntry'
GROUP BY u.user_id, u.active_month
)
-- Find median
SELECT
      distinct r.active_month AS active_month,
	  MEDIAN(r.yrd_total) OVER( partition by r.active_month) yrd_median
FROM
      users_running_total_by_month r
ORDER BY 1 DESC