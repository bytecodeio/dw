
SELECT
  TO_CHAR(DATE_TRUNC('month', created_at),'YYYY-MM-DD') AS month,
  COUNT(DISTINCT transactor_id)
FROM (
       SELECT
         created_at,
         poster_id AS transactor_id
       FROM yerdle_postings
       WHERE
         created_at >= TO_CHAR(CURRENT_DATE-1, 'YYYY-MM-01') AND created_at < CURRENT_DATE
       UNION
       SELECT
         created_at,
         to_user_id AS transactor_id
       FROM yerdle_transfers
       WHERE
         created_at >= TO_CHAR(CURRENT_DATE-1, 'YYYY-MM-01') AND created_at < CURRENT_DATE
     ) AS transactors
GROUP BY 1
ORDER BY 1 DESC
