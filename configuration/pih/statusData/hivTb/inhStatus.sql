# This retrieves all of the data points needed to provide information as to the INH Prophylaxis for the patient

select concept_from_mapping('PIH', '14534') into @inhStartDate;
select concept_from_mapping('PIH', '14535') into @inhEndDate;


select     value_datetime into @startDate
from        obs o
join        encounter e on e.encounter_id=o.encounter_id
where       e.patient_id = @patientId
and         o.voided = 0
and         o.concept_id = @inhStartDate;

select     value_datetime into @endDate
from        obs o
join        encounter e on e.encounter_id=o.encounter_id
where       e.patient_id = @patientId
and         o.voided = 0
and         o.concept_id = @inhEndDate;

select
    date(@startDate) as startDate,
    date(@endDate) as endDate,
    if(@endDate > now(), 0, 1) as isCompleted,
    if(@startDate > now(), 'future', if(@endDate > now(), 'active', 'completed')) as status,
    datediff(ifnull(@endDate, now()), @startDate)+1 as duration
;
