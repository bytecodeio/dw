SELECT
  TO_CHAR(DATE_TRUNC('month', a.activity_timestamp), 'YYYY-MM-DD') AS month,
  COUNT(DISTINCT a.user_id)
FROM mr_actives_vw AS a
  JOIN (
      SELECT
        created_at AS pro_at,
        poster_id AS user_id
      FROM (
             SELECT
               yerdle_postings.poster_id,
               yerdle_ownership_transitions.created_at,
               rank()
               OVER (PARTITION BY yerdle_postings.poster_id
                 ORDER BY yerdle_ownership_transitions.created_at ASC) AS pos
             FROM yerdle_postings
               JOIN yerdle_ownerships ON yerdle_ownerships.id = yerdle_postings.ownership_id
               JOIN yerdle_ownership_transitions
                 ON yerdle_ownership_transitions.id = yerdle_ownerships.ownership_transition_id
             WHERE
               yerdle_ownership_transitions.to_state::TEXT = 'released'::TEXT
           ) AS all_users
      WHERE
        pos = 25 -- 25th give by rank.
      ORDER BY 1 DESC
    ) AS pros
    ON a.user_id = pros.user_id
WHERE
  a.activity_timestamp >= TO_CHAR(CURRENT_DATE-1, 'YYYY-MM-01') AND a.activity_timestamp < CURRENT_DATE
  AND activity_timestamp >= pros.pro_at
GROUP BY 1
ORDER BY 1 DESC;
