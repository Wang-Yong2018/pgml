with source as (
    select passengerid,
        survived::text,
        pclass::text,
        name,
        sex,
        age,
        sibsp::boolean,
        parch::boolean,
        ticket,
        fare,
        cabin::text,
        embarked::text
    from {{ ref('stg_train') }}
)
select *
from source