-- ( registered >=60 days and NOT active in last 30 days ) / (registered >=60 days ago AND active in last 60 days )


-- Populate mr_inventory_daily summary table
UPDATE mr_churn_daily
SET not_active_30_day_count=a.count
FROM (
  SELECT
    CURRENT_DATE AS day,
    count(*) AS count
  FROM (
         SELECT
           -- All users with activity in last 60 days.
           DISTINCT user_id
         FROM etl_actives_daily AS ead
           JOIN yerdle_users AS u ON ead.user_id = u.id
         WHERE
           ead.day >= DATEADD(day, -60, CURRENT_DATE)
           AND ead.day <= CURRENT_DATE
           AND DATEDIFF(day, u.created_at, ead.day) >= 60
         EXCEPT
         SELECT
           -- All users with activity in last 30 days.
           DISTINCT user_id
         FROM etl_actives_daily AS ead
           JOIN yerdle_users AS u ON ead.user_id = u.id
         WHERE
           ead.day >= DATEADD(day, -30, CURRENT_DATE)
           AND ead.day <= CURRENT_DATE
           AND DATEDIFF(day, u.created_at, ead.day) >= 60
       ) AS inv
) AS a
WHERE a.day=mr_churn_daily.day;

UPDATE mr_churn_daily
SET active_60_day_count=a.count
FROM (
       SELECT
         CURRENT_DATE AS day,
         count(*) AS count
       FROM (
              SELECT
                -- All users with activity in last 60 days.
                DISTINCT user_id
              FROM etl_actives_daily AS ead
                JOIN yerdle_users AS u ON ead.user_id = u.id
              WHERE
                ead.day >= DATEADD(day, -60, CURRENT_DATE)
                AND ead.day <= CURRENT_DATE
                AND DATEDIFF(day, u.created_at, ead.day) >= 60
            ) AS inv
     ) AS a
WHERE a.day=mr_churn_daily.day;

-- Pull data from summary table
SELECT TO_CHAR(day, 'YYYY-MM-DD') AS day, not_active_30_day_count::float / active_60_day_count::float AS result
FROM mr_churn_daily
WHERE
  day >= '2015-01-01' AND day < CURRENT_DATE
ORDER BY 1 DESC;