-- ************************************************************************************
--  mr_churn_monthly
--  management report churn create tables
-- ************************************************************************************

-- (Not active this month) / (Active last month. Registered >= 2 months ago)

-- table for story daily churn for management report
CREATE TABLE mr_churn_monthly
(
  month DATE SORTKEY,
  not_active_this_month_count INTEGER,
  active_last_month_count INTEGER
);
GRANT ALL ON analytics.mr_churn_monthly to group db_production_group;
GRANT SELECT ON analytics.mr_churn_monthly to group db_readonly_group;

-- Populating dates so all data is always updated.
INSERT INTO mr_churn_monthly (month)
SELECT DATE_TRUNC('month', date) AS month FROM etl_dates WHERE date >= '2015-01-01' GROUP BY month ORDER BY month;

/*
# Shell script to populate historical data. Set i to the number of days from CURRENT_DATE
for i in `seq 1 12` ; do
j=$((i+1))
k=$((i-1))
psql -h analytics.c1szeu5viq2r.us-east-1.redshift.amazonaws.com -U charlie_killian -d production -p 5439 -c "
UPDATE mr_churn_monthly
SET not_active_this_month_count=a.count
FROM (
SELECT
TO_CHAR(DATEADD(month, -${i}, CURRENT_DATE), 'YYYY-MM-01') AS month,
count(*) AS count
FROM (
SELECT
-- All users with activity in last 2 months
DISTINCT user_id
FROM etl_actives_daily AS ead
JOIN yerdle_users AS u ON ead.user_id = u.id
WHERE
ead.day >= TO_CHAR(DATEADD(month, -${j}, CURRENT_DATE), 'YYYY-MM-01')
AND ead.day < TO_CHAR(DATEADD(month, -${k}, CURRENT_DATE), 'YYYY-MM-01')
AND DATEDIFF(month, u.created_at, ead.day) >= 2
EXCEPT
SELECT
-- All users with activity in last 1 month
DISTINCT user_id
FROM etl_actives_daily AS ead
JOIN yerdle_users AS u ON ead.user_id = u.id
WHERE
ead.day >= TO_CHAR(DATEADD(month, -${i}, CURRENT_DATE), 'YYYY-MM-01')
AND ead.day < TO_CHAR(DATEADD(month, -${k}, CURRENT_DATE), 'YYYY-MM-01')
AND DATEDIFF(month, u.created_at, ead.day) >= 2
) AS inv
) AS a
WHERE a.month=mr_churn_monthly.month;
"
done

for i in `seq 1 12` ; do
j=$((i+1))
psql -h analytics.c1szeu5viq2r.us-east-1.redshift.amazonaws.com -U charlie_killian -d production -p 5439 -c "
UPDATE mr_churn_monthly
SET active_last_month_count=a.count
FROM (
SELECT
TO_CHAR(DATEADD(month, -${i}, CURRENT_DATE), 'YYYY-MM-01') AS month,
count(*) AS count
FROM (
SELECT
-- All users with activity in last 2 months
DISTINCT user_id
FROM etl_actives_daily AS ead
JOIN yerdle_users AS u ON ead.user_id = u.id
WHERE
ead.day >= TO_CHAR(DATEADD(month, -${j}, CURRENT_DATE), 'YYYY-MM-01')
AND ead.day < TO_CHAR(DATEADD(month, -${i}, CURRENT_DATE), 'YYYY-MM-01')
AND DATEDIFF(month, u.created_at, ead.day) >= 2
) AS inv
) AS a
WHERE a.month=mr_churn_monthly.month;
"
done
*/

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
                AND ead.day < TO_CHAR(CURRENT_DATE, 'YYYY-MM-01')
                AND DATEDIFF(month, u.created_at, ead.day) >= 2
              EXCEPT
              SELECT
                -- All users with activity in last 1 month
                DISTINCT user_id
              FROM etl_actives_daily AS ead
                JOIN yerdle_users AS u ON ead.user_id = u.id
              WHERE
                ead.day >= TO_CHAR(DATEADD(month, -1, CURRENT_DATE), 'YYYY-MM-01')
                AND ead.day < TO_CHAR(CURRENT_DATE, 'YYYY-MM-01')
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
                AND ead.day < TO_CHAR(CURRENT_DATE, 'YYYY-MM-01')
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
