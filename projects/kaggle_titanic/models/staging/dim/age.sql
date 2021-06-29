WITH source AS (
   SELECT
        dataset,
        passengerid,
        age,
        avg(age) over (partition by titles_refined_fe_1 ) as avg_age,
        titles_refined_fe_1 as title_id
    from
    	{{ref('stg_all')}}  inner join 
        {{ref('titles_refined') }}  
        using(passengerid,dataset)
),
fillna_age as (
    select 
        dataset,
        passengerid,
        coalesce(age, avg_age) as age
    from source
)
select 
    dataset, passengerid, 
    age as age_fe_1
from
   fillna_age 