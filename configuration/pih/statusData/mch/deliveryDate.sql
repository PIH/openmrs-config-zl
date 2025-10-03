SELECT date(o.value_datetime) as estimatedDateOfConfinement
FROM obs o 
WHERE o.obs_id = (
    SELECT o2.obs_id 
    FROM obs o2 
    WHERE o2.person_id = @patientId
      AND o2.concept_id = concept_from_mapping('PIH','ESTIMATED DATE OF CONFINEMENT')
      AND o2.voided = 0
      AND DATEDIFF(NOW(), o2.obs_datetime) <= 270
    ORDER BY o2.obs_datetime DESC 
    LIMIT 1
);