CALL initialize_global_metadata();
SET  @locale = GLOBAL_PROPERTY_VALUE('default_locale', 'en');
SET @endDate = ADDDATE(@endDate, INTERVAL 1 DAY);

-- Acceptation methode moderne contraception
SELECT
    SUM(IF(DATEDIFF(e.encounter_datetime, p.birthdate)/365.25<25
   AND planing_service_status.value_coded=concept_from_mapping("PIH","13958")
    AND planing_method.value_coded=concept_from_mapping("PIH","13249") 
   ,1,0)),
    SUM(IF(DATEDIFF(e.encounter_datetime, p.birthdate)/365.25<25
   AND planing_service_status.value_coded=concept_from_mapping("PIH","13958")
    AND planing_method.value_coded=concept_from_mapping("PIH","13248") 
   ,1,0)),
   
    SUM(IF(DATEDIFF(e.encounter_datetime, p.birthdate)/365.25<25
   AND planing_service_status.value_coded=concept_from_mapping("PIH","13958")
    AND planing_method.value_coded=concept_from_mapping("PIH","907") 
   ,1,0)),
   
    SUM(IF(DATEDIFF(e.encounter_datetime, p.birthdate)/365.25<25
   AND planing_service_status.value_coded=concept_from_mapping("PIH","13958")
    AND planing_method.value_coded=concept_from_mapping("PIH","12106") 
   ,1,0)),
   
    SUM(IF(DATEDIFF(e.encounter_datetime, p.birthdate)/365.25<25
   AND planing_service_status.value_coded=concept_from_mapping("PIH","13958")
    AND planing_method.value_coded=concept_from_mapping("PIH","5275") 
   ,1,0)),
   
    SUM(IF(DATEDIFF(e.encounter_datetime, p.birthdate)/365.25<25
   AND planing_service_status.value_coded=concept_from_mapping("PIH","13958")
    AND planing_method.value_coded=concept_from_mapping("PIH","190") 
   ,1,0)),
   
    SUM(IF(DATEDIFF(e.encounter_datetime, p.birthdate)/365.25<25
   AND planing_service_status.value_coded=concept_from_mapping("PIH","13958")
    AND planing_method.value_coded=concept_from_mapping("PIH","13158") 
   ,1,0)),
   
    SUM(IF(DATEDIFF(e.encounter_datetime, p.birthdate)/365.25<25
   AND planing_service_status.value_coded=concept_from_mapping("PIH","13958")
    AND planing_method.value_coded=concept_from_mapping("PIH","5277") 
   ,1,0)),
   
    SUM(IF(DATEDIFF(e.encounter_datetime, p.birthdate)/365.25<25
   AND planing_service_status.value_coded=concept_from_mapping("PIH","13958")
    AND planing_method.value_coded=concept_from_mapping("PIH","1719") 
   ,1,0)),


    SUM(IF(DATEDIFF(e.encounter_datetime, p.birthdate)/365.25>=25
   AND planing_service_status.value_coded=concept_from_mapping("PIH","13958")
    AND planing_method.value_coded=concept_from_mapping("PIH","13249") 
   ,1,0)),
   
    SUM(IF(DATEDIFF(e.encounter_datetime, p.birthdate)/365.25>=25
   AND planing_service_status.value_coded=concept_from_mapping("PIH","13958")
    AND planing_method.value_coded=concept_from_mapping("PIH","13248") 
   ,1,0)),
   
    SUM(IF(DATEDIFF(e.encounter_datetime, p.birthdate)/365.25>=25
   AND planing_service_status.value_coded=concept_from_mapping("PIH","13958")
    AND planing_method.value_coded=concept_from_mapping("PIH","907") 
   ,1,0)),
   
    SUM(IF(DATEDIFF(e.encounter_datetime, p.birthdate)/365.25>=25
   AND planing_service_status.value_coded=concept_from_mapping("PIH","13958")
    AND planing_method.value_coded=concept_from_mapping("PIH","12106") 
   ,1,0)),
   
    SUM(IF(DATEDIFF(e.encounter_datetime, p.birthdate)/365.25>=25
   AND planing_service_status.value_coded=concept_from_mapping("PIH","13958")
    AND planing_method.value_coded=concept_from_mapping("PIH","5275") 
   ,1,0)),
   
    SUM(IF(DATEDIFF(e.encounter_datetime, p.birthdate)/365.25>=25
   AND planing_service_status.value_coded=concept_from_mapping("PIH","13958")
    AND planing_method.value_coded=concept_from_mapping("PIH","190") 
   ,1,0)),
   
    SUM(IF(DATEDIFF(e.encounter_datetime, p.birthdate)/365.25>=25
   AND planing_service_status.value_coded=concept_from_mapping("PIH","13958")
    AND planing_method.value_coded=concept_from_mapping("PIH","13158") 
   ,1,0)),
   
    SUM(IF(DATEDIFF(e.encounter_datetime, p.birthdate)/365.25>=25
   AND planing_service_status.value_coded=concept_from_mapping("PIH","13958")
    AND planing_method.value_coded=concept_from_mapping("PIH","5277") 
   ,1,0)),
   
    SUM(IF(DATEDIFF(e.encounter_datetime, p.birthdate)/365.25>=25
   AND planing_service_status.value_coded=concept_from_mapping("PIH","13958")
    AND planing_method.value_coded=concept_from_mapping("PIH","1719") 
   ,1,0))
    INTO
          @MET_COC_LESS_THAN_25_ACCEPTED,@MET_COP_LESS_THAN_25_ACCEPTED,@MET_DEPO_PROVERA_LESS_THAN_25_ACCEPTED,@MET_IMPL_LESS_THAN_25_ACCEPTED,@MET_DIU_LESS_THAN_25_ACCEPTED,@MET_CONDOM_LESS_THAN_25_ACCEPTED,@MET_MAMA_LESS_THAN_25_ACCEPTED,@MET_COLLIER_LESS_THAN_25_ACCEPTED,@MET_CCV_LESS_THAN_25_ACCEPTED,
          @MET_COC_MORE_25_ACCEPTED,@MET_COP_MORE_25_ACCEPTED,@MET_DEPO_PROVERA_MORE_25_ACCEPTED,@MET_IMPL_MORE_25_ACCEPTED,@MET_DIU_USED_MORE_25_ACCEPTED,@MET_CONDOM_MORE_25_ACCEPTED,@MET_MAMA_MORE_25_ACCEPTED,@MET_COLLIER_MORE_25_ACCEPTED,@MET_CCV_MORE_25_ACCEPTED
    FROM 
    obs o 
   INNER JOIN encounter e ON o.encounter_id = e.encounter_id 
   INNER JOIN person p ON p.person_id = o.person_id
   LEFT JOIN (
	    SELECT encounter_id, value_coded
	    FROM obs
	    WHERE concept_id = concept_from_mapping("PIH", "374")  AND voided = 0)
	    AS planing_method ON o.encounter_id = planing_method.encounter_id
    LEFT JOIN (
	    SELECT encounter_id, value_coded
	    FROM obs
	    WHERE concept_id = concept_from_mapping("PIH", "14321") AND voided = 0 ) AS planing_service_status ON o.encounter_id = planing_service_status.encounter_id
    WHERE 
    o.value_coded in (concept_from_mapping("PIH", "13254"),concept_from_mapping("PIH", "6259"),concept_from_mapping("PIH", "6261"), concept_from_mapping("PIH", "5483"))
    AND e.voided = 0
    AND o.voided = 0
    AND DATE(e.encounter_datetime) >= @startDate
    AND DATE(e.encounter_datetime) < @endDate;

  SELECT 
  SUM(IF( planing_method.value_coded=concept_from_mapping("PIH","1719") 
   ,1,0)),
   SUM(IF( planing_method.value_coded=concept_from_mapping("PIH","12106") 
   ,1,0)),

     SUM(IF(planing_method.value_coded=concept_from_mapping("PIH","5275") 
   ,1,0))

    INTO
      @MET_CCV,@MET_IMPL,@MET_DIU

    FROM 
    obs o 
   INNER JOIN encounter e ON o.encounter_id = e.encounter_id 
   INNER JOIN person p ON p.person_id = o.person_id
   LEFT JOIN (
	    SELECT encounter_id, value_coded
	    FROM obs
	    WHERE concept_id =  concept_from_mapping("PIH", "374")  AND voided = 0)
	    AS planing_method ON o.encounter_id = planing_method.encounter_id
    WHERE 
    o.value_coded in (concept_from_mapping("PIH", "13254"),concept_from_mapping("PIH", "6259"),concept_from_mapping("PIH", "6261"), concept_from_mapping("PIH", "5483"))
    AND e.voided = 0
    AND o.voided = 0
    AND DATE(e.encounter_datetime) >= @startDate
    AND DATE(e.encounter_datetime) < @endDate;


