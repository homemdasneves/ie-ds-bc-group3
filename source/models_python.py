from sklearn import tree, ensemble, metrics, preprocessing
import pandas as pd
import numpy as np
import random
from collections import defaultdict
from time import localtime, strftime, mktime
import matplotlib.pyplot as plt
import os
from scipy.stats import bernoulli

path = "C:\\work\\projetos\\ie-ds-bootcamp\\ie-ds-bc-group3\\"
path_data = path + "data\\"
path_res = path + "results\\"

def cleanup(df):
    if 'ARRIVAL_DELAY_15' in df.columns:
        df.drop('ARRIVAL_DELAY_15', axis=1, inplace=True) # remove target
        df=df.rename(columns = {'RECENT_DELAYS_AL_ORIG':'RECENT_DELAYS_AL_OR'})


def log (file = None, message = None):
    time = strftime("%Y-%m-%d %H:%M:%S", localtime())
    full_message = "{} - {}".format(time, message)
    if (file):
        file.write(message) 
    print(full_message)

def impute_missing(df, col_name):
    missing_vals = pd.isnull(df[col_name])
    mean_val = np.mean(df[col_name])
    df.loc[missing_vals,col_name] = mean_val

def label_encode(le, le_summary, df):
    # https://stackoverflow.com/questions/24458645/label-encoding-across-multiple-columns-in-scikit-learn
    log(file = None, message = "encoding variables...")
    factors = ["DEPARTURE_LABEL", "ORIGIN", "DESTINATION", "AIRLINE_CODE", "size_airline", "size_airport"]

    for c in factors:
        df[c] = le[c].fit_transform(df[c])
        le_summary[c] = pd.DataFrame(
            {
                'factor': le[c].inverse_transform(unique(df[c]))
            })

def run_model(X_train, X_validation, X_test, y_train, y_validation, y_test, model, cols, title = ''):

    if title is '':
        report = "{}_{}".format(type(model).__name__, strftime("%Y-%m-%d_%H%M", localtime()))
    else:
        report = title
            
    file = open(path_res + report + ".txt", "w")
    file.write(report + "\n") 

    log(file, "\nstarting: " + report)

    # fit model
    log(file, "\nfitting model...")
    start = localtime()
    model.fit(X_train.loc[:, cols], y_train.iloc[:,0])
    end = localtime()
    log(file, "\nfitting done! - took {} seconds\n".format(abs(mktime(end) - mktime(start))))


    # setup for GridSearchCV
    # https://stackoverflow.com/questions/37583263/scikit-learn-cross-validation-custom-splits-for-time-series-data
    # X = pd.concat([X_train, X_validation])
    # train_cutpoint = X_train.shape[0] # last train id
    #ids = range(0, len(X))
    #train_ids = ids[0:train_cutpoint]
    #validation_ids = ids[train_cutpoint:len(X)]
    #(len(train_ids) + len(validation_ids)) == len(ids) # check

    # get performance metrics
    val_accuracy = model.score(X_validation.loc[:,cols], y_validation.iloc[:,0])
    test_accuracy = model.score(X_test.loc[:,cols], y_test.iloc[:,0])
    log(file, "\nval_accuracy: {}".format(val_accuracy))
    log(file, "\ntest_accuracy: {}".format(test_accuracy))

    # get feature importances
    importances = pd.DataFrame({"column": cols, "importance": 100 * model.feature_importances_})
    importances = importances.sort_values(by = ["importance"], ascending=[False])
    log(file, "\nimportances: \n{}".format(importances))

    predictions = pd.Series(model.predict(X_test.loc[:, cols]), name = "Predictions")
    cross_tab = pd.crosstab(predictions, y_test["ARRIVAL_DELAY_15"], normalize = True)
    log(file, "\ncross tab: {}".format(cross_tab))

    log(file, "\ncalculating probabilities...")
    probabilities = model.predict_proba(X_test.loc[:, cols])
    probs = pd.DataFrame(probabilities)
    probs.columns = ["On-Time", "Delayed"]
    probs.to_csv(path_res + report + "_probs.csv")
    log(file, "\ndone...")

    file.close()

    return probabilities

def run_models(models, cols, 
               X_train, X_validation, X_test, 
               y_train, y_validation, y_test):
    probs_list = []
    for model in models:
        for c_filter in cols:
            output = run_model(X_train, X_validation, X_test, 
                      y_train, y_validation, y_test, 
                      model, c_filter)
            probs_list.append(output)
    return probs_list

def run_models_dic(models_list, 
               X_train, X_validation, X_test, 
               y_train, y_validation, y_test):
    probs_list = []
    for m in models_list:
        model = m['model']
        c_filter = m['column_filter']
        title = m['title']

        output = run_model(X_train, X_validation, X_test, y_train, y_validation, y_test, model, c_filter, title)
        probs_list.append(output)
    return probs_list
   
