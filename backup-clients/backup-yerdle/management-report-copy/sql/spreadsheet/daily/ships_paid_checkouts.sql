SELECT
  TO_CHAR(DATE_TRUNC('day', i.created_at), 'YYYY-MM-DD') AS day,
  COUNT(i.id)
FROM yerdle_deliveries d
  JOIN yerdle_invoices i ON d.id = i.delivery_id
  JOIN yerdle_line_item_bases li ON i.id = li.invoice_id AND li.type = 'LineItem::Shipping'
WHERE
  d.type = 'Shipment'
  AND i.created_at >= '2015-01-01' AND i.created_at < CURRENT_DATE
GROUP BY 1
ORDER BY 1 DESC

/* deliveries of type Shipment with LineItem::Shipping are paid. */