-- NUMBER 0F CONDOMS DONATED
  SELECT 
     SUM(nb_of_condoms.value_numeric)
    INTO
      @NB_OF_CONDOMS
    FROM 
    obs o 
   INNER JOIN encounter e ON o.encounter_id = e.encounter_id 
   INNER JOIN person p ON p.person_id = o.person_id
   LEFT JOIN (
	    SELECT encounter_id, value_numeric  
	    FROM obs
	    WHERE concept_id =  concept_from_mapping("PIH", "20151")  AND voided = 0)
	    AS nb_of_condoms ON o.encounter_id = nb_of_condoms.encounter_id
    WHERE 
    o.value_coded in (concept_from_mapping("PIH", "13254"),concept_from_mapping("PIH", "6259"),concept_from_mapping("PIH", "6261"), concept_from_mapping("PIH", "5483"))
    AND e.voided = 0
    AND o.voided = 0
    AND DATE(e.encounter_datetime) >= @startDate
    AND DATE(e.encounter_datetime) < @endDate;

---B1 Prenatal consultation
SELECT
       SUM(CASE
            WHEN  o.value_coded = concept_from_mapping("PIH","10900")
            THEN 1 ELSE 0 END),
    SUM(CASE
            WHEN o.value_coded = concept_from_mapping("PIH","10901")
            THEN 1 ELSE 0 END),
    SUM(CASE
            WHEN o.value_coded = concept_from_mapping("PIH","10902")
            THEN 1 ELSE 0 END),
    SUM(CASE
            WHEN  o.concept_id = concept_from_mapping("PIH","14390")
            AND o.value_numeric IS NULL
            THEN 1 ELSE 0 END),
    SUM(CASE
            WHEN o.concept_id =  concept_from_mapping("PIH","11672")
            AND o.value_coded = concept_from_mapping("PIH","1065")
            THEN 1 ELSE 0 END),
    SUM(CASE
            WHEN o.concept_id = concept_from_mapping("PIH","2169") 
            and o.value_coded = concept_from_mapping("PIH","703")
            THEN 1 ELSE 0 END),
    SUM(CASE
            WHEN o.concept_id = concept_from_mapping("PIH","3267")
            AND  o.value_datetime IS NOT NULL
            THEN 1 ELSE 0 END)
