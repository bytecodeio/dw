-- ************************************************************************************
--  mr_inventory
--  management report inventory create tables
-- ************************************************************************************

-- table for story daily inventory for management report
CREATE TABLE mr_inventory_daily
(
  date DATE SORTKEY,
  count INTEGER
);
GRANT ALL ON analytics.mr_inventory_daily to group db_production_group;
GRANT SELECT ON analytics.mr_inventory_daily to group db_readonly_group;

-- Populating dates so all data is always updated.
INSERT INTO mr_inventory_daily (date, count)
  SELECT date, NULL FROM etl_dates WHERE date >= '2015-01-01';

/*
# Shell script to populate historical data. Set i to the number of days from CURRENT_DATE
for i in `seq 1 376` ; do
j=$((i-1))
psql -h analytics.c1szeu5viq2r.us-east-1.redshift.amazonaws.com -U charlie_killian -d production -p 5439 -c "UPDATE mr_inventory_daily SET count=inv.c FROM ( SELECT CURRENT_DATE-${i} AS date, COUNT(DISTINCT posting_id) as c FROM yerdle_posting_transitions AS start_post WHERE start_post.to_state IN ('granting', 'up') AND CURRENT_DATE-${j} > start_post.created_at AND start_post.posting_id NOT IN ( SELECT posting_id FROM yerdle_posting_transitions WHERE to_state IN ('claimed', 'expired', 'user_pulled', 'admin_pulled') AND created_at < CURRENT_DATE-${j} ) ) AS inv WHERE inv.date=mr_inventory_daily.date"
done
 */