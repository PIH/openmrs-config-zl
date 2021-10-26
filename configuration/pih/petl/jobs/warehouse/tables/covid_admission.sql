CREATE TABLE covid_admission${tableSuffix}
(
    encounter_id                 INT,
    patient_id                   INT,
    encounter_datetime           DATETIME,
    health_care_worker           VARCHAR(11),
    health_care_worker_type      VARCHAR(255),
    home_medications             TEXT,
    allergies                    TEXT,
    symptom_start_date           DATE,
    comorbidities                VARCHAR(11),
    diabetes_type1               VARCHAR(11),
    diabetes_type2               VARCHAR(11),
    hypertension                 VARCHAR(11),
    epilepsy                     VARCHAR(11),
    sickle_cell_anemia           VARCHAR(11),
    rheumatic_heart_disease      VARCHAR(11),
    hiv_disease                  VARCHAR(11),
    chronic_kidney_disease       VARCHAR(11),
    asthma                       VARCHAR(11),
    copd                         VARCHAR(11),
    tuberculosis                 VARCHAR(11),
    cardiomyopathy               VARCHAR(11),
    stroke                       VARCHAR(11),
    malnutrition                 VARCHAR(11),
    psychosis                    VARCHAR(11),
    substance_abuse              VARCHAR(11),
    other_comorbidity            VARCHAR(11),
    other_comorbidity_specified  TEXT,
    other_mental_health          TEXT,
    tobacco                      VARCHAR(255),
    transfer_from_other_facility VARCHAR(11),
    transfer_facility_name       TEXT,
    contact_case_14d             VARCHAR(11),
    site                         VARCHAR(50),
    partition_num                INT
)
    ON psSite
(
    partition_num
);