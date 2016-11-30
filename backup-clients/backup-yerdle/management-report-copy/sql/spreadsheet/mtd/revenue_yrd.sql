
SELECT
  TO_CHAR(DATE_TRUNC('month', created_at),'YYYY-MM-DD') AS month,
  (SUM(ABS(cents::float))/100) as dollars
FROM yerdle_line_item_bases
WHERE
  created_at >= TO_CHAR(CURRENT_DATE-1, 'YYYY-MM-01') AND created_at < CURRENT_DATE
  AND type IN ('LineItem::PurchasedYrdContribution')
GROUP BY 1
ORDER BY 1 DESC
