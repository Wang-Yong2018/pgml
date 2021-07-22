with source as (select 
	row_number() over(order by _airbyte_ab_id) as row_id,
	_airbyte_data->>'Page'  as page,
	_airbyte_data-'Page' as ts 
from 
	{{ source('web_traffic','train_1') }}
)
select 
row_id::int4,
page,
ts
from source