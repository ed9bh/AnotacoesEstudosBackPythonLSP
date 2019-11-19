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
from numpy import abs

mpl.rc('figure', max_open_warning=0)
register_matplotlib_converters()
plt.style.use('seaborn')
# %%


def Down_Data(TickerName):
    Data = pdr.DataReader(
        TickerName + '.SA',
        data_source='yahoo',
        start='2018-01-01'
    )
    return Data


def Analisys(Data, Ticker):
    # SMA
    Data['MMA200'] = Data['Adj Close'].rolling(200).mean()
    Data['MMA100'] = Data['Adj Close'].rolling(100).mean()
    Data['MMA72'] = Data['Adj Close'].rolling(72).mean()
    Data['MMA66'] = Data['Adj Close'].rolling(66).mean()
    Data['MMA21'] = Data['Adj Close'].rolling(21).mean()
    Data['PriceX2'] = 2 * Data['Adj Close']

    # Bollinger Bands - https://school.stockcharts.com/doku.php?id=technical_indicators:bollinger_bands
    days = 20
    MidBollinger = (Data['High'].rolling(days).mean() +
                    Data['Low'].rolling(days).mean()) / 2
    Data['CorridorHigh'] = MidBollinger + Data['PriceX2'].std()
    Data['CorridorLow'] = MidBollinger - Data['PriceX2'].std()

    # Pivot Points - https://www.babypips.com/learn/forex/how-to-calculate-pivot-points
    global PP, R1, R2, R3, S1, S2, S3
    ref = -1
    PP = (Data['High'][ref] + Data['Low'][ref] + Data['Close'][ref]) / 3
    R1 = (2 * PP) - Data['Low'][ref]
    R2 = PP + (Data['High'][ref] - Data['Low'][ref])
    R3 = Data['High'][ref] + (2 * (PP - Data['Low'][ref]))
    S1 = (2 * PP) - Data['High'][ref]
    S2 = PP - (Data['High'][ref] - Data['Low'][ref])
    S3 = Data['Low'][ref] - (2 * (Data['High'][ref] - PP))

    # Gain / Loss
    Data['GainLoss'] = Data['Close'] - Data['Open']

    # MACD
    F, S, M = 12, 26, 9
    Data['MACD'] = Data['Adj Close'].rolling(
        F).mean() - Data['Adj Close'].rolling(S).mean()
    Data['Signal'] = Data['MACD'].rolling(M).mean()

    table_file = '.\\Tables\\' + Ticker + '.xlsx'

    Data.to_excel(table_file)

    return Data


def Graph(Data, TickerName):

    fig, ((A, B, E), (C, D, F)) = plt.subplots(
        nrows=2,
        ncols=3,
        sharex=False,
        sharey=False,
        figsize=(18, 9)
    )

    A.plot(Data['Open'], color='Blue', label='Open')
    A.plot(Data['Close'], color='Red', label='Close')
    A.plot(Data['CorridorHigh'], color='Grey', linestyle=":")
    A.plot(Data['CorridorLow'], color='Grey', linestyle=":")

    A.set_title(f'Graphic Open \\ Close {TickerName}')

    B_Periods = -90

    B.plot(Data['Adj Close'][B_Periods:], color='Black', label='Adj Close')
    B.plot(Data['MMA72'][B_Periods:], color='Red', label='72')
    B.plot(Data['MMA21'][B_Periods:], color='Orange', label='21')
    B.plot(Data['MMA66'][B_Periods:], color='Pink', label='66')
    B.plot(Data['MMA100'][B_Periods:], color='Grey', label='100')
    B.plot(Data['MMA200'][B_Periods:], color='Blue', label='200')
    B.set_title(f'MMA VIEW / Last {abs(B_Periods)} Periods  {TickerName}')

    C.bar(Data.index, Data['GainLoss'], color='Green')
    C.set_title(f' Gain / Loss - {TickerName}')

    D.plot(Data['MACD'][B_Periods:], color='Blue', label='MACD')
    D.plot(Data['Signal'][B_Periods:], color='Red', label='Signal')
    D.axhline(0, color='Black', linestyle=':')
    D.set_title(f'MACD - {TickerName}')

    Periods = -22

    E.plot(Data['Adj Close'][Periods:], color='Black', label='Adj Close')
    E.plot(Data['MMA72'][Periods:], color='Red', label='72')
    E.plot(Data['MMA21'][Periods:], color='Orange', label='21')
    E.axhline(PP, color='Green', linestyle=":")
    for pivotLine in [R1, R2, R3]:
        E.axhline(pivotLine, color='Red', linestyle=":")
    for pivotLine in [S1, S2, S3]:
        E.axhline(pivotLine, color='Blue', linestyle=":")

    E.plot(Data['CorridorHigh'][Periods:], color='Grey', linestyle=":")
    E.plot(Data['CorridorLow'][Periods:], color='Grey', linestyle=":")
    E.set_title(f'Pivot Graphic / Last {abs(Periods)} Periods - {TickerName}')

    F.bar(Data.index[Periods:], Data['Volume'][Periods:])
    F.set_title(f'Volume - {TickerName}')

    A.legend()
    B.legend()
    E.legend()
    D.legend()

    fig.autofmt_xdate()

    graph_file = r'.\\Graph\\' + TickerName + '.png'

    try:
        if isfile(graph_file):
            remove(graph_file)
            sleep(1)
        fig.savefig(graph_file)
        plt.close()
        pass
    except MemoryError as merror:
        print(merror)
        quit()
    except Exception as error:
        print(error)
    pass


def Make_Report():
    global File_Report
    with open(File_Report, 'w+') as target:
        target.write('Ticker,Adj Close\n')
    table_files = glob('.\\Tables\\*.xlsx')
    for table_file in table_files:
        try:
            Ticker = table_file.replace('.\\Tables\\', '')
            Ticker = Ticker.replace('.xlsx', '')
            Data = pd.read_excel(table_file)
            Last_Price = Data['Adj Close'][Data.index[-1]]
            with open(File_Report, 'a+') as target:
                target.write(f'{Ticker},{Last_Price}\n')
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
            data = Analisys(data, x)
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
            with open('.//CheckPoint_Error.txt', 'a+') as target:
                target.write(f'{x}\n')
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

    Make_Report()

    remove(File_List_Tickers)

    print(f'Ends in {stop - start} seconds...')
