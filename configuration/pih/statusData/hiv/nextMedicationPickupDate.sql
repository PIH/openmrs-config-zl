# This query retrieves the total number of HIV Dispensing Encounters and the Most Recent Scheduled Dispensing Date for a patient

set @hivDispensingEncounterType = encounter_type('cc1720c9-3e4c-4fa8-a7ec-40eeaad1958c');
select ifnull(q1.num_pickups, 0) as numPickups, q2.value_datetime as nextPickupDate
from patient p
left join
     (
         select e.patient_id, count(e.encounter_id) as num_pickups
         from encounter e
         where e.encounter_type = @hivDispensingEncounterType
           and e.voided = 0
           and e.patient_id = @patientId
     ) q1 on p.patient_id = q1.patient_id
left join
     (
         select o.person_id, o.value_datetime
         from obs o
                  inner join encounter e on o.encounter_id = e.encounter_id
         where o.concept_id = concept_from_mapping('PIH', '5096')
           and e.encounter_type = @hivDispensingEncounterType
           and o.voided = 0
           and e.voided = 0
           and o.person_id = @patientId
         order by e.encounter_datetime desc
         limit 1
     ) q2 on p.patient_id = q2.person_id
where p.patient_id = @patientId
;