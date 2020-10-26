SELECT
    warning_type,
    count(*) as count,
    NOW() as timestamp
FROM hivmigration_data_warnings
GROUP BY warning_type