INTO  @ANC_1ST_VISIT_T1,@ANC_1ST_VISIT_T2,@ANC_1ST_VISIT_T3,@ANC_1ST_VISIT_GA_UNK,@ANC_1ST_VISIT_HIV_TESTED,@ANC_1ST_VISIT_HIV_POS,@ANC_1ST_VISIT_SYPH_TESTED 
FROM encounter e
INNER JOIN (
    SELECT
        e.encounter_id
    FROM encounter e
    INNER JOIN obs o_pn
        ON o_pn.encounter_id = e.encounter_id
        AND o_pn.value_coded = concept_from_mapping('PIH','6259')
        AND o_pn.voided = 0
    INNER JOIN obs o_nv
        ON o_nv.encounter_id = e.encounter_id
        AND o_nv.value_coded = concept_from_mapping('PIH','13235')
        AND o_nv.voided = 0
    INNER JOIN (
        SELECT
            o.person_id,
            MAX(e.encounter_datetime) AS last_enc_datetime
        FROM encounter e
        INNER JOIN obs o
            ON o.encounter_id = e.encounter_id
        INNER JOIN obs o2
            ON o2.encounter_id = e.encounter_id
        WHERE
            o.value_coded = concept_from_mapping('PIH','6259')
            AND o2.value_coded = concept_from_mapping('PIH','13235')
            AND o.voided = 0
            AND o2.voided = 0
            AND e.voided = 0
            AND e.encounter_datetime IS NOT NULL
        GROUP BY o.person_id
    ) last_enc
        ON last_enc.person_id = o_pn.person_id
       AND last_enc.last_enc_datetime = e.encounter_datetime
        and e.voided = 0
        and o_pn.voided =0
        AND e.encounter_datetime >=  @startDate
	    AND e.encounter_datetime <   @endDate
       GROUP BY o_pn.person_id
) last_encounters
    ON last_encounters.encounter_id = e.encounter_id
