/*

1. Changes to ~.snowflake/config file:

  a. Make sure that following options/variables are set in ~.snowflake/config file:
  -- variable_substitution=true
  -- start_status='START QUERY'
  -- end_status='END QUERY'

  b. Sample command when above are not set in ~.snowflake/config file:
  snowsql -o variable_substitution=true -D filename_long='[102070_queries_to_potentially_redirect]' -D filename_short=102070 -D start_status='START QUERY' -D end_status='END QUERY' -f 102070_queries_to_potentially_redirect.sql > op_102070.log 2>&1 &

2. Changes to queries to be benchmarked:

  Add following statements to before and after the SQL: 
  -- Before the main SQL
  !print '================================================================================================================================='
  select '&filename_long' filename_long, '&filename_short' filename_short, '&start_status' start_status, current_timestamp() start_timestamp;
  -- After the main SQL
  select '&filename_long' filename_long, '&filename_short' filename_short, '&end_status' end_status, current_timestamp() end_timestamp;
  select 1;>
*/

-- Preliminary step: Delete all logs.
-- rm *.log
snowsql -f suspend_resume_warehouse.sql > op_status_warehouse.log 2>&1   
snowsql -D filename_long='[204_high_exit_rate_search_queries]'              -D filename_short=[[204]]    -f 204_high_exit_rate_search_queries.sql              > op_204.log 2>&1   &
snowsql -D filename_long='[205_low_product_page_views_site_search_queries]' -D filename_short=[[205]]    -f 205_low_product_page_views_site_search_queries.sql > op_205.log 2>&1   &
snowsql -D filename_long='[206_low_atc_site_search_queries]'                -D filename_short=[[206]]    -f 206_low_atc_site_search_queries.sql                > op_206.log 2>&1   &
snowsql -D filename_long='[102047_site_search_queries_with_no_product_clicks]' -D filename_short=[[102047]]  -f 102047_site_search_queries_with_no_product_clicks.sql > op_102047.log 2>&1   &
snowsql -D filename_long='[102058_queries_with_lowest_rpv]'                 -D filename_short=[[102058]] -f 102058_queries_with_lowest_rpv.sql                 > op_102058.log 2>&1   &
snowsql -D filename_long='[102060_queries_with_highest_refinement]'         -D filename_short=[[102060]] -f 102060_queries_with_highest_refinement.sql         > op_102060.log 2>&1 & 
snowsql -D filename_long='[102070_queries_to_potentially_redirect]'         -D filename_short=[[102070]] -f 102070_queries_to_potentially_redirect.sql         > op_102070.log 2>&1 &

-- Audit step: Run the following to make sure all jobs are done.
-- jobs

-- Last Step: Run the benchmark extraction script which has awk commands to extract the start/end/execution times of queries.
-- ./benchmark_extract_results.sh

