CREATE TABLE all_lab_results${tableSuffix}
(
    patient_id               INT,
    emr_id                   VARCHAR(50),
    loc_registered           TEXT,
    unknown_patient          VARCHAR(50),
    gender                   VARCHAR(11),
    age_at_enc               FLOAT,
    department               VARCHAR(255),
    commune                  VARCHAR(255),
    section                  VARCHAR(255),
    locality                 VARCHAR(255),
    street_landmark          VARCHAR(255),
    order_number             VARCHAR(50),
    orderable                VARCHAR(255),
    test                     VARCHAR(255),
    lab_id                   VARCHAR(50),
    LOINC                    VARCHAR(50),
    specimen_collection_date DATE,
    results_date             DATE,
    results_entry_date       DATETIME,
    result                   VARCHAR(255),
    units                    VARCHAR(11),
    reason_not_performed     VARCHAR(255),
    site                     VARCHAR(50),
    partition_num            INT
)
    ON psSite
(
    partition_num
);