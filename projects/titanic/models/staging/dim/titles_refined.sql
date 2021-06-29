WITH source AS (
    SELECT
        dataset,
        passengerid,
        SUBSTRING(
            NAME,
            ' ([a-zA-Z]+)\.'
        ) AS title
    FROM
        {{ref('stg_all')}}
),
less_titles as (
    SELECT
        dataset,
        passengerid,
        case
            when title in (
                'Mlle',
                'Ms'
            ) then 'Miss'
            when title in ('Mme') then 'Mrs'
            when title in (
                'Lady',
                'Countess',
                'Capt',
                'Col',
                'Don',
                'Dr',
                'Major',
                'Rev',
                'Sir',
                'Jonkheer',
                'Dona'
            ) then 'Rare'
            else title
        end as title
    from
       source 
),
refined_title as (
    select
        dataset,
        passengerid,
        DENSE_RANK() over(
            ORDER BY
                title
        ) AS title
    FROM
        less_titles
)
select
    dataset,
   passengerid, title as titles_refined_fe_1
from
    refined_title