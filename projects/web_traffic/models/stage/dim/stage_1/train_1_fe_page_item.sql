with source as (
select 
	row_id,
	reverse(page) as rev_page,
	--"Id" as page_id,
	length(page) as page_length
from 
	{{ref('train_1_raw')}}
),
tmp_1 as (select 
	row_id,
	--page_id,
	reverse(rev_page) as page,
	page_length,
	reverse(split_part(rev_page,'_',1)) as agent,

	reverse(split_part(rev_page,'_',2)) as access,
	reverse(split_part(rev_page,'_',3)) as project,
	left(reverse(split_part(rev_page,'_',3)),2) as lang,
	reverse(right(rev_page, -- original page string  remove the extracted feature
		 page_length-length('_'||
		 reverse(split_part(rev_page,'_',1))||'_'||
		 reverse(split_part(rev_page,'_',2))||'_'||
		 reverse(split_part(rev_page,'_',3)))
		)) as page_title,
	page_length-length('_'||
	reverse(split_part(rev_page,'_',1))||'_'||
	reverse(split_part(rev_page,'_',2))||'_'||
	reverse(split_part(rev_page,'_',3))) as title_length
--		
from source
)
select 
	row_id,
	agent, access, project,lang, page_title,title_length,page

from tmp_1

{{
config({
    "post-hook": [
		"drop index if exists {{model['schema']}}.ix_brin_t1fpi cascade ; create index ix_brin_t1fpi on {{this}} using brin(agent, access, project,lang, title_length)",
		"drop index if exists {{model['schema']}}.ix_hash_t1fpi cascade ; create index ix_hash_t1fpi on {{this}} using hash(page_title)",
		],
    })
}}