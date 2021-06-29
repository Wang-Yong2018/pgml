WITH source AS (
    SELECT
        dataset,
        passengerid,
        sex
    FROM
        {{ ref(
            'stg_all'
        ) }}
)
SELECT
    dataset,
    passengerid,
    DENSE_RANK() over(
        ORDER BY
            sex
    ) AS sex_fe_1
FROM
    source
