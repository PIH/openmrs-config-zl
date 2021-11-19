# Retrieve the  Next Medication Pickup Date (PIH:5096) from the last HIV drug dispensing encounter.
#   If this date is more than 28 days ago, highlight it in red.
#   If there have been no HIV Drug Dispensing encounters for this patient, display “No medication pickups” in red.

set @hivDispensingEncounterType = encounter_type('${encounterType.HIV_DISPENSING.uuid}');
select q1.num_pickups as numPickups, q2.value_datetime as nextPickupDate
from
    (
        select count(e.encounter_id) as num_pickups
        from encounter e
        where e.patient_id = @patientId
          and e.encounter_type = @hivDispensingEncounterType
          and e.voided = 0
    ) q1,
    (
        select o.value_datetime
        from obs o
        inner join encounter e on o.encounter_id = e.encounter_id
        where o.concept_id = concept_from_mapping('PIH','5096')
          and e.encounter_type = @hivDispensingEncounterType
          and o.voided = 0
          and e.voided = 0
          and o.person_id = @patientId
        order by e.encounter_datetime desc
        limit 1
    ) q2
;