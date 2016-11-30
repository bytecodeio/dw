SELECT
  TO_CHAR(DATE_TRUNC('day', d.date), 'YYYY-MM-DD') AS day,
  stars_sum.sum - pros_sum.sum AS stars -- Daily stars are stars minus pros
FROM etl_dates AS d
JOIN ( -- pros
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
                 yerdle_ownership_transitions.to_state :: TEXT = 'released' :: TEXT
             ) AS all_users
        WHERE
          pos = 25 -- 25th give by rank.
        GROUP BY 1
      ) AS users_day_count
    ) AS pros_sum
    ON d.date = pros_sum.day
JOIN ( -- stars
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
                 yerdle_ownership_transitions.to_state :: TEXT = 'released' :: TEXT
             ) AS all_users
        WHERE
          pos = 10 -- 10th give by rank.
        GROUP BY 1
      ) AS users_day_count
    ) AS stars_sum
    ON d.date = stars_sum.day
WHERE
  d.date >= '2015-01-01' AND d.date < CURRENT_DATE
ORDER BY 1 DESC