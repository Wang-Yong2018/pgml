with source as (
select 
	row_number() over() as row_id,
	"Id" as page_id,
	page,
	reverse(page) as rev_page,
	length(page) as page_length
from 
	{{ source('web_traffic','key_2') }}
),
tmp_1 as (
select
	row_id,
	page_id,
	page_length,
	reverse(split_part(rev_page,'_',1)) as date,
	reverse(split_part(rev_page,'_',2)) as agent,
	reverse(split_part(rev_page,'_',3)) as access,
	reverse(split_part(rev_page,'_',4)) as project,
	left(reverse(split_part(rev_page,'_',4)),2) as lang,
	reverse(right(rev_page, -- original page string  remove the extracted feature
		 page_length-length('_'||
		 reverse(split_part(rev_page,'_',1))||'_'||
		 reverse(split_part(rev_page,'_',2))||'_'||
		 reverse(split_part(rev_page,'_',3))||'_'||
		 reverse(split_part(rev_page,'_',4)))
		)) as page_title,
	page_length-length('_'||
	reverse(split_part(rev_page,'_',1))||'_'||
	reverse(split_part(rev_page,'_',2))||'_'||
	reverse(split_part(rev_page,'_',3))||'_'||
	reverse(split_part(rev_page,'_',4))) as title_length
from source
)
select 
	row_id,
	page_id,
	date,lang, agent, access, project,
	page_title,
	title_length
from tmp_1


{{
config({
    "post-hook": [
		"drop index if exists {{model['schema']}}.ix_brin_k2fpi cascade ; create index ix_brin_k2fpi on {{this}} using brin(date,agent, access, project,lang, title_length)",
		"drop index if exists {{model['schema']}}.ix_hash_k2fpi cascade ; create index ix_hash_k2fpi on {{this}} using hash(page_title)",
		],
    })
}}