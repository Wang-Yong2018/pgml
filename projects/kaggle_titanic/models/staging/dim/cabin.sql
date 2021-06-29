with source as (
	select
	dataset,
        passengerid,
        cabin as cabin_origin,
        unnest(string_to_array(coalesce(cabin,'NA'),' ')) as unnest_cabin
    from
       {{ref('stg_all')}}
),
fe_cabin as (
select dataset, passengerid,cabin_origin,
		case when unnest_cabin ='NA' then 'NA'
				else substring(unnest_cabin,1,1)
			 end as cabin_location,
		case when unnest_cabin ='NA' then '0'
				else substring(unnest_cabin,2)
			 end as cabin_id
from source),
agg_fe as (
 select dataset, passengerid,
 		-- cabin_origin,
 		string_agg(cabin_location,'') as cabin_id,
 		string_agg(cabin_id,'') as cabin_seq
 from fe_cabin
 group by dataset,passengerid,cabin_origin
 order by passengerid
),
num_fe as ( 
 select dataset, passengerid,
 	DENSE_RANK() over( ORDER BY cabin_id) AS cabin_fe_1,
	length(cabin_id) as cabin_fe_2,
 	DENSE_RANK() over( ORDER BY cabin_seq) AS cabin_fe_3,
	length(cabin_seq) as cabin_fe_4
 from agg_fe
)
select * from num_fe