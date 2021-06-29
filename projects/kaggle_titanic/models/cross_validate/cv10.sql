with tmp as (
	select 
		ceil(row_number() over( order by  random())%10) +1  cv_id, passengerid
	from 
		{{ref('stg_train')}}
	order by 
		passengerid
)
select * from tmp