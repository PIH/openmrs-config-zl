
CALL initialize_global_metadata();

 -- set  @startDate = '2024-02-01';
 -- set  @endDate = '2025-03-31';

SET  @locale = GLOBAL_PROPERTY_VALUE('default_locale', 'en');
SET @endDate = ADDDATE(@endDate, INTERVAL 1 DAY);

drop TEMPORARY TABLE if exists visits_distribution_temp;

CREATE TEMPORARY TABLE visits_distribution_temp (
    child_under_1_n int,
    child_between_1_4_n int,
    child_between_5_9_n int,
    child_between_10_14_n int,
    young_adult_between_15_19_n int,
    young_adult_between_20_24_n int,
    other_adult_n int,
    child_under_1_s int,
    child_between_1_4_s int,
    child_between_5_9_s int,
    child_between_10_14_s int,
    young_adult_between_15_19_s int,
    young_adult_between_20_24_s int,
    other_adult_s int,
    client_pf_n int,
    client_pf_s int,
    pregnancy_women_n int,
    pregnancy_women_s int
);

INSERT INTO visits_distribution_temp (child_under_1_n,child_between_1_4_n,child_between_5_9_n,child_between_10_14_n,young_adult_between_15_19_n,young_adult_between_20_24_n,other_adult_n,child_under_1_s,child_between_1_4_s,child_between_5_9_s,child_between_10_14_s,young_adult_between_15_19_s,young_adult_between_20_24_s,other_adult_s)
SELECT 
IF(DATEDIFF(e.encounter_datetime, pr.birthdate)/365.25<1 and prev_checkin.encounter_id is  null,"1","0"),
IF(DATEDIFF(e.encounter_datetime, pr.birthdate)/365.25>=1 and DATEDIFF(e.encounter_datetime, pr.birthdate)/365.25<5 and prev_checkin.encounter_id is  null,"1","0"),
IF(DATEDIFF(e.encounter_datetime, pr.birthdate)/365.25>=5 and DATEDIFF(e.encounter_datetime, pr.birthdate)/365.25<10 and prev_checkin.encounter_id is  null,"1","0"),
IF(DATEDIFF(e.encounter_datetime, pr.birthdate)/365.25>=10 and DATEDIFF(e.encounter_datetime, pr.birthdate)/365.25<15 and prev_checkin.encounter_id is  null,"1","0"),
IF(DATEDIFF(e.encounter_datetime, pr.birthdate)/365.25>=15 and DATEDIFF(e.encounter_datetime, pr.birthdate)/365.25<20 and prev_checkin.encounter_id is  null,"1","0"),
IF(DATEDIFF(e.encounter_datetime, pr.birthdate)/365.25>=20 and DATEDIFF(e.encounter_datetime, pr.birthdate)/365.25<25 and prev_checkin.encounter_id is  null,"1","0"),
IF(DATEDIFF(e.encounter_datetime, pr.birthdate)/365.25>=25 and prev_checkin.encounter_id is  null,"1","0"),

IF(DATEDIFF(e.encounter_datetime, pr.birthdate)/365.25<1 and prev_checkin.encounter_id is not null,"1","0"),
IF(DATEDIFF(e.encounter_datetime, pr.birthdate)/365.25>=1 and DATEDIFF(e.encounter_datetime, pr.birthdate)/365.25<5 and prev_checkin.encounter_id is not null,"1","0"),
IF(DATEDIFF(e.encounter_datetime, pr.birthdate)/365.25>=5 and DATEDIFF(e.encounter_datetime, pr.birthdate)/365.25<10 and prev_checkin.encounter_id is not null,"1","0"),
IF(DATEDIFF(e.encounter_datetime, pr.birthdate)/365.25>=10 and DATEDIFF(e.encounter_datetime, pr.birthdate)/365.25<15 and prev_checkin.encounter_id is not null,"1","0"),
IF(DATEDIFF(e.encounter_datetime, pr.birthdate)/365.25>=15 and DATEDIFF(e.encounter_datetime, pr.birthdate)/365.25<20 and prev_checkin.encounter_id is not null,"1","0"),
IF(DATEDIFF(e.encounter_datetime, pr.birthdate)/365.25>=20 and DATEDIFF(e.encounter_datetime, pr.birthdate)/365.25<25 and prev_checkin.encounter_id is not null,"1","0"),
IF(DATEDIFF(e.encounter_datetime, pr.birthdate)/365.25>=25 and prev_checkin.encounter_id is not null,"1","0")
FROM patient p
-- Person
INNER JOIN person pr ON p.patient_id = pr.person_id AND pr.voided = 0
-- Check in encounter
INNER JOIN encounter e ON p.patient_id = e.patient_id and e.voided = 0 AND e.encounter_type = @chkEnc
-- new/subsequent visit
LEFT OUTER JOIN encounter prev_checkin on prev_checkin.patient_id = e.patient_id and prev_checkin.encounter_type = e.encounter_type 
		and prev_checkin.encounter_datetime < e.encounter_datetime  
