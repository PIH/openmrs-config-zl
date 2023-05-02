# This retrieves all of the data points needed to provide information as to the INH Prophylaxis for the patient

select concept_from_mapping('PIH', '2739') into @currentIsoniazidConstructConceptId;
select concept_from_mapping('PIH', '1501') into @isoniazidConstructConceptId;

select      o.encounter_id into @encounterId
from        obs o
join        encounter e on e.encounter_id=o.encounter_id
where       e.patient_id =@patientId
and         o.voided = 0
and         o.concept_id = @isoniazidConstructConceptId
order by    o.obs_datetime desc
limit 1;

select      o.encounter_id into @currentEncounterId
from        obs o
join        encounter e on e.encounter_id=o.encounter_id
where       e.patient_id =@patientId
and         o.voided = 0
and         o.concept_id = @currentIsoniazidConstructConceptId
order by    o.obs_datetime desc
limit 1;

select obs_from_group_id_value_datetime(obs_group_id_of_value_coded(ifnull(@currentEncounterId,@encounterId), 'PIH',if(@currentEncounterId > 0,'2289','1282'), 'PIH','656'), 'PIH','11131') into @startDate; 

select obs_from_group_id_value_datetime(obs_group_id_of_value_coded(ifnull(@currentEncounterId,@encounterId), 'PIH',if(@currentEncounterId > 0,'2289','1282'), 'PIH','656'), 'PIH','12748') into @endDate; 

select
    date(@startDate) as startDate,
    date(@endDate) as endDate,
    if(@endDate > now(), 0, 1) as isCompleted,
    if(@startDate > now(), 'future', if(@endDate > now(), 'active', 'completed')) as status,
    datediff(ifnull(@endDate, now()),@startDate)+1 as duration;