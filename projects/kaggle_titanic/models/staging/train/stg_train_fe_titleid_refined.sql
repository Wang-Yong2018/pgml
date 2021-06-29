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
        {{ ref('titles_refined') }}
)
select
    base.*, dt.titles_refined_fe_1 
FROM
    base_0 as base inner join dim_title  as dt
    on base.passengerid = dt.passengerid