# This retrieves the Appointment Date Obs from the most recent HIV encounter

set @hivIntake = encounter_type('${encounterType.HIV_INTAKE.uuid}');
set @hivFollowup = encounter_type('${encounterType.HIV_FOLLOWUP.uuid}');
set @eidFollowup = encounter_type('${encounterType.EID_FOLLOWUP.uuid}');
set @pmtctIntake = encounter_type('${encounterType.PMTCT_INTAKE.uuid}');
set @pmtctFollowup = encounter_type('${encounterType.PMTCT_FOLLOWUP.uuid}');

select q1.value_datetime as nextPickupDate
from patient p
left join
     (
         select o.person_id, o.value_datetime
         from obs o
                  inner join encounter e on o.encounter_id = e.encounter_id
         where o.concept_id = concept_from_mapping('PIH', '5096')
           and e.encounter_type in (@hivIntake, @hivFollowup, @eidFollowup, @pmtctIntake, @pmtctFollowup)
           and o.voided = 0
           and e.voided = 0
           and o.person_id = @patientId
         order by e.encounter_datetime desc
         limit 1
     ) q1 on p.patient_id = q1.person_id
where p.patient_id = @patientId
;