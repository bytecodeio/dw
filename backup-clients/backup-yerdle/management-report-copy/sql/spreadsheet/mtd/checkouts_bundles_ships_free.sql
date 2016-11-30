
SELECT
  month,
  COUNT(*)
FROM
  (
    SELECT
      TO_CHAR(DATE_TRUNC('month', i.created_at), 'YYYY-MM-DD') AS month,
      i.id,
      COUNT(t.id)
    FROM yerdle_deliveries d
      JOIN yerdle_invoices i
        ON d.id = i.delivery_id
      LEFT JOIN yerdle_line_item_bases li
        ON i.id = li.invoice_id and li.type = 'LineItem::Shipping'
      JOIN yerdle_transfers t
        ON d.id = t.delivery_id
    WHERE
      d.type = 'Shipment'
      AND li.type IS NULL
      AND i.created_at >= TO_CHAR(CURRENT_DATE-1, 'YYYY-MM-01') AND i.created_at < CURRENT_DATE
    GROUP BY 1, 2
    HAVING COUNT(t.id) > 1
  ) AS bundles
GROUP BY 1
ORDER BY 1 DESC
