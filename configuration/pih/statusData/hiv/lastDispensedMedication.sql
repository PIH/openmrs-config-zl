# This retrieves all the data about the ARV regimen on the latest dispensing

# set pertinent concept_id
select concept_from_mapping('PIH', '9070'),
concept_from_mapping('PIH', '1535'),
concept_from_mapping('PIH', '3013'),
concept_from_mapping('PIH', '2848'),
concept_from_mapping('PIH', '13960'),
concept_from_mapping('PIH', '1282'),
concept_from_mapping('PIH', '9071')
into @dispensingConstruct, @medicationCategory, @arv1, @arv2, @arv3, @medicationName, @medicationQuantity
;


select concept_name(@arv1, 'en'), concept_name(@arv2, 'en'), concept_name(@arv3, 'en')
into  @arv1Name, @arv2Name, @arv3Name;


# Get the latest encounter with ARV1 or ARV2 or ARV3
SELECT o.encounter_id  into @encounterId
FROM obs o
join obs o2 on o.obs_group_id = o2.obs_id
join encounter e on e.encounter_id = o.encounter_id
where o.person_id = @patientId
and o2.concept_id = @dispensingConstruct
and o.concept_id = @medicationCategory
and (o.value_coded = @arv1 or o.value_coded = @arv2 or o.value_coded = @arv3)
group by o.encounter_id
order by e.encounter_datetime desc
limit 1
;

# Get group for ARV1
select obs_group_id into @arv1Group
from obs
where concept_id = @medicationCategory
and value_coded = @arv1
and person_id = @patientId and encounter_id = @encounterId
;

# Get details for ARV1
select d.drug_name, q.value_numeric into @arv1DrugName, @arv1DrugQuantity
from obs o
join obs o2 on o.obs_group_id = o2.obs_id
join (
		select obs_group_id, value_numeric
		from obs
		where concept_id = @medicationQuantity
		) q on q.obs_group_id = o.obs_group_id
join (
		select obs_group_id, drugName(value_drug) drug_name
		from obs
		where concept_id = @medicationName
		) d on q.obs_group_id = o.obs_group_id
where o.person_id = @patientId and o.encounter_id = @encounterId
and o2.concept_id = @dispensingConstruct
and o.obs_group_id = @arv1Group
group by o.encounter_id, o.obs_group_id
;


# Get group for ARV2
select obs_group_id into @arv2Group
from obs
where concept_id = @medicationCategory
and value_coded = @arv2
and person_id = @patientId and encounter_id = @encounterId
;

# Get details for ARV2
select d.drug_name, q.value_numeric into @arv2DrugName, @arv2DrugQuantity
from obs o
join obs o2 on o.obs_group_id = o2.obs_id
join (
		select obs_group_id, value_numeric
		from obs
		where concept_id = @medicationQuantity
		) q on q.obs_group_id = o.obs_group_id
join (
		select obs_group_id, drugName(value_drug) drug_name
		from obs
		where concept_id = @medicationName
		) d on q.obs_group_id = o.obs_group_id
where o.person_id = @patientId and o.encounter_id = @encounterId
and o2.concept_id = @dispensingConstruct
and o.obs_group_id = @arv2Group
group by o.encounter_id, o.obs_group_id
;


# Get group for ARV3
select obs_group_id into @arv3Group
from obs
where concept_id = @medicationCategory
and value_coded = @arv3
and person_id = @patientId and encounter_id = @encounterId
;

# Get details for ARV3
select d.drug_name, q.value_numeric into @arv3DrugName, @arv3DrugQuantity
from obs o
join obs o2 on o.obs_group_id = o2.obs_id
join (
		select obs_group_id, value_numeric
		from obs
		where concept_id = @medicationQuantity
		) q on q.obs_group_id = o.obs_group_id
join (
		select obs_group_id, drugName(value_drug) drug_name
		from obs
		where concept_id = @medicationName
		) d on q.obs_group_id = o.obs_group_id
where o.person_id = @patientId and o.encounter_id = @encounterId
and o2.concept_id = @dispensingConstruct
and o.obs_group_id = @arv3Group
group by o.encounter_id, o.obs_group_id
;


select
    @arv1Name as arv1Name,
    @arv1DrugName as arv1DrugName,
    @arv1DrugQuantity as arv1DrugQuantity,
    @arv2Name as arv2Name,
    @arv2DrugName as arv2DrugName,
    @arv2DrugQuantity as arv2DrugQuantity,
    @arv3Name as arv3Name,
    @arv3DrugName as arv3DrugName,
    @arv3DrugQuantity as arv3DrugQuantity
;
