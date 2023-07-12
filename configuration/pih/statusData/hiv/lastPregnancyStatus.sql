# Gender
select gender into @gender from person where person_id = @patientId;


# Estimated delivery date
select o.value_datetime into @edd 
from obs o
where o.obs_id = latest_obs(@patientId, 'PIH', '5596')
and o.voided = 0;

select
  @gender as gender,
    if(@edd > now(),date(@edd),null) as estimatedDeliveryDate;