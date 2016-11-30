-- ETL to update etl_actives. Can be run on a ongoing basis because it does a Redshift merge.
TRUNCATE TABLE etl_actives_staging;

START TRANSACTION ;

INSERT INTO etl_actives_staging (user_id, month)
  SELECT user_id, DATE_TRUNC('MONTH', activity_timestamp)::DATE AS month
  FROM mr_actives_vw
  --WHERE activity_timestamp >= DATE_TRUNC('month', DATEADD ('month', -1, CURRENT_DATE)) -- Only pull from 1 month ago to today
  GROUP BY user_id, month;

DELETE FROM etl_actives
USING etl_actives_staging
WHERE
  etl_actives.user_id = etl_actives_staging.user_id
  AND etl_actives.month = etl_actives_staging.month;

INSERT INTO etl_actives
  SELECT * FROM etl_actives_staging;

END TRANSACTION ;


TRUNCATE TABLE etl_actives_daily_staging;

START TRANSACTION ;

INSERT INTO etl_actives_daily_staging (user_id, day)
  SELECT user_id, DATE_TRUNC('day', activity_timestamp)::DATE AS day
  FROM mr_actives_vw
  --WHERE activity_timestamp >= DATE_TRUNC('month', DATEADD ('month', -1, CURRENT_DATE)) -- Only pull from 1 month ago to today
  GROUP BY user_id, day;

DELETE FROM etl_actives_daily
USING etl_actives_daily_staging
WHERE
  etl_actives_daily.user_id = etl_actives_daily_staging.user_id
  AND etl_actives_daily.day = etl_actives_daily_staging.day;

INSERT INTO etl_actives_daily
  SELECT * FROM etl_actives_daily_staging;

END TRANSACTION ;

-- Get counts. NOTE: This does NOT use table above.
SELECT
  TO_CHAR(DATE_TRUNC('day', activity_timestamp), 'YYYY-MM-DD') AS day,
  COUNT(DISTINCT user_id)
FROM mr_actives_vw
WHERE
  activity_timestamp >= '2015-01-01' AND activity_timestamp < CURRENT_DATE
GROUP BY 1
ORDER BY 1 DESC;
