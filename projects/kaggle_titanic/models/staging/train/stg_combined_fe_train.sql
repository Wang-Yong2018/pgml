{%- set col_names = adapter.get_columns_in_relation(ref('stg_combined_fe')) -%}

with source as (
    select 
       {% for col in col_names %}
       {% if  col.name != 'dataset' %} {{col.name}} 
       {% if not loop.last %},{% endif %}
       {% endif %}
       {% endfor %}

    from 
        {{ref('stg_combined_fe')}}
    where dataset ='train'
)
select * from source