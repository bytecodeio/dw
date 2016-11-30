SELECT
  TO_CHAR(DATE_TRUNC('month', p.created_at), 'YYYY-MM-DD') AS month,
  COUNT(p.user_id)
FROM (
     SELECT
       p0.claimer_id AS user_id,
       p0.posting_id AS posting_id,
       p0.created_at
     FROM yerdle_posting_transitions AS p0
        LEFT JOIN yerdle_posting_transitions AS p1 ON p0.claimer_id = p1.claimer_id
        AND (p0.claimer_id IS NOT NULL AND p1.claimer_id IS NOT NULL)
        AND p1.created_at < p0.created_at
     WHERE
        p1.id IS NULL
        AND p0.claimer_id IS NOT NULL
   ) AS p
WHERE p.created_at >= '2015-01-01' AND p.created_at < TO_CHAR(CURRENT_DATE, 'YYYY-MM-01')
GROUP BY 1
ORDER BY 1 DESC

/*
production=# \d yerdle_posting_transitions
        Table "analytics.yerdle_posting_transitions"
      Column       |            Type             | Modifiers
-------------------+-----------------------------+-----------
 id                | integer                     |
 to_state          | character varying(65535)    |
 metadata          | character varying(65535)    |
 sort_key          | integer                     |
 posting_id        | integer                     |
 created_at        | timestamp without time zone |
 updated_at        | timestamp without time zone |
 down_after        | timestamp without time zone |
 granting_at       | timestamp without time zone |
 granted_wish_term | character varying(256)      |
 down_at           | timestamp without time zone |
 granted_wish_id   | integer                     |
 up_at             | timestamp without time zone |
 to_location       | character varying(1024)     |
 claimer_id        | integer
 */