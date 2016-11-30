
SELECT
  month,
  AVG(c)
FROM
  (
    SELECT
      TO_CHAR(DATE_TRUNC('month', yerdle_invoices.created_at), 'YYYY-MM-DD') AS month,
      yerdle_invoices.id,
      COUNT(yerdle_transfers.id)::float AS c
    FROM yerdle_invoices
      JOIN yerdle_transfers ON yerdle_invoices.delivery_id = yerdle_transfers.delivery_id
    WHERE
      yerdle_invoices.created_at >= TO_CHAR(CURRENT_DATE-1, 'YYYY-MM-01') AND yerdle_invoices.created_at < CURRENT_DATE
    GROUP BY 1, 2
    HAVING COUNT(yerdle_transfers.id) > 1
  ) AS bundles
GROUP BY 1
ORDER BY 1 DESC
