-- HISTOGRAMS - best way to show distribution of numerical column
--This query returns the rounded value of the numerical column as a grouped "bucket", 
--the count value of that bucket, 
--and a third column that has a * value for every value, all ordered by the bucket. 
USE patient;
SELECT ROUND(time_in_hospital, 1) AS bucket,
	   COUNT(*) AS count,
	   RPAD('', COUNT(*)/100, '*') AS bar
FROM health
GROUP BY bucket
ORDER BY bucket;



-- This query returns medical specialty, rounded average number of procedures
-- with a total count of for each specialty (rows) 
SELECT medical_specialty, 
	   ROUND(AVG(num_procedures),1) AS avg_procedures,
	   COUNT(num_procedures) AS count 
FROM health 
GROUP BY medical_specialty 
ORDER BY avg_procedures DESC;	



-- This query returns same requirements as above 
-- plus specialty that has at least 50 patients 
SELECT medical_specialty, 
       ROUND(AVG(num_procedures),1) AS avg_procedures, 
       COUNT(num_procedures) AS count
FROM health 
GROUP BY medical_specialty
HAVING count > 50 
ORDER BY avg_procedures DESC;



-- To clean up the results a bit more, filter
-- specialty that has more than 2.5 average procedures
SELECT medical_specialty, ROUND(AVG(num_procedures),1) AS avg_procedures,
       COUNT(num_procedures) AS count
FROM health GROUP BY medical_specialty
HAVING count > 50 AND avg_procedures > 2.5 
ORDER BY avg_procedures DESC;



-- How can we evaluate how race plays a role in the number of lab tests?
SELECT dem.race, 
       ROUND(AVG(num_lab_procedures),1) AS avg_num_lab_procedures
FROM health 
INNER JOIN demographics AS dem
	    ON hlth.patient_nbr = dem.patient_nbr
GROUP BY dem.race, time_in_hospital
ORDER BY dem.race ASC, avg_num_lab_procedures DESC;  



-- To clean up the results filter by removing "?" entries and "Other"
SELECT dem.race, 
       ROUND(AVG(num_lab_procedures),1) AS avg_num_lab_procedures,
       hlth.time_in_hospital,
	   SUM(hlth.number_diagnoses) AS tot_num_diags
FROM health AS hlth
INNER JOIN demographics AS dem
  ON hlth.patient_nbr = dem.patient_nbr
WHERE dem.race <> "Other" AND dem.race <> "?"
GROUP BY dem.race, time_in_hospital
ORDER BY dem.race ASC, avg_num_lab_procedures DESC;



-- Do patients who get a lot of lab procedures, stay in the hospital longer?
SELECT  ROUND(AVG(time_in_hospital),1) AS avg_time,
		SUM(number_diagnoses) AS total_diagnoses,
        SUM(num_medications) AS total_meds, 
		num_procedures, number_emergency, diabetesMed,
CASE
   WHEN num_lab_procedures > 0 AND num_lab_procedures < 25 THEN "few"
   WHEN num_lab_procedures >= 25 AND num_lab_procedures < 55 THEN "average"
   WHEN num_lab_procedures >= 55 THEN "many"
   ELSE "none"
END AS procedure_frequency
FROM patient.health
GROUP BY procedure_frequency, num_procedures, number_emergency, diabetesMed
ORDER BY avg_time DESC;



-- Email from the research department
-- They want to do a medical test with anyone of 
-- African American descent or had an "Up" for metformin. 
-- They need a list of patient ID's as fast as possible. 

SELECT patient_nbr 
FROM patient.demographics 
WHERE race = 'AfricanAmerican'
UNION
SELECT patient_nbr 
FROM patient.health 
WHERE metformin = 'Up';


-- This query outputs a summary report for the top 50 medication patients,
-- racial demographics, readmission status, # of meds, and lab procedures
SELECT CONCAT_WS( ' ', 'Patient', health.patient_nbr, 'was', demographics.race, 'and',
(
  CASE 
	WHEN readmitted = 'NO' THEN 'was not readmitted. They had '
	ELSE 'was readmitted. They had'
  END),
  num_medications, 'medications and', num_lab_procedures, 'lab procedures.'
) AS summary FROM patient.health
INNER JOIN patient.demographics 
		ON demographics.patient_nbr = health.patient_nbr
ORDER BY num_medications DESC, num_lab_procedures DESC
LIMIT 50;


-- Output occurrences when patients came into the hospital with an emergency 
-- but stayed less than the average time in the hospital.
WITH avg_time AS (
	SELECT AVG(time_in_hospital) AS avg_hosp_time
	FROM health
	)
SELECT * FROM patient.health
WHERE admission_type_id = 1
AND time_in_hospital < (SELECT avg_hosp_time 
                        FROM avg_time);