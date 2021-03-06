SELECT
  TO_CHAR(DATE_TRUNC('month', i.created_at), 'YYYY-MM-DD') AS month,
  COUNT(i.id)
FROM yerdle_deliveries d
  JOIN yerdle_invoices i ON d.id = i.delivery_id
  LEFT JOIN yerdle_line_item_bases li ON i.id = li.invoice_id AND li.type = 'LineItem::Shipping'
WHERE
  d.type = 'Shipment'
  AND li.type IS NULL
  AND i.created_at >= '2015-01-01' AND i.created_at < TO_CHAR(CURRENT_DATE, 'YYYY-MM-01')
  AND d.id IN (
    SELECT -- delivery_ids for first time claimers.
      t.delivery_id
    FROM yerdle_posting_transitions AS p0
      LEFT JOIN yerdle_posting_transitions AS p1 ON p0.claimer_id = p1.claimer_id
        AND (p0.claimer_id IS NOT NULL AND p1.claimer_id IS NOT NULL)
        AND p1.created_at < p0.created_at
      JOIN yerdle_transfers AS t ON p0.posting_id = t.posting_id
    WHERE
      p1.id IS NULL
      AND p0.claimer_id IS NOT NULL
  )
GROUP BY 1
ORDER BY 1 DESC
