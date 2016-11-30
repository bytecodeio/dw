
SELECT
  day,
  AVG(c)
FROM
  (
    SELECT
      TO_CHAR(DATE_TRUNC('day', yerdle_invoices.created_at), 'YYYY-MM-DD') AS day,
      yerdle_invoices.id,
      COUNT(yerdle_transfers.id)::float AS c
    FROM yerdle_invoices
      JOIN yerdle_transfers ON yerdle_invoices.delivery_id = yerdle_transfers.delivery_id
    WHERE
      yerdle_invoices.created_at >= '2015-01-01' AND yerdle_invoices.created_at < CURRENT_DATE
    GROUP BY 1, 2
    HAVING COUNT(yerdle_transfers.id) > 1
  ) AS bundles
GROUP BY 1
ORDER BY 1 DESC
