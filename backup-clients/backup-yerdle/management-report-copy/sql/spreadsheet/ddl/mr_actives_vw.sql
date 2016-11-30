-- ************************************************************************************
--  mr_actives_vw
--  management report actives view joining keen and segment
-- ************************************************************************************

-- table for story daily inventory for management report
CREATE VIEW mr_actives_vw AS
SELECT
  original_timestamp AS activity_timestamp,
  user_id::integer
FROM segment_raw
WHERE
  type = 'track'
  AND (segment_raw.event::text ILIKE 'transaction_part'::text OR segment_raw.event::text ILIKE 'wish'::text OR segment_raw.event::text ILIKE 'search'::text OR segment_raw.event::text ILIKE 'visit'::text OR segment_raw.event::text ILIKE 'post'::text)
  AND user_id IS NOT NULL
  AND STRPOS(user_id, 'user_') = 0 -- filter out usr_02d26a8bfbbce178 ids
  AND original_timestamp >= '2016-01-01'
UNION ALL
SELECT
  keen_timestamp AS activity_timestamp,
  user_id
FROM keen_raw
WHERE
  event IN ('transaction_part', 'wish', 'search', 'visit', 'post')
  AND user_id IS NOT NULL
  AND keen_timestamp < '2016-01-01';

GRANT ALL ON analytics.mr_actives_vw to group db_production_group;
GRANT SELECT ON analytics.mr_actives_vw to group db_readonly_group;
