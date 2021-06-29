{% macro get_ml_result() %}
    create
    or replace function {{target.schema }}.get_ml_result(clf_name text, table_name text, id_col text, y_col text) 
    returns type_ml_result
    as $$ 
    # sys lib
    import json
    import datetime
    from dataclasses import dataclass, asdict
    from collections import OrderedDict, defaultdict

    # data lib
    from scipy import stats
    import pandas as pd
    import numpy as np

    # ml lib
    from sklearn.preprocessing import StandardScaler
    from sklearn.ensemble import RandomForestClassifier
    from sklearn.linear_model import RidgeClassifier
    from sklearn.svm import LinearSVC
    from sklearn.linear_model import SGDClassifier
    from sklearn.ensemble import RandomForestClassifier
    from sklearn.pipeline import make_pipeline
    from sklearn.metrics import accuracy_score, precision_score, roc_auc_score

    from lightgbm import LGBMClassifier


    N_JOBS = 3 # limit using 2 cpu
    SCORE_TYPE = 'accuracy'

    # init the ml training result
    @dataclass
    class MLResult:
        ml_name ='sk_randomforest'
        score_type = SCORE_TYPE
        score_val = 0.0
        create_time = pd.Timestamp.now()
        x_col_names=[]
        x_rows=0
        is_trained = False
        seconds = 0.0
        clf_obj = None

    start_time = datetime.datetime.now()

    ml_result = MLResult()

    # get x, y dataset 
    drop_cols = [y_col,id_col]
    sql_plan= plpy.prepare(f""" select * from {table_name} """)
    
    sql_data = plpy.execute(sql_plan)
    df = pd.DataFrame.from_records(sql_data)
    y = df [y_col]
    x = df.drop(columns=drop_cols)

    # performance debug only
    current_time = datetime.datetime.now()
    sql_time = current_time - start_time
    sql_seconds = sql_time.total_seconds() 
    # debug end 

    # training & scoring    
    clfs = {
        "SVC": LinearSVC(),
        "SGD": SGDClassifier(),
        "RANDOMFOREST": RandomForestClassifier(),
        "RIDGECLASSIFIER": RidgeClassifier(tol=1e-2, solver="sag"),
        'LIGHTGBM': LGBMClassifier(n_jobs=N_JOBS)
    }

    scorers = {
                    "accuracy": accuracy_score,
    }

    try:
        clf = clfs.get(clf_name, clfs["RANDOMFOREST"])
        scaler = StandardScaler()
        model = make_pipeline(scaler, clf)
        model.fit(x, y)

        scorer = scorers[SCORE_TYPE]
        clf_score = model.score( x, y)
        score = scorer(y, model.predict(x))

        message_score = {'clf_socre':clf_score}

        fe_importance = {'feature': None, 'importance': None}

        if clf_name == 'LIGHTGBM':
            df_feature_importance = ( 
                                pd.DataFrame(
                                            { 'name': clf.booster_.feature_name(),
                                            'importance': clf.booster_.feature_importance()
                                            }
                                            ).sort_values(by='importance',ascending=False).set_index('name')
                            )
            fe_importance = df_feature_importance.to_dict(into=OrderedDict)
                
        status = {'status': 'OK'}
        message = {'message': ""}
    except Exception as e: 
        clf =None
        clf_score=0
        score=0 
        message_score = {'clf_socre':0}
        fe_importance = {'feature': None, 'importance': None}
        status = {'status':'FAILURE'}
        message = {'message': f'{e}'}

    # update the ml_result info
    ml_result.ml_name = clf_name
    ml_result.score_val= score
    ml_result.x_col_names=x.columns.to_list()
    ml_result.x_rows=x.shape[0]

    current_time = datetime.datetime.now()
    total_time = current_time - start_time
    total_seconds = total_time.total_seconds()
    ml_result.seconds = total_seconds
    
    # performance debug
    durations = {
        "sql_seconds":sql_seconds,
        "total_seconds": total_seconds
        }
    ml_result.clf_obj = json.dumps({**status,
                                    **message,
                                    **durations,
                                    **message_score,
                                    **fe_importance
                                    }
                                    )
    # end of performance debug

    return ml_result

    $$ language 'plpython3u' volatile COST 5000; 
{% endmacro %}