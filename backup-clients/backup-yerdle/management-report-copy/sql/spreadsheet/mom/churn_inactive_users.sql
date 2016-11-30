-- (Not active this month) / (Active last month. Registered >= 2 months ago)

-- Populate mr_churn_monthly summary table
UPDATE mr_churn_monthly
SET not_active_this_month_count=a.count
FROM (
       SELECT
         TO_CHAR(DATEADD(month, -1, CURRENT_DATE), 'YYYY-MM-01') AS month,
         count(*) AS count
       FROM (
              SELECT
                -- All users with activity in last 2 months
                DISTINCT user_id
              FROM etl_actives_daily AS ead
                JOIN yerdle_users AS u ON ead.user_id = u.id
              WHERE
                ead.day >= TO_CHAR(DATEADD(month, -2, CURRENT_DATE), 'YYYY-MM-01')
                AND ead.day <= TO_CHAR(CURRENT_DATE, 'YYYY-MM-01')
                AND DATEDIFF(month, u.created_at, ead.day) >= 2
              EXCEPT
              SELECT
                -- All users with activity in last 1 month
                DISTINCT user_id
              FROM etl_actives_daily AS ead
                JOIN yerdle_users AS u ON ead.user_id = u.id
              WHERE
                ead.day >= TO_CHAR(DATEADD(month, -1, CURRENT_DATE), 'YYYY-MM-01')
                AND ead.day <= TO_CHAR(CURRENT_DATE, 'YYYY-MM-01')
                AND DATEDIFF(month, u.created_at, ead.day) >= 2
            ) AS inv
     ) AS a
WHERE a.month=mr_churn_monthly.month;

UPDATE mr_churn_monthly
SET active_last_month_count=a.count
FROM (
       SELECT
         TO_CHAR(DATEADD(month, -1, CURRENT_DATE), 'YYYY-MM-01') AS month,
         count(*) AS count
       FROM (
              SELECT
                -- All users with activity in last 2 months
                DISTINCT user_id
              FROM etl_actives_daily AS ead
                JOIN yerdle_users AS u ON ead.user_id = u.id
              WHERE
                ead.day >= TO_CHAR(DATEADD(month, -2, CURRENT_DATE), 'YYYY-MM-01')
                AND ead.day <= TO_CHAR(CURRENT_DATE, 'YYYY-MM-01')
                AND DATEDIFF(month, u.created_at, ead.day) >= 2
            ) AS inv
     ) AS a
WHERE a.month=mr_churn_monthly.month;

-- Pull data from summary table
SELECT TO_CHAR(month, 'YYYY-MM-DD') AS month, not_active_this_month_count::float / active_last_month_count::float AS result
FROM mr_churn_monthly
WHERE
  month >= '2015-01-01' AND month < TO_CHAR(CURRENT_DATE, 'YYYY-MM-01')
ORDER BY 1 DESC;