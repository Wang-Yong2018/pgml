with source as 
(
	select 
		* 
	from 
		{{ref('train_1_raw')}}
	 where 
	 	row_id =1
)
select 
	row_number() over() as date_id,
	key::date as date
from 
	source as rp,
	jsonb_each_text(rp.ts) as tsv