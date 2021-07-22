{{ config(
    indexes=[
      {'columns': ['agent', 'access', 'project', 'lang','title_length'], 'type': 'brin'},
      {'columns': ['page_title'], 'type': 'hash'},

    ]
)}}

with source as (
	select 
		agent, access, project, lang, page_title,title_length,
		count(*) as cnt 
	from 
		public_fe.key_2_fe_page_item kfpi
	group by 
		agent, access, project, lang, page_title,title_length
)
select 
	*
from source
