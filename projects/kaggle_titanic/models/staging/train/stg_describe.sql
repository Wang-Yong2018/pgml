{% set num_cols = ['passengerid','pclass', 'age', 'sibsp', 'parch','fare'] %}
{% set text_cols = ['name','sex','ticket','cabin','embarked'] %}

with source as (
    select
        --schemaname,
        tablename as table_name,
        attname as att_name,
        -- inherited,
        null_frac,
        avg_width,
        n_distinct
    from
        {{ source( 'db', 'pg_stats'
        ) }}
    where
        schemaname = 'public' and tablename in ('train','test') 
),
mode_val as ({% for col in text_cols %}
select
    table_name, '{{col}}' as att_name, 'text' as col_type,
    mode() within group ( order by {{ col }}) as most_common_val
from {{ ref('stg_train_test') }} group by table_name
    {% if not loop.last %} union all {% endif %}
{% endfor %}),

stat_agg_val as ({% for col in num_cols %}
    select 
    table_name, '{{col}}' as att_name, 'number' as col_type,
    (stats_agg({{col}})).* 
from {{ ref('stg_train_test') }} group by table_name
{% if not loop.last %}union all{% endif %}
{% endfor %})
select 
    t0.*, 
    t1.most_common_val,
    t2.count,t2.min,t2.max,t2.mean,t2.variance,t2.skewness,t2.kurtosis 
from source t0 left join mode_val t1 
        on t0.table_name = t1.table_name and t0.att_name = t1.att_name
               left join stat_agg_val t2 
        on t0.table_name = t2.table_name and t0.att_name = t2.att_name
