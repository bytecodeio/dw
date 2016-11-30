
SELECT
  week,
  COUNT(*)
FROM
  (
    SELECT
      TO_CHAR(DATE_TRUNC('week', i.created_at), 'YYYY-MM-DD') AS week,
      i.id,
      COUNT(t.id)
    FROM yerdle_deliveries d
      JOIN yerdle_invoices i
        ON d.id = i.delivery_id
      JOIN yerdle_line_item_bases li
        ON i.id = li.invoice_id and li.type = 'LineItem::Shipping'
      JOIN yerdle_transfers t
        ON d.id = t.delivery_id
    WHERE
      d.type = 'Shipment'
      AND i.created_at >= '2015-01-01' AND i.created_at < TO_CHAR(DATE_TRUNC('week', CURRENT_DATE), 'YYYY-MM-DD')
    GROUP BY 1, 2
    HAVING COUNT(t.id) > 1
  ) AS bundles
GROUP BY 1
ORDER BY 1 DESC
