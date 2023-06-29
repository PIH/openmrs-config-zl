# the last pregnancy status

# Gender
select gender into @gender from person where person_id = @patientId;

# Last menstruation date
select o.value_datetime into @lmd
from obs o
where o.obs_id = latest_obs(@patientId, 'CIEL', '1427')
and o.voided = 0;

# Estimated delivery date
select o.value_datetime into @edd 
from obs o
where o.obs_id = latest_obs(@patientId, 'PIH', '5596')
and o.voided = 0;

select
  @gender as gender,
    date(@lmd) as lastMenstrutionDate,
    date(@edd) as estimatedDeliveryDate;