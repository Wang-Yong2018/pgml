with source as (
    select *
    from {{ source('titanic', 'train') }}
)
select *
from source