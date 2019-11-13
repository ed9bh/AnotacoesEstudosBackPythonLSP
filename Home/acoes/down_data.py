# %%
from os import chdir, mkdir
from os.path import isdir, isfile
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
        Data = pdr.DataReader(TickerName + '.SA',
                              data_source='yahoo', start='2019-01-01')
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


def Graph(Data, TickerName):
    fig, ((A, B), (C, D)) = plt.subplots(
        nrows=2,
        ncols=2,
        sharex=False,
        sharey=False,
        figsize=(15, 10)
    )

    A.plot(Data['Open'], color='Blue', label='Open')
    A.plot(Data['Close'], color='Red', label='Close')
    A.set_title(f'Graphic Open \\ Close {TickerName}')

    B.plot(Data['Adj Close'], color='Black', label='Adj Close')
    B.plot(Data['MMA72'], color='Red', label='72')
    B.plot(Data['MMA21'], color='Orange', label='21')
    B.plot(Data['MMA66'], color='Pink', label='66')
    B.plot(Data['MMA100'], color='Grey', label='100')
    B.plot(Data['MMA200'], color='Blue', label='200')
    B.set_title(f'MMA VIEW {TickerName}')

    D.bar(Data.index, Data['Volume'])
    D.set_title(f'Volume - {TickerName}')

    A.legend()
    B.legend()

    fig.autofmt_xdate()

    fig.savefig(TickerName + '.png')

    pass


# %%
chdir(r'C:\Users\GOMEE11\Documents\_Referencias\Git\AnotacoesEstudosBackPythonLSP\Home\acoes')
File_Lista_Acoes = r'.//Lista_Bovespa.csv'

# %%
DF_Tickers = pd.read_csv(File_Lista_Acoes)
