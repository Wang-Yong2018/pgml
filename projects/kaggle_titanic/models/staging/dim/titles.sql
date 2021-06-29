WITH source AS (
    SELECT
        dataset,
        passengerid,
        SUBSTRING(
            NAME,
            ' ([a-zA-Z]+)\.'
        ) AS title
    FROM
        {{ ref(
            'stg_all'
        ) }}
)
SELECT
    dataset,
    passengerid,
    DENSE_RANK() over( ORDER BY title) AS titles_fe_1
FROM
    source