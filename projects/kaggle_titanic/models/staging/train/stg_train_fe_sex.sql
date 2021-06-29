WITH base_0 AS (
    SELECT
        *
    FROM
        {{ ref('stg_train_fe_baseline') }}
),
dim_sex AS (
    SELECT
       * 
    FROM
        {{ ref('sex') }}
) select 
    base.*, ds.sex_fe_1
FROM
    base_0 AS base
    INNER JOIN dim_sex AS ds
    ON base.passengerid = ds.passengerid
