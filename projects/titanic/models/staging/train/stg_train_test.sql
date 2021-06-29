with source as (

    select 'train' as table_name, passengerid,        survived,pclass,name,sex,age,sibsp,parch,ticket,fare,cabin,embarked from {{source('titanic','train')}} as t0
    union all
    select 'test' as table_name,  passengerid,NULL as survived,pclass,name,sex,age,sibsp,parch,ticket,fare,cabin,embarked from {{source('titanic','test')}} as t1

)
select * from source