WHERE p.voided = 0
-- Exclude test patients
AND p.patient_id NOT IN (SELECT person_id FROM person_attribute WHERE value = 'true' AND person_attribute_type_id = @testPt
                         AND voided = 0)
AND date(e.encounter_datetime) >= @startDate
AND date(e.encounter_datetime) < @endDate
GROUP BY e.encounter_id;

-- CLIENT PF
INSERT INTO visits_distribution_temp(client_pf_n,client_pf_s)
SELECT
IF(prev_checkin.encounter_id is  null,"1","0"), 
IF(prev_checkin.encounter_id is not null,"1","0") from
obs o 
INNER JOIN encounter e 
ON o.encounter_id =e.encounter_id 
LEFT OUTER JOIN encounter prev_checkin on prev_checkin.patient_id = e.patient_id and prev_checkin.encounter_type = e.encounter_type 
		and prev_checkin.encounter_datetime < e.encounter_datetime  
WHERE o.value_coded =concept_from_mapping('PIH','5483')
AND o.voided =0
AND date(e.encounter_datetime) >= @startDate
AND date(e.encounter_datetime) < @endDate
GROUP BY e.encounter_id;

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
INSERT INTO visits_distribution_temp(pregnancy_women_n,pregnancy_women_s)
SELECT
IF(o_pregnant.value_coded=1 and prev_checkin.encounter_id is  null,"1","0"), 
IF(o_pregnant.value_coded=1 and prev_checkin.encounter_id is not null,"1","0")
FROM  obs o_pregnant 
INNER JOIN encounter e 
ON o_pregnant.encounter_id =e.encounter_id 
LEFT OUTER JOIN encounter prev_checkin on prev_checkin.patient_id = e.patient_id and prev_checkin.encounter_type = e.encounter_type 
		and prev_checkin.encounter_datetime < e.encounter_datetime  
    WHERE  
    o_pregnant.concept_id = concept_from_mapping('CIEL', '5272') 
    AND o_pregnant.voided = 0
    AND date(e.encounter_datetime) >= @startDate
    AND date(e.encounter_datetime) < @endDate
    GROUP BY e.encounter_id;

-- ______________________________ EXAMENS DE LABORATOIRE__________________________



DROP TABLE IF EXISTS  pregnancy_patient_temp;
CREATE TEMPORARY TABLE pregnancy_patient_temp(person_id int,pregnant int);
 INSERT INTO pregnancy_patient_temp(person_id,pregnant)
SELECT p.person_id,
       IF(o_pregnant.value_coded = concept_from_mapping('CIEL', '1065') 
        AND o_dolp.value_datetime > IFNULL(o_dod.value_datetime,'0000-00-00 00:00:00'), 1, 0) as pregnant
FROM person p
LEFT JOIN obs o_edd 
    ON o_edd.obs_id = latest_obs(p.person_id, 'CIEL', '5596') 
    AND o_edd.voided = 0
LEFT JOIN obs o_dolp 
    ON o_dolp.obs_id = latest_obs(p.person_id, 'CIEL', '1427') 
    AND o_dolp.voided = 0
LEFT JOIN obs o_dod 
    ON o_dod.obs_id = latest_obs(p.person_id, 'CIEL', '5599') 
    AND o_dod.voided = 0
LEFT JOIN obs o_pregnant 
    ON o_pregnant.obs_id = latest_obs(p.person_id, 'CIEL', '5272') 
    AND o_pregnant.voided = 0
INNER JOIN encounter e 
    ON o_pregnant.encounter_id = e.encounter_id
