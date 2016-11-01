== ===================================================================================================
== Table wayfair_covisit_all_last30days
== ===================================================================================================
SHOW TABLES LIKE 'wayfair_covisit_all_last30days';
desc table wayfair_covisit_all_last30days;
-- ALTER TABLE wayfair_covisit_all_last30days DROP CLUSTERING KEY;
alter table  wayfair_covisit_all_last30days cluster by (source_entity_value, target_entity_value);
alter table wayfair_covisit_all_last30days recluster max_size=10036439552;

-- Numbers for rows clustered 
94447193 - rows clustered
SELECT SYSTEM$CLUSTERING_RATIO('wayfair_covisit_all_last30days');
69.565794304 % 


== ===================================================================================================
== Table wayfair_url_entity_map_last30days
== ===================================================================================================

SHOW TABLES LIKE 'wayfair_url_entity_map_last30days';
desc table wayfair_url_entity_map_last30days;
alter table wayfair_url_entity_map_last30days cluster by (entity_value, rawurl);
alter table wayfair_url_entity_map_last30days recluster max_size=20209053696;
SELECT SYSTEM$CLUSTERING_RATIO('wayfair_url_entity_map_last30days');
58%



== ===================================================================================================
== Table wayfair_internal_query_performance_last30days
== ===================================================================================================

SHOW TABLES LIKE 'wayfair_internal_query_performance_last30days';
desc table wayfair_internal_query_performance_last30days;
alter table wayfair_internal_query_performance_last30days cluster by (entity_value, landing_page_views);
alter table wayfair_internal_query_performance_last30days recluster max_size=203358976;
SELECT SYSTEM$CLUSTERING_RATIO('wayfair_internal_query_performance_last30days');
96%




