-- ************************************************************************************
--  etl_actives
--  Staging table for actives
-- ************************************************************************************

-- table for calculating actives on the management report
CREATE TABLE etl_actives
(
  user_id INTEGER SORTKEY,
  month DATE
);
GRANT ALL ON analytics.etl_actives to group db_production_group;
GRANT SELECT ON analytics.etl_actives to group db_readonly_group;

-- Staging table to merge into etl_actives
CREATE TABLE etl_actives_staging
(
  user_id INTEGER SORTKEY,
  month DATE
);
GRANT ALL ON analytics.etl_actives_staging to group db_production_group;
GRANT SELECT ON analytics.etl_actives_staging to group db_readonly_group;

-- ETL to update etl_actives. Can be run on a ongoing basis because it does a Redshift merge.
TRUNCATE TABLE etl_actives_staging;

START TRANSACTION ;

INSERT INTO etl_actives_staging (user_id, month)
SELECT user_id, DATE_TRUNC('MONTH', original_timestamp)::DATE AS month
FROM segment_raw
WHERE type = 'track'
AND original_timestamp >= DATE_TRUNC('month', DATEADD ('month', -1, CURRENT_DATE)) -- Only pull from 1 month ago to today
GROUP BY user_id, month;

DELETE FROM etl_actives
USING etl_actives_staging
WHERE
  etl_actives.user_id = etl_actives_staging.user_id
  AND etl_actives.month = etl_actives_staging.month;

INSERT INTO etl_actives
  SELECT * FROM etl_actives_staging;

END TRANSACTION ;
