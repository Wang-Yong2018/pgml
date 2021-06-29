{% set good_score=0.1 %}
with good_features as (
select 
	max(column_name) as column_name,
    abs(corr) as abs_corr
from {{ref('get_corr')}}
where abs(corr) > {{good_score}}
      and column_name not in ('survived','passengerid')
group by corr
)
select * from good_features 
