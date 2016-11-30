SELECT
  TO_CHAR(DATE_TRUNC('day', created_at),'YYYY-MM-DD') AS day,
  (SUM(ABS(cents::float))/100) as dollars
FROM yerdle_line_item_bases
WHERE
  created_at >= '2015-01-01' AND created_at < CURRENT_DATE
  AND type IN ('LineItem::Bundling')
GROUP BY 1
ORDER BY 1 DESC