INNER JOIN obs o 
    ON o.encounter_id = e.encounter_id
INNER JOIN person p 
    ON p.person_id = e.patient_id
    AND o.voided = 0
    AND e.voided = 0
    WHERE  e.encounter_datetime >=  @startDate
	AND e.encounter_datetime <   @endDate;


SELECT
    SUM(CASE WHEN followup_number = 1 AND trimestre='Trim1' THEN 1 ELSE 0 END),
    SUM(CASE WHEN followup_number = 2 AND trimestre='Trim1' THEN 1 ELSE 0 END),
    SUM(CASE WHEN followup_number = 3 AND trimestre='Trim1' THEN 1 ELSE 0 END) ,
    SUM(CASE WHEN followup_number >= 4 AND trimestre='Trim1' THEN 1 ELSE 0 END),
    
    SUM(CASE WHEN followup_number = 1 AND trimestre='Trim2' THEN 1 ELSE 0 END),
    SUM(CASE WHEN followup_number = 2 AND trimestre='Trim2' THEN 1 ELSE 0 END),
    SUM(CASE WHEN followup_number = 3 AND trimestre='Trim2' THEN 1 ELSE 0 END),
    SUM(CASE WHEN followup_number >= 4 AND trimestre='Trim2' THEN 1 ELSE 0 END),

    SUM(CASE WHEN followup_number = 1 AND trimestre='Trim3' THEN 1 ELSE 0 END),
    SUM(CASE WHEN followup_number = 2 AND trimestre='Trim3' THEN 1 ELSE 0 END),
    SUM(CASE WHEN followup_number = 3 AND trimestre='Trim3' THEN 1 ELSE 0 END),
    SUM(CASE WHEN followup_number >= 4 AND trimestre='Trim3' THEN 1 ELSE 0 END)
    
    INTO  @ANC_SV_0_3M,@ANC_TV_0_3M,@ANC_FV_0_3M,@ANC_5PLUS_0_3M,
    	  @ANC_SV_4_6M,@ANC_TV_4_6M,@ANC_FV_4_6M,@ANC_5PLUS_4_6M,
    	  @ANC_SV_7_9M,@ANC_TV_7_9M,@ANC_FV_7_9M,@ANC_5PLUS_7_9M
