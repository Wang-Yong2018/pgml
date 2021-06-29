Another Machine Learning way 

Data Science by Data build tools & Postgres

The typical machine learning mode is pull data from datasource, and run it in jupyter or other similar IDE. It is popular but facing following challenge:
1. Gained data privacy concern : currently, machine learning need pull all(or big simple rate) data from data source. It should be big concern about data privacy. or leak data. as the regulation strict, the concern will be more and more for data owners.
2. limited featuring engineering colaboration:  to improve the trained model accuracy, feature engineering is important. it is dirty and hard work. Though kaggle has helped share brilliant feature engineering idea about many dataset. It is time to think how to let a group of people to work on feature engineering and assign work always.
3. hard to handle complex issue: based on the juputer notebook, a small data science case could be done smoothly. if the data is big and the case is complex, the jupyter notebook will be from hundres of line to thousand and more lines. Though the python or R code could be split into class or functions, the jupyter based data science project look hard to understand and handle those complex concern.
4. lack of testing: Before a data science case jupyter notebook ready, it may need many tests for data, functions and classes.  people can write test snippest inside jupyter notebook. soon or later, those snippest are difficult to find or manucipate. And data science has to run the test manually after found those  test snippest.
5. lack of module lineage and document:  Though luckly got the trained model with expect score, the juputer note book is difficult read and found how those model was trained and which feature engineering contributed to the best modules. Some data scientists manually write docuement or draw diagram to show them. It spent extra time and the module lineage might out of data afte module refined.
6. often memeory overload: when facing big data machin learning, the featuring engineering use memory, the data manucipate need manage, the traning need memory, after rounds of works, data scientist has to release memory for unused data setts. Those gabage collection are always difficult and lead to upset.

DBT based machine learning way could solve above problems:
1. data privacy concern :  the machine learning was converted to UDF(user defined function) inside the datawarehouse/lake. There is no need to pull data outside. Data scientist could use all data in the datawarehouse. The concers of data owner for 

2. limited featuring engineering colaboration:
3. hard to handle complex issue: 
4. lack of testing: 
5. lack of module lineage and document:
6. often memeory overload:

For small data, pull data from data 
This is a try to run Kaggle dataset machine learning inside Database and with DBT.

Database helps store and computer.
DBT helps to do version control, test and documentation.
Superset help to visualize the data & model in easy understand way.