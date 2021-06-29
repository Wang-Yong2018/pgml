with source as (
    select *
    from {{ source('titanic', 'test') }}
)
select *
from source