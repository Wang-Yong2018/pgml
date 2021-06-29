{% macro create_udfs() %}

create schema if not exists {{target.schema}};
{{create_languages()}};
{# -- {{get_ml_result()}} #};
{# -- {{get_cv_result()}} #};
{# -- {get_cv_result_v2()}} #};
{# -- {get_cv_result_v4()}} #};
{# -- {get_cv_result_v5()}} #};
{# -- {get_cv_result_v6()}} #};
{# -- {get_cv_result_v6()}} #};
{# -- {get_cv_result_v7()}} #};
{# -- {get_cv_result_v8()}} #};
{{get_cv_result_v9()}};
{{create_stat_agg()}};
{{get_py_path()}};
{% endmacro %}