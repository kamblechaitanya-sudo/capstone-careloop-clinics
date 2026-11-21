-- Task 2.1 — Build and load the database 

SELECT COUNT(*) AS appointments, SUM(no_show) AS no_shows
FROM appointments;

SELECT COUNT(*) AS clinics
FROM clinics;


-- Duplicate test: 
INSERT INTO appointments VALUES ('A0001', 'P509', 'C05', '2025-01-24', '2025-01-25', 60, 'F', 18.0, 850, 'Phone', 'Consultation', 'Yes', 1, 'No-Show', 1, 1);
-- Error Code: 1062. Duplicate entry 'A0001' for key 'appointments.PRIMARY'	0.016 sec


-- Task 2.2 — No-show rate by clinic 

SELECT 
	c.clinic_id,
    c.clinic_name,
    c.city,
    COUNT(*) AS appointments,
    SUM(a.no_show) AS no_shows,
    ROUND(100.0 * SUM(a.no_show) / COUNT(*), 1) AS no_show_pct 
FROM appointments AS a
JOIN clinics AS c
	ON a.clinic_id = c.clinic_id
GROUP BY c.clinic_id, c.clinic_name, c.city
HAVING COUNT(*) >= 95
ORDER BY no_show_pct DESC;
	
-- Hadapsar Care Centre	Pune	143	39	(highest no_show_pct) 27.3

-- Task 2.3 — Does booking far ahead matter?

select
	lead_band,
    COUNT(*) AS appointments,
    SUM(no_show) AS no_shows,
    ROUND(100.0 * SUM(no_show) / COUNT(*), 1) AS no_show_pct
FROM (
	SELECT
		CASE
        	WHEN lead_days <= 7 THEN '1-7'
			WHEN lead_days <= 14 THEN '8-14'
			WHEN lead_days <= 30 THEN '15-30'
			ELSE '31+'
		END AS lead_band,
        lead_days,
        no_show
	FROM appointments
) AS banded

GROUP BY lead_band
ORDER BY MIN(lead_days);

-- Task 2.4 — Month-by-month trend 

WITH monthly AS (
	SELECT
		SUBSTR(appt_date, 1, 7) AS month,
        COUNT(*) AS appointments,
        ROUND(100.0 * SUM(no_show) / COUNT(*),1) AS no_show_pct
	FROM appointments
    GROUP BY SUBSTR(appt_date, 1, 7)
)

SELECT
	month,
    appointments,
    no_show_pct,
    LAG(no_show_pct) OVER (ORDER BY month) AS previous_month_pct,
    ROUND(
		no_show_pct - LAG(no_show_pct) OVER (ORDER BY month),
        1
	) AS change_pp
FROM monthly
Order by month;

-- Task 2.5 — Rank clinics inside each city 

WITH clinic_rates AS (
	SELECT
		c.clinic_id,
        c.clinic_name,
        c.city,
        ROUND(100.0 * SUM(a.no_show) / COUNT(*) , 1) AS no_show_pct
	FROM appointments as a
    JOIN clinics AS c
		ON a.clinic_id = c.clinic_id
	group by c.clinic_id, c.clinic_name, c.city
)

SELECT
	clinic_name,
    city,
    no_show_pct,
    RANK() OVER (
		PARTITION BY city
        ORDER BY no_show_pct DESC
	) AS rank_in_city,
    CASE
		WHEN no_show_pct > (
			SELECT 100.0 * SUM(no_show) / COUNT(*)
            FROM appointments
		) THEN 'above'
        WHEN no_show_pct < (
			SELECT 100.0 * SUM(no_show) / COUNT(*)
            FROM appointments
		) THEN 'below'
        ELSE 'equal'
	END AS vs_overall
FROM clinic_rates
ORDER BY city, rank_in_city;