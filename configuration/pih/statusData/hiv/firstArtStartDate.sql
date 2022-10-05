# Encounter and Obs Group containing first art start dates
select distinct og.obs_id, e.encounter_id, e.encounter_datetime into @artDispenseObsGroupId, @artDispenseEncounterId, @artDispenseEncounterDate
from obs o
inner join encounter e 
   on o.encounter_id = e.encounter_id
inner join obs og on o.obs_group_id = og.obs_id
where e.patient_id = @patientId
  and og.concept_id = concept_from_mapping('PIH', '9070')
  and og.voided = 0
  and o.voided = 0
  and e.voided = 0
  and e.encounter_type = (select encounter_type_id from encounter_type where name like 'HIV drug dispensing')
order by e.encounter_datetime asc
limit 1;

select
    date(@artDispenseEncounterDate) as artDispenseEncounterDate;