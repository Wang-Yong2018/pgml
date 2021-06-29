WITH source AS (
   SELECT
        dataset,
        passengerid,
        fare,
        ticket,
        avg(fare) over (partition by titles_refined_fe_1 ) avg_fare,
        titles_refined_fe_1 as title_id
    from
    	{{ref('stg_all')}}  inner join {{ref('titles_refined')}}  
        using(passengerid,dataset)
),
fillna_fare as (
    select 
        dataset,
        passengerid,
        coalesce(fare, avg_fare,0) as fare
    from source
)
select
    dataset,
    passengerid,
    log(1+fare) as fare_fe_1 -- log1p to normalize the fare skew
from
    fillna_fare
order by
    passengerid
