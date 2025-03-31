
CALL initialize_global_metadata();

 -- set  @startDate = '2024-02-01';
 -- set  @endDate = '2025-03-31';

SET  @locale = GLOBAL_PROPERTY_VALUE('default_locale', 'en');
SET @endDate = ADDDATE(@endDate, INTERVAL 1 DAY);

drop TEMPORARY TABLE if exists visits_distribution_temp;

DROP TEMPORARY TABLE IF EXISTS visits_distribution_temp;

CREATE TEMPORARY TABLE visits_distribution_temp (
    child_under_1_n INT,
    child_between_1_4_n INT,
    child_between_5_9_n INT,
    child_between_10_14_n INT,
    young_adult_between_15_19_n INT,
    young_adult_between_20_24_n INT,
    other_adult_n INT,
    child_under_1_s INT,
    child_between_1_4_s INT,
    child_between_5_9_s INT,
    child_between_10_14_s INT,
    young_adult_between_15_19_s INT,
    young_adult_between_20_24_s INT,
    other_adult_s INT
);

-- New and subsequent visits
INSERT INTO visits_distribution_temp 
(child_under_1_n, child_between_1_4_n, child_between_5_9_n, child_between_10_14_n, 
 young_adult_between_15_19_n, young_adult_between_20_24_n, other_adult_n,
 child_under_1_s, child_between_1_4_s, child_between_5_9_s, child_between_10_14_s, 
 young_adult_between_15_19_s, young_adult_between_20_24_s, other_adult_s)
