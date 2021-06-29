{% macro get_cv_result_v2() %}
    create
    or replace function {{target.schema }}.get_cv_result_v2(clf_name text,
                                                            tbl_name text,
                                                            -- sql_statement text DEFAULT '',
                                                            id_col text DEFAULT 'passengerid',
                                                            y_col text DEFAULT 'survived',
                                                            cv_col text DEFAULT 'cv_id',
                                                            n_cv int DEFAULT 3) 
    returns type_ml_result
    as $$ 

    """
    get_cv_result_v2(clf_name: str,
                     sql_statement: str = '',
                     id_col: str = 'passengerid',
                     y_col: str = 'survived',
                     cv_col: str = 'cv_id'):

    """
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
    from sklearn.model_selection import cross_val_score, cross_validate

    from lightgbm import LGBMClassifier

    DB_URL = 'postgresql://postgres:postgres@pgml:45432/titanic'
    N_JOBS = 3  # limit using 2 cpu
    SCORE_TYPE = 'accuracy'

    # init the ml training result
    @dataclass
    class MLResult:
        ml_name = 'sk_randomforest'
        score_type = SCORE_TYPE
        train_mean_score = -1
        test_mean_score = -1
        # score_val = 0.0
        create_time = pd.Timestamp.now()
        x_col_names = []
        x_rows = 0
        n_cv = 3
        is_trained = False
        total_second = 0.0
        clf_obj = None

    start_time = datetime.datetime.now()

    ml_result = MLResult()

    # get x, y dataset
    drop_cols = [y_col, id_col]
    sql_statement = f"select * from {tbl_name} "
    # plpy mode
    sql_plan = plpy.prepare(sql_statement)
    sql_data = plpy.execute(sql_plan)
    df = pd.DataFrame.from_records(sql_data)

    # # sqlalchemymode
    # df = pd.read_sql(sql_statement, DB_URL)
    # endof sqlalchemy mode

    y = df[y_col]
    x = df.drop(columns=drop_cols)
    # cv_df = df[cv_col]

    # performance debug only
    current_time = datetime.datetime.now()
    sql_time = current_time - start_time
    sql_second = sql_time.total_seconds()
    # debug end

    # training & scoring
    clfs = {
        "SVC": LinearSVC(),
        "SGD": SGDClassifier(),
        "RANDOMFOREST": RandomForestClassifier(),
        "RIDGECLASSIFIER": RidgeClassifier(tol=1e-2, solver="sag"),
        'LIGHTGBM': LGBMClassifier(n_jobs=N_JOBS)
    }

    # scorers = {"accuracy": accuracy_score}

    try:
        clf = clfs.get(clf_name, clfs["RANDOMFOREST"])
        scaler = StandardScaler()
        model = make_pipeline(scaler, clf)
        cv_results = cross_validate(model, x, y, scoring=SCORE_TYPE, cv=n_cv, return_train_score=True)

        message_score = {}

        for k,v in cv_results.items():
            message_score[k] = cv_results[k].tolist()

        message_score['test_mean_score'] = np.mean(cv_results['test_score'])
        message_score['train_mean_score'] = np.mean(cv_results['train_score'])

        fe_importance = {'feature': None, 'importance': None}

        # if clf_name == 'LIGHTGBM':
        #     lgb_boost = model.steps[1][1].booster_
        #     df_feature_importance = (
        #                         pd.DataFrame(
        #                                     { 'name': lgb_boost.feature_name(),
        #                                     'importance': lgb_boost.feature_importance()
        #                                     }
        #                                     ).sort_values(by='importance',ascending=False).set_index('name')
        #                     )
        #     fe_importance = df_feature_importance.to_dict(into=OrderedDict)

        status = {'status': 'OK'}
        message = {'message': ""}

    except Exception as e:
        clf = None
        message_score = {}
        message_score['test_mean_score'] = None
        message_score['train_mean_score'] = None
        fe_importance = {'feature': None, 'importance': None}

        status = {'status': 'FAILURE'}
        message = {'message': f'{e}'}

    # update the ml_result info

    ml_result.ml_name = clf_name
    ml_result.test_mean_score = message_score['test_mean_score']
    ml_result.train_mean_score = message_score['train_mean_score']
    ml_result.x_col_names = x.columns.to_list()
    ml_result.x_rows = x.shape[0]

    current_time = datetime.datetime.now()
    total_time = current_time - start_time
    total_second = total_time.total_seconds()
    ml_result.total_second = total_second

    # performance debug
    durations = {
        "sql_second": sql_second,
        "total_second": total_second
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