SELECT
  a.month,
  (a.fulfilled::float / a.total::float) as rate
FROM (
       SELECT
         TO_CHAR(DATE_TRUNC('month', f.created_at), 'YYYY-MM-DD') AS month,
         SUM( CASE WHEN f.fulfilled THEN 1 ELSE 0 END) as fulfilled,
         COUNT( DISTINCT f.delivery_id ) AS total
       FROM (
              SELECT
                t.delivery_id as delivery_id,
                MAX(t.created_at) as created_at,
                (CASE WHEN t.delivery_id IN (
                  SELECT
                    DISTINCT e.delivery_id
                  FROM yerdle_delivery_events e
                    LEFT JOIN yerdle_transfers t
                      on t.delivery_id = e.delivery_id
                  WHERE
                    e.to_state in ('shipped', 'delivered')
                    AND t.created_at + '10 days'::INTERVAL > e.created_at
                ) THEN true ELSE false END) as fulfilled
              FROM yerdle_transfers t
                JOIN yerdle_deliveries d
                  ON t.delivery_id = d.id AND d.type = 'Pickup'
              GROUP BY 1
              ORDER BY created_at DESC
            ) f
       GROUP BY 1
     ) a
WHERE a.month >= '2015-01-01' AND a.month < TO_CHAR(CURRENT_DATE, 'YYYY-MM-01')
ORDER BY 1 DESC
