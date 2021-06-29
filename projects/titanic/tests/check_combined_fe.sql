with tmp as ( 
    select * from {{ref('stg_combined_fe')}} 
    where dataset = 'train'
    )
select
    1 
from
   tmp t
where
    not (
        t is not NULL
    )
    
