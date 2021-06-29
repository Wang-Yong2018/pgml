with tmp as (
select ml_name, create_time, avg(test_mean_score) as cv_score
from {{ ref('ml_fe_combined')}} 
where create_time > now()- interval '1 hours'
group by ml_name, create_time
)

select * from tmp where cv_score <0.79