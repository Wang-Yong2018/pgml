{% macro get_ml_results_names() %}
{{ return(['ml_fe_baseline',
           'ml_fe_baseline_sex',
           'ml_fe_baseline_title',
           'ml_fe_baseline_title_refined',
           'ml_fe_combined',
           'ml_fe_benchmark_819p',
           ])
}}
{% endmacro %}