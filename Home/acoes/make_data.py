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
from gc import collect

mpl.rc('figure', max_open_warning=0)
register_matplotlib_converters()
plt.style.use('seaborn')
# %%


def Down_Data(TickerName):
    Data = pdr.DataReader(TickerName + '.SA',
                          data_source='yahoo', start='2019-01-01')
    return Data


def MMA_Analisys(Data, Ticker):
    # SMA
    Data['MMA200'] = Data['Adj Close'].rolling(200).mean()
    Data['MMA100'] = Data['Adj Close'].rolling(100).mean()
    Data['MMA72'] = Data['Adj Close'].rolling(72).mean()
    Data['MMA66'] = Data['Adj Close'].rolling(66).mean()
    Data['MMA21'] = Data['Adj Close'].rolling(21).mean()
    Data['PriceX2'] = 2 * Data['Adj Close']

    # Bollinger Bands
    days = 9
    MidBollinger = (Data['High'].rolling(days).mean() +
                    Data['Low'].rolling(days).mean()) / 2
    Data['CorridorHigh'] = MidBollinger + Data['PriceX2'].std()
    Data['CorridorLow'] = MidBollinger - Data['PriceX2'].std()

    # Pivot Points
    global PP, R1, R2, R3, S1, S2, S3
    ref = -1
    PP = (Data['High'][ref] + Data['Low'][ref] + Data['Close'][ref]) / 3
    R1 = (2 * PP) - Data['Low'][ref]
    S1 = (2 * PP) - Data['High'][ref]
    R2 = PP + (Data['High'][ref] - Data['Low'][ref])
    S2 = PP - (Data['High'][ref] - Data['Low'][ref])
    R3 = Data['High'][ref] + (2 * (PP - Data['Low'][ref]))
    S3 = Data['Low'][ref] - (2 * (Data['High'][ref] - PP))

    # Gain / Loss
    Data['GainLoss'] = Data['Close'] - Data['Open']

    table_file = '.\\Tables\\' + Ticker + '.xlsx'

    Data.to_excel(table_file)

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
    A.plot(Data['CorridorHigh'], color='Grey', linestyle=":")
    A.plot(Data['CorridorLow'], color='Grey', linestyle=":")
    first = True
    for pivotLine in [PP, R1, R2, R3, S1, S2, S3]:
        if first == True:
            color, first = 'Black', False
        else:
            color = 'Grey'
        A.axhline(pivotLine, color=color, linestyle=":")
    A.set_title(f'Graphic Open \\ Close {TickerName}')

    B.plot(Data['Adj Close'], color='Black', label='Adj Close')
    B.plot(Data['MMA72'], color='Red', label='72')
    B.plot(Data['MMA21'], color='Orange', label='21')
    B.plot(Data['MMA66'], color='Pink', label='66')
    B.plot(Data['MMA100'], color='Grey', label='100')
    B.plot(Data['MMA200'], color='Blue', label='200')
    B.set_title(f'MMA VIEW {TickerName}')

    C.bar(Data.index, Data['GainLoss'], color='Green')
    C.set_title(f' Gain / Loss - {TickerName}')

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
try:
    chdir(r'A:\_Projetos\AnotacoesEstudosBackPythonLSP\Home\acoes')
except:
    chdir(r'C:\Users\GOMEE11\Documents\_Referencias\Git\AnotacoesEstudosBackPythonLSP\Home\acoes')

File_Lista_Acoes = r'.//Lista_Bovespa.csv'
File_List_Tickers = r'.//CheckPoint.txt'
File_Report = r'./Report.csv'
DF_Tickers = pd.read_csv(File_Lista_Acoes)
Report = pd.DataFrame(columns=['Ticker', 'Adj Close'])
List_Tickers = []
mem = 0


def inicializa():
    global File_List_Tickers, File_Lista_Acoes, List_Tickers
    if isfile(File_List_Tickers):
        with open(File_List_Tickers, 'r') as arq:
            List_Tickers_Raw = arq.readlines()
            for x in List_Tickers_Raw:
                Ticker = x.replace('\n', '')
                List_Tickers.append(Ticker)
            pass
        pass
    else:
        with open(File_Report, 'w+') as report:
            report.write('Ticker,Price\n')
            pass

        List_Tickers = list(DF_Tickers['Ticker'])

        with open(File_List_Tickers, 'w+') as arq:
            for x in List_Tickers:
                arq.write(x + '\n')
            pass
        pass

    for d in ['.\\Graph', '.\\Tables']:
        if isdir(d):
            pass
        else:
            mkdir(d)
            pass

# %%


if __name__ == '__main__':
    start = perf_counter()

    inicializa()

    for x in List_Tickers:

        print(f'Downloading {x} data from yahoo...', end='')

        try:
            data = Down_Data(x)
            print(' Download Sucess...', end='')
            pass
        except:
            data = None
            print(' Download Failed...', end='')
            sleep(9)
            pass
        try:
            data = MMA_Analisys(data, x)
            print(' Analysis Sucess...', end='')
            pass
        except:
            print(' Analysis Failed...', end='')
            sleep(9)
            pass
        try:
            Graph(data, x)
            print(' Graph Sucess...')
            pass
        except:
            print(' Graph Failed...')
            sleep(9)
            pass

        try:
            with open(File_Report, 'a+') as report:
                last_price = data['Adj Close'][-1]
                report.write(f'{x},{last_price}\n')
        except Exception as error:
            # print(error)
            sleep(9)
            pass

        List_Tickers.remove(x)
        with open(File_List_Tickers, 'w+') as arq:
            for x in List_Tickers:
                arq.write(x + '\n')

        if mem == 18:
            collect()
            mem = 0
            sleep(45)
        else:
            mem += 1
            sleep(9)
        pass

    stop = perf_counter()

    Report.to_excel('Report.xlsx')

    remove(File_List_Tickers)

    print(f'Ends in {stop - start} seconds...')
