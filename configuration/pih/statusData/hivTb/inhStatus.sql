# This retrieves all of the data points needed to provide information as to the INH Prophylaxis for the patient

select concept_from_mapping('CIEL', '78280') into @inh;

select      ifnull(o.scheduled_date, o.date_activated),
            ifnull(o.date_stopped, o.auto_expire_date)
            into @startDate, @endDate
from        orders o
where       o.patient_id = @patientId
and         o.voided = 0
and         o.order_action != 'DISCONTINUE'
and         o.concept_id = @inh
order by    ifnull(o.scheduled_date, o.date_activated) desc
limit 1
;

select
    date(@startDate) as startDate,
    date(@endDate) as endDate,
    if(@endDate > now(), 0, 1) as isCompleted,
    if(@startDate > now(), 'future', if(@endDate > now(), 'active', 'completed')) as status,
    datediff(ifnull(@endDate, now()), @startDate)+1 as duration
;
