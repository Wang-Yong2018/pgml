{{ config(
    materialized = 'table',
    indexes=[
      {'columns': ['today','row_id'], 'type': 'brin'},
    ]
)}}

with tmp as (select * 
from {{ref('train_1_raw')}} 
limit 100
),
tmp_1 as (
  select
	row_id, 
  row_number() over (partition by row_id order by key )::int2 date_id ,
	lag(key) over( partition by row_id order by value)::date as yesterday,
  tsv.key::date as today, 
  tsv.value::float4 as nclick 
from 
	tmp,jsonb_each_text(ts) as tsv
)
select 
  row_id,  
  date_id,
  today,
  yesterday,
  nclick
from tmp_1
