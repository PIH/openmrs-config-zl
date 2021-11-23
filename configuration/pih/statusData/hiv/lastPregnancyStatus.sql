# This retrieves all of the data points needed to provide information as to
# the last pregnancy status

# Gender
select gender into @gender from person where person_id = @patientId;

# Pregnancy Status
select e.encounter_id, o.value_coded into @pregnantEncounterId, @pregnantValueCoded
from obs o
inner join encounter e on o.encounter_id = e.encounter_id
where o.person_id = @patientId
and o.concept_id = concept_from_mapping('CIEL', '5272')
and o.voided = 0
and e.voided = 0
order by e.encounter_datetime desc
limit 1
;

select obs_value_datetime(@pregnantEncounterId, 'CIEL', '5596') into @edd;

select
    @gender as gender,
    if (@pregnantValueCoded = concept_from_mapping('CIEL', '1065'), true, false) as pregnant,
    if (@pregnantValueCoded = concept_from_mapping('CIEL', '1065'), date(@edd), null) as dueDate
;
