{% macro create_types() %}

create schema if not exists {{target.schema}};
{{create_stat_agg() }};
{{create_ml_result_type() }};
{% endmacro %}
