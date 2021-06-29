WITH schema_map as (
    select
        schemaname as schema,
        tablename as name,
        'Table' as Type,
        CASE
            WHEN schemaname like '%dbt%' THEN 1
            ELSE 0
        END as dbt_created
    from
        pg_tables
    WHERE
        NOT schemaname = ANY('{information_schema,pg_catalog}')
    UNION
    select
        schemaname as schema,
        viewname as name,
        'View' as Type,
        CASE
            WHEN schemaname like '%dbt%' THEN 1
            ELSE 0
        END as dbt_created
    from
        pg_views
    WHERE
        NOT schemaname = ANY('{information_schema,pg_catalog}')
)
SELECT
    count(name) as total_tables_and_views,
    sum(dbt_created) as dbt_created,
    to_char((sum(dbt_created) :: dec / count(name) :: dec) * 100, '999D99%') as dbt_coverage
FROM
    schema_map
