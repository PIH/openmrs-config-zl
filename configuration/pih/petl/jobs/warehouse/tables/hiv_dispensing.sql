create table hiv_dispensing${tableSuffix}
(
    patient_id                  int,
    encounter_id                int,
    dispense_date               datetime,
    dispense_site               varchar(255),
    age_at_dispense_date        int,
    dac                         char(1),
    dispensed_to                varchar(100),
    dispensed_accompagnateur    text,
    current_art_treatment_line  varchar(255),
    current_art_line_start_date datetime,
    months_dispensed            int,
    is_current_mmd              char(1),
    next_dispense_date          datetime,
    arv_1_med                   varchar(255),
    arv_1_med_short_name        varchar(255),
    arv_1_quantity              int,
    arv_2_med                   varchar(255),
    arv_2_med_short_name        varchar(255),
    arv_2_quantity              int,
    tms_1_med                   varchar(255),
    tms_1_med_short_name        varchar(255),
    tms_1_quantity              int,
    regimen_change              char(1),
    days_late_to_pickup         int,
    regimen_match               char(1),
    dispense_date_ascending     int,
    dispense_date_descending    int,
    site                        VARCHAR(50),
    partition_num               INT
)
    ON psSite
(
    partition_num
);