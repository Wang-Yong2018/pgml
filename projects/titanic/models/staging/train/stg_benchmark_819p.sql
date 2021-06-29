with source as ( 
    select 
        passengerid+1 as passengerid, survived, pclass, sex, age, fare, embarked, title, isalone, age_class
    from
        benchmark
)
select * from source