SELECT
  TO_CHAR(DATE_TRUNC('day', up.created_at), 'YYYY-MM-DD') AS day,
  COUNT(DISTINCT up.posting_id)
FROM yerdle_posting_transitions AS pt
  JOIN ( -- don't double count by deduping to first create_at
         SELECT
           pt.posting_id AS posting_id,
           MIN(pt.created_at) AS created_at
         FROM yerdle_posting_transitions AS pt
         WHERE
           pt.created_at >= '2015-01-01' AND pt.created_at < CURRENT_DATE
           AND pt.to_state IN ('up', 'granting')
         GROUP BY 1
       ) AS up
    ON pt.posting_id = up.posting_id AND DATEDIFF(day, up.created_at, pt.created_at) <= 28
WHERE pt.to_state IN ('claimed')
GROUP BY 1
ORDER BY 1 DESC
