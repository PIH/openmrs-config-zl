
CALL initialize_global_metadata();

-- set  @startDate = '2025-04-03';
-- set  @endDate = '2025-04-24';
SET @firstDate = CONCAT(YEAR(CURDATE()), '-01-01');

SET  @locale = GLOBAL_PROPERTY_VALUE('default_locale', 'en');
SET @endDate = ADDDATE(@endDate, INTERVAL 1 DAY);

  SELECT 
   
          -- Cas Febrile
		   
		 SUM(CASE WHEN age_at_enc(p.person_id, e.encounter_id) < 1 AND p.gender = 'F' AND diagnostic.value_coded = concept_from_mapping("PIH", "FEVER") THEN 1 ELSE 0 END),
		  SUM(CASE WHEN age_at_enc(p.person_id, e.encounter_id) < 1 AND p.gender = 'M' AND diagnostic.value_coded = concept_from_mapping("PIH", "FEVER") THEN 1 ELSE 0 END),
		  
		  SUM(CASE WHEN age_at_enc(p.person_id, e.encounter_id) BETWEEN 1 AND 4 AND p.gender = 'F' AND diagnostic.value_coded = concept_from_mapping("PIH", "FEVER") THEN 1 ELSE 0 END),
		  SUM(CASE WHEN age_at_enc(p.person_id, e.encounter_id) BETWEEN 1 AND 4 AND p.gender = 'M' AND diagnostic.value_coded = concept_from_mapping("PIH", "FEVER") THEN 1 ELSE 0 END),
		  
		  SUM(CASE WHEN age_at_enc(p.person_id, e.encounter_id) BETWEEN 5 AND 9 AND p.gender = 'F' AND diagnostic.value_coded = concept_from_mapping("PIH", "FEVER") THEN 1 ELSE 0 END),
		  SUM(CASE WHEN age_at_enc(p.person_id, e.encounter_id) BETWEEN 5 AND 9 AND p.gender = 'M' AND diagnostic.value_coded = concept_from_mapping("PIH", "FEVER") THEN 1 ELSE 0 END),
		
		  SUM(CASE WHEN age_at_enc(p.person_id, e.encounter_id) BETWEEN 10 AND 14 AND p.gender = 'F' AND diagnostic.value_coded = concept_from_mapping("PIH", "FEVER") THEN 1 ELSE 0 END),
		  SUM(CASE WHEN age_at_enc(p.person_id, e.encounter_id) BETWEEN 10 AND 14 AND p.gender = 'M' AND diagnostic.value_coded = concept_from_mapping("PIH", "FEVER") THEN 1 ELSE 0 END),
		
		  SUM(CASE WHEN age_at_enc(p.person_id, e.encounter_id) BETWEEN 15 AND 19 AND p.gender = 'F' AND diagnostic.value_coded = concept_from_mapping("PIH", "FEVER") THEN 1 ELSE 0 END),
		  SUM(CASE WHEN age_at_enc(p.person_id, e.encounter_id) BETWEEN 15 AND 19 AND p.gender = 'M' AND diagnostic.value_coded = concept_from_mapping("PIH", "FEVER") THEN 1 ELSE 0 END),
		
		  SUM(CASE WHEN age_at_enc(p.person_id, e.encounter_id) BETWEEN 20 AND 24 AND p.gender = 'F' AND diagnostic.value_coded = concept_from_mapping("PIH", "FEVER") THEN 1 ELSE 0 END),
		  SUM(CASE WHEN age_at_enc(p.person_id, e.encounter_id) BETWEEN 20 AND 24 AND p.gender = 'M' AND diagnostic.value_coded = concept_from_mapping("PIH", "FEVER") THEN 1 ELSE 0 END),
		
		  SUM(CASE WHEN age_at_enc(p.person_id, e.encounter_id) BETWEEN 25 AND 49 AND p.gender = 'F' AND diagnostic.value_coded = concept_from_mapping("PIH", "FEVER") THEN 1 ELSE 0 END),
		  SUM(CASE WHEN age_at_enc(p.person_id, e.encounter_id) BETWEEN 25 AND 49 AND p.gender = 'M' AND diagnostic.value_coded = concept_from_mapping("PIH", "FEVER") THEN 1 ELSE 0 END),
		
		  SUM(CASE WHEN age_at_enc(p.person_id, e.encounter_id) >= 50 AND p.gender = 'F' AND diagnostic.value_coded = concept_from_mapping("PIH", "FEVER") THEN 1 ELSE 0 END),
		  SUM(CASE WHEN age_at_enc(p.person_id, e.encounter_id) >= 50 AND p.gender = 'M' AND diagnostic.value_coded = concept_from_mapping("PIH", "FEVER") THEN 1 ELSE 0 END),
		  
		  SUM(CASE WHEN  p.dead=1 AND diagnostic.value_coded = concept_from_mapping("PIH", "FEVER") THEN 1 ELSE 0 END),
		  SUM(CASE WHEN  disposition.value_coded = concept_from_mapping("PIH", "Transfer out of hospital") AND diagnostic.value_coded = concept_from_mapping("PIH", "FEVER") THEN 1 ELSE 0 END)
		  
		     INTO 
			  -- Cas Febrile
			 @FE_AGE_0_F, @FE_AGE_0_M, @FE_AGE_1_4_F, @FE_AGE_1_4_M, @FE_AGE_5_9_F, @FE_AGE_5_9_M, @FE_AGE_10_14_F, @FE_AGE_10_14_M,
             @FE_AGE_15_19_F, @FE_AGE_15_19_M, @FE_AGE_20_24_F, @FE_AGE_20_24_M, @FE_AGE_25_49_F, @FE_AGE_25_49_M, @FE_AGE_50_PLUS_F, @FE_AGE_50_PLUS_M,
             @FE_DEATH, @FE_TRANSFER
		 FROM  obs o 
		  INNER JOIN encounter e ON o.encounter_id = e.encounter_id 
		  INNER JOIN person p ON p.person_id = o.person_id
		  LEFT JOIN (
		    SELECT encounter_id, value_coded
		    FROM obs
		    WHERE concept_id = concept_from_mapping("PIH", "1379") AND voided=0 ) AS diagnostic_cert ON o.encounter_id = diagnostic_cert.encounter_id
		  LEFT JOIN (
		    SELECT encounter_id, value_coded
		    FROM obs
		    WHERE concept_id = concept_from_mapping("PIH", "3064") AND voided=0 ) AS diagnostic ON o.encounter_id = diagnostic.encounter_id
		  LEFT JOIN (
		    SELECT encounter_id, value_coded
		    FROM obs
		    WHERE concept_id = concept_from_mapping("PIH", "8620") AND voided=0 ) AS disposition ON o.encounter_id = disposition.encounter_id
		
		  WHERE  e.voided = 0 AND o.voided = 0
		   AND DATE(e.encounter_datetime) >= @startDate
		   AND DATE(e.encounter_datetime) < @endDate;
		  
		  
		  
		  
		  SELECT 
		  
		   -- Malaria + confirmée + traitée 
   
		  SUM(CASE WHEN age_at_enc(p.person_id, e.encounter_id) < 1 AND p.gender = 'F' 
		  AND diagnostic.value_coded = concept_from_mapping("PIH", "MALARIA") 
		  AND diagnostic_cert.value_coded = concept_from_mapping("PIH", "CONFIRMED") 
		  AND disposition.value_coded = concept_from_mapping("PIH", "DISCHARGED") THEN 1 ELSE 0 END) ,
		  SUM(CASE WHEN age_at_enc(p.person_id, e.encounter_id) < 1 AND p.gender = 'M' 
		  AND diagnostic.value_coded = concept_from_mapping("PIH", "MALARIA") 
		  AND diagnostic.value_coded = concept_from_mapping("PIH", "CONFIRMED") 
		  AND disposition.value_coded = concept_from_mapping("PIH", "DISCHARGED") THEN 1 ELSE 0 END),
		  
		  SUM(CASE WHEN age_at_enc(p.person_id, e.encounter_id) BETWEEN 1 AND 4 AND p.gender = 'F'
		  AND diagnostic.value_coded = concept_from_mapping("PIH", "MALARIA") 
		  AND diagnostic_cert.value_coded = concept_from_mapping("PIH", "CONFIRMED") 
		  AND disposition.value_coded = concept_from_mapping("PIH", "DISCHARGED") THEN 1 ELSE 0 END),
		  SUM(CASE WHEN age_at_enc(p.person_id, e.encounter_id) BETWEEN 1 AND 4 AND p.gender = 'M' 
		  AND diagnostic.value_coded = concept_from_mapping("PIH", "MALARIA") 
		  AND diagnostic_cert.value_coded = concept_from_mapping("PIH", "CONFIRMED") 
		  AND disposition.value_coded = concept_from_mapping("PIH", "DISCHARGED") THEN 1 ELSE 0 END),
		
		  SUM(CASE WHEN age_at_enc(p.person_id, e.encounter_id) BETWEEN 5 AND 9 AND p.gender = 'F' 
		  AND diagnostic.value_coded = concept_from_mapping("PIH", "MALARIA")  
		  AND diagnostic_cert.value_coded = concept_from_mapping("PIH", "CONFIRMED") 
		  AND disposition.value_coded = concept_from_mapping("PIH", "DISCHARGED") THEN 1 ELSE 0 END),
		  SUM(CASE WHEN age_at_enc(p.person_id, e.encounter_id) BETWEEN 5 AND 9 AND p.gender = 'M'
		  AND diagnostic.value_coded = concept_from_mapping("PIH", "MALARIA") 
		  AND diagnostic_cert.value_coded = concept_from_mapping("PIH", "CONFIRMED") 
		  AND disposition.value_coded = concept_from_mapping("PIH", "DISCHARGED") THEN 1 ELSE 0 END),
		  
		  SUM(CASE WHEN age_at_enc(p.person_id, e.encounter_id) BETWEEN 10 AND 14 AND p.gender = 'F' 
		  AND diagnostic.value_coded = concept_from_mapping("PIH", "MALARIA") 
		  AND diagnostic_cert.value_coded = concept_from_mapping("PIH", "CONFIRMED") 
		  AND disposition.value_coded = concept_from_mapping("PIH", "DISCHARGED") THEN 1 ELSE 0 END),
		  SUM(CASE WHEN age_at_enc(p.person_id, e.encounter_id) BETWEEN 10 AND 14 AND p.gender = 'M'
		  AND diagnostic.value_coded = concept_from_mapping("PIH", "MALARIA")
		  AND diagnostic.value_coded = concept_from_mapping("PIH", "CONFIRMED") 
		  AND disposition.value_coded = concept_from_mapping("PIH", "DISCHARGED") THEN 1 ELSE 0 END),
		  
		  SUM(CASE WHEN age_at_enc(p.person_id, e.encounter_id) BETWEEN 15 AND 19 AND p.gender = 'F' 
		  AND diagnostic.value_coded = concept_from_mapping("PIH", "MALARIA") 
		  AND diagnostic_cert.value_coded = concept_from_mapping("PIH", "CONFIRMED") 
		  AND disposition.value_coded = concept_from_mapping("PIH", "DISCHARGED") THEN 1 ELSE 0 END),
		  SUM(CASE WHEN age_at_enc(p.person_id, e.encounter_id) BETWEEN 15 AND 19 AND p.gender = 'M' 
		  AND diagnostic.value_coded = concept_from_mapping("PIH", "MALARIA") 
		  AND diagnostic_cert.value_coded = concept_from_mapping("PIH", "CONFIRMED") 
		  AND disposition.value_coded = concept_from_mapping("PIH", "DISCHARGED") THEN 1 ELSE 0 END),
		  
		  SUM(CASE WHEN age_at_enc(p.person_id, e.encounter_id) BETWEEN 20 AND 24 AND p.gender = 'F' 
		  AND diagnostic.value_coded = concept_from_mapping("PIH", "MALARIA") 
		  AND diagnostic_cert.value_coded = concept_from_mapping("PIH", "CONFIRMED") 
		  AND diagnostic.value_coded = concept_from_mapping("PIH", "DISCHARGED") THEN 1 ELSE 0 END),
		  SUM(CASE WHEN age_at_enc(p.person_id, e.encounter_id) BETWEEN 20 AND 24 AND p.gender = 'M' 
		  AND diagnostic.value_coded = concept_from_mapping("PIH", "MALARIA") 
		  AND diagnostic_cert.value_coded = concept_from_mapping("PIH", "CONFIRMED") 
		  AND disposition.value_coded = concept_from_mapping("PIH", "DISCHARGED") THEN 1 ELSE 0 END),
		
		  SUM(CASE WHEN age_at_enc(p.person_id, e.encounter_id) BETWEEN 25 AND 49 AND p.gender = 'F' 
		  AND diagnostic.value_coded = concept_from_mapping("PIH", "MALARIA") 
		  AND diagnostic_cert.value_coded = concept_from_mapping("PIH", "CONFIRMED") 
		  AND disposition.value_coded = concept_from_mapping("PIH", "DISCHARGED") THEN 1 ELSE 0 END) ,
		  SUM(CASE WHEN age_at_enc(p.person_id, e.encounter_id) BETWEEN 25 AND 49 AND p.gender = 'M' 
		  AND diagnostic.value_coded = concept_from_mapping("PIH", "MALARIA") 
		  AND diagnostic_cert.value_coded = concept_from_mapping("PIH", "CONFIRMED") 
		  AND disposition.value_coded = concept_from_mapping("PIH", "DISCHARGED") THEN 1 ELSE 0 END) ,
		
		  SUM(CASE WHEN age_at_enc(p.person_id, e.encounter_id) >= 50 AND p.gender = 'F' 
		  AND diagnostic.value_coded = concept_from_mapping("PIH", "MALARIA") 
		  AND diagnostic_cert.value_coded = concept_from_mapping("PIH", "CONFIRMED") 
		  AND disposition.value_coded = concept_from_mapping("PIH", "DISCHARGED") THEN 1 ELSE 0 END) ,
		  SUM(CASE WHEN age_at_enc(p.person_id, e.encounter_id) >= 50 AND p.gender = 'M'
		  AND diagnostic.value_coded = concept_from_mapping("PIH", "MALARIA")
		  AND diagnostic_cert.value_coded = concept_from_mapping("PIH", "CONFIRMED") 
		  AND disposition.value_coded = concept_from_mapping("PIH", "DISCHARGED") THEN 1 ELSE 0 END) ,
		  
		   SUM(CASE WHEN diagnostic.value_coded = concept_from_mapping("PIH", "MALARIA")
		   AND diagnostic_cert.value_coded = concept_from_mapping("PIH", "CONFIRMED") 
		   AND  p.dead=1
		   AND disposition.value_coded = concept_from_mapping("PIH", "DISCHARGED") THEN 1 ELSE 0 END) ,
		   
		   SUM(CASE WHEN diagnostic.value_coded = concept_from_mapping("PIH", "MALARIA")
		   AND diagnostic_cert.value_coded = concept_from_mapping("PIH", "CONFIRMED") 
		   AND  disposition.value_coded = concept_from_mapping("PIH", "Transfer out of hospital")
		   AND disposition.value_coded = concept_from_mapping("PIH", "DISCHARGED") THEN 1 ELSE 0 END) 
		  
		  INTO
		  	 -- Malaria + confirmée + traitée 
			@MCT_AGE_0_F, @MCT_AGE_0_M, @MCT_AGE_1_4_F, @MCT_AGE_1_4_M, @MCT_AGE_5_9_F, @MCT_AGE_5_9_M, @MCT_AGE_10_14_F, @MCT_AGE_10_14_M,
            @MCT_AGE_15_19_F, @MCT_AGE_15_19_M, @MCT_AGE_20_24_F, @MCT_AGE_20_24_M, @MCT_AGE_25_49_F, @MCT_AGE_25_49_M, @MCT_AGE_50_PLUS_F, @MCT_AGE_50_PLUS_M,
            @MCT_DEATH, @MCT_TRANSFER
		  
		   FROM  obs o 
		  INNER JOIN encounter e ON o.encounter_id = e.encounter_id 
		  INNER JOIN person p ON p.person_id = o.person_id
		  LEFT JOIN (
		    SELECT encounter_id, value_coded
		    FROM obs
		    WHERE concept_id = concept_from_mapping("PIH", "1379") AND voided=0 ) AS diagnostic_cert ON o.encounter_id = diagnostic_cert.encounter_id
		  LEFT JOIN (
		    SELECT encounter_id, value_coded
		    FROM obs
		    WHERE concept_id = concept_from_mapping("PIH", "3064") AND voided=0 ) AS diagnostic ON o.encounter_id = diagnostic.encounter_id
		  LEFT JOIN (
		    SELECT encounter_id, value_coded
		    FROM obs
		    WHERE concept_id = concept_from_mapping("PIH", "8620") AND voided=0 ) AS disposition ON o.encounter_id = disposition.encounter_id
		
		  WHERE  e.voided = 0 AND o.voided = 0
		   AND DATE(e.encounter_datetime) >= @startDate
		   AND DATE(e.encounter_datetime) < @endDate;
		  
		  
		  
		  SELECT 
		  
		  
		     -- Malaria Severe  + Hospitalise 
		 
		  SUM(CASE WHEN age_at_enc(p.person_id, e.encounter_id) < 1 AND p.gender = 'F' 
		  AND diagnostic.value_coded = concept_from_mapping("PIH", "Severe malaria") 
		  AND disposition.value_coded = concept_from_mapping("PIH", "ADMIT TO HOSPITAL") THEN 1 ELSE 0 END)  ,
		  SUM(CASE WHEN age_at_enc(p.person_id, e.encounter_id) < 1 AND p.gender = 'M' 
		  AND diagnostic.value_coded = concept_from_mapping("PIH", "Severe malaria") 
		  AND disposition.value_coded = concept_from_mapping("PIH", "ADMIT TO HOSPITAL") THEN 1 ELSE 0 END)  ,
		  
		  SUM(CASE WHEN age_at_enc(p.person_id, e.encounter_id) BETWEEN 1 AND 4 AND p.gender = 'F'
		  AND diagnostic.value_coded = concept_from_mapping("PIH", "Severe malaria") 
		  AND disposition.value_coded = concept_from_mapping("PIH", "ADMIT TO HOSPITAL") THEN 1 ELSE 0 END)  ,
		  SUM(CASE WHEN age_at_enc(p.person_id, e.encounter_id) BETWEEN 1 AND 4 AND p.gender = 'M' 
		  AND diagnostic.value_coded = concept_from_mapping("PIH", "Severe malaria") 
		  AND disposition.value_coded = concept_from_mapping("PIH", "ADMIT TO HOSPITAL") THEN 1 ELSE 0 END)  ,
		
		  SUM(CASE WHEN age_at_enc(p.person_id, e.encounter_id) BETWEEN 5 AND 9 AND p.gender = 'F' 
		  AND diagnostic.value_coded = concept_from_mapping("PIH", "Severe malaria")  
		  AND disposition.value_coded = concept_from_mapping("PIH", "ADMIT TO HOSPITAL") THEN 1 ELSE 0 END) ,
		  SUM(CASE WHEN age_at_enc(p.person_id, e.encounter_id) BETWEEN 5 AND 9 AND p.gender = 'M'
		  AND diagnostic.value_coded = concept_from_mapping("PIH", "Severe malaria") 
		  AND disposition.value_coded = concept_from_mapping("PIH", "ADMIT TO HOSPITAL") THEN 1 ELSE 0 END) ,
		  
		  SUM(CASE WHEN age_at_enc(p.person_id, e.encounter_id) BETWEEN 10 AND 14 AND p.gender = 'F' 
		  AND diagnostic.value_coded = concept_from_mapping("PIH", "Severe malaria") 
		  AND disposition.value_coded = concept_from_mapping("PIH", "ADMIT TO HOSPITAL") THEN 1 ELSE 0 END),
		  SUM(CASE WHEN age_at_enc(p.person_id, e.encounter_id) BETWEEN 10 AND 14 AND p.gender = 'M'
		  AND diagnostic.value_coded = concept_from_mapping("PIH", "Severe malaria")
		  AND disposition.value_coded = concept_from_mapping("PIH", "ADMIT TO HOSPITAL") THEN 1 ELSE 0 END) ,
		  
		  SUM(CASE WHEN age_at_enc(p.person_id, e.encounter_id) BETWEEN 15 AND 19 AND p.gender = 'F' 
		  AND diagnostic.value_coded = concept_from_mapping("PIH", "Severe malaria")  
		  AND disposition.value_coded = concept_from_mapping("PIH", "ADMIT TO HOSPITAL") THEN 1 ELSE 0 END) ,
		  SUM(CASE WHEN age_at_enc(p.person_id, e.encounter_id) BETWEEN 15 AND 19 AND p.gender = 'M' 
		  AND diagnostic.value_coded = concept_from_mapping("PIH", "Severe malaria") 
		  AND disposition.value_coded = concept_from_mapping("PIH", "ADMIT TO HOSPITAL") THEN 1 ELSE 0 END) ,
		  
		  SUM(CASE WHEN age_at_enc(p.person_id, e.encounter_id) BETWEEN 20 AND 24 AND p.gender = 'F' 
		  AND diagnostic.value_coded = concept_from_mapping("PIH", "Severe malaria") 
		  AND disposition.value_coded = concept_from_mapping("PIH", "ADMIT TO HOSPITAL") THEN 1 ELSE 0 END),
		  SUM(CASE WHEN age_at_enc(p.person_id, e.encounter_id) BETWEEN 20 AND 24 AND p.gender = 'M' 
		  AND diagnostic.value_coded = concept_from_mapping("PIH", "Severe malaria") 
		  AND disposition.value_coded = concept_from_mapping("PIH", "ADMIT TO HOSPITAL") THEN 1 ELSE 0 END) ,
		
		  SUM(CASE WHEN age_at_enc(p.person_id, e.encounter_id) BETWEEN 25 AND 49 AND p.gender = 'F' 
		  AND diagnostic.value_coded = concept_from_mapping("PIH", "Severe malaria") 
		  AND disposition.value_coded = concept_from_mapping("PIH", "ADMIT TO HOSPITAL") THEN 1 ELSE 0 END) ,
		  SUM(CASE WHEN age_at_enc(p.person_id, e.encounter_id) BETWEEN 25 AND 49 AND p.gender = 'M' 
		  AND diagnostic.value_coded = concept_from_mapping("PIH", "Severe malaria") 
		  AND disposition.value_coded = concept_from_mapping("PIH", "ADMIT TO HOSPITAL") THEN 1 ELSE 0 END) ,
		
		  SUM(CASE WHEN age_at_enc(p.person_id, e.encounter_id) >= 50 AND p.gender = 'F' 
		  AND diagnostic.value_coded = concept_from_mapping("PIH", "Severe malaria") 
		  AND disposition.value_coded = concept_from_mapping("PIH", "ADMIT TO HOSPITAL") THEN 1 ELSE 0 END) ,
		  SUM(CASE WHEN age_at_enc(p.person_id, e.encounter_id) >= 50 AND p.gender = 'M'
		  AND diagnostic.value_coded = concept_from_mapping("PIH", "Severe malaria")
		  AND disposition.value_coded = concept_from_mapping("PIH", "ADMIT TO HOSPITAL") THEN 1 ELSE 0 END) ,
		  
		  SUM(CASE WHEN  diagnostic.value_coded = concept_from_mapping("PIH", "Severe malaria") 
		  AND p.dead=1 
		  AND disposition.value_coded = concept_from_mapping("PIH", "ADMIT TO HOSPITAL") THEN 1 ELSE 0 END) ,
		  
		  SUM(CASE WHEN  diagnostic.value_coded = concept_from_mapping("PIH", "Severe malaria")
		  AND disposition.value_coded = concept_from_mapping("PIH", "Transfer out of hospital	") 
		  AND disposition.value_coded = concept_from_mapping("PIH", "ADMIT TO HOSPITAL") THEN 1 ELSE 0 END) 
		  
		  INTO 
		  
		  	 -- Malaria Severe  + Hospitalise 
			@MSH_AGE_0_F, @MSH_AGE_0_M, @MSH_AGE_1_4_F, @MSH_AGE_1_4_M, @MSH_AGE_5_9_F, @MSH_AGE_5_9_M, @MSH_AGE_10_14_F, @MSH_AGE_10_14_M,
            @MSH_AGE_15_19_F, @MSH_AGE_15_19_M, @MSH_AGE_20_24_F, @MSH_AGE_20_24_M, @MSH_AGE_25_49_F, @MSH_AGE_25_49_M, @MSH_AGE_50_PLUS_F, @MSH_AGE_50_PLUS_M,
            @MSH_DEATH, @MSH_TRANSFER

		     FROM  obs o 
		  INNER JOIN encounter e ON o.encounter_id = e.encounter_id 
		  INNER JOIN person p ON p.person_id = o.person_id
		  LEFT JOIN (
		    SELECT encounter_id, value_coded
		    FROM obs
		    WHERE concept_id = concept_from_mapping("PIH", "1379") AND voided=0 ) AS diagnostic_cert ON o.encounter_id = diagnostic_cert.encounter_id
		  LEFT JOIN (
		    SELECT encounter_id, value_coded
		    FROM obs
		    WHERE concept_id = concept_from_mapping("PIH", "3064") AND voided=0 ) AS diagnostic ON o.encounter_id = diagnostic.encounter_id
		  LEFT JOIN (
		    SELECT encounter_id, value_coded
		    FROM obs
		    WHERE concept_id = concept_from_mapping("PIH", "8620") AND voided=0 ) AS disposition ON o.encounter_id = disposition.encounter_id
		
		  WHERE  e.voided = 0 AND o.voided = 0
		   AND DATE(e.encounter_datetime) >= @startDate
		   AND DATE(e.encounter_datetime) < @endDate;
		  
		  
		      -- Malaria Severe  + Hospitalise + decedee
		  SELECT 
		  
		    
		  SUM(CASE WHEN age_at_enc(p.person_id, e.encounter_id) < 1 AND p.gender = 'F' 
		  AND diagnostic.value_coded = concept_from_mapping("PIH", "Severe malaria") 
		  AND disposition.value_coded = concept_from_mapping("PIH", "ADMIT TO HOSPITAL")
		  AND p.dead=1 THEN 1 ELSE 0 END) ,
		  SUM(CASE WHEN age_at_enc(p.person_id, e.encounter_id) < 1 AND p.gender = 'M' 
		  AND diagnostic.value_coded = concept_from_mapping("PIH", "Severe malaria") 
		  AND disposition.value_coded = concept_from_mapping("PIH", "ADMIT TO HOSPITAL")
		  AND p.dead=1 THEN 1 ELSE 0 END) ,
		  
		  SUM(CASE WHEN age_at_enc(p.person_id, e.encounter_id) BETWEEN 1 AND 4 AND p.gender = 'F'
		  AND diagnostic.value_coded = concept_from_mapping("PIH", "Severe malaria") 
		  AND disposition.value_coded = concept_from_mapping("PIH", "ADMIT TO HOSPITAL") 
		  AND p.dead=1 THEN 1 ELSE 0 END) ,
		  SUM(CASE WHEN age_at_enc(p.person_id, e.encounter_id) BETWEEN 1 AND 4 AND p.gender = 'M' 
		  AND diagnostic.value_coded = concept_from_mapping("PIH", "Severe malaria") 
		  AND disposition.value_coded = concept_from_mapping("PIH", "ADMIT TO HOSPITAL") 
		  AND p.dead=1 THEN 1 ELSE 0 END) ,
		
		  SUM(CASE WHEN age_at_enc(p.person_id, e.encounter_id) BETWEEN 5 AND 9 AND p.gender = 'F' 
		  AND diagnostic.value_coded = concept_from_mapping("PIH", "Severe malaria")  
		  AND disposition.value_coded = concept_from_mapping("PIH", "ADMIT TO HOSPITAL") 
		  AND p.dead=1 THEN 1 ELSE 0 END) ,
		  SUM(CASE WHEN age_at_enc(p.person_id, e.encounter_id) BETWEEN 5 AND 9 AND p.gender = 'M'
		  AND diagnostic.value_coded = concept_from_mapping("PIH", "Severe malaria") 
		  AND disposition.value_coded = concept_from_mapping("PIH", "ADMIT TO HOSPITAL")
		  AND p.dead=1 THEN 1 ELSE 0 END),
		  
		  SUM(CASE WHEN age_at_enc(p.person_id, e.encounter_id) BETWEEN 10 AND 14 AND p.gender = 'F' 
		  AND diagnostic.value_coded = concept_from_mapping("PIH", "Severe malaria") 
		  AND disposition.value_coded = concept_from_mapping("PIH", "ADMIT TO HOSPITAL")
		  AND p.dead=1 THEN 1 ELSE 0 END) ,
		  SUM(CASE WHEN age_at_enc(p.person_id, e.encounter_id) BETWEEN 10 AND 14 AND p.gender = 'M'
		  AND diagnostic.value_coded = concept_from_mapping("PIH", "Severe malaria")
		  AND disposition.value_coded = concept_from_mapping("PIH", "ADMIT TO HOSPITAL") 
		  AND p.dead=1 THEN 1 ELSE 0 END),
		  
		  SUM(CASE WHEN age_at_enc(p.person_id, e.encounter_id) BETWEEN 15 AND 19 AND p.gender = 'F' 
		  AND diagnostic.value_coded = concept_from_mapping("PIH", "Severe malaria")  
		  AND disposition.value_coded = concept_from_mapping("PIH", "ADMIT TO HOSPITAL") 
		  AND p.dead=1 THEN 1 ELSE 0 END),
		  SUM(CASE WHEN age_at_enc(p.person_id, e.encounter_id) BETWEEN 15 AND 19 AND p.gender = 'M' 
		  AND diagnostic.value_coded = concept_from_mapping("PIH", "Severe malaria") 
		  AND disposition.value_coded = concept_from_mapping("PIH", "ADMIT TO HOSPITAL") 
		  AND p.dead=1 THEN 1 ELSE 0 END),
		  
		  SUM(CASE WHEN age_at_enc(p.person_id, e.encounter_id) BETWEEN 20 AND 24 AND p.gender = 'F' 
		  AND diagnostic.value_coded = concept_from_mapping("PIH", "Severe malaria") 
		  AND diagnostic.value_coded = concept_from_mapping("PIH", "ADMIT TO HOSPITAL") 
		  AND p.dead=1 THEN 1 ELSE 0 END),
		  SUM(CASE WHEN age_at_enc(p.person_id, e.encounter_id) BETWEEN 20 AND 24 AND p.gender = 'M' 
		  AND diagnostic.value_coded = concept_from_mapping("PIH", "Severe malaria") 
		  AND diagnostic.value_coded = concept_from_mapping("PIH", "ADMIT TO HOSPITAL") 
		  AND p.dead=1 THEN 1 ELSE 0 END),
		
		  SUM(CASE WHEN age_at_enc(p.person_id, e.encounter_id) BETWEEN 25 AND 49 AND p.gender = 'F' 
		  AND diagnostic.value_coded = concept_from_mapping("PIH", "Severe malaria") 
		  AND diagnostic.value_coded = concept_from_mapping("PIH", "ADMIT TO HOSPITAL") 
		  AND p.dead=1 THEN 1 ELSE 0 END),
		  SUM(CASE WHEN age_at_enc(p.person_id, e.encounter_id) BETWEEN 25 AND 49 AND p.gender = 'M' 
		  AND diagnostic.value_coded = concept_from_mapping("PIH", "Severe malaria") 
		  AND diagnostic.value_coded = concept_from_mapping("PIH", "ADMIT TO HOSPITAL") 
		  AND p.dead=1 THEN 1 ELSE 0 END),
		
		  SUM(CASE WHEN age_at_enc(p.person_id, e.encounter_id) >= 50 AND p.gender = 'F' 
		  AND diagnostic.value_coded = concept_from_mapping("PIH", "Severe malaria") 
		  AND diagnostic.value_coded = concept_from_mapping("PIH", "ADMIT TO HOSPITAL") 
		  AND p.dead=1 THEN 1 ELSE 0 END),
		  SUM(CASE WHEN age_at_enc(p.person_id, e.encounter_id) >= 50 AND p.gender = 'M'
		  AND diagnostic.value_coded = concept_from_mapping("PIH", "Severe malaria")
		  AND diagnostic.value_coded = concept_from_mapping("PIH", "ADMIT TO HOSPITAL")
		  AND p.dead=1 THEN 1 ELSE 0 END),
		  
		  SUM(CASE WHEN diagnostic.value_coded = concept_from_mapping("PIH", "Severe malaria") 
		  AND diagnostic.value_coded = concept_from_mapping("PIH", "ADMIT TO HOSPITAL") 
		  AND p.dead=1 THEN 1 ELSE 0 END),
		  
		  SUM(CASE WHEN  diagnostic.value_coded = concept_from_mapping("PIH", "Severe malaria")
		  AND diagnostic.value_coded = concept_from_mapping("PIH", "ADMIT TO HOSPITAL")
		  AND disposition.value_coded = concept_from_mapping("PIH", "Transfer out of hospital") THEN 1 ELSE 0 END)
		  
		  INTO
		  
		  	  -- Malaria Severe  + Hospitalise + decedee
			@MSHD_AGE_0_F, @MSHD_AGE_0_M, @MSHD_AGE_1_4_F, @MSHD_AGE_1_4_M, @MSHD_AGE_5_9_F, @MSHD_AGE_5_9_M, @MSHD_AGE_10_14_F, @MSHD_AGE_10_14_M,
            @MSHD_AGE_15_19_F, @MSHD_AGE_15_19_M, @MSHD_AGE_20_24_F, @MSHD_AGE_20_24_M, @MSHD_AGE_25_49_F, @MSHD_AGE_25_49_M, @MSHD_AGE_50_PLUS_F, @MSHD_AGE_50_PLUS_M,
            @MSHD_DEATH, @MSHD_TRANSFER
		  
		     FROM  obs o 
		  INNER JOIN encounter e ON o.encounter_id = e.encounter_id 
		  INNER JOIN person p ON p.person_id = o.person_id
		  LEFT JOIN (
		    SELECT encounter_id, value_coded
		    FROM obs
		    WHERE concept_id = concept_from_mapping("PIH", "1379") AND voided=0 ) AS diagnostic_cert ON o.encounter_id = diagnostic_cert.encounter_id
		  LEFT JOIN (
		    SELECT encounter_id, value_coded
		    FROM obs
		    WHERE concept_id = concept_from_mapping("PIH", "3064") AND voided=0 ) AS diagnostic ON o.encounter_id = diagnostic.encounter_id
		  LEFT JOIN (
		    SELECT encounter_id, value_coded
		    FROM obs
		    WHERE concept_id = concept_from_mapping("PIH", "8620") AND voided=0 ) AS disposition ON o.encounter_id = disposition.encounter_id
		
		  WHERE  e.voided = 0 AND o.voided = 0
		   AND DATE(e.encounter_datetime) >= @startDate
		   AND DATE(e.encounter_datetime) < @endDate;
		  
		  
		  
		  
		  
		  SELECT 
		  
		   
		   -- Anxiete
		 
		  SUM(CASE WHEN age_at_enc(p.person_id, e.encounter_id) < 1 AND p.gender = 'F' 
		  AND diagnostic.value_coded = concept_from_mapping("PIH", "ANXIETY DISORDER") THEN 1 ELSE 0 END),
		  SUM(CASE WHEN age_at_enc(p.person_id, e.encounter_id) < 1 AND p.gender = 'M' 
		  AND diagnostic.value_coded = concept_from_mapping("PIH", "ANXIETY DISORDER") THEN 1 ELSE 0 END)  ,
		  
		  SUM(CASE WHEN age_at_enc(p.person_id, e.encounter_id) BETWEEN 1 AND 4 AND p.gender = 'F'
		  AND diagnostic.value_coded = concept_from_mapping("PIH", "ANXIETY DISORDER") THEN 1 ELSE 0 END) ,
		  SUM(CASE WHEN age_at_enc(p.person_id, e.encounter_id) BETWEEN 1 AND 4 AND p.gender = 'M' 
		  AND diagnostic.value_coded = concept_from_mapping("PIH", "ANXIETY DISORDER")  THEN 1 ELSE 0 END) ,
		
		  SUM(CASE WHEN age_at_enc(p.person_id, e.encounter_id) BETWEEN 5 AND 9 AND p.gender = 'F' 
		  AND diagnostic.value_coded = concept_from_mapping("PIH", "ANXIETY DISORDER") THEN 1 ELSE 0 END) ,
		  SUM(CASE WHEN age_at_enc(p.person_id, e.encounter_id) BETWEEN 5 AND 9 AND p.gender = 'M'
		  AND diagnostic.value_coded = concept_from_mapping("PIH", "ANXIETY DISORDER") THEN 1 ELSE 0 END) ,
		  
		  SUM(CASE WHEN age_at_enc(p.person_id, e.encounter_id) BETWEEN 10 AND 14 AND p.gender = 'F' 
		  AND diagnostic.value_coded = concept_from_mapping("PIH", "ANXIETY DISORDER") THEN 1 ELSE 0 END),
		  SUM(CASE WHEN age_at_enc(p.person_id, e.encounter_id) BETWEEN 10 AND 14 AND p.gender = 'M'
		  AND diagnostic.value_coded = concept_from_mapping("PIH", "ANXIETY DISORDER") THEN 1 ELSE 0 END) ,
		  
		  SUM(CASE WHEN age_at_enc(p.person_id, e.encounter_id) BETWEEN 15 AND 19 AND p.gender = 'F' 
		  AND diagnostic.value_coded = concept_from_mapping("PIH", "ANXIETY DISORDER") THEN 1 ELSE 0 END) ,
		  SUM(CASE WHEN age_at_enc(p.person_id, e.encounter_id) BETWEEN 15 AND 19 AND p.gender = 'M' 
		  AND diagnostic.value_coded = concept_from_mapping("PIH", "ANXIETY DISORDER") THEN 1 ELSE 0 END) ,
		  
		  SUM(CASE WHEN age_at_enc(p.person_id, e.encounter_id) BETWEEN 20 AND 24 AND p.gender = 'F' 
		  AND diagnostic.value_coded = concept_from_mapping("PIH", "ANXIETY DISORDER") THEN 1 ELSE 0 END) ,
		  SUM(CASE WHEN age_at_enc(p.person_id, e.encounter_id) BETWEEN 20 AND 24 AND p.gender = 'M' 
		  AND diagnostic.value_coded = concept_from_mapping("PIH", "ANXIETY DISORDER") THEN 1 ELSE 0 END) ,
		
		  SUM(CASE WHEN age_at_enc(p.person_id, e.encounter_id) BETWEEN 25 AND 49 AND p.gender = 'F' 
		  AND diagnostic.value_coded = concept_from_mapping("PIH", "ANXIETY DISORDER")  THEN 1 ELSE 0 END) ,
		  SUM(CASE WHEN age_at_enc(p.person_id, e.encounter_id) BETWEEN 25 AND 49 AND p.gender = 'M' 
		  AND diagnostic.value_coded = concept_from_mapping("PIH", "ANXIETY DISORDER") THEN 1 ELSE 0 END) ,
		
		  SUM(CASE WHEN age_at_enc(p.person_id, e.encounter_id) >= 50 AND p.gender = 'F' 
		  AND diagnostic.value_coded = concept_from_mapping("PIH", "ANXIETY DISORDER") THEN 1 ELSE 0 END) ,
		  SUM(CASE WHEN age_at_enc(p.person_id, e.encounter_id) >= 50 AND p.gender = 'M'
		  AND diagnostic.value_coded = concept_from_mapping("PIH", "ANXIETY DISORDER") THEN 1 ELSE 0 END) ,
		  
		  SUM(CASE WHEN  p.dead=1
		  AND diagnostic.value_coded = concept_from_mapping("PIH", "ANXIETY DISORDER") THEN 1 ELSE 0 END) ,
		  
		  SUM(CASE WHEN disposition.value_coded = concept_from_mapping("PIH", "Transfer out of hospital")
		  AND diagnostic.value_coded = concept_from_mapping("PIH", "ANXIETY DISORDER") THEN 1 ELSE 0 END) 
		  
		  INTO
		  
		    @ANX_AGE_0_F, @ANX_AGE_0_M, @ANX_AGE_1_4_F, @ANX_AGE_1_4_M, @ANX_AGE_5_9_F, @ANX_AGE_5_9_M, @ANX_AGE_10_14_F, @ANX_AGE_10_14_M,
            @ANX_AGE_15_19_F, @ANX_AGE_15_19_M, @ANX_AGE_20_24_F, @ANX_AGE_20_24_M, @ANX_AGE_25_49_F, @ANX_AGE_25_49_M, @ANX_AGE_50_PLUS_F, @ANX_AGE_50_PLUS_M,
            @ANX_DEATH,@ANX_TRANSFER
		     FROM  obs o 
		  INNER JOIN encounter e ON o.encounter_id = e.encounter_id 
		  INNER JOIN person p ON p.person_id = o.person_id
		  LEFT JOIN (
		    SELECT encounter_id, value_coded
		    FROM obs
		    WHERE concept_id = concept_from_mapping("PIH", "1379") AND voided=0 ) AS diagnostic_cert ON o.encounter_id = diagnostic_cert.encounter_id
		  LEFT JOIN (
		    SELECT encounter_id, value_coded
		    FROM obs
		    WHERE concept_id = concept_from_mapping("PIH", "3064") AND voided=0 ) AS diagnostic ON o.encounter_id = diagnostic.encounter_id
		  LEFT JOIN (
		    SELECT encounter_id, value_coded
		    FROM obs
		    WHERE concept_id = concept_from_mapping("PIH", "8620") AND voided=0 ) AS disposition ON o.encounter_id = disposition.encounter_id
		
		  WHERE  e.voided = 0 AND o.voided = 0
		   AND DATE(e.encounter_datetime) >= @startDate
		   AND DATE(e.encounter_datetime) < @endDate;
		  
		  
		  
		  SELECT
		   -- Démence
		    SUM(CASE WHEN age_at_enc(p.person_id, e.encounter_id) < 1 AND p.gender = 'F' 
		  AND diagnostic.value_coded = concept_from_mapping("PIH", "DEMENTIA") THEN 1 ELSE 0 END) ,
		  SUM(CASE WHEN age_at_enc(p.person_id, e.encounter_id) < 1 AND p.gender = 'M' 
		  AND diagnostic.value_coded = concept_from_mapping("PIH", "DEMENTIA") THEN 1 ELSE 0 END) ,
		  
		  SUM(CASE WHEN age_at_enc(p.person_id, e.encounter_id) BETWEEN 1 AND 4 AND p.gender = 'F'
		  AND diagnostic.value_coded = concept_from_mapping("PIH", "DEMENTIA") THEN 1 ELSE 0 END) ,
		  SUM(CASE WHEN age_at_enc(p.person_id, e.encounter_id) BETWEEN 1 AND 4 AND p.gender = 'M' 
		  AND diagnostic.value_coded = concept_from_mapping("PIH", "DEMENTIA")  THEN 1 ELSE 0 END) ,
		
		  SUM(CASE WHEN age_at_enc(p.person_id, e.encounter_id) BETWEEN 5 AND 9 AND p.gender = 'F' 
		  AND diagnostic.value_coded = concept_from_mapping("PIH", "DEMENTIA") THEN 1 ELSE 0 END) ,
		  SUM(CASE WHEN age_at_enc(p.person_id, e.encounter_id) BETWEEN 5 AND 9 AND p.gender = 'M'
		  AND diagnostic.value_coded = concept_from_mapping("PIH", "DEMENTIA") THEN 1 ELSE 0 END) ,
		  
		  SUM(CASE WHEN age_at_enc(p.person_id, e.encounter_id) BETWEEN 10 AND 14 AND p.gender = 'F' 
		  AND diagnostic.value_coded = concept_from_mapping("PIH", "DEMENTIA") THEN 1 ELSE 0 END) ,
		  SUM(CASE WHEN age_at_enc(p.person_id, e.encounter_id) BETWEEN 10 AND 14 AND p.gender = 'M'
		  AND diagnostic.value_coded = concept_from_mapping("PIH", "DEMENTIA") THEN 1 ELSE 0 END) ,
		  
		  SUM(CASE WHEN age_at_enc(p.person_id, e.encounter_id) BETWEEN 15 AND 19 AND p.gender = 'F' 
		  AND diagnostic.value_coded = concept_from_mapping("PIH", "DEMENTIA") THEN 1 ELSE 0 END),
		  SUM(CASE WHEN age_at_enc(p.person_id, e.encounter_id) BETWEEN 15 AND 19 AND p.gender = 'M' 
		  AND diagnostic.value_coded = concept_from_mapping("PIH", "DEMENTIA") THEN 1 ELSE 0 END) ,
		  
		  SUM(CASE WHEN age_at_enc(p.person_id, e.encounter_id) BETWEEN 20 AND 24 AND p.gender = 'F' 
		  AND diagnostic.value_coded = concept_from_mapping("PIH", "DEMENTIA") THEN 1 ELSE 0 END) ,
		  SUM(CASE WHEN age_at_enc(p.person_id, e.encounter_id) BETWEEN 20 AND 24 AND p.gender = 'M' 
		  AND diagnostic.value_coded = concept_from_mapping("PIH", "DEMENTIA") THEN 1 ELSE 0 END) ,
		
		  SUM(CASE WHEN age_at_enc(p.person_id, e.encounter_id) BETWEEN 25 AND 49 AND p.gender = 'F' 
		  AND diagnostic.value_coded = concept_from_mapping("PIH", "DEMENTIA")  THEN 1 ELSE 0 END) ,
		  SUM(CASE WHEN age_at_enc(p.person_id, e.encounter_id) BETWEEN 25 AND 49 AND p.gender = 'M' 
		  AND diagnostic.value_coded = concept_from_mapping("PIH", "DEMENTIA") THEN 1 ELSE 0 END) ,
		
		  SUM(CASE WHEN age_at_enc(p.person_id, e.encounter_id) >= 50 AND p.gender = 'F' 
		  AND diagnostic.value_coded = concept_from_mapping("PIH", "DEMENTIA") THEN 1 ELSE 0 END) ,
		  SUM(CASE WHEN age_at_enc(p.person_id, e.encounter_id) >= 50 AND p.gender = 'M'
		  AND diagnostic.value_coded = concept_from_mapping("PIH", "DEMENTIA") THEN 1 ELSE 0 END) ,
		  
		  SUM(CASE WHEN p.dead=1
		  AND diagnostic.value_coded = concept_from_mapping("PIH", "DEMENTIA") THEN 1 ELSE 0 END) ,
		  
		  SUM(CASE WHEN disposition.value_coded = concept_from_mapping("PIH", "	Transfer out of hospital")
		  AND diagnostic.value_coded = concept_from_mapping("PIH", "DEMENTIA") THEN 1 ELSE 0 END) 
		  
		  INTO 
		  
		  
		  	@DEMENTIA_AGE_0_F, @DEMENTIA_AGE_0_M, @DEMENTIA_AGE_1_4_F, @DEMENTIA_AGE_1_4_M, @DEMENTIA_AGE_5_9_F, @DEMENTIA_AGE_5_9_M, @DEMENTIA_AGE_10_14_F, @DEMENTIA_AGE_10_14_M,
			@DEMENTIA_AGE_15_19_F, @DEMENTIA_AGE_15_19_M, @DEMENTIA_AGE_20_24_F, @DEMENTIA_AGE_20_24_M, @DEMENTIA_AGE_25_49_F, @DEMENTIA_AGE_25_49_M, @DEMENTIA_AGE_50_PLUS_F, @DEMENTIA_AGE_50_PLUS_M,
		    @DEMENTIA_DEATH,@DEMENTIA_TRANSFER
		    
		      FROM  obs o 
		  INNER JOIN encounter e ON o.encounter_id = e.encounter_id 
		  INNER JOIN person p ON p.person_id = o.person_id
		  LEFT JOIN (
		    SELECT encounter_id, value_coded
		    FROM obs
		    WHERE concept_id = concept_from_mapping("PIH", "1379") AND voided=0 ) AS diagnostic_cert ON o.encounter_id = diagnostic_cert.encounter_id
		  LEFT JOIN (
		    SELECT encounter_id, value_coded
		    FROM obs
		    WHERE concept_id = concept_from_mapping("PIH", "3064") AND voided=0 ) AS diagnostic ON o.encounter_id = diagnostic.encounter_id
		  LEFT JOIN (
		    SELECT encounter_id, value_coded
		    FROM obs
		    WHERE concept_id = concept_from_mapping("PIH", "8620") AND voided=0 ) AS disposition ON o.encounter_id = disposition.encounter_id
		
		  WHERE  e.voided = 0 AND o.voided = 0
		   AND DATE(e.encounter_datetime) >= @startDate
		   AND DATE(e.encounter_datetime) < @endDate;
		  
		  
		  
		  
		  SELECT 
		  
		  
		  -- Dépression
		 
		  SUM(CASE WHEN age_at_enc(p.person_id, e.encounter_id) < 1 AND p.gender = 'F' 
		  AND diagnostic.value_coded = concept_from_mapping("PIH", "DEPRESSION") THEN 1 ELSE 0 END) ,
		  SUM(CASE WHEN age_at_enc(p.person_id, e.encounter_id) < 1 AND p.gender = 'M' 
		  AND diagnostic.value_coded = concept_from_mapping("PIH", "DEPRESSION") THEN 1 ELSE 0 END) ,
		  
		  SUM(CASE WHEN age_at_enc(p.person_id, e.encounter_id) BETWEEN 1 AND 4 AND p.gender = 'F'
		  AND diagnostic.value_coded = concept_from_mapping("PIH", "DEPRESSION") THEN 1 ELSE 0 END) ,
		  SUM(CASE WHEN age_at_enc(p.person_id, e.encounter_id) BETWEEN 1 AND 4 AND p.gender = 'M' 
		  AND diagnostic.value_coded = concept_from_mapping("PIH", "DEPRESSION")  THEN 1 ELSE 0 END) ,
		
		  SUM(CASE WHEN age_at_enc(p.person_id, e.encounter_id) BETWEEN 5 AND 9 AND p.gender = 'F' 
		  AND diagnostic.value_coded = concept_from_mapping("PIH", "DEPRESSION") THEN 1 ELSE 0 END) ,
		  SUM(CASE WHEN age_at_enc(p.person_id, e.encounter_id) BETWEEN 5 AND 9 AND p.gender = 'M'
		  AND diagnostic.value_coded = concept_from_mapping("PIH", "DEPRESSION") THEN 1 ELSE 0 END) ,
		  
		  SUM(CASE WHEN age_at_enc(p.person_id, e.encounter_id) BETWEEN 10 AND 14 AND p.gender = 'F' 
		  AND diagnostic.value_coded = concept_from_mapping("PIH", "DEPRESSION") THEN 1 ELSE 0 END),
		  SUM(CASE WHEN age_at_enc(p.person_id, e.encounter_id) BETWEEN 10 AND 14 AND p.gender = 'M'
		  AND diagnostic.value_coded = concept_from_mapping("PIH", "DEPRESSION") THEN 1 ELSE 0 END),
		  
		  SUM(CASE WHEN age_at_enc(p.person_id, e.encounter_id) BETWEEN 15 AND 19 AND p.gender = 'F' 
		  AND diagnostic.value_coded = concept_from_mapping("PIH", "DEPRESSION") THEN 1 ELSE 0 END) ,
		  SUM(CASE WHEN age_at_enc(p.person_id, e.encounter_id) BETWEEN 15 AND 19 AND p.gender = 'M' 
		  AND diagnostic.value_coded = concept_from_mapping("PIH", "DEPRESSION") THEN 1 ELSE 0 END) ,
		  
		  SUM(CASE WHEN age_at_enc(p.person_id, e.encounter_id) BETWEEN 20 AND 24 AND p.gender = 'F' 
		  AND diagnostic.value_coded = concept_from_mapping("PIH", "DEPRESSION") THEN 1 ELSE 0 END) ,
		  SUM(CASE WHEN age_at_enc(p.person_id, e.encounter_id) BETWEEN 20 AND 24 AND p.gender = 'M' 
		  AND diagnostic.value_coded = concept_from_mapping("PIH", "DEPRESSION") THEN 1 ELSE 0 END) ,
		
		  SUM(CASE WHEN age_at_enc(p.person_id, e.encounter_id) BETWEEN 25 AND 49 AND p.gender = 'F' 
		  AND diagnostic.value_coded = concept_from_mapping("PIH", "DEPRESSION")  THEN 1 ELSE 0 END) ,
		  SUM(CASE WHEN age_at_enc(p.person_id, e.encounter_id) BETWEEN 25 AND 49 AND p.gender = 'M' 
		  AND diagnostic.value_coded = concept_from_mapping("PIH", "DEPRESSION") THEN 1 ELSE 0 END) ,
		
		  SUM(CASE WHEN age_at_enc(p.person_id, e.encounter_id) >= 50 AND p.gender = 'F' 
		  AND diagnostic.value_coded = concept_from_mapping("PIH", "DEPRESSION") THEN 1 ELSE 0 END) ,
		  SUM(CASE WHEN age_at_enc(p.person_id, e.encounter_id) >= 50 AND p.gender = 'M'
		  AND diagnostic.value_coded = concept_from_mapping("PIH", "DEPRESSION") THEN 1 ELSE 0 END) ,
		  
		  SUM(CASE WHEN p.dead=1
		  AND diagnostic.value_coded = concept_from_mapping("PIH", "DEPRESSION") THEN 1 ELSE 0 END) ,
		  
		  SUM(CASE WHEN disposition.value_coded = concept_from_mapping("PIH", "Transfer out of hospital")
		  AND diagnostic.value_coded = concept_from_mapping("PIH", "DEPRESSION") THEN 1 ELSE 0 END) 
		  
		  INTO
		  
		   @DEPRESSION_AGE_0_F, @DEPRESSION_AGE_0_M, @DEPRESSION_AGE_1_4_F, @DEPRESSION_AGE_1_4_M, @DEPRESSION_AGE_5_9_F, @DEPRESSION_AGE_5_9_M, @DEPRESSION_AGE_10_14_F, @DEPRESSION_AGE_10_14_M,
			@DEPRESSION_AGE_15_19_F, @DEPRESSION_AGE_15_19_M, @DEPRESSION_AGE_20_24_F, @DEPRESSION_AGE_20_24_M, @DEPRESSION_AGE_25_49_F, @DEPRESSION_AGE_25_49_M, @DEPRESSION_AGE_50_PLUS_F, @DEPRESSION_AGE_50_PLUS_M,
			@DEPRESSION_DEATH,@DEPRESSION_TRANSFER
		  
		        FROM  obs o 
		  INNER JOIN encounter e ON o.encounter_id = e.encounter_id 
		  INNER JOIN person p ON p.person_id = o.person_id
		  LEFT JOIN (
		    SELECT encounter_id, value_coded
		    FROM obs
		    WHERE concept_id = concept_from_mapping("PIH", "1379") AND voided=0 ) AS diagnostic_cert ON o.encounter_id = diagnostic_cert.encounter_id
		  LEFT JOIN (
		    SELECT encounter_id, value_coded
		    FROM obs
		    WHERE concept_id = concept_from_mapping("PIH", "3064") AND voided=0 ) AS diagnostic ON o.encounter_id = diagnostic.encounter_id
		  LEFT JOIN (
		    SELECT encounter_id, value_coded
		    FROM obs
		    WHERE concept_id = concept_from_mapping("PIH", "8620") AND voided=0 ) AS disposition ON o.encounter_id = disposition.encounter_id
		
		  WHERE  e.voided = 0 AND o.voided = 0
		   AND DATE(e.encounter_datetime) >= @startDate
		   AND DATE(e.encounter_datetime) < @endDate;
		  
		  
		  
		  SELECT
		     -- Schizophrénie
		 
		   SUM(CASE WHEN age_at_enc(p.person_id, e.encounter_id) < 1 AND p.gender = 'F' 
		  AND diagnostic.value_coded = concept_from_mapping("PIH", "SCHIZOPHRENIA") THEN 1 ELSE 0 END) ,
		  SUM(CASE WHEN age_at_enc(p.person_id, e.encounter_id) < 1 AND p.gender = 'M' 
		  AND diagnostic.value_coded = concept_from_mapping("PIH", "SCHIZOPHRENIA") THEN 1 ELSE 0 END) ,
		  
		  SUM(CASE WHEN age_at_enc(p.person_id, e.encounter_id) BETWEEN 1 AND 4 AND p.gender = 'F'
		  AND diagnostic.value_coded = concept_from_mapping("PIH", "SCHIZOPHRENIA") THEN 1 ELSE 0 END) ,
		  SUM(CASE WHEN age_at_enc(p.person_id, e.encounter_id) BETWEEN 1 AND 4 AND p.gender = 'M' 
		  AND diagnostic.value_coded = concept_from_mapping("PIH", "SCHIZOPHRENIA")  THEN 1 ELSE 0 END),
		
		  SUM(CASE WHEN age_at_enc(p.person_id, e.encounter_id) BETWEEN 5 AND 9 AND p.gender = 'F' 
		  AND diagnostic.value_coded = concept_from_mapping("PIH", "SCHIZOPHRENIA") THEN 1 ELSE 0 END) ,
		  SUM(CASE WHEN age_at_enc(p.person_id, e.encounter_id) BETWEEN 5 AND 9 AND p.gender = 'M'
		  AND diagnostic.value_coded = concept_from_mapping("PIH", "SCHIZOPHRENIA") THEN 1 ELSE 0 END) ,
		  
		  SUM(CASE WHEN age_at_enc(p.person_id, e.encounter_id) BETWEEN 10 AND 14 AND p.gender = 'F' 
		  AND diagnostic.value_coded = concept_from_mapping("PIH", "SCHIZOPHRENIA") THEN 1 ELSE 0 END) ,
		  SUM(CASE WHEN age_at_enc(p.person_id, e.encounter_id) BETWEEN 10 AND 14 AND p.gender = 'M'
		  AND diagnostic.value_coded = concept_from_mapping("PIH", "SCHIZOPHRENIA") THEN 1 ELSE 0 END) ,
		  
		  SUM(CASE WHEN age_at_enc(p.person_id, e.encounter_id) BETWEEN 15 AND 19 AND p.gender = 'F' 
		  AND diagnostic.value_coded = concept_from_mapping("PIH", "SCHIZOPHRENIA") THEN 1 ELSE 0 END) ,
		  SUM(CASE WHEN age_at_enc(p.person_id, e.encounter_id) BETWEEN 15 AND 19 AND p.gender = 'M' 
		  AND diagnostic.value_coded = concept_from_mapping("PIH", "SCHIZOPHRENIA") THEN 1 ELSE 0 END) ,
		  
		  SUM(CASE WHEN age_at_enc(p.person_id, e.encounter_id) BETWEEN 20 AND 24 AND p.gender = 'F' 
		  AND diagnostic.value_coded = concept_from_mapping("PIH", "SCHIZOPHRENIA") THEN 1 ELSE 0 END) ,
		  SUM(CASE WHEN age_at_enc(p.person_id, e.encounter_id) BETWEEN 20 AND 24 AND p.gender = 'M' 
		  AND diagnostic.value_coded = concept_from_mapping("PIH", "SCHIZOPHRENIA") THEN 1 ELSE 0 END) ,
		
		  SUM(CASE WHEN age_at_enc(p.person_id, e.encounter_id) BETWEEN 25 AND 49 AND p.gender = 'F' 
		  AND diagnostic.value_coded = concept_from_mapping("PIH", "SCHIZOPHRENIA")  THEN 1 ELSE 0 END) ,
		  SUM(CASE WHEN age_at_enc(p.person_id, e.encounter_id) BETWEEN 25 AND 49 AND p.gender = 'M' 
		  AND diagnostic.value_coded = concept_from_mapping("PIH", "SCHIZOPHRENIA") THEN 1 ELSE 0 END) ,
		
		  SUM(CASE WHEN age_at_enc(p.person_id, e.encounter_id) >= 50 AND p.gender = 'F' 
		  AND diagnostic.value_coded = concept_from_mapping("PIH", "SCHIZOPHRENIA") THEN 1 ELSE 0 END) ,
		  SUM(CASE WHEN age_at_enc(p.person_id, e.encounter_id) >= 50 AND p.gender = 'M'
		  AND diagnostic.value_coded = concept_from_mapping("PIH", "SCHIZOPHRENIA") THEN 1 ELSE 0 END) ,
		  
		  
		  SUM(CASE WHEN p.dead=1
		  AND diagnostic.value_coded = concept_from_mapping("PIH", "SCHIZOPHRENIA") THEN 1 ELSE 0 END) ,
		  
		  SUM(CASE WHEN disposition.value_coded = concept_from_mapping("PIH", "Transfer out of hospital")
		  AND diagnostic.value_coded = concept_from_mapping("PIH", "SCHIZOPHRENIA") THEN 1 ELSE 0 END)
		  
		  INTO
		  
		     @SCHIZOPHRENIA_AGE_0_F, @SCHIZOPHRENIA_AGE_0_M, @SCHIZOPHRENIA_AGE_1_4_F, @SCHIZOPHRENIA_AGE_1_4_M, @SCHIZOPHRENIA_AGE_5_9_F, @SCHIZOPHRENIA_AGE_5_9_M, @SCHIZOPHRENIA_AGE_10_14_F, @SCHIZOPHRENIA_AGE_10_14_M,
			@SCHIZOPHRENIA_AGE_15_19_F, @SCHIZOPHRENIA_AGE_15_19_M, @SCHIZOPHRENIA_AGE_20_24_F, @SCHIZOPHRENIA_AGE_20_24_M, @SCHIZOPHRENIA_AGE_25_49_F, @SCHIZOPHRENIA_AGE_25_49_M, @SCHIZOPHRENIA_AGE_50_PLUS_F, @SCHIZOPHRENIA_AGE_50_PLUS_M,
		    @SCHIZOPHRENIA_DEATH, @SCHIZOPHRENIA_TRANSFER
		         FROM  obs o 
		  INNER JOIN encounter e ON o.encounter_id = e.encounter_id 
		  INNER JOIN person p ON p.person_id = o.person_id
		  LEFT JOIN (
		    SELECT encounter_id, value_coded
		    FROM obs
		    WHERE concept_id = concept_from_mapping("PIH", "1379") AND voided=0 ) AS diagnostic_cert ON o.encounter_id = diagnostic_cert.encounter_id
		  LEFT JOIN (
		    SELECT encounter_id, value_coded
		    FROM obs
		    WHERE concept_id = concept_from_mapping("PIH", "3064") AND voided=0 ) AS diagnostic ON o.encounter_id = diagnostic.encounter_id
		  LEFT JOIN (
		    SELECT encounter_id, value_coded
		    FROM obs
		    WHERE concept_id = concept_from_mapping("PIH", "8620") AND voided=0 ) AS disposition ON o.encounter_id = disposition.encounter_id
		
		  WHERE  e.voided = 0 AND o.voided = 0
		   AND DATE(e.encounter_datetime) >= @startDate
		   AND DATE(e.encounter_datetime) < @endDate;
		  
		  
		  
		  SELECT
		  
		    -- Stress aiguë
		 
		  SUM(CASE WHEN age_at_enc(p.person_id, e.encounter_id) < 1 AND p.gender = 'F' 
		  AND diagnostic.value_coded = concept_from_mapping("PIH", "7950") THEN 1 ELSE 0 END),
		  SUM(CASE WHEN age_at_enc(p.person_id, e.encounter_id) < 1 AND p.gender = 'M' 
		  AND diagnostic.value_coded = concept_from_mapping("PIH", "7950") THEN 1 ELSE 0 END) ,
		  
		  SUM(CASE WHEN age_at_enc(p.person_id, e.encounter_id) BETWEEN 1 AND 4 AND p.gender = 'F'
		  AND diagnostic.value_coded = concept_from_mapping("PIH", "7950") THEN 1 ELSE 0 END),
		  SUM(CASE WHEN age_at_enc(p.person_id, e.encounter_id) BETWEEN 1 AND 4 AND p.gender = 'M' 
		  AND diagnostic.value_coded = concept_from_mapping("PIH", "7950")  THEN 1 ELSE 0 END) ,
		
		  SUM(CASE WHEN age_at_enc(p.person_id, e.encounter_id) BETWEEN 5 AND 9 AND p.gender = 'F' 
		  AND diagnostic.value_coded = concept_from_mapping("PIH", "7950") THEN 1 ELSE 0 END) ,
		  SUM(CASE WHEN age_at_enc(p.person_id, e.encounter_id) BETWEEN 5 AND 9 AND p.gender = 'M'
		  AND diagnostic.value_coded = concept_from_mapping("PIH", "7950") THEN 1 ELSE 0 END) ,
		  
		  SUM(CASE WHEN age_at_enc(p.person_id, e.encounter_id) BETWEEN 10 AND 14 AND p.gender = 'F' 
		  AND diagnostic.value_coded = concept_from_mapping("PIH", "7950") THEN 1 ELSE 0 END) ,
		  SUM(CASE WHEN age_at_enc(p.person_id, e.encounter_id) BETWEEN 10 AND 14 AND p.gender = 'M'
		  AND diagnostic.value_coded = concept_from_mapping("PIH", "7950") THEN 1 ELSE 0 END) ,
		  
		  SUM(CASE WHEN age_at_enc(p.person_id, e.encounter_id) BETWEEN 15 AND 19 AND p.gender = 'F' 
		  AND diagnostic.value_coded = concept_from_mapping("PIH", "7950") THEN 1 ELSE 0 END),
		  SUM(CASE WHEN age_at_enc(p.person_id, e.encounter_id) BETWEEN 15 AND 19 AND p.gender = 'M' 
		  AND diagnostic.value_coded = concept_from_mapping("PIH", "7950") THEN 1 ELSE 0 END) ,
		  
		  SUM(CASE WHEN age_at_enc(p.person_id, e.encounter_id) BETWEEN 20 AND 24 AND p.gender = 'F' 
		  AND diagnostic.value_coded = concept_from_mapping("PIH", "7950") THEN 1 ELSE 0 END),
		  SUM(CASE WHEN age_at_enc(p.person_id, e.encounter_id) BETWEEN 20 AND 24 AND p.gender = 'M' 
		  AND diagnostic.value_coded = concept_from_mapping("PIH", "7950") THEN 1 ELSE 0 END) ,
		
		  SUM(CASE WHEN age_at_enc(p.person_id, e.encounter_id) BETWEEN 25 AND 49 AND p.gender = 'F' 
		  AND diagnostic.value_coded = concept_from_mapping("PIH", "7950")  THEN 1 ELSE 0 END) ,
		  SUM(CASE WHEN age_at_enc(p.person_id, e.encounter_id) BETWEEN 25 AND 49 AND p.gender = 'M' 
		  AND diagnostic.value_coded = concept_from_mapping("PIH", "7950") THEN 1 ELSE 0 END) ,
		
		  SUM(CASE WHEN age_at_enc(p.person_id, e.encounter_id) >= 50 AND p.gender = 'F' 
		  AND diagnostic.value_coded = concept_from_mapping("PIH", "7950") THEN 1 ELSE 0 END) ,
		  SUM(CASE WHEN age_at_enc(p.person_id, e.encounter_id) >= 50 AND p.gender = 'M'
		  AND diagnostic.value_coded = concept_from_mapping("PIH", "7950") THEN 1 ELSE 0 END) ,
		  
		  SUM(CASE WHEN p.dead=1
		  AND diagnostic.value_coded = concept_from_mapping("PIH", "7950") THEN 1 ELSE 0 END) ,
		  
		  SUM(CASE WHEN disposition.value_coded = concept_from_mapping("PIH", "Transfer out of hospital")
		  AND diagnostic.value_coded = concept_from_mapping("PIH", "7950") THEN 1 ELSE 0 END)
		  
		  INTO 
		   @STRESS_AIG_AGE_0_F, @STRESS_AIG_AGE_0_M, @STRESS_AIG_AGE_1_4_F, @STRESS_AIG_AGE_1_4_M, @STRESS_AIG_AGE_5_9_F, @STRESS_AIG_AGE_5_9_M, @STRESS_AIG_AGE_10_14_F, @STRESS_AIG_AGE_10_14_M,
			@STRESS_AIG_AGE_15_19_F, @STRESS_AIG_AGE_15_19_M, @STRESS_AIG_AGE_20_24_F, @STRESS_AIG_AGE_20_24_M, @STRESS_AIG_AGE_25_49_F, @STRESS_AIG_AGE_25_49_M, @STRESS_AIG_AGE_50_PLUS_F, @STRESS_AIG_AGE_50_PLUS_M,
			@STRESS_AIG_DEATH, @STRESS_AIG_TRANSFER
		  
		  FROM  obs o 
		  INNER JOIN encounter e ON o.encounter_id = e.encounter_id 
		  INNER JOIN person p ON p.person_id = o.person_id
		  LEFT JOIN (
		    SELECT encounter_id, value_coded
		    FROM obs
		    WHERE concept_id = concept_from_mapping("PIH", "1379") AND voided=0 ) AS diagnostic_cert ON o.encounter_id = diagnostic_cert.encounter_id
		  LEFT JOIN (
		    SELECT encounter_id, value_coded
		    FROM obs
		    WHERE concept_id = concept_from_mapping("PIH", "3064") AND voided=0 ) AS diagnostic ON o.encounter_id = diagnostic.encounter_id
		  LEFT JOIN (
		    SELECT encounter_id, value_coded
		    FROM obs
		    WHERE concept_id = concept_from_mapping("PIH", "8620") AND voided=0 ) AS disposition ON o.encounter_id = disposition.encounter_id
		
		  WHERE  e.voided = 0 AND o.voided = 0
		   AND DATE(e.encounter_datetime) >= @startDate
		   AND DATE(e.encounter_datetime) < @endDate;
		  
		  
		  
		  
		  SELECT
