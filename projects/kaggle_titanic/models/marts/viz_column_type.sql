WITH source as (
    SELECT table_name,
        column_name,
        data_type
    FROM {{ source(
            'informatic',
            'columns'
        ) }}
    WHERE table_name in ('train', 'test')
),

tbl_describe as (
    select *
    from {{ ref('stg_describe') }}
)
SELECT 
    s.table_name,
    s.column_name,
    s.data_type,
    td.null_frac,
    td.avg_width,
    td.n_distinct,
    td.most_common_val
FROM source as s
    inner join tbl_describe as td on s.table_name = td.table_name
    and s.column_name = td.att_name