SELECT
  TO_CHAR(DATE_TRUNC('day', u.created_at),'YYYY-MM-DD') AS day,
  COUNT(DISTINCT pt.id)
FROM yerdle_users AS u
  JOIN yerdle_posting_transitions AS pt ON u.id = pt.claimer_id
    AND DATEDIFF(day, u.created_at, pt.created_at) = 0 -- 1 day = signup day
    AND pt.to_state = 'claimed'
  LEFT JOIN yerdle_referrals AS r ON u.id = r.referred_user_id AND r.referring_user_id IN (769521, 553536, 815601, 816736, 816346, 817171, 817716, 818226, 818259, 818903, 818089, 818097, 821146, 847085)
  LEFT JOIN yerdle_promotion_bases AS pb ON u.signup_promotion_id = pb.id AND pb.type = 'Promotion::Signup' AND pb.parallelable = 't'
WHERE
  u.created_at >= '2015-01-01' AND u.created_at < CURRENT_DATE
  AND (r.referred_user_id IS NOT NULL OR pb.id IS NOT NULL)
GROUP BY 1
ORDER BY 1 DESC
