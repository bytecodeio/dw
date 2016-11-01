ALTER SESSION SET USE_CACHED_RESULT = False;
-- Before the main SQL
!print '================================================================================================================================='
select '&filename_long' filename_long, '&filename_short' filename_short, '&start_status' start_status, current_timestamp() start_timestamp;

--204
ORDER BY exit_rate DESC LIMIT 1000; 
-- After the main SQL
select '&filename_long' filename_long, '&filename_short' filename_short, '&end_status' end_status, current_timestamp() end_timestamp;
select 1;>

