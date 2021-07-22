--explain (analyze , buffers, verbose)
with tmp as 
	(
		select 
			row_id, 
			array_remove(arr_value,null)  as arr_value
		from 
			{{ref('train_1_fe_arr')}}
	)
select 
	row_id,
	array_to_min(arr_value),
	array_to_median(arr_value)::int4,
	array_to_mean(arr_value)::int4,
	array_to_max(arr_value),

	array_to_skewness(arr_value),
	array_to_kurtosis(arr_value), 
	array_to_hist(arr_value,0::real, 50::real,20)

from tmp