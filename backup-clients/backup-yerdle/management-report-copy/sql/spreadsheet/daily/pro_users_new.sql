
SELECT
  TO_CHAR(DATE_TRUNC('day', created_at), 'YYYY-MM-DD') AS day,
  COUNT(poster_id)
FROM (
       SELECT
         yerdle_postings.poster_id, yerdle_ownership_transitions.created_at,
         rank()  OVER (PARTITION BY yerdle_postings.poster_id ORDER BY yerdle_ownership_transitions.created_at ASC) AS pos
       FROM yerdle_postings
         JOIN yerdle_ownerships ON yerdle_ownerships.id = yerdle_postings.ownership_id
         JOIN yerdle_ownership_transitions ON yerdle_ownership_transitions.id = yerdle_ownerships.ownership_transition_id
       WHERE
         yerdle_ownership_transitions.to_state::text = 'released'::text
     ) AS all_users
WHERE
  pos = 25 -- 25th give by rank. See pro_users view
  AND created_at >= '2015-01-01' AND created_at < CURRENT_DATE
GROUP BY 1
ORDER BY 1 DESC;
