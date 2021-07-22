with tmp as (
	select distinct date::date,  'key_1' as source    from {{ref('key_1_fe_page_item')}}
	union all
	select distinct date::date,  'key_2' as source    from {{ref('key_2_fe_page_item')}}
	union all
	select distinct date::date,  'train_1' as source  from {{ref('train_1_fe_date')}}
	union all
	select distinct date::date,  'train_2' as source  from {{ref('train_2_fe_date')}}
)
select source, date from tmp


{{ config(
    materialized = 'table',
    indexes=[
      {'columns': ['source','date'], 'type': 'brin'},
    ]
)}}