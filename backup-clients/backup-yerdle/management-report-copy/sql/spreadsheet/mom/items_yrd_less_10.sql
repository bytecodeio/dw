SELECT 
      TO_CHAR(DATE_TRUNC('month', pt.created_at), 'YYYY-MM-DD') AS month,
      COUNT(DISTINCT pt.posting_id) count_items
FROM 
      yerdle_postings AS p
 JOIN yerdle_posting_transitions AS pt 
   ON pt.posting_id = p.id
WHERE  
      pt.created_at >= '2015-01-01' AND pt.created_at < TO_CHAR(CURRENT_DATE, 'YYYY-MM-01')
  AND p.yrd_price <= 10
  AND pt.to_state IN ('up', 'granting')
GROUP BY 1
ORDER BY 1 DESC