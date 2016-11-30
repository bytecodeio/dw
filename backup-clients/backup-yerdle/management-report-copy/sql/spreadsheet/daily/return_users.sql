-- return (Joined 1 month ago, active this month)
SELECT DISTINCT
	TO_CHAR(DATE_TRUNC('day', d.date), 'YYYY-MM-DD') AS day,
	COUNT(DISTINCT u.id)
FROM etl_dates AS d
	LEFT JOIN mr_actives_vw AS a ON d.date = DATE_TRUNC('day', a.activity_timestamp)
	JOIN yerdle_users AS u ON a.user_id = u.id
WHERE
	d.date >= '2015-01-01' AND d.date < CURRENT_DATE
	AND DATEDIFF(month, u.created_at, a.activity_timestamp) = 1
	AND DATEDIFF(month, d.date, a.activity_timestamp) = 0
GROUP BY 1
ORDER BY 1 DESC