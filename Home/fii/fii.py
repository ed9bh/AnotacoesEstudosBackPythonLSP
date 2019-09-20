# %%
from os import chdir, mkdir
from os.path import isdir
import pandas as pd
import pandas_datareader as pdr
import matplotlib.pyplot as plt
from matplotlib import dates as mpl_dates
from time import sleep

# %%
chdir(r'C:\Users\GOMEE11\Documents\_Referencias\Git\AnotacoesEstudosBackPythonLSP\Home\fii')
folder = 'logFiles'

data_sheet = pd.read_excel('Lista_FII.xlsx')

if isdir(folder) == False:
    mkdir(folder)


# %%

plt.style.use('seaborn')

for item in data_sheet['Ticker']:
    ticker = f'{item}11.SA'
    df = pdr.DataReader(ticker, data_source='yahoo', start='2019-06-01')

    # Media Movel Aritimetica

    df['MMA10'] = df['Adj Close'].rolling(10).mean()
    df['MMA30'] = df['Adj Close'].rolling(30).mean()
    df['MMA60'] = df['Adj Close'].rolling(60).mean()

    # Graficos

    plt.plot(df['Adj Close'], color='Blue', label='Adj Close')
    plt.plot(df['MMA10'], color='Yellow', label='MMA_10')
    plt.plot(df['MMA30'], color='Orange', label='MMA_30')
    plt.plot(df['MMA60'], color='Red', label='MMA_60')

    plt.gcf().autofmt_xdate()
    date_format = mpl_dates.DateFormatter('%b, %d, %Y')
    plt.gca().xaxis.set_major_formatter(date_format)

    plt.legend()

    plt.title(f'Estudo do \"{ticker}\"')

    plt.savefig(folder + '/' + ticker + '.png')

    sleep(60)
