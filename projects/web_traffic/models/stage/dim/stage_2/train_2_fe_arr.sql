with 
source as 
(
	select 
		row_id,
		ARRAY(SELECT nullif(tsv.value,'NaN') 
			
		from jsonb_each_text(ts) tsv)::float4[] as arr_value
	from 
		{{ref('train_2_raw')}} as rp		
)
select 
	row_id, 
	arr_value,array_length(arr_value,1)::smallint as arr_length,
	-1 = any(arr_value) is null as is_contain_null
from source
order by 1