def load_data(file):
    log(file = None, message = "loading file {}".format(file))
    return pd.read_csv(file)

def read_probs_csvs(directory):

    probs_list = []
    filenames = []
    for filename in os.listdir(directory):
        if filename.endswith("_probs.csv"):
            probs_list.append(pd.read_csv(directory + filename))
            filenames.append(filename)

    return probs_list, filenames

def plot_roc_auc(probabilities, model_names, y_test):

    # using matplotlib
    my_dpi = 192
    plt.figure(figsize=(2048/my_dpi, 1520/my_dpi), dpi=192)
    plt.title('ROC')

    colors = ['b', 'g', 'r', 'c', 'y', 'k', 'pink', 'orange', 'brown']

    # calculate the fpr and tpr for all thresholds of the classification
    for i in range(0, len(probabilities)):
        model_name = model_names[i]
        color = colors[i%len(colors)]
        print(model_name)

        fpr, tpr, threshold = metrics.roc_curve(y_test, probabilities[i].iloc[:,-1])
        roc_auc = metrics.roc_auc_score(y_test, probabilities[i].iloc[:,-1])
        plt.plot(fpr, tpr, color, label = model_name + ' : %0.2f' % roc_auc)

    plt.legend(loc = 'lower right')
    plt.plot([0, 1], [0, 1],'r--',label='Luck')
    plt.xlim([0, 1])
    plt.ylim([0, 1])
    plt.ylabel('True Positive Rate')
    plt.xlabel('False Positive Rate')

    plt.savefig(path_res + 'roc_auc.png', dpi=192)
    plt.show()

############################################

X_train = load_data(path_data + "train.csv") 
X_validation = load_data(path_data + "validation.csv")
X_test = load_data(path_data + "test.csv")
X_list = [X_train, X_validation, X_test]

sum(pd.isnull(X_validation["RECENT_DELAYS_AL_ORIG"]))

[impute_missing(x, "RECENT_DELAYS_AL_ORIG") for x in X_list]

# get the target arrays
y_train,y_validation,y_test = [pd.DataFrame(x.loc[:,"ARRIVAL_DELAY_15"]) for x in X_list] 

[cleanup(x) for x in X_list] # remove the target from the X's

le = defaultdict(preprocessing.LabelEncoder)
le_summary = defaultdict(preprocessing.LabelEncoder)
[label_encode(le, le_summary, x) for x in X_list] # encode factor variables

# column filters
cols_all = list(X_train.columns)
cols_no_weather = list(filter(lambda x: ('_ORIG' not in x) and ('_DEST' not in x), cols_all))
cols_basic = ['MONTH','DAY_OF_MONTH','DAY_OF_WEEK','DEPARTURE_LABEL']
cols = [cols_all, cols_no_weather, cols_basic]

# models
dt_model = tree.DecisionTreeClassifier()
rf_model = ensemble.RandomForestClassifier()
models = [dt_model, rf_model]

# run models
# probs_list = run_models(models, cols, X_train, X_validation, X_test, y_train, y_validation, y_test)
model_list = []
model_list.append({'model': dt_model, 'column_filter': cols_basic, 'title': 'M_1 - DT basic'})
model_list.append({'model': dt_model, 'column_filter': cols_all, 'title': 'M_2 - DT extra vars'})
model_list.append({'model': rf_model, 'column_filter': cols_all, 'title': 'M_3 - RF extra vars'})
run_models_dic(model_list, X_train, X_validation, X_test, y_train, y_validation, y_test)

m = model_list[0]
model = m['model']
c_filter = m['column_filter']
title = m['title']
run_model(X_train, X_validation, X_test, y_train, y_validation, y_test, model, c_filter, title)

# ROC AUCs for all models
probs_list, filenames = read_probs_csvs(path_res)
monkey = pd.DataFrame(np.repeat(0.8, len(y_test), axis=0), columns = ["prob"])
rand = pd.DataFrame(bernoulli.rvs(.5,size=len(y_test)), columns = ["prob"])
rand_08 = pd.DataFrame(bernoulli.rvs(.2,size=len(y_test)), columns = ["prob"])
probs_list.append(monkey)

titles = ['M1: DT','M2: DT + extra vars','M3: RF + extra vars','M4: XGBoost + extra vars']
titles.append('MONKEY')
# titles.append('bern_08')
plot_roc_auc(probs_list, titles, y_test)

np.sum(rand[0])

# 1 - DT without weather
# 2 - DT with weather + new variables
# 3 - RF with weather + new variables
# 4 - XGBoost with weather + new variables



