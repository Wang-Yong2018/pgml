with tmp as (
	select 
		ml_name, fe_source, total_second ,
		train_mean_score ,test_mean_score, create_time 
		-- jsonb_pretty(clf_obj->'dropped_feature'),
		-- jsonb_pretty(clf_obj->'feature_importance'),
		-- jsonb_Pretty(clf_obj)
	from 
		{{ref('viz_trained_results')}}
	where 
		create_time > now() - interval '6 hours' -- recent record
		and (	 (train_mean_score <= 0.847  -- poor learning 
					or test_mean_score <= 0.79 -- poor generalized )
						or 
				total_second >3  --long working duration
			)
			)
)
select * from tmp