SELECT 
    -- New visits (First visit of the year)
    SUM(IF(DATEDIFF(e.encounter_datetime, pr.birthdate) / 365.25 < 1 
           AND YEAR(e.encounter_datetime) = YEAR(CURDATE())
           AND e.encounter_datetime = first_visit.first_visit_this_year 
           AND DATE(e.encounter_datetime) BETWEEN @startDate AND @endDate, 1, 0)),
    SUM(IF(DATEDIFF(e.encounter_datetime, pr.birthdate) / 365.25 BETWEEN 1 AND 4 
           AND YEAR(e.encounter_datetime) = YEAR(CURDATE()) 
           AND e.encounter_datetime = first_visit.first_visit_this_year
           AND DATE(e.encounter_datetime) BETWEEN @startDate AND @endDate, 1, 0)),
    SUM(IF(DATEDIFF(e.encounter_datetime, pr.birthdate) / 365.25 BETWEEN 5 AND 9 
           AND YEAR(e.encounter_datetime) = YEAR(CURDATE()) 
           AND e.encounter_datetime = first_visit.first_visit_this_year
           AND DATE(e.encounter_datetime) BETWEEN @startDate AND @endDate, 1, 0)),
    SUM(IF(DATEDIFF(e.encounter_datetime, pr.birthdate) / 365.25 BETWEEN 10 AND 14 
           AND YEAR(e.encounter_datetime) = YEAR(CURDATE()) 
           AND e.encounter_datetime = first_visit.first_visit_this_year
           AND DATE(e.encounter_datetime) BETWEEN @startDate AND @endDate, 1, 0)),
    SUM(IF(DATEDIFF(e.encounter_datetime, pr.birthdate) / 365.25 BETWEEN 15 AND 19 
           AND YEAR(e.encounter_datetime) = YEAR(CURDATE()) 
           AND e.encounter_datetime = first_visit.first_visit_this_year
           AND DATE(e.encounter_datetime) BETWEEN @startDate AND @endDate, 1, 0)),
    SUM(IF(DATEDIFF(e.encounter_datetime, pr.birthdate) / 365.25 BETWEEN 20 AND 24 
           AND YEAR(e.encounter_datetime) = YEAR(CURDATE()) 
           AND e.encounter_datetime = first_visit.first_visit_this_year
           AND DATE(e.encounter_datetime) BETWEEN @startDate AND @endDate, 1, 0)),
    SUM(IF(DATEDIFF(e.encounter_datetime, pr.birthdate) / 365.25 >= 25 
           AND YEAR(e.encounter_datetime) = YEAR(CURDATE()) 
           AND e.encounter_datetime = first_visit.first_visit_this_year
           AND DATE(e.encounter_datetime) BETWEEN @startDate AND @endDate, 1, 0)),

    -- Subsequent visits 
    SUM(IF(DATEDIFF(e.encounter_datetime, pr.birthdate) / 365.25 < 1 
           AND YEAR(e.encounter_datetime) <= YEAR(CURDATE())
           AND e.encounter_datetime != first_visit.first_visit_this_year
           AND DATE(e.encounter_datetime) BETWEEN @startDate AND @endDate, 1, 0)),
    SUM(IF(DATEDIFF(e.encounter_datetime, pr.birthdate) / 365.25 BETWEEN 1 AND 4 
           AND YEAR(e.encounter_datetime) <= YEAR(CURDATE()) 
           AND e.encounter_datetime != first_visit.first_visit_this_year
           AND DATE(e.encounter_datetime) BETWEEN @startDate AND @endDate, 1, 0)),
    SUM(IF(DATEDIFF(e.encounter_datetime, pr.birthdate) / 365.25 BETWEEN 5 AND 9 
           AND YEAR(e.encounter_datetime) <= YEAR(CURDATE()) 
           AND e.encounter_datetime != first_visit.first_visit_this_year
           AND DATE(e.encounter_datetime) BETWEEN @startDate AND @endDate, 1, 0)),
    SUM(IF(DATEDIFF(e.encounter_datetime, pr.birthdate) / 365.25 BETWEEN 10 AND 14 
           AND YEAR(e.encounter_datetime) <= YEAR(CURDATE()) 
           AND e.encounter_datetime != first_visit.first_visit_this_year
           AND DATE(e.encounter_datetime) BETWEEN @startDate AND @endDate, 1, 0)),
    SUM(IF(DATEDIFF(e.encounter_datetime, pr.birthdate) / 365.25 BETWEEN 15 AND 19 
           AND YEAR(e.encounter_datetime) < YEAR(CURDATE()) 
           AND e.encounter_datetime != first_visit.first_visit_this_year
           AND DATE(e.encounter_datetime) BETWEEN @startDate AND @endDate, 1, 0)),
    SUM(IF(DATEDIFF(e.encounter_datetime, pr.birthdate) / 365.25 BETWEEN 20 AND 24 
           AND YEAR(e.encounter_datetime) <= YEAR(CURDATE()) 
           AND e.encounter_datetime != first_visit.first_visit_this_year
           AND DATE(e.encounter_datetime) BETWEEN @startDate AND @endDate, 1, 0)),
    SUM(IF(DATEDIFF(e.encounter_datetime, pr.birthdate) / 365.25 >= 25 
           AND YEAR(e.encounter_datetime) <= YEAR(CURDATE()) 
           AND e.encounter_datetime != first_visit.first_visit_this_year
           AND DATE(e.encounter_datetime) BETWEEN @startDate AND @endDate, 1, 0))
FROM patient p
-- Person
INNER JOIN person pr ON p.patient_id = pr.person_id AND pr.voided = 0
-- Check in encounter
INNER JOIN encounter e ON p.patient_id = e.patient_id AND e.voided = 0 AND e.encounter_type = @chkEnc
-- Determining the first visit of the year
LEFT JOIN (
    SELECT patient_id, MIN(encounter_datetime) AS first_visit_this_year
    FROM encounter
    WHERE YEAR(encounter_datetime) = YEAR(CURDATE()) 
    GROUP BY patient_id
) AS first_visit ON e.patient_id = first_visit.patient_id
WHERE p.voided = 0
-- Exclude test patients
AND p.patient_id NOT IN (
    SELECT person_id 
    FROM person_attribute 
    WHERE value = 'true' 
    AND person_attribute_type_id = @testPt 
    AND voided = 0
)
AND DATE(e.encounter_datetime) >= @startDate
AND DATE(e.encounter_datetime) < @endDate;

