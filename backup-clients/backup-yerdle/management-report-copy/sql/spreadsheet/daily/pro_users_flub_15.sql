-- NOTE: Flub rate is calculated for the last day. Historic DATA is not tracked
SELECT
  TO_CHAR(CURRENT_DATE-1, 'YYYY-MM-DD') AS day,
  COUNT(*)
FROM yerdle_pro_users_vw
WHERE flub_rate >= 0.15
  AND count_of_received_gives >= 25
  AND last_active_at >= CURRENT_DATE-1 -- since yesterday.
GROUP BY 1
ORDER BY 1 DESC
