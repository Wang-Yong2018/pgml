WITH source AS (
    SELECT
        passengerid,
        age,
        fare,
        pclass,
        sibsp,
        parch,
        survived
    FROM
        {{ ref('stg_all') }}
    where dataset ='train'
),

fillna_source AS (
    SELECT
        passengerid,
        COALESCE(age,avg(age) over(), 0) AS age,
        COALESCE(fare,avg(fare) over(), 0) AS fare,
        COALESCE(pclass::float,avg(pclass) over(), 3.0) AS pclass,
        COALESCE(sibsp::float, avg(sibsp) over(), 0.0) AS sibsp,
        COALESCE(parch::float, avg(parch) over(), 0.0) AS parch,
        survived
    FROM
        source)
    SELECT
        *
    FROM
        fillna_source
