SELECT
  TO_CHAR(DATE_TRUNC('day', pt.created_at),'YYYY-MM-DD') AS day,
  COUNT(DISTINCT pt.posting_id)
FROM yerdle_posting_transitions AS pt
  LEFT JOIN yerdle_echelon_transitions AS star
    ON pt.claimer_id = star.user_id AND star.to_state in ('star')
  LEFT JOIN yerdle_echelon_transitions AS pro
    ON pt.claimer_id = pro.user_id AND pro.to_state in ('pro')
WHERE
  pt.created_at >= '2015-01-01' AND pt.created_at < CURRENT_DATE
  AND pt.to_state in ('claimed')
  AND star.created_at <= pt.created_at
  AND (pt.created_at < pro.created_at OR pro.created_at IS NULL) -- filter out pro claims
GROUP BY 1
ORDER BY 1 DESC

-- checked using: AND star.user_id = 845832 and 845866
--
