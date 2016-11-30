-- Populate mr_inventory_daily summary table
UPDATE mr_inventory_daily
SET count=inv.c
FROM (
       SELECT CURRENT_DATE-1 AS date, COUNT(DISTINCT posting_id) as c
        FROM yerdle_posting_transitions AS start_post
        WHERE start_post.to_state IN ('granting', 'up')
          AND CURRENT_DATE > start_post.created_at
          AND start_post.posting_id NOT IN (
            SELECT DISTINCT posting_id
            FROM yerdle_posting_transitions
            WHERE
              to_state IN ('claimed', 'expired', 'user_pulled', 'admin_pulled')
              AND created_at < CURRENT_DATE
          )
     ) AS inv
WHERE inv.date=mr_inventory_daily.date;

-- Pull data from summary table
SELECT TO_CHAR(date, 'YYYY-MM-DD') AS day, count
FROM mr_inventory_daily
WHERE
  date >= '2015-01-01' AND date < CURRENT_DATE
ORDER BY 1 DESC;

