
SELECT
  week,
  fulfilled::float / total::float AS rate
FROM (
       SELECT
         TO_CHAR(DATE_TRUNC('week', f.created_at), 'YYYY-MM-DD') AS week,
         SUM( CASE WHEN f.fulfilled THEN 1 ELSE 0 END) as fulfilled,
         COUNT( DISTINCT f.delivery_id ) AS total
       FROM (
              SELECT
                t.delivery_id AS delivery_id,
                MAX(t.created_at) AS created_at,
                (
                  CASE WHEN t.delivery_id IN (
                    SELECT
                      DISTINCT e.delivery_id
                    FROM yerdle_delivery_events AS e
                      LEFT JOIN yerdle_transfers AS t ON t.delivery_id = e.delivery_id
                    WHERE
                      e.to_state IN ('shipped', 'delivered')
                      AND t.created_at + '10 days'::INTERVAL > e.created_at
                  ) THEN true ELSE false END
                ) as fulfilled
              FROM yerdle_transfers AS t
              GROUP BY 1
              ORDER BY created_at DESC
            ) AS f
       GROUP BY 1
     ) AS a
WHERE
  week >= '2015-01-01' AND week < TO_CHAR(DATE_TRUNC('week', CURRENT_DATE), 'YYYY-MM-DD')
ORDER BY 1 DESC
