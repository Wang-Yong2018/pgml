with 
source as (
	select
	dataset,
        passengerid,
        embarked
    from
       {{ref('stg_all')}}
),
most_embark as (
	select 
		mode() within group (order by embarked) as embarked_mode
	from source
),
combined_source as (
	select t0.dataset,
		t0.passengerid, 
		   t0.embarked, 
		   t1.embarked_mode,
		   coalesce(t0.embarked, t1.embarked_mode) as embarked_fe_1
	from source t0, most_embark t1
 ),
embark_fe as ( 
	select 
		dataset,
		passengerid,
		DENSE_RANK() over( ORDER BY embarked_fe_1) AS embarked_fe_1
	from combined_source
)
select * from embark_fe