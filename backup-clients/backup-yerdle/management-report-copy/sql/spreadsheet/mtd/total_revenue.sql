
SELECT
  TO_CHAR(DATE_TRUNC('month', created_at),'YYYY-MM-DD') AS month,
  (SUM(ABS(cents::float))/100) as dollars
FROM yerdle_line_item_bases
WHERE
  created_at >= TO_CHAR(CURRENT_DATE-1, 'YYYY-MM-01') AND created_at < CURRENT_DATE
  AND type IN ('LineItem::Service', 'LineItem::Bundling', 'LineItem::PurchasedYrdContribution')
GROUP BY 1
ORDER BY 1 DESC

/*
d9t4qt8assu9io=> select distinct type from line_item_bases;
                type
------------------------------------
 LineItem::Bundling
 LineItem::UserYrdContribution
 LineItem::Service
 LineItem::PurchasedYrdContribution
 LineItem::Shipping
(5 rows)
 */
