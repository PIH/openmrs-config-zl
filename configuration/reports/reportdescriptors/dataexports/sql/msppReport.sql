
CALL initialize_global_metadata();

-- set  @startDate = '2025-04-03';
-- set  @endDate = '2025-04-24';
SET @firstDate = CONCAT(YEAR(CURDATE()), '-01-01');

SET  @locale = GLOBAL_PROPERTY_VALUE('default_locale', 'en');
SET @endDate = ADDDATE(@endDate, INTERVAL 1 DAY);

SET  @kid_age=14;
SET @death = concept_from_mapping('PIH','DEATH');
SET @discharged = concept_from_mapping('PIH','DISCHARGED');
SET @TransferOutOfHospital = concept_from_mapping('PIH','Transfer out of hospital');
SET @LeftWithoutSeeingClinician = concept_from_mapping('PIH','Left without seeing a clinician');

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
    other_adult_s INT,
    pregnant_visits_n INT,
    pregnant_visits_s INT
);

-- New visits (First visit of the year)
INSERT INTO visits_distribution_temp 
(child_under_1_n, child_between_1_4_n, child_between_5_9_n, child_between_10_14_n, 
 young_adult_between_15_19_n, young_adult_between_20_24_n, other_adult_n)
SELECT 
    SUM(IF(DATEDIFF(e.encounter_datetime, pr.birthdate) / 365.25 < 1 
           AND YEAR(e.encounter_datetime) = YEAR(CURDATE())
           AND e.encounter_datetime = first_visit.first_visit_this_year 
           AND DATE(e.encounter_datetime) BETWEEN @firstDate AND @endDate, 1, 0)),
    SUM(IF(DATEDIFF(e.encounter_datetime, pr.birthdate)/365.25>=1 AND DATEDIFF(e.encounter_datetime, pr.birthdate)/365.25<5
           AND YEAR(e.encounter_datetime) = YEAR(CURDATE()) 
           AND e.encounter_datetime = first_visit.first_visit_this_year
           AND DATE(e.encounter_datetime) BETWEEN @firstDate AND @endDate, 1, 0)),
    SUM(IF(DATEDIFF(e.encounter_datetime, pr.birthdate)/365.25>=5 and DATEDIFF(e.encounter_datetime, pr.birthdate)/365.25<10 
           AND YEAR(e.encounter_datetime) = YEAR(CURDATE()) 
           AND e.encounter_datetime = first_visit.first_visit_this_year
           AND DATE(e.encounter_datetime) BETWEEN @firstDate AND @endDate, 1, 0)),
    SUM(IF(DATEDIFF(e.encounter_datetime, pr.birthdate)/365.25>=10 and DATEDIFF(e.encounter_datetime, pr.birthdate)/365.25<15 
           AND YEAR(e.encounter_datetime) = YEAR(CURDATE()) 
           AND e.encounter_datetime = first_visit.first_visit_this_year
           AND DATE(e.encounter_datetime) BETWEEN @firstDate AND @endDate, 1, 0)),
    SUM(IF(DATEDIFF(e.encounter_datetime, pr.birthdate)/365.25>=15 and DATEDIFF(e.encounter_datetime, pr.birthdate)/365.25<20
           AND YEAR(e.encounter_datetime) = YEAR(CURDATE()) 
           AND e.encounter_datetime = first_visit.first_visit_this_year
           AND DATE(e.encounter_datetime) BETWEEN @firstDate AND @endDate, 1, 0)),
    SUM(IF(DATEDIFF(e.encounter_datetime, pr.birthdate)/365.25>=20 and DATEDIFF(e.encounter_datetime, pr.birthdate)/365.25<25
           AND YEAR(e.encounter_datetime) = YEAR(CURDATE()) 
           AND e.encounter_datetime = first_visit.first_visit_this_year
           AND DATE(e.encounter_datetime) BETWEEN @firstDate AND @endDate, 1, 0)),
           
    SUM(IF(DATEDIFF(e.encounter_datetime, pr.birthdate) / 365.25 >= 25 
           AND YEAR(e.encounter_datetime) = YEAR(CURDATE()) 
           AND e.encounter_datetime = first_visit.first_visit_this_year
           AND DATE(e.encounter_datetime) BETWEEN @firstDate AND @endDate, 1, 0))
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
     AND DATE(encounter_datetime) >= @firstDate
   AND DATE(encounter_datetime) < @endDate
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
AND DATE(e.encounter_datetime) >= @firstDate
AND DATE(e.encounter_datetime) < @endDate;


-- Subsequent visits 
INSERT INTO visits_distribution_temp 
(child_under_1_s, child_between_1_4_s, child_between_5_9_s, child_between_10_14_s, 
 young_adult_between_15_19_s, young_adult_between_20_24_s, other_adult_s)
