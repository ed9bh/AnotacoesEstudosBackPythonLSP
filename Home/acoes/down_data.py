# %%
from os import chdir
from time import sleep, perf_counter
import pandas_datareader as pdr
from matplotlib import pyplot as plt, dates as mpl_dates
import pandas as pd
from pandas.plotting import register_matplotlib_converters
import requests
from lxml import html

register_matplotlib_converters()
plt.style.use('seaborn')
# %%
def Down_Data(TickerName):
    try:
        Data = pdr.DataReader(TickerName + '.SA', data_source='yahoo', start='2019-01-01')
        return Data
    except:
        return False

def MMA_Analisys(Data):
    Data['MMA200'] = Data['Adj Close'].rolling(200).mean()
    Data['MMA100'] = Data['Adj Close'].rolling(100).mean()
    Data['MMA72'] = Data['Adj Close'].rolling(72).mean()
    Data['MMA66'] = Data['Adj Close'].rolling(66).mean()
    Data['MMA21'] = Data['Adj Close'].rolling(21).mean()
    return Data

def Graph(Data):
    pass

# %%
chdir(r'C:\Users\GOMEE11\Documents\_Referencias\Git\AnotacoesEstudosBackPythonLSP\Home\acoes')
File_Lista_Acoes = r'.//Lista_Bovespa.csv'
# %%
DF_Tickers = pd.read_csv(File_Lista_Acoes)
