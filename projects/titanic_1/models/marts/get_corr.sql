{%- set col_names = adapter.get_columns_in_relation(ref('stg_combined_fe')) -%}

with v_corr as (
       {% for col in col_names %}
       {% if (col.name != "dataset") and (col.name != "passengerid") %}
       select  '{{col.name}}' as column_name, corr({{col.name}},survived) as corr from {{ref('stg_combined_fe')}}
       {% if not loop.last %} union all {% endif %}
       {% endif %}
       {% endfor %}
 )
select * from v_corr

-- depends_on: {{ref('stg_combined_fe')}}