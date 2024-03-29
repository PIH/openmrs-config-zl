-- this script resolves UHM-6635
-- It sets ther encounter datetime of registration encounter 
-- to the earliest encounter for that patient
-- (not including drug documentation and comment encounters) 


select encounter_type_id into @registrationEncId from encounter_type et where uuid = '873f968a-73a8-4f9c-ac78-9f4778b751b6';
select encounter_type_id into @drugDocEncId from encounter_type et where uuid = '0b242b71-5b60-11eb-8f5a-0242ac110002';
select encounter_type_id into @commentEncId from encounter_type et where uuid = 'c30d6e06-0f00-460a-8f81-3c39a1853b56';

drop temporary table if exists temp_registration_encounters ;
create temporary table temp_registration_encounters
(encounter_id int(11),
patient_id int(11),
min_encounter_datetime datetime
);


-- load encounters into temp table that need to be updated
insert into temp_registration_encounters (encounter_id, patient_id)
select encounter_id, patient_id   
from encounter e 
where e.encounter_type = @registrationEncId
and e.voided = 0
and EXISTS 
	(select 1 from encounter e2
	where e2.voided = 0
	and e2.patient_id = e.patient_id 
	and e2.encounter_type not in (@drugDocEncId, @commentEncId)
	and date(e2.encounter_datetime) < date(e.encounter_datetime) )
;

-- update min encounter_datetime on temp table   
update temp_registration_encounters t 
set t.min_encounter_datetime = (select min(encounter_datetime) from encounter e where e.patient_id = t.patient_id )
;

-- update encounter table
update encounter e
inner join temp_registration_encounters t on e.encounter_id = t.encounter_id
set e.encounter_datetime = t.min_encounter_datetime,
	e.date_changed = now(),
	e.changed_by  = 1 -- Super User person ID
;

-- update obs table
update obs o
inner join temp_registration_encounters t on o.encounter_id = t.encounter_id
set o.obs_datetime = t.min_encounter_datetime
;
 
drop temporary table if exists temp_registration_encounters ;
