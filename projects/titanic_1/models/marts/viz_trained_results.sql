{%- set ml_results =get_ml_results_names() -%}

-- depends on: {{ ref('ml_fe_baseline') }}
-- depends on: {{ ref('ml_fe_baseline_sex') }}
-- depends on: {{ ref('ml_fe_baseline_title') }}
-- depends on: {{ ref('ml_fe_baseline_title_refined') }}
-- depends on: {{ ref('ml_fe_combined') }}
-- depends on: {{ ref('ml_fe_benchmark_819p') }}


with combined_results as (

{% for ml_result in ml_results %}
    select '{{ml_result}}' as fe_source, * from public_models.{{ml_result}}
    {% if not loop.last %}union all{% endif %} {% endfor %}
)
select * from combined_results