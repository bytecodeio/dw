-- Get the list of months we are interested in.
WITH etl_dates_t AS (
SELECT
      DISTINCT
      TO_CHAR(DATE_TRUNC('MONTH', d.date), 'YYYY-MM-DD') AS active_month
FROM
      etl_dates d
WHERE
      d.date >= TO_DATE('2015-01-01', 'YYYY-MM-DD')
  AND d.date <  TO_CHAR(CURRENT_DATE, 'YYYY-MM-01')
),
-- This will give 2 records for a posting, if it was in 'up'/'granting',
-- and then moved to the terminal state like 'expired'/'pulled' etc.
-- Else one record.
all_posting_states AS
(
SELECT
      pt.posting_id      AS posting_id,
      MIN(pt.created_at) AS posted_at,
      NULL               AS claimed_at
FROM
      yerdle_posting_transitions AS pt
WHERE
      pt.created_at >= '2015-01-01'
  AND pt.created_at <  TO_CHAR(CURRENT_DATE, 'YYYY-MM-01')
  AND pt.to_state IN ('up', 'granting')
GROUP BY 1
UNION ALL
SELECT
       pt.posting_id         AS posting_id,
       NULL                  AS posted_at,
       MIN(pt.created_at)    AS claimed_at
FROM
       yerdle_posting_transitions AS pt
WHERE
       pt.created_at >= '2015-01-01'
   AND pt.created_at <  TO_CHAR(CURRENT_DATE, 'YYYY-MM-01')
   AND pt.to_state NOT IN ('up', 'granting')
GROUP BY 1
),
-- Collapse the 2 records for a posting_id to one by using an aggregate - MAX.
-- Posts for which 'up'/'granting' date is unavailable, default "posted_at" to '2015-01-01' -beginning of time.
-- Posts which have not been 'claimed'/'expired' etc., and are currently active, default "claimed_at" to 1st of current month.
flat_postings_record AS
(
SELECT ps.posting_id,
       p.yrd_price,
       MAX(COALESCE(TO_CHAR(ps.posted_at, 'YYYY-MM-01'), '2015-01-01')) posted_at,
       MAX(COALESCE(TO_CHAR(ps.claimed_at, 'YYYY-MM-01'), TO_CHAR(CURRENT_DATE, 'YYYY-MM-01')))  claimed_at
FROM
       all_posting_states ps
JOIN   yerdle_postings p
  ON   p.id = ps.posting_id
GROUP BY 1, 2
)
-- Simple inner join is fine since every month will have some postings. 
SELECT d.active_month,
       SUM(p.yrd_price) total_yrd
FROM
       etl_dates_t d
JOIN   flat_postings_record p
  ON   d.active_month  BETWEEN p.posted_at AND  p.claimed_at
GROUP BY 1
ORDER BY 1 DESC