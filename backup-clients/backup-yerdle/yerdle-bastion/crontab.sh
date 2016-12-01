# Management Report cron jobs. Run at 4:00 UTC as stated on Manamgent Report
#Daily
0 9 * * * /root/bin/management-report-daily.sh   >> /root/management-report/management-report.log 2>&1
# Weekly
0 10 * * 1 /root/bin/management-report-weekly.sh  >> /root/management-report/management-report.log 2>&1
# Monthly (insert column runs at midnight pst on the 1st of the month)
0 12 1 * * /root/bin/management-report-monthly.sh >> /root/management-report/management-report.log 2>&1
# Commented on 5/11/2016. Uncommented on 6/3/106. #TODO: Modify this to post to byte_bot slack channel.  
30 15 * * * /root/db_checks/wrapper.sh >> /root/db_checks/table_counts.log 2>&1
45 15 * * * /root/db_checks/lag_wrapper.sh >> /root/db_checks/postgres_lag.log 2>&1
#Daily Segment Job. 
40 13 * * * /root/bin/segment-report-daily.sh   >> /root/management-report/segment-report.log 2>&1