FROM (
    SELECT
        fs.patient_id,
        fs.encounter_id,
        COUNT(fs_prev.encounter_id) + 1 AS followup_number,
        CASE
            WHEN o_trimester.value_coded = concept_from_mapping('PIH','10900') THEN 'Trim1'
            WHEN o_trimester.value_coded = concept_from_mapping('PIH','10901') THEN 'Trim2'
            WHEN o_trimester.value_coded = concept_from_mapping('PIH','10902') THEN 'Trim3'
        END AS trimestre
    FROM encounter fs
    INNER JOIN obs o_suivi
        ON o_suivi.encounter_id = fs.encounter_id
        AND o_suivi.value_coded = concept_from_mapping('PIH','7383')
        AND o_suivi.voided = 0
    INNER JOIN obs o_pn
        ON o_pn.encounter_id = fs.encounter_id
        AND o_pn.value_coded = concept_from_mapping('PIH','6259')
        AND o_pn.voided = 0
    INNER JOIN obs o_trimester
        ON o_trimester.encounter_id = fs.encounter_id
        AND o_trimester.value_coded IN (
            concept_from_mapping('PIH','10900'),
            concept_from_mapping('PIH','10901'),
            concept_from_mapping('PIH','10902')
        )
        AND o_trimester.voided = 0
    INNER JOIN (
        SELECT
            e.patient_id,
            MAX(e.encounter_datetime) AS last_new_visit_date
        FROM encounter e
        INNER JOIN obs o_pn2
            ON o_pn2.encounter_id = e.encounter_id
            AND o_pn2.value_coded = concept_from_mapping('PIH','6259')
            AND o_pn2.voided = 0
        INNER JOIN obs o_nv
            ON o_nv.encounter_id = e.encounter_id
            AND o_nv.value_coded = concept_from_mapping('PIH','13235')
            AND o_nv.voided = 0
        WHERE e.voided = 0
        GROUP BY e.patient_id
    ) last_nv
        ON last_nv.patient_id = fs.patient_id
    LEFT JOIN encounter fs_prev
        ON fs_prev.patient_id = fs.patient_id
        AND fs_prev.encounter_datetime > last_nv.last_new_visit_date
        AND fs_prev.encounter_datetime < fs.encounter_datetime
        AND fs_prev.voided = 0
    LEFT JOIN obs o_suivi_prev
        ON o_suivi_prev.encounter_id = fs_prev.encounter_id
        AND o_suivi_prev.value_coded = concept_from_mapping('PIH','7383')
        AND o_suivi_prev.voided = 0
    LEFT JOIN obs o_pn_prev
        ON o_pn_prev.encounter_id = fs_prev.encounter_id
        AND o_pn_prev.value_coded = concept_from_mapping('PIH','6259')
        AND o_pn_prev.voided = 0
    WHERE fs.encounter_datetime > last_nv.last_new_visit_date
      AND fs.encounter_datetime >=  @startDate
      AND fs.encounter_datetime <   @endDate
      AND fs.voided = 0
    GROUP BY fs.patient_id, fs.encounter_id, o_trimester.value_coded
) x;

---Number of pregnant women with an estimated due date (EDD) for the month of the report
SELECT 
COUNT(x.person_id ) INTO @ANC_DPA_MONTH
FROM (
SELECT o.person_id FROM encounter e 
INNER JOIN obs o on o.encounter_id =e.encounter_id 
INNER JOIN (
        SELECT
            e.patient_id,e.encounter_id ,
            MAX(e.encounter_datetime) AS last_new_visit_date
        FROM encounter e
        INNER JOIN obs o_pn2
            ON o_pn2.encounter_id = e.encounter_id
            AND o_pn2.value_coded = concept_from_mapping('PIH','6259')
            AND o_pn2.voided = 0
        INNER JOIN obs o_nv
            ON o_nv.encounter_id = e.encounter_id
            AND o_nv.value_coded = concept_from_mapping('PIH','13235')
            AND o_nv.voided = 0
        WHERE e.voided = 0
        GROUP BY e.patient_id
    ) last_nv
        ON last_nv.patient_id = e.patient_id
WHERE
 e.encounter_datetime = last_nv.last_new_visit_date 
 AND e.encounter_datetime >= @startDate
 AND e.encounter_datetime <  @endDate
 AND o.voided =0
 AND e.voided =0
 AND o.concept_id =concept_from_mapping('PIH','5596')
 GROUP BY o.person_id 
 )x;

----# of high-risk pregnancies
SELECT COUNT(x.person_id ) INTO @ANC_PREG_HR_CONDITIONS
 FROM (
    SELECT o.person_id FROM encounter e 
    INNER JOIN obs o on o.encounter_id =e.encounter_id 
    INNER JOIN (
            SELECT
                e.patient_id,e.encounter_id ,
                MAX(e.encounter_datetime) AS last_new_visit_date
            FROM encounter e
            INNER JOIN obs o_pn2
                ON o_pn2.encounter_id = e.encounter_id
                AND o_pn2.value_coded = concept_from_mapping('PIH','6259')
                AND o_pn2.voided = 0
            INNER JOIN obs o_nv
                ON o_nv.encounter_id = e.encounter_id
                AND o_nv.value_coded = concept_from_mapping('PIH','13235')
                AND o_nv.voided = 0
            WHERE e.voided = 0
            GROUP BY e.patient_id
        ) last_nv
            ON last_nv.patient_id = e.patient_id
    WHERE
    e.encounter_datetime   >= last_nv.last_new_visit_date 
    AND e.encounter_datetime >=  @startDate
    AND e.encounter_datetime <  @endDate
    AND o.voided =0
    AND e.voided =0
    AND o.concept_id =concept_from_mapping('PIH','11673')
    GROUP BY o.person_id 
 )x;

