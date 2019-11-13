# %%
from os import chdir, mkdir, remove
from os.path import isdir, isfile
from glob import glob
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


def MMA_Analisys(Data, Ticker):
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

    fig.savefig('.\\Graph\\' + TickerName + '.png')

    pass


# %%
chdir(r'C:\Users\GOMEE11\Documents\_Referencias\Git\AnotacoesEstudosBackPythonLSP\Home\acoes')
File_Lista_Acoes = r'.//Lista_Bovespa.csv'
DF_Tickers = pd.read_csv(File_Lista_Acoes)

if isdir('.\\Graph'):
    to_erase = glob('.\\Graph\\*.png')
    for e in to_erase:
        remove(e)
    pass
else:
    mkdir('.\\Graph')
    pass

if isdir('.\\Tables'):
    to_erase = glob('.\\Tables\\*.xlsx')
    for e in to_erase:
        remove(e)
else:
    mkdir('.\\Tables')
    pass

# %%

if __name__ == '__main__':
    start = perf_counter()
    for x in DF_Tickers['Ticker']:

        print(f'Donloading {x} data from yahoo...', end='')

        try:
            data = Down_Data(x)
            print(' Download Sucess...', end='')
            pass
        except:
            print(' Download Failed...', end='')
            pass
        try:
            data = MMA_Analisys(data, x)
            print(' Analisys Sucess...', end='')
            pass
        except:
            print(' Analisys Failed...', end='')
            pass
        try:
            Graph(data, x)
            print(' Graph Sucess...')
            pass
        except:
            print(' Graph Failed...')
            pass

        try:
            data.to_excel('.\\Tables\\' + x + '.xlsx')
        except Exception as error:
            print(error)
            pass

        sleep(18)
        pass

    stop = perf_counter()

    print(f'Ends in {stop - start} seconds...')
