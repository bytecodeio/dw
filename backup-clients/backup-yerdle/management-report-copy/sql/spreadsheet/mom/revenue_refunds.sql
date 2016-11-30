
SELECT
  TO_CHAR(DATE_TRUNC('month', coalesce(cents_refunded_at, yrd_refunded_at)),'YYYY-MM-DD') AS month,
  (SUM(ABS(cents))/100)::FLOAT as dollars
FROM yerdle_line_item_bases
WHERE
  cents_refunded_at >= '2015-01-01' AND cents_refunded_at < TO_CHAR(CURRENT_DATE, 'YYYY-MM-01')
  AND type IN ('LineItem::Service', 'LineItem::Bundling', 'LineItem::PurchasedYrdContribution')
  AND  (cents_refunded_at IS NOT NULL OR yrd_refunded_at IS NOT NULL)
GROUP BY 1
ORDER BY 1 DESC
