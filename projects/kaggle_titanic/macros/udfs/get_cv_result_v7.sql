{% macro get_cv_result_v7() %}
    create or replace function {{ target.schema }}.get_cv_result_v7(
        clf_name text,
        tbl_name text,
        -- sql_statement text DEFAULT '',
        id_col text DEFAULT 'passengerid',
        y_col text DEFAULT 'survived',
        cv_col text DEFAULT 'cv_id',
        n_cv int DEFAULT 3,
        return_model boolean DEFAULT False, -- Return the trained model or not. Note the model might be MB based.
        cluster_t float4 default 0.8
    ) returns type_ml_result as $$ 
    
"""
this is for cross validation, feature importance and reduce multilinear case.

"""

import json
import sys
import pickle
# import datetime
import time
from dataclasses import dataclass
from collections import defaultdict

# data lib
from scipy.stats import spearmanr
from scipy.cluster import hierarchy
# from scipy import stats
import pandas as pd
import numpy as np

# ml lib
from sklearn.preprocessing import StandardScaler
from sklearn.ensemble import RandomForestClassifier
from sklearn.linear_model import RidgeClassifier
from sklearn.svm import LinearSVC
from sklearn.linear_model import SGDClassifier  # a
from sklearn.pipeline import make_pipeline
# from sklearn.metrics import accuracy_score, precision_score, roc_auc_score
from sklearn.model_selection import cross_validate
from sklearn.inspection import permutation_importance

from lightgbm import LGBMClassifier

DB_URL = 'postgresql://postgres:postgres@45432/titanic'
N_JOBS = 3  # limit using 2 cpu
SCORE_TYPE = 'accuracy'
INSIDE_DB = True # init the ml training result


@dataclass
class MLResult:
    """
    type definition of machine learning result.
    it will be used both in python and postgres data type
    the MLResult should be matched between postgres and python code
    """
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
    trained_model = None


def handling_multilinear(var_x, t=1):
    """
    using correlation_linkage matrix to remove the feature multilinear
    X is the dataset (pandas.DataFrame)
    t is the criteria scala, default =1
    """
    corr = spearmanr(var_x).correlation
    corr_linkage = hierarchy.ward(corr)
    cluster_ids = hierarchy.fcluster(corr_linkage, t, criterion='distance')
    cluster_id_to_feature_ids = defaultdict(list)

    for idx, cluster_id in enumerate(cluster_ids):
        cluster_id_to_feature_ids[cluster_id].append(idx)
    selected_features = [v[0] for v in cluster_id_to_feature_ids.values()]

    var_x = var_x.iloc[:, selected_features]
    return var_x, corr_linkage


def get_db_table(tbl_name):
    """
    To get table from a database from external or internal by variable INSIDE_DB
    """
    inside_db = INSIDE_DB  # INSDIE_DB is global variable constant
    db_url = DB_URL  # DB_URL is global constant variable
    sql_statement = f"select * from {tbl_name}"
    if inside_db:  # get table inside of postgres
        sql_plan = plpy.prepare(sql_statement)
        sql_data = plpy.execute(sql_plan)
        df_tbl = pd.DataFrame.from_records(sql_data)
    else:  # sqlalchemymode. get table from outside by sqlalchemy
        df_tbl = pd.read_sql(sql_statement, db_url)

    return df_tbl


# def get_cv_v8(clf_name,
              # tbl_name,
              # id_col='passengerid',
              # y_col='survived',
              # cv_col='cv_id',
              # n_cv=3,
              # return_model=True,
              # cluster_t=1):
    # pylint: disable=unused-argument
"""
this version is added a feature which could handling the multilinear situation.
by calculate spearman correlation and cluster feature ,drop the feature with cretria.
"""

start_time = time.perf_counter()
ml_result = MLResult()  # get x, y dataset
# plpy mode
drop_cols = [y_col, id_col]

df_tbl = get_db_table(tbl_name)
var_y = df_tbl[y_col]
original_x = df_tbl.drop(columns=drop_cols)
var_x, linkage = handling_multilinear(original_x, cluster_t)
# cv_df = df_tbl[cv_col]

# performance debug only
sql_seconds = time.perf_counter() - start_time
# debug end

# training & scoring
clfs = {"SVC": LinearSVC(),
        "SGD": SGDClassifier(),
        "RANDOMFOREST": RandomForestClassifier(),
        "RIDGECLASSIFIER": RidgeClassifier(solver="sag"),
        'LIGHTGBM': LGBMClassifier(n_jobs=N_JOBS)}
# scorers = {"accuracy": accuracy_score}
trained_model = None

try:
    clf = clfs.get(clf_name, clfs["RANDOMFOREST"])
    scaler = StandardScaler()
    model = make_pipeline(scaler, clf)
    model.fit(var_x, var_y)
    cv_results = cross_validate(model,
                                var_x,
                                var_y,
                                scoring=SCORE_TYPE,
                                cv=n_cv,
                                return_train_score=True,
                                return_estimator=True)
    if return_model:
        model.fit(var_x, var_y)
        trained_model = model

    message_score = {}
    for key, value in cv_results.items():
        if key != 'estimator':
            message_score[key] = value.tolist()

    message_score['test_mean_score'] = np.mean(cv_results['test_score'])
    message_score['train_mean_score'] = np.mean(cv_results['train_score'])
    fe_importance = {'feature': None, 'importance': None}

    n_estimator = 0
    permutation_result = permutation_importance(
        cv_results['estimator'][n_estimator], var_x, var_y)

    fe_importance = {'feature_importance': dict(zip(
        var_x.columns.to_list(),
        permutation_result.importances_mean.round(4).tolist()
    ))}

    status = {'status': 'OK'}
    message = {'message': ""}

except Exception as error_instance:
    clf = None
    message_score = {}
    message_score['test_mean_score'] = None
    message_score['train_mean_score'] = None
    fe_importance = {'feature': None, 'importance': None}

    status = {'status': 'FAILURE'}
    message = {'message': f'{error_instance}'}
# update the ml_result info
ml_result.ml_name = clf_name
ml_result.test_mean_score = message_score['test_mean_score']
ml_result.train_mean_score = message_score['train_mean_score']
ml_result.x_col_names = var_x.columns.to_list()
ml_result.x_rows = var_x.shape[0]

ml_result.total_second = time.perf_counter() - start_time

# persistent models
ml_result.is_trained = return_model
if ml_result.is_trained:
    ml_result.trained_model = pickle.dumps(trained_model)

size_of_model_kb = {'size_of_model_kb': sys.getsizeof(
    ml_result.trained_model) // 2 ** 10}
# performance debug
durations = {"sql_seconds": sql_seconds,
                "total_seconds": ml_result.total_second,
                }

ml_result.clf_obj = json.dumps({
    **status,
    **message,
    **durations,
    **message_score,
    **fe_importance,
    **{"original_feature": original_x.columns.to_list()},
    **{"dropped_feature": original_x.columns.difference(var_x.columns).to_list()},
    **{'corr_linkage': {"t_value": cluster_t,
                        "linkage": linkage.tolist()}},
    ** size_of_model_kb
})
# end of performance debug
return ml_result


$$ language 'plpython3u' volatile COST 5000;
{% endmacro %}
