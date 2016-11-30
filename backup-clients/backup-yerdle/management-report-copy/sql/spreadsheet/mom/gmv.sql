
SELECT
  TO_CHAR(DATE_TRUNC('month', created_at),'YYYY-MM-DD') AS month,
  SUM(ABS(yrd))
FROM yerdle_line_item_bases
WHERE
  created_at >= '2015-01-01' AND created_at < TO_CHAR(CURRENT_DATE, 'YYYY-MM-01')
  AND type IN ('LineItem::UserYrdContribution', 'LineItem::PurchasedYrdContribution')
GROUP BY 1
ORDER BY 1 DESC
