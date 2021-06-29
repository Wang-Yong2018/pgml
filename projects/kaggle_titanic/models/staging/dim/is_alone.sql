with source as (
    select
        dataset,
        passengerid,
        sibsp + parch + 1 as family_size
    from
        {{ ref('stg_all') }}
)
select
        dataset,
    passengerid,
    case
        when family_size < 2 then 1
        else 0
    end as is_alone_fe_1
from
    source
