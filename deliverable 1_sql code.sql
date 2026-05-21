/*
   DIALECT: SQLITE
   PROJECT: 3MTT FELLOWSHIP ANALYTICS
   DELIVERABLE 1: SQL ANALYSIS
*/



/*
QUESTION 1
   Which 10 ALCs have the lowest completion rate
   in the most recent cohort?
 */

SELECT
       f.alc_code,
       f.geopolitical_zone,
       COUNT(*) AS total_enrolled,
       SUM(
           CASE
               WHEN f.completion_status = 'complete'
               THEN 1
               ELSE 0
           END
       ) AS completed_fellows,
       ROUND(
           SUM(
               CASE
                   WHEN f.completion_status = 'complete'
                   THEN 1
                   ELSE 0
               END
           ) * 100.0 / COUNT(*),
           2
       ) AS completion_rate
  FROM fellows AS f
 WHERE f.cohort_number = 4
   AND f.alc_code IS NOT NULL
 GROUP BY
       f.alc_code,
       f.geopolitical_zone
HAVING COUNT(*) >= 5
 ORDER BY completion_rate ASC
 LIMIT 10;



/*
QUESTION 2
   fellows have been absent (no reflection survey response)
   for 3 or more consecutive weeks?
 */

WITH latest_week AS (
    SELECT
           MAX(rs.week) AS current_week
      FROM reflection_surveys AS rs
),
fellow_last_response AS (
    SELECT
           rs.fellow_id,
           MAX(rs.week) AS last_recorded_week
      FROM reflection_surveys AS rs
     GROUP BY rs.fellow_id
)

SELECT
       f.fellow_id,
       f.alc_code,
       f.track,
       flr.last_recorded_week,
       (
           (SELECT current_week FROM latest_week)
           - flr.last_recorded_week
       ) AS weeks_absent
  FROM fellows AS f
  LEFT JOIN fellow_last_response AS flr
    ON f.fellow_id = flr.fellow_id
 WHERE (
           (SELECT current_week FROM latest_week)
           - flr.last_recorded_week
       ) >= 3
 ORDER BY weeks_absent DESC;



/*
QUESTION 3
   Weekly attendance trend by geopolitical zone
   over the last 8 weeks
*/

WITH latest_week AS (
    SELECT
           MAX(awl.week_number) AS max_week
      FROM alc_weekly_logs AS awl
     WHERE awl.week_number != 99
)

SELECT
       awl.geopolitical_zone,
       awl.week_number,
       SUM(awl.sessions_held) AS total_sessions_held,
       SUM(awl.fellows_present) AS total_fellows_present,
       ROUND(
           SUM(awl.fellows_present) * 1.0
           / SUM(awl.sessions_held),
           2
       ) AS attendance_per_session
  FROM alc_weekly_logs AS awl
 WHERE awl.week_number >= (
           (SELECT max_week FROM latest_week) - 7
       )
   AND awl.week_number != 99
 GROUP BY
       awl.geopolitical_zone,
       awl.week_number
 ORDER BY
       awl.geopolitical_zone,
       awl.week_number;



/* 
QUESTION 4
   tracks that have the highest certification
   rate broken down by state?
*/ 

WITH certification_rates AS (
    SELECT
           f.state,
           f.track,
           COUNT(*) AS total_fellows,
           SUM(
               CASE
                   WHEN f.certification_status = 'certified'
                   THEN 1
                   ELSE 0
               END
           ) AS certified_fellows,
           ROUND(
               SUM(
                   CASE
                       WHEN f.certification_status = 'certified'
                       THEN 1
                       ELSE 0
                   END
               ) * 100.0 / COUNT(*),
               2
           ) AS certification_rate
      FROM fellows AS f
     GROUP BY
           f.state,
           f.track
    HAVING COUNT(*) >= 5
)

SELECT
       cr.state,
       cr.track,
       cr.total_fellows,
       cr.certified_fellows,
       cr.certification_rate,
       RANK() OVER (
           PARTITION BY cr.state
           ORDER BY cr.certification_rate DESC
       ) AS certification_rank
  FROM certification_rates AS cr
 ORDER BY
       cr.state,
       certification_rank;



/*
QUESTION 5
   CTE that flags ‘at-risk’ fellows:
   completion status = incomplete
   AND no survey response in the last 2 weeks
   AND enrolment date more than 10 weeks ago.
*/

WITH latest_week AS (
    SELECT
           MAX(rs.week) AS current_week
      FROM reflection_surveys AS rs
),
fellow_last_response AS (
    SELECT
           rs.fellow_id,
           MAX(rs.week) AS last_response_week
      FROM reflection_surveys AS rs
     GROUP BY rs.fellow_id
),
at_risk_fellows AS (
    SELECT
           f.fellow_id,
           f.alc_code,
           f.track,
           f.state,
           f.enrollment_duration_weeks,
           f.completion_status,
           flr.last_response_week,
           (
               (SELECT current_week FROM latest_week)
               - flr.last_response_week
           ) AS weeks_since_response,
           CASE
               WHEN (
                        (SELECT current_week FROM latest_week)
                        - flr.last_response_week
                    ) >= 4
               THEN 'High Risk'

               WHEN (
                        (SELECT current_week FROM latest_week)
                        - flr.last_response_week
                    ) = 3
               THEN 'Medium Risk'

               ELSE 'Low Risk'
           END AS risk_level
      FROM fellows AS f
      LEFT JOIN fellow_last_response AS flr
        ON f.fellow_id = flr.fellow_id
     WHERE f.completion_status = 'incomplete'
       AND (
                (
                    (SELECT current_week FROM latest_week)
                    - flr.last_response_week
                ) >= 2
           )
       AND f.enrollment_duration_weeks > 10
)

SELECT
       arf.fellow_id,
       arf.alc_code,
       arf.track,
       arf.state,
       arf.enrollment_duration_weeks,
       arf.completion_status,
       arf.last_response_week,
       arf.weeks_since_response,
       arf.risk_level
  FROM at_risk_fellows AS arf
 ORDER BY
       arf.weeks_since_response DESC,
       arf.enrollment_duration_weeks DESC;