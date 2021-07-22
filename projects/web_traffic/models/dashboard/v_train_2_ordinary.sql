{{ config(
    materialized = 'table',
    indexes=[
      {'columns': ['today','row_id'], 'type': 'brin'},
    ]
)}}

with tmp as (select * 
from {{ref('train_2_raw')}}
),
tmp_1 as (
  select
	row_id, 
  tsv.key::date as date, 
  tsv.value::float4 as nclick 
from 
	tmp,jsonb_each_text(ts) as tsv
)
select 
  row_id,  
	lag(date) over( partition by row_id order by date) as yesterday
  date as today,
  nclick
from tmp_1
