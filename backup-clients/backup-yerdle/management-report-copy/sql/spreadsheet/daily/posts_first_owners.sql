SELECT
  TO_CHAR(DATE_TRUNC('DAY', p.created_at), 'YYYY-MM-DD') AS day,
  COUNT(p.posting_id)
FROM (
       SELECT
         MIN(o.posting_id) AS posting_id,
         MIN(o.created_at) AS created_at
       FROM yerdle_ownerships AS o
       GROUP BY o.item_id
       HAVING COUNT(o.item_id) = 1
     ) p
WHERE p.created_at >= '2015-01-01' AND p.created_at < CURRENT_DATE
GROUP BY 1
ORDER BY 1 DESC
