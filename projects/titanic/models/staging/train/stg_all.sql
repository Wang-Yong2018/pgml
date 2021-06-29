with source as (
    select 
        'train' as dataset,
        passengerid ,
        survived ,
        pclass ,name ,sex ,age ,sibsp ,parch ,ticket ,fare ,cabin ,embarked 
    from {{ source('titanic', 'train') }}
    union all
    select 
        'test' as dataset,
        passengerid ,
        Null as survived ,
        pclass ,name ,sex ,age ,sibsp ,parch ,ticket ,fare ,cabin ,embarked 
    from {{ source('titanic', 'test') }}
)
select *
from source