-- 		    Trouble Bipolaire
		  SUM(CASE WHEN age_at_enc(p.person_id, e.encounter_id) < 1 AND p.gender = 'F' 
		  AND diagnostic.value_coded = concept_from_mapping("PIH", "Bipolar disorder") THEN 1 ELSE 0 END) ,
		  SUM(CASE WHEN age_at_enc(p.person_id, e.encounter_id) < 1 AND p.gender = 'M' 
		  AND diagnostic.value_coded = concept_from_mapping("PIH", "Bipolar disorder") THEN 1 ELSE 0 END) ,
		  
		  SUM(CASE WHEN age_at_enc(p.person_id, e.encounter_id) BETWEEN 1 AND 4 AND p.gender = 'F'
		  AND diagnostic.value_coded = concept_from_mapping("PIH", "Bipolar disorder") THEN 1 ELSE 0 END) ,
		  SUM(CASE WHEN age_at_enc(p.person_id, e.encounter_id) BETWEEN 1 AND 4 AND p.gender = 'M' 
		  AND diagnostic.value_coded = concept_from_mapping("PIH", "Bipolar disorder")  THEN 1 ELSE 0 END) ,
		
		  SUM(CASE WHEN age_at_enc(p.person_id, e.encounter_id) BETWEEN 5 AND 9 AND p.gender = 'F' 
		  AND diagnostic.value_coded = concept_from_mapping("PIH", "Bipolar disorder") THEN 1 ELSE 0 END) ,
		  SUM(CASE WHEN age_at_enc(p.person_id, e.encounter_id) BETWEEN 5 AND 9 AND p.gender = 'M'
		  AND diagnostic.value_coded = concept_from_mapping("PIH", "Bipolar disorder") THEN 1 ELSE 0 END) ,
		  
		  SUM(CASE WHEN age_at_enc(p.person_id, e.encounter_id) BETWEEN 10 AND 14 AND p.gender = 'F' 
		  AND diagnostic.value_coded = concept_from_mapping("PIH", "Bipolar disorder") THEN 1 ELSE 0 END) ,
		  SUM(CASE WHEN age_at_enc(p.person_id, e.encounter_id) BETWEEN 10 AND 14 AND p.gender = 'M'
		  AND diagnostic.value_coded = concept_from_mapping("PIH", "Bipolar disorder") THEN 1 ELSE 0 END) ,
		  
		  SUM(CASE WHEN age_at_enc(p.person_id, e.encounter_id) BETWEEN 15 AND 19 AND p.gender = 'F' 
		  AND diagnostic.value_coded = concept_from_mapping("PIH", "Bipolar disorder") THEN 1 ELSE 0 END) ,
		  SUM(CASE WHEN age_at_enc(p.person_id, e.encounter_id) BETWEEN 15 AND 19 AND p.gender = 'M' 
		  AND diagnostic.value_coded = concept_from_mapping("PIH", "Bipolar disorder") THEN 1 ELSE 0 END) ,
		  
		  SUM(CASE WHEN age_at_enc(p.person_id, e.encounter_id) BETWEEN 20 AND 24 AND p.gender = 'F' 
		  AND diagnostic.value_coded = concept_from_mapping("PIH", "Bipolar disorder") THEN 1 ELSE 0 END) ,
		  SUM(CASE WHEN age_at_enc(p.person_id, e.encounter_id) BETWEEN 20 AND 24 AND p.gender = 'M' 
		  AND diagnostic.value_coded = concept_from_mapping("PIH", "Bipolar disorder") THEN 1 ELSE 0 END) ,
		
		  SUM(CASE WHEN age_at_enc(p.person_id, e.encounter_id) BETWEEN 25 AND 49 AND p.gender = 'F' 
		  AND diagnostic.value_coded = concept_from_mapping("PIH", "Bipolar disorder")  THEN 1 ELSE 0 END) ,
		  SUM(CASE WHEN age_at_enc(p.person_id, e.encounter_id) BETWEEN 25 AND 49 AND p.gender = 'M' 
		  AND diagnostic.value_coded = concept_from_mapping("PIH", "Bipolar disorder") THEN 1 ELSE 0 END) ,
		
		  SUM(CASE WHEN age_at_enc(p.person_id, e.encounter_id) >= 50 AND p.gender = 'F' 
		  AND diagnostic.value_coded = concept_from_mapping("PIH", "Bipolar disorder") THEN 1 ELSE 0 END) ,
		  SUM(CASE WHEN age_at_enc(p.person_id, e.encounter_id) >= 50 AND p.gender = 'M'
		  AND diagnostic.value_coded = concept_from_mapping("PIH", "Bipolar disorder") THEN 1 ELSE 0 END) ,
		  
		  SUM(CASE WHEN p.dead=1
		  AND diagnostic.value_coded = concept_from_mapping("PIH", "Bipolar disorder") THEN 1 ELSE 0 END) ,
		  
		  SUM(CASE WHEN disposition.value_coded = concept_from_mapping("PIH", "Transfer out of hospital")
		  AND diagnostic.value_coded = concept_from_mapping("PIH", "Bipolar disorder") THEN 1 ELSE 0 END) 
		  
		  INTO
		  
		  			@BIPOLAR_DISO_AGE_0_F, @BIPOLAR_DISO_AGE_0_M, @BIPOLAR_DISO_AGE_1_4_F, @BIPOLAR_DISO_AGE_1_4_M, @BIPOLAR_DISO_AGE_5_9_F, @BIPOLAR_DISO_AGE_5_9_M, @BIPOLAR_DISO_AGE_10_14_F, @BIPOLAR_DISO_AGE_10_14_M,
			@BIPOLAR_DISO_AGE_15_19_F, @BIPOLAR_DISO_AGE_15_19_M, @BIPOLAR_DISO_AGE_20_24_F, @BIPOLAR_DISO_AGE_20_24_M, @BIPOLAR_DISO_AGE_25_49_F, @BIPOLAR_DISO_AGE_25_49_M, @BIPOLAR_DISO_AGE_50_PLUS_F, @BIPOLAR_DISO_AGE_50_PLUS_M,
			@BIPOLAR_DISO_DEATH,@BIPOLAR_DISO_TRANSFER
		  FROM  obs o 
		  INNER JOIN encounter e ON o.encounter_id = e.encounter_id 
		  INNER JOIN person p ON p.person_id = o.person_id
		  LEFT JOIN (
		    SELECT encounter_id, value_coded
		    FROM obs
		    WHERE concept_id = concept_from_mapping("PIH", "1379") AND voided=0 ) AS diagnostic_cert ON o.encounter_id = diagnostic_cert.encounter_id
		  LEFT JOIN (
		    SELECT encounter_id, value_coded
		    FROM obs
		    WHERE concept_id = concept_from_mapping("PIH", "3064") AND voided=0 ) AS diagnostic ON o.encounter_id = diagnostic.encounter_id
		  LEFT JOIN (
		    SELECT encounter_id, value_coded
		    FROM obs
		    WHERE concept_id = concept_from_mapping("PIH", "8620") AND voided=0 ) AS disposition ON o.encounter_id = disposition.encounter_id
	
		  WHERE  e.voided = 0 AND o.voided = 0
		   AND DATE(e.encounter_datetime) >= @startDate
		   AND DATE(e.encounter_datetime) < @endDate;
		  
		  
		  
		  SELECT
		  
		   -- Troubles lies a la consomation de drogues 
		 
		  SUM(CASE WHEN age_at_enc(p.person_id, e.encounter_id) < 1 AND p.gender = 'F' 
		  AND diagnostic.value_coded = concept_from_mapping("PIH", "7201") THEN 1 ELSE 0 END) ,
		  SUM(CASE WHEN age_at_enc(p.person_id, e.encounter_id) < 1 AND p.gender = 'M' 
		  AND diagnostic.value_coded = concept_from_mapping("PIH", "7201") THEN 1 ELSE 0 END) ,
		  
		  SUM(CASE WHEN age_at_enc(p.person_id, e.encounter_id) BETWEEN 1 AND 4 AND p.gender = 'F'
		  AND diagnostic.value_coded = concept_from_mapping("PIH", "7201") THEN 1 ELSE 0 END) ,
		  SUM(CASE WHEN age_at_enc(p.person_id, e.encounter_id) BETWEEN 1 AND 4 AND p.gender = 'M' 
		  AND diagnostic.value_coded = concept_from_mapping("PIH", "7201")  THEN 1 ELSE 0 END) ,
		
		  SUM(CASE WHEN age_at_enc(p.person_id, e.encounter_id) BETWEEN 5 AND 9 AND p.gender = 'F' 
		  AND diagnostic.value_coded = concept_from_mapping("PIH", "7201") THEN 1 ELSE 0 END) ,
		  SUM(CASE WHEN age_at_enc(p.person_id, e.encounter_id) BETWEEN 5 AND 9 AND p.gender = 'M'
		  AND diagnostic.value_coded = concept_from_mapping("PIH", "7201") THEN 1 ELSE 0 END) ,
		  
		  SUM(CASE WHEN age_at_enc(p.person_id, e.encounter_id) BETWEEN 10 AND 14 AND p.gender = 'F' 
		  AND diagnostic.value_coded = concept_from_mapping("PIH", "7201") THEN 1 ELSE 0 END) ,
		  SUM(CASE WHEN age_at_enc(p.person_id, e.encounter_id) BETWEEN 10 AND 14 AND p.gender = 'M'
		  AND diagnostic.value_coded = concept_from_mapping("PIH", "7201") THEN 1 ELSE 0 END) ,
		  
		  SUM(CASE WHEN age_at_enc(p.person_id, e.encounter_id) BETWEEN 15 AND 19 AND p.gender = 'F' 
		  AND diagnostic.value_coded = concept_from_mapping("PIH", "7201") THEN 1 ELSE 0 END) ,
		  SUM(CASE WHEN age_at_enc(p.person_id, e.encounter_id) BETWEEN 15 AND 19 AND p.gender = 'M' 
		  AND diagnostic.value_coded = concept_from_mapping("PIH", "7201") THEN 1 ELSE 0 END) ,
		  
		  SUM(CASE WHEN age_at_enc(p.person_id, e.encounter_id) BETWEEN 20 AND 24 AND p.gender = 'F' 
		  AND diagnostic.value_coded = concept_from_mapping("PIH", "7201") THEN 1 ELSE 0 END) ,
		  SUM(CASE WHEN age_at_enc(p.person_id, e.encounter_id) BETWEEN 20 AND 24 AND p.gender = 'M' 
		  AND diagnostic.value_coded = concept_from_mapping("PIH", "7201") THEN 1 ELSE 0 END) ,
		
		  SUM(CASE WHEN age_at_enc(p.person_id, e.encounter_id) BETWEEN 25 AND 49 AND p.gender = 'F' 
		  AND diagnostic.value_coded = concept_from_mapping("PIH", "7201")  THEN 1 ELSE 0 END),
		  SUM(CASE WHEN age_at_enc(p.person_id, e.encounter_id) BETWEEN 25 AND 49 AND p.gender = 'M' 
		  AND diagnostic.value_coded = concept_from_mapping("PIH", "7201") THEN 1 ELSE 0 END) ,
		
		  SUM(CASE WHEN age_at_enc(p.person_id, e.encounter_id) >= 50 AND p.gender = 'F' 
		  AND diagnostic.value_coded = concept_from_mapping("PIH", "7201") THEN 1 ELSE 0 END) ,
		  SUM(CASE WHEN age_at_enc(p.person_id, e.encounter_id) >= 50 AND p.gender = 'M'
		  AND diagnostic.value_coded = concept_from_mapping("PIH", "7201") THEN 1 ELSE 0 END) ,
		  
		    SUM(CASE WHEN p.dead=1
		  AND diagnostic.value_coded = concept_from_mapping("PIH", "7201") THEN 1 ELSE 0 END) ,
		  
		  SUM(CASE WHEN disposition.value_coded = concept_from_mapping("PIH", "Transfer out of hospital")
		  AND diagnostic.value_coded = concept_from_mapping("PIH", "7201") THEN 1 ELSE 0 END) 
		  
		  INTO
		  
		  @DROG_USED_DISO_AGE_0_F, @DROG_USED_DISO_AGE_0_M, @DROG_USED_DISO_AGE_1_4_F, @DROG_USED_DISO_AGE_1_4_M, @DROG_USED_DISO_AGE_5_9_F, @DROG_USED_DISO_AGE_5_9_M, @DROG_USED_DISO_AGE_10_14_F, @DROG_USED_DISO_AGE_10_14_M,
			@DROG_USED_DISO_AGE_15_19_F, @DROG_USED_DISO_AGE_15_19_M, @DROG_USED_DISO_AGE_20_24_F, @DROG_USED_DISO_AGE_20_24_M, @DROG_USED_DISO_AGE_25_49_F, @DROG_USED_DISO_AGE_25_49_M, @DROG_USED_DISO_AGE_50_PLUS_F, @DROG_USED_DISO_AGE_50_PLUS_M,
			@DROG_USED_DISO_DEATH, @DROG_USED_DISO_TRANSFER
		  
		  
		    FROM  obs o 
		  INNER JOIN encounter e ON o.encounter_id = e.encounter_id 
		  INNER JOIN person p ON p.person_id = o.person_id
		  LEFT JOIN (
		    SELECT encounter_id, value_coded
		    FROM obs
		    WHERE concept_id = concept_from_mapping("PIH", "1379") AND voided=0 ) AS diagnostic_cert ON o.encounter_id = diagnostic_cert.encounter_id
		  LEFT JOIN (
		    SELECT encounter_id, value_coded
		    FROM obs
		    WHERE concept_id = concept_from_mapping("PIH", "3064") AND voided=0 ) AS diagnostic ON o.encounter_id = diagnostic.encounter_id
		  LEFT JOIN (
		    SELECT encounter_id, value_coded
		    FROM obs
		    WHERE concept_id = concept_from_mapping("PIH", "8620") AND voided=0 ) AS disposition ON o.encounter_id = disposition.encounter_id
	
		  WHERE  e.voided = 0 AND o.voided = 0
		   AND DATE(e.encounter_datetime) >= @startDate
		   AND DATE(e.encounter_datetime) < @endDate;
		  
		  
		  
		  
		  
		  
		  SELECT 
		  
		  
		   -- Troubles developmental
		 
		  SUM(CASE WHEN age_at_enc(p.person_id, e.encounter_id) < 1 AND p.gender = 'F' 
		  AND diagnostic.value_coded = concept_from_mapping("PIH", "7951") THEN 1 ELSE 0 END) ,
		  SUM(CASE WHEN age_at_enc(p.person_id, e.encounter_id) < 1 AND p.gender = 'M' 
		  AND diagnostic.value_coded = concept_from_mapping("PIH", "7951") THEN 1 ELSE 0 END) ,
		  
		  SUM(CASE WHEN age_at_enc(p.person_id, e.encounter_id) BETWEEN 1 AND 4 AND p.gender = 'F'
		  AND diagnostic.value_coded = concept_from_mapping("PIH", "7951") THEN 1 ELSE 0 END) ,
		  SUM(CASE WHEN age_at_enc(p.person_id, e.encounter_id) BETWEEN 1 AND 4 AND p.gender = 'M' 
		  AND diagnostic.value_coded = concept_from_mapping("PIH", "7951")  THEN 1 ELSE 0 END) ,
		
		  SUM(CASE WHEN age_at_enc(p.person_id, e.encounter_id) BETWEEN 5 AND 9 AND p.gender = 'F' 
		  AND diagnostic.value_coded = concept_from_mapping("PIH", "7951") THEN 1 ELSE 0 END) ,
		  SUM(CASE WHEN age_at_enc(p.person_id, e.encounter_id) BETWEEN 5 AND 9 AND p.gender = 'M'
		  AND diagnostic.value_coded = concept_from_mapping("PIH", "7951") THEN 1 ELSE 0 END) ,
		  
		  SUM(CASE WHEN age_at_enc(p.person_id, e.encounter_id) BETWEEN 10 AND 14 AND p.gender = 'F' 
		  AND diagnostic.value_coded = concept_from_mapping("PIH", "7951") THEN 1 ELSE 0 END) ,
		  SUM(CASE WHEN age_at_enc(p.person_id, e.encounter_id) BETWEEN 10 AND 14 AND p.gender = 'M'
		  AND diagnostic.value_coded = concept_from_mapping("PIH", "7951") THEN 1 ELSE 0 END) ,
		  
		  SUM(CASE WHEN age_at_enc(p.person_id, e.encounter_id) BETWEEN 15 AND 19 AND p.gender = 'F' 
		  AND diagnostic.value_coded = concept_from_mapping("PIH", "7951") THEN 1 ELSE 0 END) ,
		  SUM(CASE WHEN age_at_enc(p.person_id, e.encounter_id) BETWEEN 15 AND 19 AND p.gender = 'M' 
		  AND diagnostic.value_coded = concept_from_mapping("PIH", "7951") THEN 1 ELSE 0 END) ,
		  
		  SUM(CASE WHEN age_at_enc(p.person_id, e.encounter_id) BETWEEN 20 AND 24 AND p.gender = 'F' 
		  AND diagnostic.value_coded = concept_from_mapping("PIH", "7951") THEN 1 ELSE 0 END) ,
		  SUM(CASE WHEN age_at_enc(p.person_id, e.encounter_id) BETWEEN 20 AND 24 AND p.gender = 'M' 
		  AND diagnostic.value_coded = concept_from_mapping("PIH", "7951") THEN 1 ELSE 0 END) ,
		
		  SUM(CASE WHEN age_at_enc(p.person_id, e.encounter_id) BETWEEN 25 AND 49 AND p.gender = 'F' 
		  AND diagnostic.value_coded = concept_from_mapping("PIH", "7951")  THEN 1 ELSE 0 END) ,
		  SUM(CASE WHEN age_at_enc(p.person_id, e.encounter_id) BETWEEN 25 AND 49 AND p.gender = 'M' 
		  AND diagnostic.value_coded = concept_from_mapping("PIH", "7951") THEN 1 ELSE 0 END) ,
		
		  SUM(CASE WHEN age_at_enc(p.person_id, e.encounter_id) >= 50 AND p.gender = 'F' 
		  AND diagnostic.value_coded = concept_from_mapping("PIH", "7951") THEN 1 ELSE 0 END) ,
		  SUM(CASE WHEN age_at_enc(p.person_id, e.encounter_id) >= 50 AND p.gender = 'M'
		  AND diagnostic.value_coded = concept_from_mapping("PIH", "7951") THEN 1 ELSE 0 END) ,
		  
		  SUM(CASE WHEN p.dead=1
		  AND diagnostic.value_coded = concept_from_mapping("PIH", "7951") THEN 1 ELSE 0 END) ,
		  
		  SUM(CASE WHEN disposition.value_coded = concept_from_mapping("PIH", "Transfer out of hospital")
		  AND diagnostic.value_coded = concept_from_mapping("PIH", "7951") THEN 1 ELSE 0 END) 
		  
		   INTO
		   @DEVELOP_DISO_AGE_0_F, @DEVELOP_DISO_AGE_0_M, @DEVELOP_DISO_AGE_1_4_F, @DEVELOP_DISO_AGE_1_4_M, @DEVELOP_DISO_AGE_5_9_F, @DEVELOP_DISO_AGE_5_9_M, @DEVELOP_DISO_AGE_10_14_F, @DEVELOP_DISO_AGE_10_14_M,
			@DEVELOP_DISO_AGE_15_19_F, @DEVELOP_DISO_AGE_15_19_M, @DEVELOP_DISO_AGE_20_24_F, @DEVELOP_DISO_AGE_20_24_M, @DEVELOP_DISO_AGE_25_49_F, @DEVELOP_DISO_AGE_25_49_M, @DEVELOP_DISO_AGE_50_PLUS_F, @DEVELOP_DISO_AGE_50_PLUS_M,
			@DEVELOP_DISO_DEATH,  @DEVELOP_DISO_TRANSFER
		  
		     FROM  obs o 
		  INNER JOIN encounter e ON o.encounter_id = e.encounter_id 
		  INNER JOIN person p ON p.person_id = o.person_id
		  LEFT JOIN (
		    SELECT encounter_id, value_coded
		    FROM obs
		    WHERE concept_id = concept_from_mapping("PIH", "1379") AND voided=0 ) AS diagnostic_cert ON o.encounter_id = diagnostic_cert.encounter_id
		  LEFT JOIN (
		    SELECT encounter_id, value_coded
		    FROM obs
		    WHERE concept_id = concept_from_mapping("PIH", "3064") AND voided=0 ) AS diagnostic ON o.encounter_id = diagnostic.encounter_id
		  LEFT JOIN (
		    SELECT encounter_id, value_coded
		    FROM obs
		    WHERE concept_id = concept_from_mapping("PIH", "8620") AND voided=0 ) AS disposition ON o.encounter_id = disposition.encounter_id
	
		  WHERE  e.voided = 0 AND o.voided = 0
		   AND DATE(e.encounter_datetime) >= @startDate
		   AND DATE(e.encounter_datetime) < @endDate;
		  
		  
		  
		  
		  SELECT 
		  
