from flask import Flask
import quandl
import pandas as pd
import numpy as np
from sklearn.datasets import make_regression
from sklearn.linear_model import Lasso
import os

app = Flask(__name__)

@app.route('/')
def hello_world():
    return 'Hello, World!'

@app.route('/get_stock')
def get_stock():
    quandl.ApiConfig.api_key = os.getenv('QUANDLE_API_KEY')
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


    