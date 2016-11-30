SELECT
  TO_CHAR(DATE_TRUNC('month', u.created_at),'YYYY-MM-DD') AS month,
  COUNT(DISTINCT u.id)
FROM yerdle_users AS u
  JOIN yerdle_postings AS p ON u.id = p.poster_id
    AND DATEDIFF(day, u.created_at, p.created_at) >= 0 -- 1 day = signup day
    AND DATEDIFF(day, u.created_at, p.created_at) <= 167
  LEFT JOIN yerdle_referrals AS r ON u.id = r.referred_user_id AND r.referring_user_id IN (769521, 553536, 815601, 816736, 816346, 817171, 817716, 818226, 818259, 818903, 818089, 818097, 821146, 847085)
  LEFT JOIN yerdle_promotion_bases AS pb ON u.signup_promotion_id = pb.id AND pb.type = 'Promotion::Signup' AND pb.parallelable = 't'
WHERE
  u.created_at >= '2015-01-01' AND u.created_at < TO_CHAR(CURRENT_DATE, 'YYYY-MM-01')
  AND (r.referred_user_id IS NOT NULL OR pb.id IS NOT NULL)
GROUP BY 1
ORDER BY 1 DESC
