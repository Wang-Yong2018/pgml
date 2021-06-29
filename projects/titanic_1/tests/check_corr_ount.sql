with tmp as (
    select 
    count(*) as cnt
   from {{ref('get_corr')}}
    
)
select * from tmp where cnt <=10 
