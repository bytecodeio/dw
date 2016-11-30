SELECT
  TO_CHAR(DATE_TRUNC('day', i.created_at), 'YYYY-MM-DD') AS day,
  COUNT(DISTINCT i.id)
FROM yerdle_invoices AS i
  JOIN yerdle_line_item_bases li ON i.id = li.invoice_id AND li.type IN ('LineItem::Service', 'LineItem::Bundling')
WHERE
  i.created_at >= '2015-01-01' AND i.created_at < CURRENT_DATE
GROUP BY 1
ORDER BY 1 DESC
