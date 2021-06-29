WITH base_0 AS (
    SELECT
       *
    FROM
        {{ ref('stg_train_fe_baseline') }}
),
dim_title AS (
    SELECT
        *
    FROM
        {{ ref('titles') }}
) 
select base.*, title.titles_fe_1
FROM
    base_0 AS base
    INNER JOIN dim_title AS title
    on base.passengerid = title.passengerid