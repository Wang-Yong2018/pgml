{% macro drop_functions() %}
  {% set query %}
    drop function if exists get_cv_result_v2(text,text,text,text,text,smallint);
    drop type if exists  type_ml_result CASCADE ;
  {% endset %}

  {% do run_query(query) %}
{% endmacro %}