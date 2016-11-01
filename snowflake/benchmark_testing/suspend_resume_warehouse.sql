-- suspend
!set echo=true
ALTER WAREHOUSE load_wh SUSPEND;
-- resume
ALTER WAREHOUSE load_wh RESUME;
SELECT 'warehouse resumed successfully' resume_warehouse, current_timestamp();