----# of pregnant women who had their first visit since October during the month of the report.
 SELECT COUNT(x.person_id ) INTO  @ANC_1ST_VISIT_SINCE_OCT_MONTH
  FROM (
    SELECT o.person_id FROM encounter e 
    INNER JOIN obs o on o.encounter_id =e.encounter_id 
    INNER JOIN (
            SELECT
                e.patient_id,e.encounter_id ,
                MAX(e.encounter_datetime) AS last_new_visit_date
            FROM encounter e
            INNER JOIN obs o_pn2
                ON o_pn2.encounter_id = e.encounter_id
                AND o_pn2.value_coded = concept_from_mapping('PIH','6259')
                AND o_pn2.voided = 0
            INNER JOIN obs o_nv
                ON o_nv.encounter_id = e.encounter_id
                AND o_nv.value_coded = concept_from_mapping('PIH','13235')
                AND o_nv.voided = 0
            WHERE e.voided = 0
            GROUP BY e.patient_id
        ) last_nv
            ON last_nv.patient_id = e.patient_id
    WHERE
    e.encounter_datetime = last_nv.last_new_visit_date 
    AND e.encounter_datetime >=  @startDate
    AND e.encounter_datetime <  @endDate
    AND o.voided =0
    AND e.voided =0
    AND o.value_coded = concept_from_mapping('PIH','6259')
    GROUP BY o.person_id 
 )x;

--- number of pregnant women who received iron during prenatal visits (ferrous sulfate, iron, iron dextran)
SELECT COUNT(x.person_id ) INTO  @ANC_PREG_IRON_SUPP_COUNT
    FROM (
    SELECT o.person_id FROM encounter e 
    INNER JOIN obs o on o.encounter_id =e.encounter_id 
    INNER JOIN orders o2 on o2.encounter_id = e.encounter_id
    INNER JOIN (
            SELECT
                e.patient_id,e.encounter_id ,
                MAX(e.encounter_datetime) AS last_new_visit_date
            FROM encounter e
            INNER JOIN obs o_pn2
                ON o_pn2.encounter_id = e.encounter_id
                AND o_pn2.value_coded = concept_from_mapping('PIH','6259')
                AND o_pn2.voided = 0
            INNER JOIN obs o_nv
                ON o_nv.encounter_id = e.encounter_id
                AND o_nv.value_coded = concept_from_mapping('PIH','13235')
                AND o_nv.voided = 0
            WHERE e.voided = 0
            GROUP BY e.patient_id
        ) last_nv
            ON last_nv.patient_id = e.patient_id
    WHERE
    e.encounter_datetime >= last_nv.last_new_visit_date 
    AND e.encounter_datetime >=  @startDate
    AND e.encounter_datetime <  @endDate
    AND o.voided =0
    AND e.voided =0
    AND o.value_coded = concept_from_mapping('PIH','6259')
    and o2.concept_id in (concept_from_mapping('PIH','256'),concept_from_mapping('PIH','9267'))
    AND o2.voided =0
    GROUP BY o.person_id 
  )x;

