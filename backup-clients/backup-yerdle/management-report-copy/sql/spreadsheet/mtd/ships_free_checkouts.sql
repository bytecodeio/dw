
SELECT
  TO_CHAR(DATE_TRUNC('month', i.created_at), 'YYYY-MM-DD') AS month,
  COUNT(i.id)
FROM yerdle_deliveries d
  JOIN yerdle_invoices i ON d.id = i.delivery_id
  LEFT JOIN yerdle_line_item_bases li ON i.id = li.invoice_id AND li.type = 'LineItem::Shipping'
WHERE
  d.type = 'Shipment'
  AND li.type IS NULL
  AND i.created_at >= TO_CHAR(CURRENT_DATE-1, 'YYYY-MM-01') AND i.created_at < CURRENT_DATE
GROUP BY 1
ORDER BY 1 DESC

/* deliveries of type Shipment without LineItem::Shipping are paid. */
