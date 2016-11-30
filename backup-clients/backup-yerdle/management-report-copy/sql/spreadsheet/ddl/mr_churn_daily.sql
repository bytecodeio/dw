-- ************************************************************************************
--  mr_churn_daily
--  management report churn create tables
-- ************************************************************************************

--  ( registered >=60 days and NOT active in last 30 days ) / (registered >=60 days ago AND active in last 60 days )

-- table for story daily churn for management report
CREATE TABLE mr_churn_daily
(
  day DATE SORTKEY,
  not_active_30_day_count INTEGER,
  active_60_day_count INTEGER
);
GRANT ALL ON analytics.mr_churn_daily to group db_production_group;
GRANT SELECT ON analytics.mr_churn_daily to group db_readonly_group;

-- Populating dates so all data is always updated.
INSERT INTO mr_churn_daily (day)
  SELECT date FROM etl_dates WHERE date >= '2015-01-01';

/*
# Shell script to populate historical data. Set i to the number of days from CURRENT_DATE
for i in `seq 1 376` ; do
psql -h analytics.c1szeu5viq2r.us-east-1.redshift.amazonaws.com -U charlie_killian -d production -p 5439 -c "
UPDATE mr_churn_daily
SET not_active_30_day_count=a.count
FROM (
SELECT
CURRENT_DATE-${i} AS day,
count(*) AS count
FROM (
SELECT
DISTINCT user_id
FROM etl_actives_daily AS ead
JOIN yerdle_users AS u ON ead.user_id = u.id
WHERE
ead.day >= DATEADD(day, -60, CURRENT_DATE-${i})
AND ead.day <= CURRENT_DATE-${i}
AND DATEDIFF(day, u.created_at, ead.day) >= 60
EXCEPT
SELECT
DISTINCT user_id
FROM etl_actives_daily AS ead
JOIN yerdle_users AS u ON ead.user_id = u.id
WHERE
ead.day >= DATEADD(day, -30, CURRENT_DATE-${i})
AND ead.day <= CURRENT_DATE-${i}
AND DATEDIFF(day, u.created_at, ead.day) >= 60
) AS inv
) AS a
WHERE a.day=mr_churn_daily.day;
"
done

for i in `seq 1 376` ; do
psql -h analytics.c1szeu5viq2r.us-east-1.redshift.amazonaws.com -U charlie_killian -d production -p 5439 -c "
UPDATE mr_churn_daily
SET active_60_day_count=a.count
FROM (
SELECT
CURRENT_DATE-${i} AS day,
count(*) AS count
FROM (
SELECT
-- All users with activity in last 60 days.
DISTINCT user_id
FROM etl_actives_daily AS ead
JOIN yerdle_users AS u ON ead.user_id = u.id
WHERE
ead.day >= DATEADD(day, -60, CURRENT_DATE-${i})
AND ead.day <= CURRENT_DATE-${i}
AND DATEDIFF(day, u.created_at, ead.day) >= 60
) AS inv
) AS a
WHERE a.day=mr_churn_daily.day;
"
done
*/

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
