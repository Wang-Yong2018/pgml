with source as (
    select
        dataset,
        passengerid,
        ticket,
        string_to_array(
            ticket,
            ' '
        ) as ticket_arr,
        array_length(string_to_array(ticket, ' '), 1) as arr_len
    from
        {{ ref('stg_all') }}
),
source_fe as (
    select
        dataset,
        passengerid,
        ticket,
        -- arr_len,
        ticket_arr [arr_len] as ticket_id,
        case
            when arr_len in (
                2,
                3,
                4,
                5
            ) then array_to_string(
                ticket_arr [1:arr_len-1],
                ' '
            )
            when arr_len in (1) then 'NO'
        end as ticket_prefix
    from
        source
),
num_fe as (
select
        dataset,
    passengerid, 
    length(ticket) as ticket_fe_1,
    DENSE_RANK() over( ORDER BY ticket_id) AS ticket_fe_2,
    length(ticket_id) as ticket_fe_3,
    DENSE_RANK() over( ORDER BY ticket_prefix) AS ticket_fe_4,
    length(ticket_prefix) as ticket_fe_5
from
    source_fe
)
select * from num_fe
