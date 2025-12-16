SELECT 
    o.value_text INTO @medication_effect_value
FROM obs o
INNER JOIN encounter e ON o.encounter_id = e.encounter_id
INNER JOIN (
    SELECT o2.encounter_id
    FROM obs o2
    INNER JOIN encounter e2 ON o2.encounter_id = e2.encounter_id
    WHERE o2.concept_id = concept_from_mapping('PIH','12352')
      AND o2.value_coded = concept_from_mapping('PIH','YES')
      AND o2.person_id = @patientId
      AND o2.voided = 0
      AND e2.voided = 0
) AS medicationEffectType ON o.encounter_id = medicationEffectType.encounter_id
WHERE o.person_id = @patientId
  AND o.concept_id = concept_from_mapping('PIH','12351')
  AND o.voided = 0
  AND e.voided = 0
ORDER BY o.obs_id DESC
LIMIT 1;
  
  SELECT @medication_effect_value as medication_effect_value;