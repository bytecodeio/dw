-- All users who visited in last 7 days
WITH recent_users AS
( 
SELECT id AS user_id
  FROM yerdle_users 
 WHERE last_visit >= CURRENT_DATE - '7 days'::INTERVAL 
),
-- Get the data to be sent to Segment
all_users_data AS 
(
SELECT x.user_id              AS user_id, 
       MAX(x.last_login_date) AS last_login_date,
       MAX(x.last_claim_date) AS last_claim_date ,
       MAX(x.last_given_date) AS last_given_date,
       MAX(x.claims_count)    AS claims_count,
       MAX(x.given_count)     AS given_count
FROM ( 
SELECT id         AS user_id,
       updated_at AS last_login_date,
       NULL       AS last_claim_date,
       NULL       AS last_given_date,
       0          AS claims_count,
       0          AS given_count 
  FROM yerdle_users
UNION ALL
SELECT
       claimer_id                 AS user_id,
       NULL                       AS last_login_date,
       MAX(created_at)            AS last_claim_date,
       NULL                       AS last_given_date,
       COUNT(distinct posting_id) AS claims_count,
       0                          AS given_count
 FROM yerdle_posting_transitions 
WHERE
      created_at >= '2015-01-01' AND created_at < CURRENT_DATE
  AND to_state in ('claimed')
GROUP BY claimer_id
UNION ALL
SELECT
       p.poster_id          AS user_id,
       NULL                 AS last_login_date,    
       NULL                 AS last_claim_date,    
       MAX(pt.created_at)   AS last_given_date,
       0                    AS claims_count,
       COUNT(distinct p.id) AS given_count
  FROM 
       yerdle_posting_transitions pt
  JOIN yerdle_postings p 
    ON p.id = pt.posting_id
WHERE
      pt.created_at >= '2015-01-01' AND pt.created_at < CURRENT_DATE
  AND pt.to_state in ('claimed')
GROUP BY p.poster_id
)  X 
GROUP BY x.user_id
)
-- Convert dates to strings(ISO 8601 format) to be used in JSON 
SELECT d.user_id, 
       u.first_name || ' ' || u.last_name user_name,
       u.first_name || ' ' || u.last_name user_name,
       TO_CHAR(d.last_login_date, 'YYYY-MM-DD HH24:MI:SS') last_login_date,
       TO_CHAR(d.last_claim_date, 'YYYY-MM-DD HH24:MI:SS') last_claim_date,
       TO_CHAR(d.last_given_date, 'YYYY-MM-DD HH24:MI:SS') last_given_date,
       d.claims_count,
       d.given_count
  FROM recent_users r 
  JOIN all_users_data d 
    ON r.user_id = d.user_id
  JOIN yerdle_users u 
    ON u.id = r.user_id
 ORDER BY 1