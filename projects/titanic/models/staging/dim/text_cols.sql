{% set text_cols = ['name','sex','ticket','cabin','embarked'] %}
select
    dataset,
    passengerid,
    {% for col in text_cols %}
        DENSE_RANK() over(
            ORDER BY
                {{ col }}
        ) AS {{ col }}_text_col

        {% if not loop.last %},
        {% endif %}
    {% endfor %}
from
    {{ ref('stg_all') }}
