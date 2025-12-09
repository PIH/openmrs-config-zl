CALL initialize_global_metadata();
SET  @locale = GLOBAL_PROPERTY_VALUE('default_locale', 'en');
SET @endDate = ADDDATE(@endDate, INTERVAL 1 DAY);

-- Utilisation et Acceptation methode moderne contraception
SELECT 
    SUM(IF(planing_service_status.value_coded=concept_from_mapping("PIH","10867")
    AND planing_method.value_coded=concept_from_mapping("PIH","13249") 
   ,1,0)),
    SUM(IF(planing_service_status.value_coded=concept_from_mapping("PIH","10867")
    AND planing_method.value_coded=concept_from_mapping("PIH","13248") 
   ,1,0)) ,
     SUM(IF(planing_service_status.value_coded=concept_from_mapping("PIH","10867")
    AND planing_method.value_coded=concept_from_mapping("PIH","907") 
   ,1,0)),
   SUM(IF(planing_service_status.value_coded=concept_from_mapping("PIH","10867")
    AND planing_method.value_coded=concept_from_mapping("PIH","12106") 
   ,1,0)),
     SUM(IF(planing_service_status.value_coded=concept_from_mapping("PIH","10867")
    AND planing_method.value_coded=concept_from_mapping("PIH","5275") 
   ,1,0)),
   SUM(IF(planing_service_status.value_coded=concept_from_mapping("PIH","10867")
    AND planing_method.value_coded=concept_from_mapping("PIH","190") 
   ,1,0)),
      SUM(IF(planing_service_status.value_coded=concept_from_mapping("PIH","10867")
    AND planing_method.value_coded=concept_from_mapping("PIH","13158") 
   ,1,0)),
     SUM(IF(planing_service_status.value_coded=concept_from_mapping("PIH","10867")
    AND planing_method.value_coded=concept_from_mapping("PIH","5277") 
   ,1,0)),
     SUM(IF(planing_service_status.value_coded=concept_from_mapping("PIH","10867")
    AND planing_method.value_coded=concept_from_mapping("PIH","1719") 
   ,1,0)),
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
          @MET_COC_USED,@MET_COP_USED,@MET_DEPO_PROVERA_USED,@MET_IMPL_USED,@MET_DIU_USED,@MET_CONDOM_USED,@MET_MAMA_USED,@MET_COLLIER_USED,@MET_CCV_USED,
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



SELECT @MET_COC_USED 'MET_COC_USED',
        @MET_COP_USED 'MET_COP_USED',
        @MET_DEPO_PROVERA_USED 'MET_DEPO_PROVERA_USED',
        @MET_IMPL_USED 'MET_IMPL_USED',
        @MET_DIU_USED 'MET_DIU_USED',
        @MET_CONDOM_USED 'MET_CONDOM_USED',
        @MET_MAMA_USED 'MET_MAMA_USED',
        @MET_COLLIER_USED 'MET_COLLIER_USED',
        @MET_CCV_USED 'MET_CCV_USED',
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
        @MET_CCV 'MET_CCV',@MET_IMPL 'MET_IMPL',@MET_DIU 'MET_DIU';