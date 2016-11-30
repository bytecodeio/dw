
-- COALESCE(flub_counts.count, 0::bigint)::numeric / (flub_counts.count::numeric + received_give_counts.count::numeric) AS flub_rate,

SELECT COUNT(*) AS flubs, DATE_TRUNC('day', created_at) AS day, user_id
FROM yerdle_flubs
GROUP BY day, user_id
ORDER BY day, user_id


SELECT postings_with_released_ownerships.poster_id AS user_id,
       count(*) AS count
FROM postings_with_released_ownerships
GROUP BY postings_with_released_ownerships.poster_id

--postings_with_released_ownerships
SELECT
  p.poster_id AS user_id,
  p.created_at
FROM yerdle_postings AS p
  JOIN yerdle_ownerships AS o ON o.id = p.ownership_id
  LEFT JOIN yerdle_ownership_transitions AS ot ON ot.id = o.ownership_transition_id
WHERE ot.to_state = 'released'
limit 10


SELECT
    day,
    SUM(count) OVER (ORDER BY day ROWS UNBOUNDED PRECEDING) AS sum FROM ( -- window function summing daily over all time
        SELECT
          TO_CHAR(DATE_TRUNC('day', created_at) :: DATE, 'YYYY-MM-DD') AS day,
          COUNT(poster_id) AS count
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
                 yerdle_ownership_transitions.to_state::TEXT = 'released' :: TEXT
             ) AS all_users
        WHERE
          pos = 25 -- 25th give by rank.
        GROUP BY 1
      ) AS users_day_count