SELECT 
    SUM(IF(DATEDIFF(e.encounter_datetime, pr.birthdate) / 365.25 < 1 
           AND YEAR(e.encounter_datetime) <= YEAR(CURDATE())
           AND e.encounter_datetime != first_visit.first_visit_this_year
           AND DATE(e.encounter_datetime) BETWEEN @startDate AND @endDate, 1, 0)),
    SUM(IF(DATEDIFF(e.encounter_datetime, pr.birthdate)/365.25>=1 AND DATEDIFF(e.encounter_datetime, pr.birthdate)/365.25<5
           AND YEAR(e.encounter_datetime) <= YEAR(CURDATE()) 
           AND e.encounter_datetime != first_visit.first_visit_this_year
           AND DATE(e.encounter_datetime) BETWEEN @startDate AND @endDate, 1, 0)),
    SUM(IF(DATEDIFF(e.encounter_datetime, pr.birthdate)/365.25>=5 and DATEDIFF(e.encounter_datetime, pr.birthdate)/365.25<10 
           AND YEAR(e.encounter_datetime) <= YEAR(CURDATE()) 
           AND e.encounter_datetime != first_visit.first_visit_this_year
           AND DATE(e.encounter_datetime) BETWEEN @startDate AND @endDate, 1, 0)),
    SUM(IF(DATEDIFF(e.encounter_datetime, pr.birthdate)/365.25>=10 and DATEDIFF(e.encounter_datetime, pr.birthdate)/365.25<15 
           AND YEAR(e.encounter_datetime) <= YEAR(CURDATE()) 
           AND e.encounter_datetime != first_visit.first_visit_this_year
           AND DATE(e.encounter_datetime) BETWEEN @startDate AND @endDate, 1, 0)),
    SUM(IF(DATEDIFF(e.encounter_datetime, pr.birthdate)/365.25>=15 and DATEDIFF(e.encounter_datetime, pr.birthdate)/365.25<20
           AND YEAR(e.encounter_datetime) <= YEAR(CURDATE()) 
           AND e.encounter_datetime != first_visit.first_visit_this_year
           AND DATE(e.encounter_datetime) BETWEEN @startDate AND @endDate, 1, 0)),
    SUM(IF(DATEDIFF(e.encounter_datetime, pr.birthdate)/365.25>=20 and DATEDIFF(e.encounter_datetime, pr.birthdate)/365.25<25
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
     AND DATE(encounter_datetime) >= @firstDate
   AND DATE(encounter_datetime) < @endDate
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
AND DATE(e.encounter_datetime) BETWEEN @startDate AND @endDate;


-- New visits Of pregnancy women
INSERT INTO visits_distribution_temp 
(pregnant_visits_n)
    SELECT
    IF(DATE(e.encounter_datetime) = DATE(first_visit.first_visit_this_year), 1, 0)
    FROM obs o
    INNER JOIN encounter e on e.patient_id =o.person_id 
    LEFT JOIN (
    SELECT patient_id, MIN(encounter_datetime) AS first_visit_this_year
    FROM encounter
    WHERE YEAR(encounter_datetime) = YEAR(CURDATE())
    GROUP BY patient_id
    ) AS first_visit ON e.patient_id = first_visit.patient_id
    WHERE o.concept_id = concept_from_mapping('PIH', '5596')
    AND o.voided = 0
    AND e.voided = 0
    AND DATE(o.value_datetime) > CURDATE()
    AND DATE(e.encounter_datetime) >= @firstDate
    AND DATE(e.encounter_datetime) < @endDate
    GROUP BY e.visit_id 
    ORDER BY e.visit_id DESC;


-- Subsequent visits for pregnancy women
INSERT INTO visits_distribution_temp 
(pregnant_visits_s)
       SELECT
    IF(DATE(e.encounter_datetime) > DATE(first_visit.first_visit_this_year), 1, 0)
    FROM obs o
    INNER JOIN encounter e on e.patient_id =o.person_id 
    LEFT JOIN (
    SELECT patient_id, MIN(encounter_datetime) AS first_visit_this_year
    FROM encounter
    WHERE YEAR(encounter_datetime) = YEAR(CURDATE())
    GROUP BY patient_id
    ) AS first_visit ON e.patient_id = first_visit.patient_id
    WHERE o.concept_id = concept_from_mapping('PIH', '5596')
    AND o.voided = 0
    AND e.voided = 0
    AND DATE(o.value_datetime) > CURDATE()
    AND DATE(e.encounter_datetime) >= @startDate
    AND DATE(e.encounter_datetime) < @endDate
    GROUP BY e.visit_id 
    ORDER BY e.visit_id DESC;

-- NEW CLIENT PF
SELECT 
 SUM(IF(YEAR(e.encounter_datetime) = YEAR(CURDATE())
           AND e.encounter_datetime = first_visit.first_visit_this_year 
           AND DATE(e.encounter_datetime) BETWEEN @firstDate AND @endDate, 1, 0)) INTO @clientPfN
from obs o 
INNER JOIN encounter e 
ON o.encounter_id =e.encounter_id 
LEFT JOIN (
    SELECT e.patient_id, MIN(e.encounter_datetime) AS first_visit_this_year
    FROM encounter e
    JOIN obs o2 ON e.encounter_id=o2.encounter_id
    WHERE YEAR(encounter_datetime) = YEAR(CURDATE()) 
    AND o2.value_coded =concept_from_mapping('PIH','5483')
    AND date(e.encounter_datetime) >= @firstDate
	AND date(e.encounter_datetime) < @endDate
    GROUP BY e.patient_id
) AS first_visit ON e.patient_id = first_visit.patient_id
WHERE o.value_coded =concept_from_mapping('PIH','5483')
AND o.voided =0
AND date(e.encounter_datetime) >= @firstDate
AND date(e.encounter_datetime) < @endDate;


-- SUBSEQUENT CLIENT PF
SELECT  
SUM(IF(YEAR(e.encounter_datetime) <= YEAR(CURDATE())
           AND e.encounter_datetime != first_visit.first_visit_this_year
           AND DATE(e.encounter_datetime) BETWEEN @startDate AND @endDate, 1, 0)) INTO @clientPfS
from obs o 
INNER JOIN encounter e 
ON o.encounter_id =e.encounter_id 
LEFT JOIN (
    SELECT e.patient_id, MIN(e.encounter_datetime) AS first_visit_this_year
    FROM encounter e
    JOIN obs o2 ON e.encounter_id=o2.encounter_id
    WHERE YEAR(encounter_datetime) = YEAR(CURDATE()) 
    AND o2.value_coded =concept_from_mapping('PIH','5483')
    AND date(e.encounter_datetime) >= @firstDate
	AND date(e.encounter_datetime) < @endDate
    GROUP BY e.patient_id
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

-- EXAMEN LABORATOIRE

 DROP TEMPORARY TABLE IF EXISTS  pregnancy_patient_temp;
CREATE TEMPORARY TABLE pregnancy_patient_temp(person_id int,pregnant int);
 INSERT INTO pregnancy_patient_temp(person_id,pregnant)
   SELECT
    o.person_id, IF(DATE(o.value_datetime) > CURDATE(), 1, 0)
    FROM obs o
    WHERE o.concept_id = concept_from_mapping('PIH', '5596')
    AND o.voided = 0
    AND DATE(o.value_datetime) > CURDATE()
    GROUP BY o.person_id;


-- TOTAL TEST D'URINE
SELECT COUNT(*) INTO @total_urine_test_women
FROM obs o 
INNER JOIN encounter e 
    ON o.encounter_id = e.encounter_id
INNER JOIN person p
    ON p.person_id = o.person_id
INNER JOIN pregnancy_patient_temp pr
    ON p.person_id = pr.person_id
WHERE o.concept_id = concept_from_mapping('PIH', '12375')
  AND pr.pregnant=1
  AND o.voided = 0 
  AND e.voided = 0
  AND date(e.encounter_datetime) >= @startDate
  AND date(e.encounter_datetime) < @endDate;


-- TOTAL TEST D'HEMOGRAME
SELECT COUNT(*) INTO @total_hemogram_test_women
FROM obs o 
INNER JOIN encounter e 
    ON o.encounter_id = e.encounter_id
INNER JOIN person p
    ON p.person_id = o.person_id
INNER JOIN pregnancy_patient_temp pr
    ON p.person_id = pr.person_id
WHERE o.concept_id = concept_from_mapping('PIH', '11711')
  AND pr.pregnant=1
  AND o.voided = 0 
  AND e.voided = 0
  AND date(e.encounter_datetime) >= @startDate
  AND date(e.encounter_datetime) < @endDate;
 

 -- TOTAL TEST MALARIA TEST RAPID
SELECT COUNT(*) INTO @totat_malaria_rapd_test_women
FROM obs o 
INNER JOIN encounter e 
    ON o.encounter_id = e.encounter_id
INNER JOIN person p
    ON p.person_id = o.person_id
INNER JOIN pregnancy_patient_temp pr
    ON p.person_id = pr.person_id
WHERE o.concept_id = concept_from_mapping('PIH', '11464')
  AND pr.pregnant=1
  AND o.voided = 0 
  AND e.voided = 0
  AND date(e.encounter_datetime) >= @startDate
  AND date(e.encounter_datetime) < @endDate;
 
  -- TOTAL TEST RPR
SELECT COUNT(*) INTO @total_rpr_test_women
FROM obs o 
INNER JOIN encounter e 
    ON o.encounter_id = e.encounter_id
INNER JOIN person p
    ON p.person_id = o.person_id
INNER JOIN pregnancy_patient_temp pr
    ON p.person_id = pr.person_id
WHERE o.concept_id = concept_from_mapping('PIH', 'RPR')
  AND pr.pregnant=1
  AND o.voided = 0 
  AND e.voided = 0
  AND date(e.encounter_datetime) >= @startDate
  AND date(e.encounter_datetime) < @endDate;
 
 
  -- TOTAL TEST  HIV
SELECT COUNT(*) INTO @total_hiv_test_women
FROM obs o 
INNER JOIN encounter e 
    ON o.encounter_id = e.encounter_id
INNER JOIN person p
    ON p.person_id = o.person_id
INNER JOIN pregnancy_patient_temp pr
    ON p.person_id = pr.person_id
WHERE o.concept_id = concept_from_mapping('PIH', '1040')
  AND pr.pregnant=1
  AND o.voided = 0 
  AND e.voided = 0
  AND date(e.encounter_datetime) >= @startDate
  AND date(e.encounter_datetime) < @endDate;
 
  -- TOTAL SICKLING TEST
SELECT COUNT(*) INTO @total_sickling_test_women
FROM obs o 
INNER JOIN encounter e 
    ON o.encounter_id = e.encounter_id
INNER JOIN person p
    ON p.person_id = o.person_id
INNER JOIN pregnancy_patient_temp pr
    ON p.person_id = pr.person_id
WHERE o.concept_id = concept_from_mapping('PIH', '12716')
  AND pr.pregnant=1
  AND o.voided = 0 
  AND e.voided = 0
  AND date(e.encounter_datetime) >= @startDate
  AND date(e.encounter_datetime) < @endDate;
 
 
  -- TOTAL TEST GROUPE SANGUIN
SELECT COUNT(*) INTO @total_blood_type_test_women
FROM obs o 
INNER JOIN encounter e 
    ON o.encounter_id = e.encounter_id
INNER JOIN person p
    ON p.person_id = o.person_id
INNER JOIN pregnancy_patient_temp pr
    ON p.person_id = pr.person_id
WHERE o.concept_id = concept_from_mapping('PIH', 'BLOOD TYPING')
  AND pr.pregnant=1
  AND o.voided = 0 
  AND e.voided = 0
  AND date(e.encounter_datetime) >= @startDate
  AND date(e.encounter_datetime) < @endDate;
   
 

-- Data for not Pregnant Women
 
  -- TOTAL TEST GROUPE SANGUIN FOR NOT PREGNANT
SELECT COUNT(*) INTO @total_blood_type_test
FROM obs o 
INNER JOIN encounter e 
    ON o.encounter_id = e.encounter_id
INNER JOIN person p
    ON p.person_id = o.person_id
WHERE o.concept_id = concept_from_mapping('PIH', 'BLOOD TYPING')
  AND o.voided = 0 
  AND e.voided = 0
  AND date(e.encounter_datetime) >= @startDate
  AND date(e.encounter_datetime) < @endDate;
 
  -- TOTAL SICKLING TEST NOT PREGNANT
SELECT COUNT(*) 
INTO @total_sickling_test
FROM obs o 
INNER JOIN encounter e 
    ON o.encounter_id = e.encounter_id
INNER JOIN person p
    ON p.person_id = o.person_id
WHERE o.concept_id = concept_from_mapping('PIH', '12716')
  AND o.voided = 0 
  AND e.voided = 0
  AND date(e.encounter_datetime) >= @startDate;

  
  
 -- TOTAL TEST MALARIA TEST RAPID NOT PREGNANT

 SELECT COUNT(*) 
INTO @total_malaria_rapd_test
FROM obs o 
INNER JOIN encounter e 
    ON o.encounter_id = e.encounter_id
INNER JOIN person p
    ON p.person_id = o.person_id
WHERE o.concept_id = concept_from_mapping('PIH', '11464')
  AND o.voided = 0 
  AND e.voided = 0
  AND date(e.encounter_datetime) >= @startDate
  AND date(e.encounter_datetime) < @endDate;



  
 -- TOTAL TEST MALARIA TEST RAPID POSITIVE NOT PREGNANT
SELECT COUNT(*) INTO @totat_malaria_rapd_test_positif
FROM obs o 
INNER JOIN encounter e 
    ON o.encounter_id = e.encounter_id
INNER JOIN person p
    ON p.person_id = o.person_id
WHERE o.concept_id = concept_from_mapping('PIH', '11464')
  AND concept_name(o.value_coded, 'fr') = 'Positif'
  AND o.voided = 0 
  AND e.voided = 0
  AND date(e.encounter_datetime) >= @startDate
  AND date(e.encounter_datetime) < @endDate;
 
 
 -- TOTAL TEST MALARIA TEST RAPID POSITIVE
SELECT COUNT(*) INTO @totat_malaria_rapd_test_positif_women
FROM obs o 
INNER JOIN encounter e 
    ON o.encounter_id = e.encounter_id
INNER JOIN person p
    ON p.person_id = o.person_id
INNER JOIN pregnancy_patient_temp pr
    ON p.person_id = pr.person_id
WHERE o.concept_id = concept_from_mapping('PIH', '11464')
  AND pr.pregnant=1
  AND concept_name(o.value_coded, 'fr') = 'Positif'
  AND o.voided = 0 
  AND e.voided = 0
  AND date(e.encounter_datetime) >= @startDate
  AND date(e.encounter_datetime) < @endDate;
 
  -- TOTAL TEST RPR POSITIVE
 SELECT COUNT(*) INTO @total_rpr_test_positif_women
FROM obs o 
INNER JOIN encounter e 
    ON o.encounter_id = e.encounter_id
INNER JOIN person p
    ON p.person_id = o.person_id
INNER JOIN pregnancy_patient_temp pr
    ON p.person_id = pr.person_id
WHERE o.concept_id = concept_from_mapping('PIH', 'RPR')
  AND pr.pregnant=1
  AND concept_name(o.value_coded, 'fr') = 'Positif'
  AND o.voided = 0 
  AND e.voided = 0
  AND date(e.encounter_datetime) >= @startDate
  AND date(e.encounter_datetime) < @endDate;
 
 
 
  -- TOTAL TEST  HIV POSITIVE
SELECT COUNT(*) INTO @total_hiv_test_positif_women
FROM obs o 
INNER JOIN encounter e 
    ON o.encounter_id = e.encounter_id
INNER JOIN person p
    ON p.person_id = o.person_id
INNER JOIN pregnancy_patient_temp pr
    ON p.person_id = pr.person_id
WHERE o.concept_id = concept_from_mapping('PIH', '1040')
  AND pr.pregnant=1
  AND concept_name(o.value_coded, 'fr') = 'Positif'
  AND o.voided = 0 
  AND e.voided = 0
  AND date(e.encounter_datetime) >= @startDate
  AND date(e.encounter_datetime) < @endDate;

--  FOR Malaria Test microscopique
 
 SELECT COUNT(1) INTO @malaria_test_microscopique_vivax  
FROM obs o 
INNER JOIN encounter e 
    ON o.encounter_id = e.encounter_id
INNER JOIN person p
    ON p.person_id = o.person_id
WHERE o.value_coded = concept_from_mapping("PIH","11463")
  AND o.concept_id = concept_from_mapping('PIH', '20079')
  AND o.voided = 0 
  AND e.voided = 0
  AND date(e.encounter_datetime) >= @startDate
  AND date(e.encounter_datetime) < @endDate;
 
 
 
SELECT COUNT(1) INTO @malaria_test_microscopique_oval  
FROM obs o 
INNER JOIN encounter e 
    ON o.encounter_id = e.encounter_id
INNER JOIN person p
    ON p.person_id = o.person_id
WHERE o.value_coded = concept_from_mapping("PIH","20083")
  AND o.concept_id = concept_from_mapping('PIH', '20079')
  AND o.voided = 0 
  AND e.voided = 0
  AND date(e.encounter_datetime) >= @startDate
  AND date(e.encounter_datetime) < @endDate;
 

SELECT COUNT(1) INTO @malaria_test_microscopique_malariae 
FROM obs o 
INNER JOIN encounter e 
    ON o.encounter_id = e.encounter_id
INNER JOIN person p
    ON p.person_id = o.person_id
WHERE o.value_coded = concept_from_mapping("PIH","20082")
 AND o.concept_id = concept_from_mapping('PIH', '20079')
  AND o.voided = 0 
  AND e.voided = 0
  AND date(e.encounter_datetime) >= @startDate
  AND date(e.encounter_datetime) < @endDate;
 
SELECT COUNT(1) INTO @malaria_test_microscopique_falciparum 
FROM obs o 
INNER JOIN encounter e 
    ON o.encounter_id = e.encounter_id
INNER JOIN person p
    ON p.person_id = o.person_id
 WHERE o.value_coded = concept_from_mapping("PIH","11461")
  AND o.concept_id = concept_from_mapping('PIH', '20079')
  AND o.voided = 0 
  AND e.voided = 0
  AND date(e.encounter_datetime) >= @startDate
  AND date(e.encounter_datetime) < @endDate;
 
SELECT  (@malaria_test_microscopique_vivax +
         @malaria_test_microscopique_oval +
         @malaria_test_microscopique_malariae +
         @malaria_test_microscopique_falciparum
         ) INTO @malaria_test_microscopique_total ;
         

-- PHYSICAL VIOLENCE
SELECT 
SUM(IF(disp.value_coded=@death AND p.gender ='F',1,0)),
SUM(IF(disp.value_coded=@death AND p.gender ='M',1,0)),
SUM(IF(disp.value_coded=@death AND age_at_enc(p.person_id,e.encounter_id) <=@kid_age,1,0)),
SUM(IF(disp.value_coded=@discharged AND p.gender ='F',1,0)),
SUM(IF(disp.value_coded=@discharged AND p.gender ='M',1,0)),
SUM(IF(disp.value_coded=@discharged AND age_at_enc(p.person_id,e.encounter_id) <=@kid_age,1,0)),
SUM(IF(disp.value_coded=@TransferOutOfHospital AND p.gender ='F',1,0)),
SUM(IF(disp.value_coded=@TransferOutOfHospital AND p.gender ='M',1,0)),
SUM(IF(disp.value_coded=@TransferOutOfHospital AND age_at_enc(p.person_id,e.encounter_id) <=@kid_age,1,0)),
SUM(IF(disp.value_coded=@LeftWithoutSeeingClinician AND p.gender ='F',1,0)),
SUM(IF(disp.value_coded=@LeftWithoutSeeingClinician AND p.gender ='M',1,0)),
SUM(IF(disp.value_coded=@LeftWithoutSeeingClinician AND age_at_enc(p.person_id,e.encounter_id) <=@kid_age,1,0)) 
INTO @PHYSICAL_VIOL_WOMEN_DEAD,@PHYSICAL_VIOL_MEN_DEAD,@PHYSICAL_VIOL_KID_DEAD,@PHYSICAL_VIOL_WOMEN_TREATED,@PHYSICAL_VIOL_MEN_TREATED,@PHYSICAL_VIOL_KID_TREATED,
@PHYSICAL_VIOL_WOMEN_TRANSFER,@PHYSICAL_VIOL_MEN_TRANSFER,@PHYSICAL_VIOL_KID_TRANSFER,@PHYSICAL_VIOL_WOMEN_LEFT,@PHYSICAL_VIOL_MEN_LEFT,@PHYSICAL_VIOL_KID_LEFT
FROM obs o 
INNER JOIN encounter e on o.encounter_id =e.encounter_id
INNER JOIN person p ON p.person_id = o.person_id
LEFT JOIN (
SELECT encounter_id,value_coded  from obs where concept_id =concept_from_mapping("PIH","8620")
GROUP BY encounter_id 
) as disp on o.encounter_id=disp.encounter_id 
where o.concept_id =concept_from_mapping("PIH","3064")
and o.value_coded =concept_from_mapping("PIH","11533")
and e.voided =0
and o.voided =0
AND date(e.encounter_datetime) >= @startDate
 AND date(e.encounter_datetime) < @endDate;
 

-- SEXUAL VIOLENCE 
SELECT 
SUM(IF(disp.value_coded=@death AND p.gender ='F',1,0)),
SUM(IF(disp.value_coded=@death AND p.gender ='M',1,0)),
SUM(IF(disp.value_coded=@death AND p.gender ='F' AND age_at_enc(p.person_id,e.encounter_id) <=@kid_age,1,0)),
SUM(IF(disp.value_coded=@death AND p.gender ='M' AND age_at_enc(p.person_id,e.encounter_id) <=@kid_age,1,0)),
SUM(IF(disp.value_coded=@discharged AND p.gender ='F',1,0)),
SUM(IF(disp.value_coded=@discharged AND p.gender ='M',1,0)),
SUM(IF(disp.value_coded=@discharged AND p.gender ='F' AND age_at_enc(p.person_id,e.encounter_id) <=@kid_age,1,0)),
SUM(IF(disp.value_coded=@discharged AND p.gender ='M' AND age_at_enc(p.person_id,e.encounter_id) <=@kid_age,1,0)),
SUM(IF(disp.value_coded=@TransferOutOfHospital AND p.gender ='F',1,0)),
SUM(IF(disp.value_coded=@TransferOutOfHospital AND p.gender ='M',1,0)),
SUM(IF(disp.value_coded=@TransferOutOfHospital AND p.gender ='F' AND age_at_enc(p.person_id,e.encounter_id) <=@kid_age,1,0)),
SUM(IF(disp.value_coded=@TransferOutOfHospital AND p.gender ='M' AND age_at_enc(p.person_id,e.encounter_id) <=@kid_age,1,0)),
SUM(IF(disp.value_coded=@LeftWithoutSeeingClinician AND p.gender ='F',1,0)),
SUM(IF(disp.value_coded=@LeftWithoutSeeingClinician AND p.gender ='M',1,0)),
SUM(IF(disp.value_coded=@LeftWithoutSeeingClinician AND p.gender ='F' AND age_at_enc(p.person_id,e.encounter_id) <=@kid_age,1,0)),
SUM(IF(disp.value_coded=@LeftWithoutSeeingClinician AND p.gender ='M' AND age_at_enc(p.person_id,e.encounter_id) <=@kid_age,1,0))
INTO @SEX_VIOL_WOMEN_DEAD,@SEX_VIOL_MEN_DEAD,@SEX_VIOL_KIDF_DEAD,@SEX_VIOL_KIDM_DEAD,@SEX_VIOL_WOMEN_TREATED,@SEX_VIOL_MEN_TREATED,@SEX_VIOL_KIDF_TREATED,@SEX_VIOL_KIDM_TREATED,@SEX_VIOL_WOMEN_TRANSFER,
@SEX_VIOL_MEN_LEFT,@SEX_VIOL_KIDF_TRANSFER,@SEX_VIOL_KIDM_TRANSFER,@SEX_VIOL_WOMEN_LEFT,@SEX_VIOL_MEN_DEAD,@SEX_VIOL_KIDF_LEFT,@SEX_VIOL_KIDM_LEFT
FROM obs o 
INNER JOIN encounter e on o.encounter_id =e.encounter_id
INNER JOIN person p ON p.person_id = o.person_id
LEFT JOIN (
SELECT encounter_id,value_coded  from obs where concept_id =concept_from_mapping("PIH","8620")
GROUP BY encounter_id 
) as disp on o.encounter_id=disp.encounter_id 
where o.concept_id = concept_from_mapping("PIH","3064")
and o.value_coded = concept_from_mapping("PIH","11049")
and e.voided =0
and o.voided =0
 AND date(e.encounter_datetime) >= @startDate
    AND date(e.encounter_datetime) < @endDate;

-- OTHER VIOLENCE
SELECT 
SUM(IF(disp.value_coded=@death AND p.gender ='F',1,0)),
SUM(IF(disp.value_coded=@death AND p.gender ='M',1,0)),
SUM(IF(disp.value_coded=@death AND age_at_enc(p.person_id,e.encounter_id) <=@kid_age,1,0)),
SUM(IF(disp.value_coded=@discharged AND p.gender ='F',1,0)),
SUM(IF(disp.value_coded=@discharged AND p.gender ='M',1,0)),
SUM(IF(disp.value_coded=@discharged AND age_at_enc(p.person_id,e.encounter_id) <=@kid_age,1,0)),
SUM(IF(disp.value_coded=@TransferOutOfHospital AND p.gender ='F',1,0)),
SUM(IF(disp.value_coded=@TransferOutOfHospital AND p.gender ='M',1,0)),
SUM(IF(disp.value_coded=@TransferOutOfHospital AND age_at_enc(p.person_id,e.encounter_id) <=@kid_age,1,0)),
SUM(IF(disp.value_coded=@LeftWithoutSeeingClinician AND p.gender ='F',1,0)),
SUM(IF(disp.value_coded=@LeftWithoutSeeingClinician AND p.gender ='M',1,0)),
SUM(IF(disp.value_coded=@LeftWithoutSeeingClinician AND age_at_enc(p.person_id,e.encounter_id) <=@kid_age,1,0)) 
INTO @OTHER_SEX_VIOL_WOMEN_DEAD,@OTHER_SEX_VIOL_MEN_DEAD,@OTHER_SEX_VIOL_KID_DEAD,@OTHER_SEX_VIOL_WOMEN_TREATED,@OTHER_SEX_VIOL_MEN_TREATED,@OTHER_SEX_VIOL_KID_TREATED,
@OTHER_SEX_VIOL_WOMEN_TRANSFER,@OTHER_SEX_VIOL_MEN_TRANSFER,@OTHER_SEX_VIOL_KID_TRANSFER,@OTHER_SEX_VIOL_WOMEN_LEFT,@OTHER_SEX_VIOL_MEN_LEFT,@OTHER_SEX_VIOL_KID_LEFT
FROM obs o 
INNER JOIN encounter e on o.encounter_id =e.encounter_id
INNER JOIN person p ON p.person_id = o.person_id
LEFT JOIN (
SELECT encounter_id,value_coded  from obs where concept_id =concept_from_mapping("PIH","8620")
GROUP BY encounter_id 
) as disp on o.encounter_id=disp.encounter_id 
where o.concept_id =concept_from_mapping("PIH","3064")
 AND 
      (
        o.value_coded = concept_from_mapping("PIH","8852")
        OR o.value_coded = concept_from_mapping("PIH","11550")
      )
and e.voided =0
and o.voided =0
AND date(e.encounter_datetime) >= @startDate
 AND date(e.encounter_datetime) < @endDate;
 
-- DOMESTIC ACCIDENT
SELECT 
SUM(IF(disp.value_coded=@LeftWithoutSeeingClinician,1,0)),
SUM(IF(disp.value_coded=@discharged,1,0)) ,
SUM(IF(disp.value_coded=@TransferOutOfHospital,1,0)),
SUM(IF(disp.value_coded=@death,1,0)) 
INTO @ACC_DOMES_LEFT,@ACC_DOMES_TREATED,@ACC_DOMES_TRANSFER,@ACC_DOMES_DEAD
FROM obs o 
INNER JOIN encounter e on o.encounter_id =e.encounter_id
LEFT JOIN (
SELECT encounter_id,value_coded  FROM obs WHERE concept_id =concept_from_mapping("PIH","8620")
GROUP BY encounter_id 
) AS disp ON o.encounter_id=disp.encounter_id 
WHERE o.concept_id =concept_from_mapping("PIH","3064")
AND o.value_coded = concept_from_mapping('PIH','Home accident')
AND e.voided =0
AND o.voided =0
AND date(e.encounter_datetime) >= @startDate
AND date(e.encounter_datetime) < @endDate;
      
-- WORK ACCIDENT
SELECT 
SUM(IF(disp.value_coded=@death,1,0)),
SUM(IF(disp.value_coded=@discharged,1,0)),
SUM(IF(disp.value_coded=@TransferOutOfHospital,1,0)),
SUM(IF(disp.value_coded=@LeftWithoutSeeingClinician,1,0))
INTO @ACC_TR_DEAD,@ACC_TR_TREATED,@ACC_TR_TRANSFER,@ACC_TR_LEFT
FROM obs o 
INNER JOIN encounter e on o.encounter_id =e.encounter_id
LEFT JOIN (
SELECT encounter_id,value_coded  from obs where concept_id =concept_from_mapping("PIH","8620")
GROUP BY encounter_id 
) as disp on o.encounter_id=disp.encounter_id 
where o.concept_id = concept_from_mapping("PIH","8849")
and o.value_coded = concept_from_mapping("PIH","8851")
and e.voided =0
and o.voided =0
AND date(e.encounter_datetime) >= @startDate
AND date(e.encounter_datetime) < @endDate;
   

 
-- TRANSPORT-MOTOR ACCIDENT
SELECT 
SUM(IF(disp.value_coded=@death,1,0)),
SUM(IF(disp.value_coded=@discharged,1,0)),
SUM(IF(disp.value_coded=@TransferOutOfHospital,1,0)),
SUM(IF(disp.value_coded=@LeftWithoutSeeingClinician,1,0)) 
INTO @ACC_TR_MOTOR_DEAD,@ACC_TR_MOTOR_TREATED,@ACC_TR_MOTOR_TRANSFER,@ACC_TR_MOTOR_LEFT
FROM obs o 
INNER JOIN encounter e on o.encounter_id =e.encounter_id
LEFT JOIN (
SELECT encounter_id,value_coded  from obs where concept_id =concept_from_mapping("PIH","8620")
GROUP BY encounter_id 
) as disp on o.encounter_id=disp.encounter_id 
where o.concept_id =concept_from_mapping("PIH","3064")
and o.value_coded = concept_from_mapping("PIH","9579")
and e.voided =0
and o.voided =0
AND date(e.encounter_datetime) >= @startDate
AND date(e.encounter_datetime) < @endDate;


-- TRANSPORT-VEHICLE ACCIDENT
SELECT 
SUM(IF(disp.value_coded=@death,1,0)),
SUM(IF(disp.value_coded=@discharged,1,0)),
SUM(IF(disp.value_coded=@TransferOutOfHospital,1,0)),
SUM(IF(disp.value_coded=@LeftWithoutSeeingClinician,1,0)) 
INTO @ACC_TR_VEHICLE_DEAD,@ACC_TR_VEHICLE_TREATED,@ACC_TR_VEHICLE_TRANSFER,@ACC_TR_VEHICLE_LEFT
FROM obs o 
INNER JOIN encounter e on o.encounter_id =e.encounter_id
LEFT JOIN (
SELECT encounter_id,value_coded  from obs where concept_id =concept_from_mapping("PIH","8620")
GROUP BY encounter_id 
) as disp on o.encounter_id=disp.encounter_id 
where o.concept_id =concept_from_mapping("PIH","3064")
and o.value_coded= concept_from_mapping("PIH","9556")
and e.voided =0
and o.voided =0
AND date(e.encounter_datetime) >= @startDate
AND date(e.encounter_datetime) < @endDate;

-- OTHER ACCIDENTS 
SELECT 
SUM(IF(disp.value_coded=@death,1,0)),
SUM(IF(disp.value_coded=@discharged,1,0)),
SUM(IF(disp.value_coded=@TransferOutOfHospital,1,0)),
SUM(IF(disp.value_coded=@LeftWithoutSeeingClinician,1,0)) 
INTO @OTHER_ACC_TR_DEAD,@OTHER_ACC_TR_TREATED,@OTHER_ACC_TR_TRANSFER,@OTHER_ACC_TR_LEFT
FROM obs o 
INNER JOIN encounter e on o.encounter_id =e.encounter_id
LEFT JOIN (
SELECT encounter_id,value_coded  from obs where concept_id =concept_from_mapping("PIH","8620")
GROUP BY encounter_id 
) as disp on o.encounter_id=disp.encounter_id 
where o.concept_id =concept_from_mapping("PIH","3064")
and o.value_coded = concept_from_mapping("PIH","8437")
and e.voided =0
and o.voided =0
AND date(e.encounter_datetime) >= @startDate
AND date(e.encounter_datetime) < @endDate;


SELECT SUM(child_under_1_n) "CHILD_UNDER_1_N",SUM(child_under_1_s) "CHILD_UNDER_1_S",
        SUM(child_between_1_4_n) "CHILD_BETWEEN_1_4_N", SUM(child_between_1_4_s) "CHILD_BETWEEN_1_4_S",
        SUM(child_between_5_9_n) "CHILD_BETWEEN_5_9_N",SUM(child_between_5_9_s) "CHILD_BETWEEN_5_9_S",
         SUM(child_between_10_14_n) "CHILD_BETWEEN_10_14_N", SUM(child_between_10_14_s) "CHILD_BETWEEN_10_14_S",
          SUM(young_adult_between_15_19_n) "YOUNG_ADULT_BETWEEN_15_19_N", SUM(young_adult_between_15_19_s) "YOUNG_ADULT_BETWEEN_15_19_S",
           SUM(young_adult_between_20_24_n) "YOUNG_ADULT_BETWEEN_20_24_N",  SUM(young_adult_between_20_24_s) "YOUNG_ADULT_BETWEEN_20_24_S", 
           SUM(other_adult_n) "OTHER_ADULT_N", SUM(other_adult_s) "OTHER_ADULT_S",
           @clientPfN "CLIENT_PF_N", @clientPfS "CLIENT_PF_S",
            SUM(pregnant_visits_n) 'PREGNANCY_WOMEN_N',SUM(pregnant_visits_s) 'PREGNANCY_WOMEN_S',
            @totalMentalDisorder 'PEOPLE_MENTAL_DISODER',
            0 'CLIENT_S_BU_DENTAIRE_N', 0 'CLIENT_S_BU_DENTAIRE_S',
            0 'PEOPLE_REDUCED_MOB_MOTOR_N',0 'PEOPLE_REDUCED_MOB_MOTOR_S',
            0 'PEOPLE_REDUCED_MOB_SENSORY_N',0 'PEOPLE_REDUCED_MOB_SENSORY_S',
            @total_urine_test_women 'TOTAL_URINE_TEST_WOMEN',
            @total_hemogram_test_women 'TOTAL_HEMOGRAM_TEST_WOMEN',
            @totat_malaria_rapd_test_women 'TOTAL_MALARIA_RAPD_TEST_WOMEN',
            @totat_malaria_rapd_test_positif_women 'TOTAL_MALARIA_RAPD_TEST_POSITIF_WOMEN',
            @total_rpr_test_women 'TOTAL_RPR_TEST_WOMEN',
            @total_rpr_test_positif_women 'TOTAL_RPR_TEST_POSITIF_WOMEN',
            @total_hiv_test_women 'TOTAL_HIV_TEST_WOMEN',
            @total_hiv_test_positif_women 'TOTAL_HIV_TEST_POSITIF_WOMEN',
            @total_sickling_test_women 'TOTAL_SICKLING_TEST_WOMEN',
            @total_sickling_test 'TOTAL_SICKLING_TEST',
            @total_blood_type_test_women 'TOTAL_BLOOD_TYPE_TEST_WOMEN',
            @total_blood_type_test 'TOTAL_BLOOD_TYPE_TEST',
            @total_blood_type_test 'TOTAL_BLOOD_TYPE_TEST',
            @total_sickling_test 'TOTAL_SICKLING_TEST',
            @total_malaria_rapd_test 'TOTAL_MALARIA_RAPD_TEST',
            @totat_malaria_rapd_test_positif 'TOTAL_MALARIA_RAPD_TEST_POSITIF',
            @total_malaria_rapd_test 'TOTAL_MALARIA',
            @totat_malaria_rapd_test_positif 'TOTAL_MALARIA_POSITIF',
            @malaria_test_microscopique_vivax 'VIVAX',
            @malaria_test_microscopique_oval'OVAL',
            @malaria_test_microscopique_malariae 'MALARIAE',
            @malaria_test_microscopique_falciparum 'FALCIPARUM',
            @malaria_test_microscopique_total 'MALARIAN_TEST_MICRO',
            @PHYSICAL_VIOL_WOMEN_DEAD AS 'PHYSICAL_VIOL_WOMEN_DEAD',
            @PHYSICAL_VIOL_WOMEN_TRANSFER AS 'PHYSICAL_VIOL_WOMEN_TRANSFER',
            @PHYSICAL_VIOL_WOMEN_LEFT AS 'PHYSICAL_VIOL_WOMEN_LEFT',
            @PHYSICAL_VIOL_WOMEN_TREATED AS 'PHYSICAL_VIOL_WOMEN_TREATED',
            IFNULL(@PHYSICAL_VIOL_WOMEN_DEAD, 0) + IFNULL(@PHYSICAL_VIOL_WOMEN_TRANSFER, 0) + IFNULL(@PHYSICAL_VIOL_WOMEN_LEFT, 0) + IFNULL(@PHYSICAL_VIOL_WOMEN_TREATED, 0) AS 'PHYSICAL_VIOL_WOMEN_TOTAL',
            @PHYSICAL_VIOL_MEN_DEAD AS 'PHYSICAL_VIOL_MEN_DEAD',
            @PHYSICAL_VIOL_MEN_TRANSFER AS 'PHYSICAL_VIOL_MEN_TRANSFER',
            @PHYSICAL_VIOL_MEN_LEFT AS 'PHYSICAL_VIOL_MEN_LEFT',
            @PHYSICAL_VIOL_MEN_TREATED AS 'PHYSICAL_VIOL_MEN_TREATED',
            IFNULL(@PHYSICAL_VIOL_MEN_DEAD, 0) + IFNULL(@PHYSICAL_VIOL_MEN_TRANSFER, 0) + IFNULL(@PHYSICAL_VIOL_MEN_LEFT, 0) + IFNULL(@PHYSICAL_VIOL_MEN_TREATED, 0) AS 'PHYSICAL_VIOL_MEN_TOTAL',
            @PHYSICAL_VIOL_KID_DEAD AS 'PHYSICAL_VIOL_KID_DEAD',
            @PHYSICAL_VIOL_KID_TRANSFER AS 'PHYSICAL_VIOL_KID_TRANSFER',
            @PHYSICAL_VIOL_KID_LEFT AS 'PHYSICAL_VIOL_KID_LEFT',
            @PHYSICAL_VIOL_KID_TREATED AS 'PHYSICAL_VIOL_KID_TREATED',
            IFNULL(@PHYSICAL_VIOL_KID_DEAD, 0) + IFNULL(@PHYSICAL_VIOL_KID_TRANSFER, 0) + IFNULL(@PHYSICAL_VIOL_KID_LEFT, 0) + IFNULL(@PHYSICAL_VIOL_KID_TREATED, 0) AS 'PHYSICAL_VIOL_KID_TOTAL',
            @SEX_VIOL_WOMEN_DEAD AS 'SEX_VIOL_WOMEN_DEAD',
            @SEX_VIOL_WOMEN_TRANSFER AS 'SEX_VIOL_WOMEN_TRANSFER',
            @SEX_VIOL_WOMEN_LEFT AS 'SEX_VIOL_WOMEN_LEFT',
            @SEX_VIOL_WOMEN_TREATED AS 'SEX_VIOL_WOMEN_TREATED',
            IFNULL(@SEX_VIOL_WOMEN_DEAD, 0) + IFNULL(@SEX_VIOL_WOMEN_TRANSFER, 0) + IFNULL(@SEX_VIOL_WOMEN_LEFT, 0) + IFNULL(@SEX_VIOL_WOMEN_TREATED, 0) AS 'SEX_VIOL_WOMEN_TOTAL', 
            @SEX_VIOL_KIDF_DEAD AS 'SEX_VIOL_KIDF_DEAD',
            @SEX_VIOL_KIDF_TRANSFER AS 'SEX_VIOL_KIDF_TRANSFER',
            @SEX_VIOL_KIDF_LEFT AS 'SEX_VIOL_KIDF_LEFT',
            @SEX_VIOL_KIDF_TREATED AS 'SEX_VIOL_KIDF_TREATED',
            IFNULL(@SEX_VIOL_KIDF_DEAD, 0) + IFNULL(@SEX_VIOL_KIDF_TRANSFER, 0) + IFNULL(@SEX_VIOL_KIDF_LEFT, 0) + IFNULL(@SEX_VIOL_KIDF_TREATED, 0) AS 'SEX_VIOL_KIDF_TOTAL', 
            @SEX_VIOL_MEN_DEAD AS 'SEX_VIOL_MEN_DEAD',
            @SEX_VIOL_MEN_TRANSFER AS 'SEX_VIOL_MEN_TRANSFER',
            @SEX_VIOL_MEN_LEFT AS 'SEX_VIOL_MEN_LEFT',
            @SEX_VIOL_MEN_TREATED AS 'SEX_VIOL_MEN_TREATED',
            IFNULL(@SEX_VIOL_MEN_DEAD, 0) + IFNULL(@SEX_VIOL_MEN_TRANSFER, 0) + IFNULL(@SEX_VIOL_MEN_LEFT, 0) + IFNULL(@SEX_VIOL_MEN_TREATED, 0) AS 'SEX_VIOL_MEN_TOTAL', 
            @SEX_VIOL_KIDM_DEAD AS 'SEX_VIOL_KIDM_DEAD',
            @SEX_VIOL_KIDM_TRANSFER AS 'SEX_VIOL_KIDM_TRANSFER',
            @SEX_VIOL_KIDM_LEFT AS 'SEX_VIOL_KIDM_LEFT',
            @SEX_VIOL_KIDM_TREATED AS 'SEX_VIOL_KIDM_TREATED',
            IFNULL(@SEX_VIOL_KIDM_DEAD, 0) + IFNULL(@SEX_VIOL_KIDM_TRANSFER, 0) + IFNULL(@SEX_VIOL_KIDM_LEFT, 0) + IFNULL(@SEX_VIOL_KIDM_TREATED, 0) AS 'SEX_VIOL_KIDM_TOTAL',
            @ACC_DOMES_DEAD AS 'ACC_DOMES_DEAD',
            @ACC_DOMES_TREATED AS 'ACC_DOMES_TREATED',
            @ACC_DOMES_TRANSFER AS 'ACC_DOMES_TRANSFER',
            @ACC_DOMES_LEFT AS 'ACC_DOMES_LEFT',
            IFNULL(@ACC_DOMES_DEAD, 0) + IFNULL(@ACC_DOMES_TREATED, 0) + IFNULL(@ACC_DOMES_TRANSFER, 0) + IFNULL(@ACC_DOMES_LEFT, 0) AS 'ACC_DOMES_TOTAL',
            @ACC_TR_DEAD AS 'ACC_TR_DEAD',
            @ACC_TR_TREATED AS 'ACC_TR_TREATED',
            @ACC_TR_TRANSFER AS 'ACC_TR_TRANSFER',
            @ACC_TR_LEFT AS 'ACC_TR_LEFT',
            IFNULL(@ACC_TR_DEAD, 0) + IFNULL(@ACC_TR_TREATED, 0) + IFNULL(@ACC_TR_TRANSFER, 0) + IFNULL(@ACC_TR_LEFT, 0) AS 'ACC_TR_TOTAL',
            @ACC_TR_MOTOR_DEAD AS 'ACC_TR_MOTOR_DEAD',
            @ACC_TR_MOTOR_TREATED AS 'ACC_TR_MOTOR_TREATED',
            @ACC_TR_MOTOR_TRANSFER AS 'ACC_TR_MOTOR_TRANSFER',
            @ACC_TR_MOTOR_LEFT AS 'ACC_TR_MOTOR_LEFT',
            IFNULL(@ACC_TR_MOTOR_DEAD, 0) + IFNULL(@ACC_TR_MOTOR_TREATED, 0) + IFNULL(@ACC_TR_MOTOR_TRANSFER, 0) + IFNULL(@ACC_TR_MOTOR_LEFT, 0) AS 'ACC_TR_MOTOR_TOTAL', 
            @ACC_TR_VEHICLE_DEAD AS 'ACC_TR_VEHICLE_DEAD',
            @ACC_TR_VEHICLE_TREATED AS 'ACC_TR_VEHICLE_TREATED',
            @ACC_TR_VEHICLE_TRANSFER AS 'ACC_TR_VEHICLE_TRANSFER',
            @ACC_TR_VEHICLE_LEFT AS 'ACC_TR_VEHICLE_LEFT',
            IFNULL(@ACC_TR_VEHICLE_DEAD, 0) + IFNULL(@ACC_TR_VEHICLE_TREATED, 0) + IFNULL(@ACC_TR_VEHICLE_TRANSFER, 0) + IFNULL(@ACC_TR_VEHICLE_LEFT, 0) AS 'ACC_TR_VEHICLE_TOTAL',
            @OTHER_ACC_TR_DEAD AS 'OTHER_ACC_TR_DEAD',
            @OTHER_ACC_TR_TREATED AS 'OTHER_ACC_TR_TREATED',
            @OTHER_ACC_TR_TRANSFER AS 'OTHER_ACC_TR_TRANSFER',
            @OTHER_ACC_TR_LEFT AS 'OTHER_ACC_TR_LEFT',
            IFNULL(@OTHER_ACC_TR_DEAD, 0) + IFNULL(@OTHER_ACC_TR_TREATED, 0) + IFNULL(@OTHER_ACC_TR_TRANSFER, 0) + IFNULL(@OTHER_ACC_TR_LEFT, 0) AS 'OTHER_ACC_TR_TOTAL',  
            @OTHER_SEX_VIOL_WOMEN_DEAD AS 'OTHER_SEX_VIOL_WOMEN_DEAD',
            @OTHER_SEX_VIOL_WOMEN_TREATED AS 'OTHER_SEX_VIOL_WOMEN_TREATED',
            @OTHER_SEX_VIOL_WOMEN_TRANSFER AS 'OTHER_SEX_VIOL_WOMEN_TRANSFER',
            @OTHER_SEX_VIOL_WOMEN_LEFT AS 'OTHER_SEX_VIOL_WOMEN_LEFT',
            IFNULL(@OTHER_SEX_VIOL_WOMEN_DEAD, 0) + IFNULL(@OTHER_SEX_VIOL_WOMEN_TREATED, 0) + IFNULL(@OTHER_SEX_VIOL_WOMEN_TRANSFER, 0) + IFNULL(@OTHER_SEX_VIOL_WOMEN_LEFT, 0) AS 'OTHER_SEX_VIOL_WOMEN_TOTAL',
            @OTHER_SEX_VIOL_MEN_DEAD AS 'OTHER_SEX_VIOL_MEN_DEAD',
            @OTHER_SEX_VIOL_MEN_TREATED AS 'OTHER_SEX_VIOL_MEN_TREATED',
            @OTHER_SEX_VIOL_MEN_TRANSFER AS 'OTHER_SEX_VIOL_MEN_TRANSFER',
            @OTHER_SEX_VIOL_MEN_LEFT AS 'OTHER_SEX_VIOL_MEN_LEFT',
            IFNULL(@OTHER_SEX_VIOL_MEN_DEAD, 0) + IFNULL(@OTHER_SEX_VIOL_MEN_TREATED, 0) + IFNULL(@OTHER_SEX_VIOL_MEN_TRANSFER, 0) + IFNULL(@OTHER_SEX_VIOL_MEN_LEFT, 0) AS 'OTHER_SEX_VIOL_MEN_TOTAL',  
            @OTHER_SEX_VIOL_KID_DEAD AS 'OTHER_SEX_VIOL_KID_DEAD',
            @OTHER_SEX_VIOL_KID_TREATED AS 'OTHER_SEX_VIOL_KID_TREATED',
            @OTHER_SEX_VIOL_KID_TRANSFER AS 'OTHER_SEX_VIOL_KID_TRANSFER',
            @OTHER_SEX_VIOL_KID_LEFT AS 'OTHER_SEX_VIOL_KID_LEFT',
            IFNULL(@OTHER_SEX_VIOL_KID_DEAD, 0) + IFNULL(@OTHER_SEX_VIOL_KID_TREATED, 0) + IFNULL(@OTHER_SEX_VIOL_KID_TRANSFER, 0) + IFNULL(@OTHER_SEX_VIOL_KID_LEFT, 0) AS 'OTHER_SEX_VIOL_KID_TOTAL'
FROM visits_distribution_temp;