WHERE p.person_id = p.person_id
     AND  p.gender='F'
     AND date(e.encounter_datetime) >=@startDate
     AND date(e.encounter_datetime) < @endDate 
     GROUP BY e.encounter_id ;
 

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
WHERE concept_name(o.value_coded, 'fr') = 'Positive for Plasmodium vivax'
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
WHERE concept_name(o.value_coded, 'fr') = 'Positive for Plasmodium ovale'
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
WHERE concept_name(o.value_coded, 'fr') = 'Positive for Plasmodium malariae'
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
 WHERE concept_name(o.value_coded, 'fr') = 'Positive for Plasmodium falciparum'
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


  SELECT SUM(child_under_1_n) "CHILD_UNDER_1_N",SUM(child_under_1_s) "CHILD_UNDER_1_S",
       SUM(child_between_1_4_n) "CHILD_BETWEEN_1_4_N", SUM(child_between_1_4_s) "CHILD_BETWEEN_1_4_S",
        SUM(child_between_5_9_n) "CHILD_BETWEEN_5_9_N",SUM(child_between_5_9_s) "CHILD_BETWEEN_5_9_S",
         SUM(child_between_10_14_n) "CHILD_BETWEEN_10_14_N",SUM(child_between_10_14_s) "CHILD_BETWEEN_10_14_S",
          SUM(young_adult_between_15_19_n) "YOUNG_ADULT_BETWEEN_15_19_N", SUM(young_adult_between_15_19_s) "YOUNG_ADULT_BETWEEN_15_19_S",
           SUM(young_adult_between_20_24_n) "YOUNG_ADULT_BETWEEN_20_24_N",  SUM(young_adult_between_20_24_s) "YOUNG_ADULT_BETWEEN_20_24_S", 
           SUM(other_adult_n) "OTHER_ADULT_N", SUM(other_adult_s) "OTHER_ADULT_S",
           SUM(client_pf_n) "CLIENT_PF_N", SUM(client_pf_s) "CLIENT_PF_S",
           SUM(pregnancy_women_n) 'PREGNANCY_WOMEN_N',SUM(pregnancy_women_s) 'PREGNANCY_WOMEN_S',
            @totalMentalDisorder 'PEOPLE_MENTAL_DISODER',
            0 'CLIENT_S_BU_DENTAIRE_N', 0 'CLIENT_S_BU_DENTAIRE_S',
            0 'PEOPLE_REDUCED_MOB_MOTOR_N',0 'PEOPLE_REDUCED_MOB_MOTOR_S',
            0 'PEOPLE_REDUCED_MOB_SENSORY_N',0 'PEOPLE_REDUCED_MOB_SENSORY_S',

            @total_urine_test_women 'TOTAL_URINE_TEST_WOMEN',
            @total_hemogram_test_women 'TOTAL_HEMOGRAM_TEST_WOMEN',
            @totat_malaria_rapd_test_women 'TOTAL_MALARIA_RAPD_TEST_WOMEN',
            @totat_malaria_rapd_test_positif_women 'TOTAL_MALARIA_RAPD_TEST_POSITIF_WOMEN',
            @total_rpr_test_women 'TOTAL_RPR_TEST_WOMEN',
            @total_hiv_test_women 'TOTAL_HIV_TEST_WOMEN',
            @total_rpr_test_positif_women 'TOTAL_RPR_TEST_POSITIF_WOMEN',
            @total_hiv_test_positif_women 'TOTAL_HIV_TEST_POSITIF_WOMEN',
            @total_sickling_test_women 'TOTAL_SICKLING_TEST_WOMEN',
            @total_blood_type_test_women 'TOTAL_BLOOD_TYPE_TEST_WOMEN',
            
            @total_blood_type_test 'TOTAL_BLOOD_TYPE_TEST',
            @total_sickling_test 'TOTAL_SICKLING_TEST',
            @total_malaria_rapd_test 'TOTAL_MALARIA_RAPD_TEST',
            @totat_malaria_rapd_test_positif 'TOTAL_MALARIA_RAPD_TEST_POSITIF',
            @total_malaria_rapd_test 'TOTAL_MALARIA',
            @totat_malaria_rapd_test_positif 'TOTAL_MALARIA_POSITIF',
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
            @malaria_test_microscopique_total 'MALARIAN_TEST_MICRO'
       FROM visits_distribution_temp;
 