SELECT 
        @MET_COC_LESS_THAN_25_ACCEPTED 'MET_COC_LESS_THAN_25_ACCEPTED',
        @MET_COP_LESS_THAN_25_ACCEPTED 'MET_COP_LESS_THAN_25_ACCEPTED',
        @MET_DEPO_PROVERA_LESS_THAN_25_ACCEPTED 'MET_DEPO_PROVERA_LESS_THAN_25_ACCEPTED',
        @MET_IMPL_LESS_THAN_25_ACCEPTED 'MET_IMPL_LESS_THAN_25_ACCEPTED',
        @MET_DIU_LESS_THAN_25_ACCEPTED 'MET_DIU_LESS_THAN_25_ACCEPTED',
        @MET_CONDOM_LESS_THAN_25_ACCEPTED 'MET_CONDOM_LESS_THAN_25_ACCEPTED',
        @MET_MAMA_LESS_THAN_25_ACCEPTED 'MET_MAMA_LESS_THAN_25_ACCEPTED',
        @MET_COLLIER_LESS_THAN_25_ACCEPTED 'MET_COLLIER_LESS_THAN_25_ACCEPTED',
        @MET_CCV_LESS_THAN_25_ACCEPTED 'MET_CCV_LESS_THAN_25_ACCEPTED',
        @MET_COC_MORE_25_ACCEPTED 'MET_COC_MORE_25_ACCEPTED',
        @MET_COP_MORE_25_ACCEPTED 'MET_COP_MORE_25_ACCEPTED',
        @MET_DEPO_PROVERA_MORE_25_ACCEPTED 'MET_DEPO_PROVERA_MORE_25_ACCEPTED',
        @MET_IMPL_MORE_25_ACCEPTED 'MET_IMPL_MORE_25_ACCEPTED',
        @MET_DIU_USED_MORE_25_ACCEPTED 'MET_DIU_USED_MORE_25_ACCEPTED',
        @MET_CONDOM_MORE_25_ACCEPTED 'MET_CONDOM_MORE_25_ACCEPTED',
        @MET_MAMA_MORE_25_ACCEPTED 'MET_MAMA_MORE_25_ACCEPTED',
        @MET_COLLIER_MORE_25_ACCEPTED 'MET_COLLIER_MORE_25_ACCEPTED',
        @MET_CCV_MORE_25_ACCEPTED 'MET_CCV_MORE_25_ACCEPTED',
        @MET_CCV 'MET_CCV',@MET_IMPL 'MET_IMPL',@MET_DIU 'MET_DIU',
        @NB_OF_CONDOMS 'NB_OF_CONDOMS',
        @ANC_1ST_VISIT_T1 'ANC_1ST_VISIT_T1',@ANC_1ST_VISIT_T2 'ANC_1ST_VISIT_T2',
        @ANC_1ST_VISIT_T3 'ANC_1ST_VISIT_T3',@ANC_1ST_VISIT_GA_UNK 'ANC_1ST_VISIT_GA_UNK',
        @ANC_1ST_VISIT_HIV_TESTED 'ANC_1ST_VISIT_HIV_TESTED',@ANC_1ST_VISIT_HIV_POS 'ANC_1ST_VISIT_HIV_POS',
        @ANC_1ST_VISIT_SYPH_TESTED 'ANC_1ST_VISIT_SYPH_TESTED',
        @ANC_SV_0_3M 'ANC_SV_0_3M',@ANC_TV_0_3M 'ANC_TV_0_3M',@ANC_FV_0_3M 'ANC_FV_0_3M',@ANC_5PLUS_0_3M 'ANC_5PLUS_0_3M',
    	@ANC_SV_4_6M 'ANC_SV_4_6M',@ANC_TV_4_6M 'ANC_TV_4_6M',@ANC_FV_4_6M 'ANC_FV_4_6M',@ANC_5PLUS_4_6M 'ANC_5PLUS_4_6M',
    	@ANC_SV_7_9M 'ANC_SV_7_9M',@ANC_TV_7_9M 'ANC_TV_7_9M',@ANC_FV_7_9M 'ANC_FV_7_9M',@ANC_5PLUS_7_9M 'ANC_5PLUS_7_9M',
        @ANC_DPA_MONTH 'ANC_DPA_MONTH', @ANC_PREG_HR_CONDITIONS 'ANC_PREG_HR_CONDITIONS', @ANC_1ST_VISIT_SINCE_OCT_MONTH 'ANC_1ST_VISIT_SINCE_OCT_MONTH', 
        @ANC_PREG_IRON_SUPP_COUNT 'ANC_PREG_IRON_SUPP_COUNT', 0 'ANC_VACC_COMPLETED_MONTH',0 'ANC_PREG_ABORTED_MONTH', 0 'ANC_PAC_MANAGED_MONTH';