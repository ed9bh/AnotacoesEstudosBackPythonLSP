# %%
from os import chdir
import pandas as pd
import pandas_datareader as pdr
import matplotlib.pyplot as plt
from time import sleep

# %%
chdir(r'C:\Users\GOMEE11\Documents\_Referencias\Git\AnotacoesEstudosBackPythonLSP\Home\fii')
data_sheet = pd.read_excel('Lista_FII.xlsx')

# %%
for item in data_sheet['Ticker']:
    ticker = f'{item}11.SA'
    df = pdr.DataReader(ticker, data_source='yahoo', start='2019-06-01')
    df['MMA10'] = df['Adj Close'].rolling(10).mean()
    df['MMA30'] = df['Adj Close'].rolling(30).mean()
    df['MMA60'] = df['Adj Close'].rolling(60).mean()
