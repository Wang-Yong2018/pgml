select
    dataset,
    passengerid,
    survived
from
    {{ ref ('stg_all')}}
