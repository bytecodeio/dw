-- 1. users_per_month: 
-- Find list of all active users for each month
-- 2. shipping_credits_for_users:
-- Shipping credits redeemed - backfill logic:
-- Redeemd credits are outstanding between the month in which they are created, 
-- and EXCLUDING the month in which they are redeemed. 
-- Shipping credits unredeemed:
-- Unredeemed credits are outstanding between the month in which they were created, 
-- and INCLUDING the month in which they will/would have expire(d). 
-- e.g. Credit created in DEC, and redeemed in FEB, is outstanding in DEC, and JAN.
-- e.g. Credit created in DEC, not redeemed, and expired in FEB, is oustanding in DEC, JAN, FEB. 
-- NOTE 1: Logic for redeemed credits - take the invoice created date, and use the < sign. This excludes the month in which the invoice was created.
-- NOTE 2: Logic for unredeemed credits - take the expired date, go to the FIRST of following month, and use the < sign. This includes the expired month.
WITH  users_per_month AS
(
SELECT
      DISTINCT user_id,
      TO_CHAR(DATE_TRUNC('MONTH', activity_timestamp), 'YYYY-MM-DD') AS active_month
FROM
      mr_actives_vw
WHERE
      activity_timestamp >= '2015-01-01'
  AND activity_timestamp < TO_CHAR(CURRENT_DATE, 'YYYY-MM-01')
),
shipping_credits_for_users AS
(
 SELECT 
        s.user_id, 
		s.created_at, 
		i.created_at AS redeemed_at
   FROM
        yerdle_shipping_credits s
   JOIN yerdle_invoices i
     ON i.shipping_credit_id = s.id
  WHERE
        s.redeemed = 't'
UNION ALL
SELECT 
        s.user_id, 
		s.created_at, 
		DATEADD(MONTH, 1, TO_DATE(s.expires_at, 'YYYY-MM-01')) AS redeemed_at
   FROM 
        yerdle_shipping_credits s
  WHERE 
        s.redeemed = 'f' 
)
SELECT  
       u.active_month, 
	   COUNT( DISTINCT r.user_id)
FROM
       users_per_month u
 JOIN  shipping_credits_for_users r
    ON r.user_id = u.user_id
WHERE TO_DATE(u.active_month, 'YYYY-MM-DD') >= TO_DATE(r.created_at, 'YYYY-MM-01') 
  AND TO_DATE(u.active_month, 'YYYY-MM-DD') <  TO_DATE(r.redeemed_at, 'YYYY-MM-01')
GROUP BY 1
ORDER BY 1 DESC