-- 		  Troubles Lies a la consommation de l'alcool
		 
		  SUM(CASE WHEN age_at_enc(p.person_id, e.encounter_id) < 1 AND p.gender = 'F' 
		  AND diagnostic.value_coded = concept_from_mapping("PIH", "9522") THEN 1 ELSE 0 END),
		  SUM(CASE WHEN age_at_enc(p.person_id, e.encounter_id) < 1 AND p.gender = 'M' 
		  AND diagnostic.value_coded = concept_from_mapping("PIH", "9522") THEN 1 ELSE 0 END) ,
		  
		  SUM(CASE WHEN age_at_enc(p.person_id, e.encounter_id) BETWEEN 1 AND 4 AND p.gender = 'F'
		  AND diagnostic.value_coded = concept_from_mapping("PIH", "9522") THEN 1 ELSE 0 END) ,
		  SUM(CASE WHEN age_at_enc(p.person_id, e.encounter_id) BETWEEN 1 AND 4 AND p.gender = 'M' 
		  AND diagnostic.value_coded = concept_from_mapping("PIH", "9522")  THEN 1 ELSE 0 END) ,
		
		  SUM(CASE WHEN age_at_enc(p.person_id, e.encounter_id) BETWEEN 5 AND 9 AND p.gender = 'F' 
		  AND diagnostic.value_coded = concept_from_mapping("PIH", "9522") THEN 1 ELSE 0 END) ,
		  SUM(CASE WHEN age_at_enc(p.person_id, e.encounter_id) BETWEEN 5 AND 9 AND p.gender = 'M'
		  AND diagnostic.value_coded = concept_from_mapping("PIH", "9522") THEN 1 ELSE 0 END) ,
		  
		  SUM(CASE WHEN age_at_enc(p.person_id, e.encounter_id) BETWEEN 10 AND 14 AND p.gender = 'F' 
		  AND diagnostic.value_coded = concept_from_mapping("PIH", "9522") THEN 1 ELSE 0 END) ,
		  SUM(CASE WHEN age_at_enc(p.person_id, e.encounter_id) BETWEEN 10 AND 14 AND p.gender = 'M'
		  AND diagnostic.value_coded = concept_from_mapping("PIH", "9522") THEN 1 ELSE 0 END) ,
		  
		  SUM(CASE WHEN age_at_enc(p.person_id, e.encounter_id) BETWEEN 15 AND 19 AND p.gender = 'F' 
		  AND diagnostic.value_coded = concept_from_mapping("PIH", "9522") THEN 1 ELSE 0 END) ,
		  SUM(CASE WHEN age_at_enc(p.person_id, e.encounter_id) BETWEEN 15 AND 19 AND p.gender = 'M' 
		  AND diagnostic.value_coded = concept_from_mapping("PIH", "9522") THEN 1 ELSE 0 END) ,
		  
		  SUM(CASE WHEN age_at_enc(p.person_id, e.encounter_id) BETWEEN 20 AND 24 AND p.gender = 'F' 
		  AND diagnostic.value_coded = concept_from_mapping("PIH", "9522") THEN 1 ELSE 0 END) ,
		  SUM(CASE WHEN age_at_enc(p.person_id, e.encounter_id) BETWEEN 20 AND 24 AND p.gender = 'M' 
		  AND diagnostic.value_coded = concept_from_mapping("PIH", "9522") THEN 1 ELSE 0 END) ,
		
		  SUM(CASE WHEN age_at_enc(p.person_id, e.encounter_id) BETWEEN 25 AND 49 AND p.gender = 'F' 
		  AND diagnostic.value_coded = concept_from_mapping("PIH", "9522")  THEN 1 ELSE 0 END) ,
		  SUM(CASE WHEN age_at_enc(p.person_id, e.encounter_id) BETWEEN 25 AND 49 AND p.gender = 'M' 
		  AND diagnostic.value_coded = concept_from_mapping("PIH", "9522") THEN 1 ELSE 0 END) ,
		
		  SUM(CASE WHEN age_at_enc(p.person_id, e.encounter_id) >= 50 AND p.gender = 'F' 
		  AND diagnostic.value_coded = concept_from_mapping("PIH", "9522") THEN 1 ELSE 0 END) ,
		  SUM(CASE WHEN age_at_enc(p.person_id, e.encounter_id) >= 50 AND p.gender = 'M'
		  AND diagnostic.value_coded = concept_from_mapping("PIH", "9522") THEN 1 ELSE 0 END) ,
		  
		  SUM(CASE WHEN p.dead=1
		  AND diagnostic.value_coded = concept_from_mapping("PIH", "9522") THEN 1 ELSE 0 END) ,
		  
		  SUM(CASE WHEN disposition.value_coded = concept_from_mapping("PIH", "Transfer out of hospital")
		  AND diagnostic.value_coded = concept_from_mapping("PIH", "9522") THEN 1 ELSE 0 END)
		  
		  INTO
		  
		    @ALCOHOL_USED_DISO_AGE_0_F, @ALCOHOL_USED_DISO_AGE_0_M, @ALCOHOL_USED_DISO_AGE_1_4_F, @ALCOHOL_USED_DISO_AGE_1_4_M, @ALCOHOL_USED_DISO_AGE_5_9_F, @ALCOHOL_USED_DISO_AGE_5_9_M, @ALCOHOL_USED_DISO_AGE_10_14_F, @ALCOHOL_USED_DISO_AGE_10_14_M,
			@ALCOHOL_USED_DISO_AGE_15_19_F, @ALCOHOL_USED_DISO_AGE_15_19_M, @ALCOHOL_USED_DISO_AGE_20_24_F, @ALCOHOL_USED_DISO_AGE_20_24_M, @ALCOHOL_USED_DISO_AGE_25_49_F, @ALCOHOL_USED_DISO_AGE_25_49_M, @ALCOHOL_USED_DISO_AGE_50_PLUS_F, @ALCOHOL_USED_DISO_AGE_50_PLUS_M,
			@ALCOHOL_USED_DISO_DEATH,   @ALCOHOL_USED_DISO_TRANSFER
		       FROM  obs o 
		  INNER JOIN encounter e ON o.encounter_id = e.encounter_id 
		  INNER JOIN person p ON p.person_id = o.person_id
		  LEFT JOIN (
		    SELECT encounter_id, value_coded
		    FROM obs
		    WHERE concept_id = concept_from_mapping("PIH", "1379") AND voided=0 ) AS diagnostic_cert ON o.encounter_id = diagnostic_cert.encounter_id
		  LEFT JOIN (
		    SELECT encounter_id, value_coded
		    FROM obs
		    WHERE concept_id = concept_from_mapping("PIH", "3064") AND voided=0 ) AS diagnostic ON o.encounter_id = diagnostic.encounter_id
		  LEFT JOIN (
		    SELECT encounter_id, value_coded
		    FROM obs
		    WHERE concept_id = concept_from_mapping("PIH", "8620") AND voided=0 ) AS disposition ON o.encounter_id = disposition.encounter_id
	
		  WHERE  e.voided = 0 AND o.voided = 0
		   AND DATE(e.encounter_datetime) >= @startDate
		   AND DATE(e.encounter_datetime) < @endDate;
		  
		  
		  
		  
		  SELECT 
		    --  		Trouble de stress post-traumatique
		  SUM(CASE WHEN age_at_enc(p.person_id, e.encounter_id) < 1 AND p.gender = 'F' 
		  AND diagnostic.value_coded = concept_from_mapping("PIH", "7197") THEN 1 ELSE 0 END),
		  SUM(CASE WHEN age_at_enc(p.person_id, e.encounter_id) < 1 AND p.gender = 'M' 
		  AND diagnostic.value_coded = concept_from_mapping("PIH", "7197") THEN 1 ELSE 0 END) ,
		  
		  SUM(CASE WHEN age_at_enc(p.person_id, e.encounter_id) BETWEEN 1 AND 4 AND p.gender = 'F'
		  AND diagnostic.value_coded = concept_from_mapping("PIH", "7197") THEN 1 ELSE 0 END) ,
		  SUM(CASE WHEN age_at_enc(p.person_id, e.encounter_id) BETWEEN 1 AND 4 AND p.gender = 'M' 
		  AND diagnostic.value_coded = concept_from_mapping("PIH", "7197")  THEN 1 ELSE 0 END) ,
		
		  SUM(CASE WHEN age_at_enc(p.person_id, e.encounter_id) BETWEEN 5 AND 9 AND p.gender = 'F' 
		  AND diagnostic.value_coded = concept_from_mapping("PIH", "7197") THEN 1 ELSE 0 END) ,
		  SUM(CASE WHEN age_at_enc(p.person_id, e.encounter_id) BETWEEN 5 AND 9 AND p.gender = 'M'
		  AND diagnostic.value_coded = concept_from_mapping("PIH", "7197") THEN 1 ELSE 0 END) ,
		  
		  SUM(CASE WHEN age_at_enc(p.person_id, e.encounter_id) BETWEEN 10 AND 14 AND p.gender = 'F' 
		  AND diagnostic.value_coded = concept_from_mapping("PIH", "7197") THEN 1 ELSE 0 END) ,
		  SUM(CASE WHEN age_at_enc(p.person_id, e.encounter_id) BETWEEN 10 AND 14 AND p.gender = 'M'
		  AND diagnostic.value_coded = concept_from_mapping("PIH", "7197") THEN 1 ELSE 0 END) ,
		  
		  SUM(CASE WHEN age_at_enc(p.person_id, e.encounter_id) BETWEEN 15 AND 19 AND p.gender = 'F' 
		  AND diagnostic.value_coded = concept_from_mapping("PIH", "7197") THEN 1 ELSE 0 END) ,
		  SUM(CASE WHEN age_at_enc(p.person_id, e.encounter_id) BETWEEN 15 AND 19 AND p.gender = 'M' 
		  AND diagnostic.value_coded = concept_from_mapping("PIH", "7197") THEN 1 ELSE 0 END) ,
		  
		  SUM(CASE WHEN age_at_enc(p.person_id, e.encounter_id) BETWEEN 20 AND 24 AND p.gender = 'F' 
		  AND diagnostic.value_coded = concept_from_mapping("PIH", "7197") THEN 1 ELSE 0 END),
		  SUM(CASE WHEN age_at_enc(p.person_id, e.encounter_id) BETWEEN 20 AND 24 AND p.gender = 'M' 
		  AND diagnostic.value_coded = concept_from_mapping("PIH", "7197") THEN 1 ELSE 0 END),
		
		  SUM(CASE WHEN age_at_enc(p.person_id, e.encounter_id) BETWEEN 25 AND 49 AND p.gender = 'F' 
		  AND diagnostic.value_coded = concept_from_mapping("PIH", "7197")  THEN 1 ELSE 0 END) ,
		  SUM(CASE WHEN age_at_enc(p.person_id, e.encounter_id) BETWEEN 25 AND 49 AND p.gender = 'M' 
		  AND diagnostic.value_coded = concept_from_mapping("PIH", "7197") THEN 1 ELSE 0 END) ,
		
		  SUM(CASE WHEN age_at_enc(p.person_id, e.encounter_id) >= 50 AND p.gender = 'F' 
		  AND diagnostic.value_coded = concept_from_mapping("PIH", "7197") THEN 1 ELSE 0 END) ,
		  SUM(CASE WHEN age_at_enc(p.person_id, e.encounter_id) >= 50 AND p.gender = 'M'
		  AND diagnostic.value_coded = concept_from_mapping("PIH", "7197") THEN 1 ELSE 0 END) ,
		  
		  SUM(CASE WHEN p.dead=1
		  AND diagnostic.value_coded = concept_from_mapping("PIH", "7197") THEN 1 ELSE 0 END) ,
		  
		  SUM(CASE WHEN disposition.value_coded = concept_from_mapping("PIH", "Transfer out of hospital")
		  AND diagnostic.value_coded = concept_from_mapping("PIH", "7197") THEN 1 ELSE 0 END) 
		  
		  
		  INTO
		  
		    @POST_TRAUMATIC_DISO_AGE_0_F, @POST_TRAUMATIC_DISO_AGE_0_M, @POST_TRAUMATIC_DISO_AGE_1_4_F, @POST_TRAUMATIC_DISO_AGE_1_4_M, @POST_TRAUMATIC_DISO_AGE_5_9_F, @POST_TRAUMATIC_DISO_AGE_5_9_M, @POST_TRAUMATIC_DISO_AGE_10_14_F, @POST_TRAUMATIC_DISO_AGE_10_14_M,
			@POST_TRAUMATIC_DISO_AGE_15_19_F, @POST_TRAUMATIC_DISO_AGE_15_19_M, @POST_TRAUMATIC_DISO_AGE_20_24_F, @POST_TRAUMATIC_DISO_AGE_20_24_M, @POST_TRAUMATIC_DISO_AGE_25_49_F, @POST_TRAUMATIC_DISO_AGE_25_49_M, @POST_TRAUMATIC_DISO_AGE_50_PLUS_F, @POST_TRAUMATIC_DISO_AGE_50_PLUS_M,
		    @POST_TRAUMATIC_DISO_DEATH,@POST_TRAUMATIC_DISO_TRANSFER
		    
		  FROM  obs o 
		  INNER JOIN encounter e ON o.encounter_id = e.encounter_id 
		  INNER JOIN person p ON p.person_id = o.person_id
		  LEFT JOIN (
		    SELECT encounter_id, value_coded
		    FROM obs
		    WHERE concept_id = concept_from_mapping("PIH", "1379") AND voided=0 ) AS diagnostic_cert ON o.encounter_id = diagnostic_cert.encounter_id
		  LEFT JOIN (
		    SELECT encounter_id, value_coded
		    FROM obs
		    WHERE concept_id = concept_from_mapping("PIH", "3064") AND voided=0 ) AS diagnostic ON o.encounter_id = diagnostic.encounter_id
		  LEFT JOIN (
		    SELECT encounter_id, value_coded
		    FROM obs
		    WHERE concept_id = concept_from_mapping("PIH", "8620") AND voided=0 ) AS disposition ON o.encounter_id = disposition.encounter_id
	
		  WHERE  e.voided = 0 AND o.voided = 0
		   AND DATE(e.encounter_datetime) >= @startDate
		   AND DATE(e.encounter_datetime) < @endDate;
		  
		  
		  
		  SELECT
		    --  		Idéation suicidaire
		  		 
		  SUM(CASE WHEN age_at_enc(p.person_id, e.encounter_id) < 1 AND p.gender = 'F' 
		  AND diagnostic.value_coded = concept_from_mapping("PIH", "10633") THEN 1 ELSE 0 END) ,
		  SUM(CASE WHEN age_at_enc(p.person_id, e.encounter_id) < 1 AND p.gender = 'M' 
		  AND diagnostic.value_coded = concept_from_mapping("PIH", "10633") THEN 1 ELSE 0 END) ,
		  
		  SUM(CASE WHEN age_at_enc(p.person_id, e.encounter_id) BETWEEN 1 AND 4 AND p.gender = 'F'
		  AND diagnostic.value_coded = concept_from_mapping("PIH", "10633") THEN 1 ELSE 0 END) ,
		  SUM(CASE WHEN age_at_enc(p.person_id, e.encounter_id) BETWEEN 1 AND 4 AND p.gender = 'M' 
		  AND diagnostic.value_coded = concept_from_mapping("PIH", "10633")  THEN 1 ELSE 0 END) ,
		
		  SUM(CASE WHEN age_at_enc(p.person_id, e.encounter_id) BETWEEN 5 AND 9 AND p.gender = 'F' 
		  AND diagnostic.value_coded = concept_from_mapping("PIH", "10633") THEN 1 ELSE 0 END) ,
		  SUM(CASE WHEN age_at_enc(p.person_id, e.encounter_id) BETWEEN 5 AND 9 AND p.gender = 'M'
		  AND diagnostic.value_coded = concept_from_mapping("PIH", "10633") THEN 1 ELSE 0 END) ,
		  
		  SUM(CASE WHEN age_at_enc(p.person_id, e.encounter_id) BETWEEN 10 AND 14 AND p.gender = 'F' 
		  AND diagnostic.value_coded = concept_from_mapping("PIH", "10633") THEN 1 ELSE 0 END) ,
		  SUM(CASE WHEN age_at_enc(p.person_id, e.encounter_id) BETWEEN 10 AND 14 AND p.gender = 'M'
		  AND diagnostic.value_coded = concept_from_mapping("PIH", "10633") THEN 1 ELSE 0 END) ,
		  
		  SUM(CASE WHEN age_at_enc(p.person_id, e.encounter_id) BETWEEN 15 AND 19 AND p.gender = 'F' 
		  AND diagnostic.value_coded = concept_from_mapping("PIH", "10633") THEN 1 ELSE 0 END) ,
		  SUM(CASE WHEN age_at_enc(p.person_id, e.encounter_id) BETWEEN 15 AND 19 AND p.gender = 'M' 
		  AND diagnostic.value_coded = concept_from_mapping("PIH", "10633") THEN 1 ELSE 0 END) ,
		  
		  SUM(CASE WHEN age_at_enc(p.person_id, e.encounter_id) BETWEEN 20 AND 24 AND p.gender = 'F' 
		  AND diagnostic.value_coded = concept_from_mapping("PIH", "10633") THEN 1 ELSE 0 END) ,
		  SUM(CASE WHEN age_at_enc(p.person_id, e.encounter_id) BETWEEN 20 AND 24 AND p.gender = 'M' 
		  AND diagnostic.value_coded = concept_from_mapping("PIH", "10633") THEN 1 ELSE 0 END) ,
		
		  SUM(CASE WHEN age_at_enc(p.person_id, e.encounter_id) BETWEEN 25 AND 49 AND p.gender = 'F' 
		  AND diagnostic.value_coded = concept_from_mapping("PIH", "10633")  THEN 1 ELSE 0 END) ,
		  SUM(CASE WHEN age_at_enc(p.person_id, e.encounter_id) BETWEEN 25 AND 49 AND p.gender = 'M' 
		  AND diagnostic.value_coded = concept_from_mapping("PIH", "10633") THEN 1 ELSE 0 END) ,
		
		  SUM(CASE WHEN age_at_enc(p.person_id, e.encounter_id) >= 50 AND p.gender = 'F' 
		  AND diagnostic.value_coded = concept_from_mapping("PIH", "10633") THEN 1 ELSE 0 END) ,
		  SUM(CASE WHEN age_at_enc(p.person_id, e.encounter_id) >= 50 AND p.gender = 'M'
		  AND diagnostic.value_coded = concept_from_mapping("PIH", "10633") THEN 1 ELSE 0 END),
		  
		  SUM(CASE WHEN p.dead=1
		  AND diagnostic.value_coded = concept_from_mapping("PIH", "10633") THEN 1 ELSE 0 END) ,
		  
		  SUM(CASE WHEN disposition.value_coded = concept_from_mapping("PIH", "Transfer out of hospital")
		  AND diagnostic.value_coded = concept_from_mapping("PIH", "10633") THEN 1 ELSE 0 END) 
		  
		  INTO
		  
		  	@SUICIDAL_IDEATION_AGE_0_F, @SUICIDAL_IDEATION_AGE_0_M, @SUICIDAL_IDEATION_AGE_1_4_F, @SUICIDAL_IDEATION_AGE_1_4_M, @SUICIDAL_IDEATION_AGE_5_9_F, @SUICIDAL_IDEATION_AGE_5_9_M, @SUICIDAL_IDEATION_AGE_10_14_F, @SUICIDAL_IDEATION_AGE_10_14_M,
			@SUICIDAL_IDEATION_AGE_15_19_F, @SUICIDAL_IDEATION_AGE_15_19_M, @SUICIDAL_IDEATION_AGE_20_24_F, @SUICIDAL_IDEATION_AGE_20_24_M, @SUICIDAL_IDEATION_AGE_25_49_F, @SUICIDAL_IDEATION_AGE_25_49_M, @SUICIDAL_IDEATION_AGE_50_PLUS_F, @SUICIDAL_IDEATION_AGE_50_PLUS_M,
            @SUICIDAL_IDEATION_DEATH,@SUICIDAL_IDEATION_TRANSFER
		  
		    FROM  obs o 
		  INNER JOIN encounter e ON o.encounter_id = e.encounter_id 
		  INNER JOIN person p ON p.person_id = o.person_id
		  LEFT JOIN (
		    SELECT encounter_id, value_coded
		    FROM obs
		    WHERE concept_id = concept_from_mapping("PIH", "1379") AND voided=0 ) AS diagnostic_cert ON o.encounter_id = diagnostic_cert.encounter_id
		  LEFT JOIN (
		    SELECT encounter_id, value_coded
		    FROM obs
		    WHERE concept_id = concept_from_mapping("PIH", "3064") AND voided=0 ) AS diagnostic ON o.encounter_id = diagnostic.encounter_id
		  LEFT JOIN (
		    SELECT encounter_id, value_coded
		    FROM obs
		    WHERE concept_id = concept_from_mapping("PIH", "8620") AND voided=0 ) AS disposition ON o.encounter_id = disposition.encounter_id
	
		  WHERE  e.voided = 0 AND o.voided = 0
		   AND DATE(e.encounter_datetime) >= @startDate
		   AND DATE(e.encounter_datetime) < @endDate;


            
            SELECT 
            @FE_AGE_0_F 'FE_AGE_0_F',  @FE_AGE_0_M 'FE_AGE_0_M', @FE_AGE_1_4_F 'FE_AGE_1_4_F', 
            @FE_AGE_1_4_M 'FE_AGE_1_4_M', @FE_AGE_5_9_F 'FE_AGE_5_9_F',  @FE_AGE_5_9_M 'FE_AGE_5_9_M',
            @FE_AGE_10_14_F 'FE_AGE_10_14_F',  @FE_AGE_10_14_M 'FE_AGE_10_14_M',@FE_AGE_15_19_F 'FE_AGE_15_19_F', 
            @FE_AGE_15_19_M 'FE_AGE_15_19_M',@FE_AGE_20_24_F 'FE_AGE_20_24_F', @FE_AGE_20_24_M 'FE_AGE_20_24_M', @FE_AGE_25_49_F 'FE_AGE_25_49_F', 
            @FE_AGE_25_49_M 'FE_AGE_25_49_M', @FE_AGE_50_PLUS_F 'FE_AGE_50_PLUS_F',  @FE_AGE_50_PLUS_M 'FE_AGE_50_PLUS_M',
            @FE_DEATH 'FE_DEATH',@FE_TRANSFER 'FE_TRANSFER',
            
            @MCT_AGE_0_F 'MCT_AGE_0_F', @MCT_AGE_0_M 'MCT_AGE_0_M', @MCT_AGE_1_4_F 'MCT_AGE_1_4_F', 
            @MCT_AGE_1_4_M 'MCT_AGE_1_4_M', @MCT_AGE_5_9_F 'MCT_AGE_5_9_F',@MCT_AGE_5_9_M 'MCT_AGE_5_9_M',
            @MCT_AGE_10_14_F 'MCT_AGE_10_14_F', @MCT_AGE_10_14_M 'MCT_AGE_10_14_M', @MCT_AGE_15_19_F 'MCT_AGE_15_19_F', 
            @MCT_AGE_15_19_M 'MCT_AGE_15_19_M', @MCT_AGE_20_24_F 'MCT_AGE_20_24_F', @MCT_AGE_20_24_M 'MCT_AGE_20_24_M',
            @MCT_AGE_25_49_F 'MCT_AGE_25_49_F', @MCT_AGE_25_49_M 'MCT_AGE_25_49_M', @MCT_AGE_50_PLUS_F 'MCT_AGE_50_PLUS_F',
            @MCT_AGE_50_PLUS_M 'MCT_AGE_50_PLUS_M',@MCT_DEATH 'MCT_DEATH',@MCT_TRANSFER 'MCT_TRANSFER',
            
            @MSH_AGE_0_F 'MSH_AGE_0_F', @MSH_AGE_0_M 'MSH_AGE_0_M', @MSH_AGE_1_4_F 'MSH_AGE_1_4_F',
            @MSH_AGE_1_4_M 'MSH_AGE_1_4_M', @MSH_AGE_5_9_F 'MSH_AGE_5_9_F', @MSH_AGE_5_9_M 'MSH_AGE_5_9_M',
            @MSH_AGE_10_14_F 'MSH_AGE_10_14_F', @MSH_AGE_10_14_M 'MSH_AGE_10_14_M', @MSH_AGE_15_19_F 'MSH_AGE_15_19_F',
            @MSH_AGE_15_19_M 'MSH_AGE_15_19_M', @MSH_AGE_20_24_F 'MSH_AGE_20_24_F', @MSH_AGE_20_24_M 'MSH_AGE_20_24_M',
            @MSH_AGE_25_49_F 'MSH_AGE_25_49_F', @MSH_AGE_25_49_M 'MSH_AGE_25_49_M', @MSH_AGE_50_PLUS_F 'MSH_AGE_50_PLUS_F',
            @MSH_AGE_50_PLUS_M 'MSH_AGE_50_PLUS_M',@MSH_DEATH 'MSH_DEATH',@MSH_TRANSFER 'MSH_TRANSFER',
            
            @MSHD_AGE_0_F 'MSHD_AGE_0_F', @MSHD_AGE_0_M 'MSHD_AGE_0_M', @MSHD_AGE_1_4_F 'MSHD_AGE_1_4_F',
            @MSHD_AGE_1_4_M 'MSHD_AGE_1_4_M', @MSHD_AGE_5_9_F 'MSHD_AGE_5_9_F', @MSHD_AGE_5_9_M 'MSHD_AGE_5_9_M',
            @MSHD_AGE_10_14_F 'MSHD_AGE_10_14_F', @MSHD_AGE_10_14_M 'MSHD_AGE_10_14_M', @MSHD_AGE_15_19_F 'MSHD_AGE_15_19_F',
            @MSHD_AGE_15_19_M 'MSHD_AGE_15_19_M', @MSHD_AGE_20_24_F 'MSHD_AGE_20_24_F', @MSHD_AGE_20_24_M 'MSHD_AGE_20_24_M',
            @MSHD_AGE_25_49_F 'MSHD_AGE_25_49_F', @MSHD_AGE_25_49_M 'MSHD_AGE_25_49_M', @MSHD_AGE_50_PLUS_F 'MSHD_AGE_50_PLUS_F',
            @MSHD_AGE_50_PLUS_M 'MSHD_AGE_50_PLUS_M', @MSHD_DEATH 'MSHD_DEATH', @MSHD_TRANSFER 'MSHD_TRANSFER',
            
            @ANX_AGE_0_F 'ANX_AGE_0_F', @ANX_AGE_0_M 'ANX_AGE_0_M', @ANX_AGE_1_4_F 'ANX_AGE_1_4_F',
            @ANX_AGE_1_4_M 'ANX_AGE_1_4_M', @ANX_AGE_5_9_F 'ANX_AGE_5_9_F', @ANX_AGE_5_9_M 'ANX_AGE_5_9_M',
            @ANX_AGE_10_14_F 'ANX_AGE_10_14_F', @ANX_AGE_10_14_M 'ANX_AGE_10_14_M', @ANX_AGE_15_19_F 'ANX_AGE_15_19_F',
            @ANX_AGE_15_19_M 'ANX_AGE_15_19_M', @ANX_AGE_20_24_F 'ANX_AGE_20_24_F', @ANX_AGE_20_24_M 'ANX_AGE_20_24_M',
            @ANX_AGE_25_49_F 'ANX_AGE_25_49_F', @ANX_AGE_25_49_M 'ANX_AGE_25_49_M', @ANX_AGE_50_PLUS_F 'ANX_AGE_50_PLUS_F',
            @ANX_AGE_50_PLUS_M 'ANX_AGE_50_PLUS_M',@ANX_DEATH 'ANX_DEATH', @ANX_TRANSFER 'ANX_TRANSFER',
            
            @DEMENTIA_AGE_0_F 'DEMENTIA_AGE_0_F', @DEMENTIA_AGE_0_M 'DEMENTIA_AGE_0_M', @DEMENTIA_AGE_1_4_F 'DEMENTIA_AGE_1_4_F',
            @DEMENTIA_AGE_1_4_M 'DEMENTIA_AGE_1_4_M', @DEMENTIA_AGE_5_9_F 'DEMENTIA_AGE_5_9_F', @DEMENTIA_AGE_5_9_M 'DEMENTIA_AGE_5_9_M',
            @DEMENTIA_AGE_10_14_F 'DEMENTIA_AGE_10_14_F', @DEMENTIA_AGE_10_14_M 'DEMENTIA_AGE_10_14_M', @DEMENTIA_AGE_15_19_F 'DEMENTIA_AGE_15_19_F',
            @DEMENTIA_AGE_15_19_M 'DEMENTIA_AGE_15_19_M', @DEMENTIA_AGE_20_24_F 'DEMENTIA_AGE_20_24_F', @DEMENTIA_AGE_20_24_M 'DEMENTIA_AGE_20_24_M',
            @DEMENTIA_AGE_25_49_F 'DEMENTIA_AGE_25_49_F', @DEMENTIA_AGE_25_49_M 'DEMENTIA_AGE_25_49_M', @DEMENTIA_AGE_50_PLUS_F 'DEMENTIA_AGE_50_PLUS_F',
            @DEMENTIA_AGE_50_PLUS_M 'DEMENTIA_AGE_50_PLUS_M', @DEMENTIA_DEATH 'DEMENTIA_DEATH', @DEMENTIA_TRANSFER 'DEMENTIA_TRANSFER',
            
            @DEPRESSION_AGE_0_F 'DEPRESSION_AGE_0_F', @DEPRESSION_AGE_0_M 'DEPRESSION_AGE_0_M', @DEPRESSION_AGE_1_4_F 'DEPRESSION_AGE_1_4_F',
            @DEPRESSION_AGE_1_4_M 'DEPRESSION_AGE_1_4_M', @DEPRESSION_AGE_5_9_F 'DEPRESSION_AGE_5_9_F', @DEPRESSION_AGE_5_9_M 'DEPRESSION_AGE_5_9_M',
            @DEPRESSION_AGE_10_14_F 'DEPRESSION_AGE_10_14_F', @DEPRESSION_AGE_10_14_M 'DEPRESSION_AGE_10_14_M', @DEPRESSION_AGE_15_19_F 'DEPRESSION_AGE_15_19_F',
            @DEPRESSION_AGE_15_19_M 'DEPRESSION_AGE_15_19_M', @DEPRESSION_AGE_20_24_F 'DEPRESSION_AGE_20_24_F', @DEPRESSION_AGE_20_24_M 'DEPRESSION_AGE_20_24_M',
            @DEPRESSION_AGE_25_49_F 'DEPRESSION_AGE_25_49_F', @DEPRESSION_AGE_25_49_M 'DEPRESSION_AGE_25_49_M', @DEPRESSION_AGE_50_PLUS_F 'DEPRESSION_AGE_50_PLUS_F',
            @DEPRESSION_AGE_50_PLUS_M 'DEPRESSION_AGE_50_PLUS_M', @DEPRESSION_DEATH 'DEPRESSION_DEATH', @DEPRESSION_TRANSFER 'DEPRESSION_TRANSFER',

            
            @SCHIZOPHRENIA_AGE_0_F 'SCHIZOPHRENIA_AGE_0_F', @SCHIZOPHRENIA_AGE_0_M 'SCHIZOPHRENIA_AGE_0_M', @SCHIZOPHRENIA_AGE_1_4_F 'SCHIZOPHRENIA_AGE_1_4_F',
            @SCHIZOPHRENIA_AGE_1_4_M 'SCHIZOPHRENIA_AGE_1_4_M', @SCHIZOPHRENIA_AGE_5_9_F 'SCHIZOPHRENIA_AGE_5_9_F', @SCHIZOPHRENIA_AGE_5_9_M 'SCHIZOPHRENIA_AGE_5_9_M',
            @SCHIZOPHRENIA_AGE_10_14_F 'SCHIZOPHRENIA_AGE_10_14_F', @SCHIZOPHRENIA_AGE_10_14_M 'SCHIZOPHRENIA_AGE_10_14_M', @SCHIZOPHRENIA_AGE_15_19_F 'SCHIZOPHRENIA_AGE_15_19_F',
            @SCHIZOPHRENIA_AGE_15_19_M 'SCHIZOPHRENIA_AGE_15_19_M', @SCHIZOPHRENIA_AGE_20_24_F 'SCHIZOPHRENIA_AGE_20_24_F', @SCHIZOPHRENIA_AGE_20_24_M 'SCHIZOPHRENIA_AGE_20_24_M',
            @SCHIZOPHRENIA_AGE_25_49_F 'SCHIZOPHRENIA_AGE_25_49_F', @SCHIZOPHRENIA_AGE_25_49_M 'SCHIZOPHRENIA_AGE_25_49_M', @SCHIZOPHRENIA_AGE_50_PLUS_F 'SCHIZOPHRENIA_AGE_50_PLUS_F',
            @SCHIZOPHRENIA_AGE_50_PLUS_M 'SCHIZOPHRENIA_AGE_50_PLUS_M', @SCHIZOPHRENIA_DEATH 'SCHIZOPHRENIA_DEATH', @SCHIZOPHRENIA_TRANSFER 'SCHIZOPHRENIA_TRANSFER',
            
            @STRESS_AIG_AGE_0_F 'STRESS_AIG_AGE_0_F', @STRESS_AIG_AGE_0_M 'STRESS_AIG_AGE_0_M', @STRESS_AIG_AGE_1_4_F 'STRESS_AIG_AGE_1_4_F',
            @STRESS_AIG_AGE_1_4_M 'STRESS_AIG_AGE_1_4_M', @STRESS_AIG_AGE_5_9_F 'STRESS_AIG_AGE_5_9_F', @STRESS_AIG_AGE_5_9_M 'STRESS_AIG_AGE_5_9_M',
            @STRESS_AIG_AGE_10_14_F 'STRESS_AIG_AGE_10_14_F', @STRESS_AIG_AGE_10_14_M 'STRESS_AIG_AGE_10_14_M', @STRESS_AIG_AGE_15_19_F 'STRESS_AIG_AGE_15_19_F',
            @STRESS_AIG_AGE_15_19_M 'STRESS_AIG_AGE_15_19_M', @STRESS_AIG_AGE_20_24_F 'STRESS_AIG_AGE_20_24_F', @STRESS_AIG_AGE_20_24_M 'STRESS_AIG_AGE_20_24_M',
            @STRESS_AIG_AGE_25_49_F 'STRESS_AIG_AGE_25_49_F', @STRESS_AIG_AGE_25_49_M 'STRESS_AIG_AGE_25_49_M', @STRESS_AIG_AGE_50_PLUS_F 'STRESS_AIG_AGE_50_PLUS_F',
            @STRESS_AIG_AGE_50_PLUS_M 'STRESS_AIG_AGE_50_PLUS_M',  @STRESS_AIG_DEATH 'STRESS_AIG_DEATH', @STRESS_AIG_TRANSFER 'STRESS_AIG_TRANSFER',
            
            @BIPOLAR_DISO_AGE_0_F 'BIPOLAR_DISO_AGE_0_F', @BIPOLAR_DISO_AGE_0_M 'BIPOLAR_DISO_AGE_0_M', @BIPOLAR_DISO_AGE_1_4_F 'BIPOLAR_DISO_AGE_1_4_F',
            @BIPOLAR_DISO_AGE_1_4_M 'BIPOLAR_DISO_AGE_1_4_M', @BIPOLAR_DISO_AGE_5_9_F 'BIPOLAR_DISO_AGE_5_9_F', @BIPOLAR_DISO_AGE_5_9_M 'BIPOLAR_DISO_AGE_5_9_M',
            @BIPOLAR_DISO_AGE_10_14_F 'BIPOLAR_DISO_AGE_10_14_F', @BIPOLAR_DISO_AGE_10_14_M 'BIPOLAR_DISO_AGE_10_14_M', @BIPOLAR_DISO_AGE_15_19_F 'BIPOLAR_DISO_AGE_15_19_F',
            @BIPOLAR_DISO_AGE_15_19_M 'BIPOLAR_DISO_AGE_15_19_M', @BIPOLAR_DISO_AGE_20_24_F 'BIPOLAR_DISO_AGE_20_24_F', @BIPOLAR_DISO_AGE_20_24_M 'BIPOLAR_DISO_AGE_20_24_M',
            @BIPOLAR_DISO_AGE_25_49_F 'BIPOLAR_DISO_AGE_25_49_F', @BIPOLAR_DISO_AGE_25_49_M 'BIPOLAR_DISO_AGE_25_49_M', @BIPOLAR_DISO_AGE_50_PLUS_F 'BIPOLAR_DISO_AGE_50_PLUS_F',
            @BIPOLAR_DISO_AGE_50_PLUS_M 'BIPOLAR_DISO_AGE_50_PLUS_M', @BIPOLAR_DISO_DEATH 'BIPOLAR_DISO_DEATH',@BIPOLAR_DISO_TRANSFER 'BIPOLAR_DISO_TRANSFER',

            
            @DROG_USED_DISO_AGE_0_F 'DROG_USED_DISO_AGE_0_F', @DROG_USED_DISO_AGE_0_M 'DROG_USED_DISO_AGE_0_M', @DROG_USED_DISO_AGE_1_4_F 'DROG_USED_DISO_AGE_1_4_F',
            @DROG_USED_DISO_AGE_1_4_M 'DROG_USED_DISO_AGE_1_4_M', @DROG_USED_DISO_AGE_5_9_F 'DROG_USED_DISO_AGE_5_9_F', @DROG_USED_DISO_AGE_5_9_M 'DROG_USED_DISO_AGE_5_9_M',
            @DROG_USED_DISO_AGE_10_14_F 'DROG_USED_DISO_AGE_10_14_F', @DROG_USED_DISO_AGE_10_14_M 'DROG_USED_DISO_AGE_10_14_M', @DROG_USED_DISO_AGE_15_19_F 'DROG_USED_DISO_AGE_15_19_F',
            @DROG_USED_DISO_AGE_15_19_M 'DROG_USED_DISO_AGE_15_19_M', @DROG_USED_DISO_AGE_20_24_F 'DROG_USED_DISO_AGE_20_24_F', @DROG_USED_DISO_AGE_20_24_M 'DROG_USED_DISO_AGE_20_24_M',
            @DROG_USED_DISO_AGE_25_49_F 'DROG_USED_DISO_AGE_25_49_F', @DROG_USED_DISO_AGE_25_49_M 'DROG_USED_DISO_AGE_25_49_M', @DROG_USED_DISO_AGE_50_PLUS_F 'DROG_USED_DISO_AGE_50_PLUS_F',
            @DROG_USED_DISO_AGE_50_PLUS_M 'DROG_USED_DISO_AGE_50_PLUS_M', @DROG_USED_DISO_DEATH 'DROG_USED_DISO_DEATH', @DROG_USED_DISO_TRANSFER 'DROG_USED_DISO_TRANSFER',


            @DEVELOP_DISO_AGE_0_F 'DEVELOP_DISO_AGE_0_F', @DEVELOP_DISO_AGE_0_M 'DEVELOP_DISO_AGE_0_M', @DEVELOP_DISO_AGE_1_4_F 'DEVELOP_DISO_AGE_1_4_F',
            @DEVELOP_DISO_AGE_1_4_M 'DEVELOP_DISO_AGE_1_4_M', @DEVELOP_DISO_AGE_5_9_F 'DEVELOP_DISO_AGE_5_9_F', @DEVELOP_DISO_AGE_5_9_M 'DEVELOP_DISO_AGE_5_9_M',
            @DEVELOP_DISO_AGE_10_14_F 'DEVELOP_DISO_AGE_10_14_F', @DEVELOP_DISO_AGE_10_14_M 'DEVELOP_DISO_AGE_10_14_M', @DEVELOP_DISO_AGE_15_19_F 'DEVELOP_DISO_AGE_15_19_F',
            @DEVELOP_DISO_AGE_15_19_M 'DEVELOP_DISO_AGE_15_19_M', @DEVELOP_DISO_AGE_20_24_F 'DEVELOP_DISO_AGE_20_24_F', @DEVELOP_DISO_AGE_20_24_M 'DEVELOP_DISO_AGE_20_24_M',
            @DEVELOP_DISO_AGE_25_49_F 'DEVELOP_DISO_AGE_25_49_F', @DEVELOP_DISO_AGE_25_49_M 'DEVELOP_DISO_AGE_25_49_M', @DEVELOP_DISO_AGE_50_PLUS_F 'DEVELOP_DISO_AGE_50_PLUS_F',
            @DEVELOP_DISO_AGE_50_PLUS_M 'DEVELOP_DISO_AGE_50_PLUS_M',  @DEVELOP_DISO_DEATH 'DEVELOP_DISO_DEATH',  @DEVELOP_DISO_TRANSFER 'DEVELOP_DISO_TRANSFER',
            
            @ALCOHOL_USED_DISO_AGE_0_F 'ALCOHOL_USED_DISO_AGE_0_F', @ALCOHOL_USED_DISO_AGE_0_M 'ALCOHOL_USED_DISO_AGE_0_M', @ALCOHOL_USED_DISO_AGE_1_4_F 'ALCOHOL_USED_DISO_AGE_1_4_F',
            @ALCOHOL_USED_DISO_AGE_1_4_M 'ALCOHOL_USED_DISO_AGE_1_4_M', @ALCOHOL_USED_DISO_AGE_5_9_F 'ALCOHOL_USED_DISO_AGE_5_9_F', @ALCOHOL_USED_DISO_AGE_5_9_M 'ALCOHOL_USED_DISO_AGE_5_9_M',
            @ALCOHOL_USED_DISO_AGE_10_14_F 'ALCOHOL_USED_DISO_AGE_10_14_F', @ALCOHOL_USED_DISO_AGE_10_14_M 'ALCOHOL_USED_DISO_AGE_10_14_M', @ALCOHOL_USED_DISO_AGE_15_19_F 'ALCOHOL_USED_DISO_AGE_15_19_F',
            @ALCOHOL_USED_DISO_AGE_15_19_M 'ALCOHOL_USED_DISO_AGE_15_19_M', @ALCOHOL_USED_DISO_AGE_20_24_F 'ALCOHOL_USED_DISO_AGE_20_24_F', @ALCOHOL_USED_DISO_AGE_20_24_M 'ALCOHOL_USED_DISO_AGE_20_24_M',
            @ALCOHOL_USED_DISO_AGE_25_49_F 'ALCOHOL_USED_DISO_AGE_25_49_F', @ALCOHOL_USED_DISO_AGE_25_49_M 'ALCOHOL_USED_DISO_AGE_25_49_M', @ALCOHOL_USED_DISO_AGE_50_PLUS_F 'ALCOHOL_USED_DISO_AGE_50_PLUS_F',
            @ALCOHOL_USED_DISO_AGE_50_PLUS_M 'ALCOHOL_USED_DISO_AGE_50_PLUS_M', @ALCOHOL_USED_DISO_DEATH 'ALCOHOL_USED_DISO_DEATH',   @ALCOHOL_USED_DISO_TRANSFER 'ALCOHOL_USED_DISO_TRANSFER',

            @POST_TRAUMATIC_DISO_AGE_0_F 'POST_TRAUMATIC_DISO_AGE_0_F', @POST_TRAUMATIC_DISO_AGE_0_M 'POST_TRAUMATIC_DISO_AGE_0_M', @POST_TRAUMATIC_DISO_AGE_1_4_F 'POST_TRAUMATIC_DISO_AGE_1_4_F',
            @POST_TRAUMATIC_DISO_AGE_1_4_M 'POST_TRAUMATIC_DISO_AGE_1_4_M', @POST_TRAUMATIC_DISO_AGE_5_9_F 'POST_TRAUMATIC_DISO_AGE_5_9_F', @POST_TRAUMATIC_DISO_AGE_5_9_M 'POST_TRAUMATIC_DISO_AGE_5_9_M',
            @POST_TRAUMATIC_DISO_AGE_10_14_F 'POST_TRAUMATIC_DISO_AGE_10_14_F', @POST_TRAUMATIC_DISO_AGE_10_14_M 'POST_TRAUMATIC_DISO_AGE_10_14_M', @POST_TRAUMATIC_DISO_AGE_15_19_F 'POST_TRAUMATIC_DISO_AGE_15_19_F',
            @POST_TRAUMATIC_DISO_AGE_15_19_M 'POST_TRAUMATIC_DISO_AGE_15_19_M', @POST_TRAUMATIC_DISO_AGE_20_24_F 'POST_TRAUMATIC_DISO_AGE_20_24_F', @POST_TRAUMATIC_DISO_AGE_20_24_M 'POST_TRAUMATIC_DISO_AGE_20_24_M',
            @POST_TRAUMATIC_DISO_AGE_25_49_F 'POST_TRAUMATIC_DISO_AGE_25_49_F', @POST_TRAUMATIC_DISO_AGE_25_49_M 'POST_TRAUMATIC_DISO_AGE_25_49_M', @POST_TRAUMATIC_DISO_AGE_50_PLUS_F 'POST_TRAUMATIC_DISO_AGE_50_PLUS_F',
            @POST_TRAUMATIC_DISO_AGE_50_PLUS_M 'POST_TRAUMATIC_DISO_AGE_50_PLUS_M', @POST_TRAUMATIC_DISO_DEATH 'POST_TRAUMATIC_DISO_DEATH',@POST_TRAUMATIC_DISO_TRANSFER 'POST_TRAUMATIC_DISO_TRANSFER',

            @SUICIDAL_IDEATION_AGE_0_F 'SUICIDAL_IDEATION_AGE_0_F', @SUICIDAL_IDEATION_AGE_0_M 'SUICIDAL_IDEATION_AGE_0_M', @SUICIDAL_IDEATION_AGE_1_4_F 'SUICIDAL_IDEATION_AGE_1_4_F',
            @SUICIDAL_IDEATION_AGE_1_4_M 'SUICIDAL_IDEATION_AGE_1_4_M', @SUICIDAL_IDEATION_AGE_5_9_F 'SUICIDAL_IDEATION_AGE_5_9_F', @SUICIDAL_IDEATION_AGE_5_9_M 'SUICIDAL_IDEATION_AGE_5_9_M',
            @SUICIDAL_IDEATION_AGE_10_14_F 'SUICIDAL_IDEATION_AGE_10_14_F', @SUICIDAL_IDEATION_AGE_10_14_M 'SUICIDAL_IDEATION_AGE_10_14_M', @SUICIDAL_IDEATION_AGE_15_19_F 'SUICIDAL_IDEATION_AGE_15_19_F',
            @SUICIDAL_IDEATION_AGE_15_19_M 'SUICIDAL_IDEATION_AGE_15_19_M', @SUICIDAL_IDEATION_AGE_20_24_F 'SUICIDAL_IDEATION_AGE_20_24_F', @SUICIDAL_IDEATION_AGE_20_24_M 'SUICIDAL_IDEATION_AGE_20_24_M',
            @SUICIDAL_IDEATION_AGE_25_49_F 'SUICIDAL_IDEATION_AGE_25_49_F', @SUICIDAL_IDEATION_AGE_25_49_M 'SUICIDAL_IDEATION_AGE_25_49_M', @SUICIDAL_IDEATION_AGE_50_PLUS_F 'SUICIDAL_IDEATION_AGE_50_PLUS_F',
            @SUICIDAL_IDEATION_AGE_50_PLUS_M 'SUICIDAL_IDEATION_AGE_50_PLUS_M',  @SUICIDAL_IDEATION_DEATH 'SUICIDAL_IDEATION_DEATH', @SUICIDAL_IDEATION_TRANSFER 'SUICIDAL_IDEATION_TRANSFER';
