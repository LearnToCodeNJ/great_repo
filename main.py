from flask import Flask, request
import quandl
import pandas as pd
import numpy as np
from sklearn.datasets import make_regression
from sklearn.linear_model import Lasso
import os
import requests
from urllib.request import urlopen
from datetime import datetime
import pandas_datareader.data as web
# import matplotlib.pyplot as plt
# import matplotlib.pyplot as plt;

app = Flask(__name__)
quandl.ApiConfig.api_key = os.getenv('QUANDLE_API_KEY')
AV_API_KEY = os.getenv('ALPHA_VANTAGE')
ALPHA_VANTAGE_URL = os.getenv('ALPHA_VANTAGE_URL')

@app.route('/')
def hello_world():
    return 'Hello, World!'

@app.route('/getVix')
def getVix():
    start = datetime(2010,1,1)
    end = datetime(2014,3,24)
    ticker = "AAPL"
    f= web.DataReader(['CPIAUCSL', 'CPILFESL'], 'fred', start, end)
    # plt.plot(f['Close'])
    # plt.title('AAPL Closing Prices')
    # plt.show()
    return str(f)

@app.route('/get_stock')
def get_stock():
    test = quandl.get('NASDAQOMX/XQC', start_date='2018-12-17', end_date='2018-12-17')
    return test.to_json()

@app.route('/adaptive_lasso')
def get_lasso():
    X, y, coef = make_regression(n_samples=306, n_features=8000, n_informative=50,
                    noise=0.1, shuffle=True, coef=True, random_state=42)
    X /= np.sum(X ** 2, axis=0)  # scale features

    alpha = 0.1

    g = lambda w: np.sqrt(np.abs(w))
    gprime = lambda w: 1. / (2. * np.sqrt(np.abs(w)) + np.finfo(float).eps)
    n_samples, n_features = X.shape
    p_obj = lambda w: 1. / (2 * n_samples) * np.sum((y - np.dot(X, w)) ** 2) \
                    + alpha * np.sum(g(w))

    weights = np.ones(n_features)
    n_lasso_iterations = 5

    for k in range(n_lasso_iterations):
        X_w = X / weights[np.newaxis, :]
        clf = Lasso(alpha=alpha, fit_intercept=False)
        clf.fit(X_w, y)
        coef_ = clf.coef_ / weights
        weights = gprime(coef_)
        # print p_obj(coef_)  # should go down

    return str(np.mean((clf.coef_ != 0.0) == (coef != 0.0)))

@app.route('/get_test')
def get_test():
    return quandl.get('ML/EEMCBI', start_date='2008-04-01', end_date='2028-10-01').to_json()


@app.route('/stock_data')
def stock_data():
    ticker = request.args['ticker']
    url = f'{ALPHA_VANTAGE_URL}/query?function=TIME_SERIES_DAILY&symbol={ticker}&apikey={AV_API_KEY}'
    r = requests.get(url)
    return str(r.json())

@app.route('/cboe')
def getPutCallRatio():
    """ download current Put/Call ratio"""
    urlStr = 'http://www.cboe.com/publish/ScheduledTask/MktData/datahouse/totalpc.csv'

    try:
        lines = urlopen(urlStr).readlines()
    except Exception as e:
        s = "Failed to download:\n{0}".format(e)
        print (s)
       
    headerLine = 2

    header = lines[headerLine].decode("utf-8").strip().split(',')
    
    data =   [[] for i in range(len(header))]
    
    for line in lines[(headerLine+1):]:
        fields = line.rstrip().decode("utf-8").split(',')
        print(fields)
        data[0].append(datetime.strptime(fields[0],'%m/%d/%Y'))
        for i,field  in enumerate(fields[1:]):
            data[i+1].append(float(field))
    
    return pd.DataFrame(dict(zip(header[1:],data[1:])), index = pd.Index(data[0])).to_json()