-- CLIENT PF
SELECT 
 SUM(IF(YEAR(e.encounter_datetime) = YEAR(CURDATE())
           AND e.encounter_datetime = first_visit.first_visit_this_year 
           AND DATE(e.encounter_datetime) BETWEEN @startDate AND @endDate, 1, 0)), 
SUM(IF(YEAR(e.encounter_datetime) <= YEAR(CURDATE())
           AND e.encounter_datetime != first_visit.first_visit_this_year
           AND DATE(e.encounter_datetime) BETWEEN @startDate AND @endDate, 1, 0)) INTO @clientPfN, @clientPfS
from obs o 
INNER JOIN encounter e 
ON o.encounter_id =e.encounter_id 
LEFT JOIN (
    SELECT patient_id, MIN(encounter_datetime) AS first_visit_this_year
    FROM encounter
    WHERE YEAR(encounter_datetime) = YEAR(CURDATE()) 
    GROUP BY patient_id
) AS first_visit ON e.patient_id = first_visit.patient_id
WHERE o.value_coded =concept_from_mapping('PIH','5483')
AND o.voided =0
AND date(e.encounter_datetime) >= @startDate
AND date(e.encounter_datetime) < @endDate;

-- PEOPLE MENTAL DISODER
SELECT COUNT(*) INTO @totalMentalDisorder from
obs o 
INNER JOIN encounter e 
ON o.encounter_id =e.encounter_id  
WHERE o.value_coded =concept_from_mapping('PIH','7202')
AND o.voided =0
AND date(e.encounter_datetime) >= @startDate
AND date(e.encounter_datetime) < @endDate;

-- PREGNANCY WOMEN
SELECT
SUM(IF(o_pregnant.value_datetime > CURDATE() ,1, 0)), 
SUM(IF(o_pregnant.value_datetime < CURDATE() ,1, 0)) INTO  @pregnancyWomenN,@pregnancyWomenS
FROM  obs o_pregnant 
INNER JOIN encounter e 
ON o_pregnant.encounter_id =e.encounter_id 
    WHERE  
    o_pregnant.concept_id = concept_from_mapping('PIH', '5596') 
    AND o_pregnant.voided = 0
    AND date(e.encounter_datetime) >= @startDate
    AND date(e.encounter_datetime) < @endDate;  


SELECT child_under_1_n "CHILD_UNDER_1_N",child_under_1_s "CHILD_UNDER_1_S",
        child_between_1_4_n "CHILD_BETWEEN_1_4_N", child_between_1_4_s "CHILD_BETWEEN_1_4_S",
        child_between_5_9_n "CHILD_BETWEEN_5_9_N",child_between_5_9_s "CHILD_BETWEEN_5_9_S",
         child_between_10_14_n "CHILD_BETWEEN_10_14_N", child_between_10_14_s "CHILD_BETWEEN_10_14_S",
          young_adult_between_15_19_n "YOUNG_ADULT_BETWEEN_15_19_N", young_adult_between_15_19_s "YOUNG_ADULT_BETWEEN_15_19_S",
           young_adult_between_20_24_n "YOUNG_ADULT_BETWEEN_20_24_N",  young_adult_between_20_24_s "YOUNG_ADULT_BETWEEN_20_24_S", 
           other_adult_n "OTHER_ADULT_N", other_adult_s "OTHER_ADULT_S",
           @clientPfN "CLIENT_PF_N", @clientPfS "CLIENT_PF_S",
            @pregnancyWomenN 'PREGNANCY_WOMEN_N',@pregnancyWomenS 'PREGNANCY_WOMEN_S',
            @totalMentalDisorder 'PEOPLE_MENTAL_DISODER',
            0 'CLIENT_S_BU_DENTAIRE_N', 0 'CLIENT_S_BU_DENTAIRE_S',
            0 'PEOPLE_REDUCED_MOB_MOTOR_N',0 'PEOPLE_REDUCED_MOB_MOTOR_S',
            0 'PEOPLE_REDUCED_MOB_SENSORY_N',0 'PEOPLE_REDUCED_MOB_SENSORY_S'
       FROM visits_distribution_temp;
