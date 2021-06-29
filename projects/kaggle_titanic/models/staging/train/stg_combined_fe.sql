{% set fe_models = dbt_utils.get_relations_by_pattern(schema_pattern ='public_fe', table_pattern = '%', exclude ='target' ) %}

with source as (
    select *
    from 
       {{ref('target')}}
        {% for fe_model in fe_models %}
            inner join {{fe_model}} using (dataset,passengerid) 
        {% endfor %}
)
select * from source 

-- depends_on: {{ ref('cabin')}}
-- depends_on: {{ ref('fare')}}
-- depends_on: {{ ref('is_alone')}}
-- depends_on: {{ ref('sex')}}
-- depends_on: {{ ref('ticket')}}
-- depends_on: {{ ref('titles')}}
-- depends_on: {{ ref('titles_refined')}}
-- depends_on: {{ ref('age')}}
-- depends_on: {{ ref('embarked')}}
-- depends_on: {{ ref('text_cols')}}
