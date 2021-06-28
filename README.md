# pgml

## what is pgml
pgml is postgresql machine learning tools. It combined the advantage of postgresql and machine learning power together
by :

* install popular machine learning modules like sklearn, lightgbm, scipy, numpy, pandas and etc co-located with
postgresql database(we call it as datawarehouse).
* computer the data insides of database by postgres UDF. it is write in plpython3( one server programm lanugage).
* in this way, the data can be read inside postgresql and utilize the machine learning lib power.
* last but not least, all of above are built inside of docker image. It can easily move and revised at local or in the
cloud.

## Getting start

### requirements:

*. centos/debian linux system with docker/docker-compose installed.
*. windows10 system with docker desktop installed. 

### Steps:

* git clone <the pgml git address>
* change to the cloned folder it might be <prefix>/pgml
* docker-compose up -d
* docker-compose exec pgml psql -U postgres -c 'select get_python_version()' 

if every thing is smooth, you will get 'python 3.7.5' prompt at the end.

### how to use the pgml tool

#### hard mode
1. write postgresql UDF by plpython3u. Inside of UDF, you can write it like normal python script or functions. 
2. call the writed UDF in sql
3. get the result.

#### easy mode
You can use DBT + vscode ide. It will make life and work easy. 
DBT is a data built tool which focused on data
transformation with data lineage, test, and DAG. With DBT, You can still write SQL and gain quality control, documents
and team work.
VScode is a popular IDE. Both python, Sql, and DBT can work inside it. you can use python extension, dbt extension as
well as git extension.
Last but not least, Vscode can work remotely with docker-compose. 

That's all!

If you like pgml, pls click like. Any idea is welcomed.

WangYong
2021-6-28

