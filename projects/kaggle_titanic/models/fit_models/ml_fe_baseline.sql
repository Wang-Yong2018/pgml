-- depends_on {{ref('stg_train_fe_baseline')}}
{%- set clf_names = get_ml_names() -%}
{%- set latest_ml = get_latest_ml() -%}
{%set fe_source = 'stg_train_fe_baseline' %}
with data_source as (
    select 1 from {{fe_source}} limit 0
),
combined_results as (
    {% for clf_name in clf_names %}
    SELECT * from {{latest_ml}}( '{{clf_name}}', '{{fe_source}}', 'passengerid', 'survived') 
    {% if not loop.last %} union all {% endif %}{% endfor %}
)

select * from combined_results