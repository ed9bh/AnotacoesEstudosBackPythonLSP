# %%
from os import chdir, mkdir, remove
from os.path import isdir, isfile
from glob import glob
from time import sleep, perf_counter
import pandas_datareader as pdr
from matplotlib import pyplot as plt, dates as mpl_dates
import matplotlib as mpl
import pandas as pd
from pandas.plotting import register_matplotlib_converters
import requests
from lxml import html

mpl.rc('figure', max_open_warning=0)
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

    graph_file = r'.\\Graph\\' + TickerName + '.png'

    try:
        if isfile(graph_file):
            remove(graph_file)
            sleep(1)
        fig.savefig(graph_file)
        pass
    except Exception as error:
        print(error)
    pass


# %%
# chdir(r'C:\Users\GOMEE11\Documents\_Referencias\Git\AnotacoesEstudosBackPythonLSP\Home\acoes')
chdir(r'A:\_Projetos\AnotacoesEstudosBackPythonLSP\Home\acoes')

File_Lista_Acoes = r'.//Lista_Bovespa.csv'
File_List_Tickers = r'.//CheckPoint.asc'
DF_Tickers = pd.read_csv(File_Lista_Acoes)
Report = pd.DataFrame(columns=['Ticker', 'Adj Close'])
List_Tickers = []

if isfile(File_List_Tickers):
    with open(File_List_Tickers, 'r') as arq:
        List_Tickers_Raw = arq.readlines()
        for x in List_Tickers_Raw:
            Ticker = x.replace('\n', '')
            List_Tickers.append(Ticker)
        pass
    pass
else:
    List_Tickers = list(DF_Tickers['Ticker'])
    with open(File_List_Tickers, 'w+') as arq:
        for x in List_Tickers:
            arq.write(x + '\n')
        pass
    pass


if isdir('.\\Graph'):
    pass
    #to_erase = glob('.\\Graph\\*.png')
    # for e in to_erase:
    #     remove(e)
    pass
else:
    mkdir('.\\Graph')
    pass

if isdir('.\\Tables'):
    pass
    #to_erase = glob('.\\Tables\\*.xlsx')
    # for e in to_erase:
    #     remove(e)
else:
    mkdir('.\\Tables')
    pass

# %%

if __name__ == '__main__':
    start = perf_counter()
    for x in List_Tickers:

        print(f'Downloading {x} data from yahoo...', end='')

        try:
            data = Down_Data(x)
            print(' Download Sucess...', end='')
            pass
        except:
            print(' Download Failed...', end='')
            pass
        try:
            data = MMA_Analisys(data, x)
            print(' Analysis Sucess...', end='')
            pass
        except:
            print(' Analysis Failed...', end='')
            pass
        try:
            Graph(data, x)
            print(' Graph Sucess...')
            pass
        except:
            print(' Graph Failed...')
            pass

        table_file = '.\\Tables\\' + x + '.xlsx'

        if isfile(table_file):
            remove(table_file)
            sleep(1)

        try:
            data.to_excel(table_file)
        except Exception as error:
            print(error)
            pass

        try:
            Report = Report.append(
                {'Ticker': x, 'Adj Close': data['Adj Close'][-1]},  ignore_index=True)
            Report.to_excel('Report.xlsx')
        except Exception as error:
            print(error)
            pass

        if isfile('.\\Graph\\' + x + '.png'):
            List_Tickers.remove(x)
            with open(File_List_Tickers, 'w+') as arq:
                for x in List_Tickers:
                    arq.write(x + '\n')

        sleep(9)
        pass

    stop = perf_counter()

    Report.to_excel('Report.xlsx')

    remove(File_List_Tickers)

    print(f'Ends in {stop - start} seconds...')
