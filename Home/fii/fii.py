# %%
from os import chdir, mkdir, listdir
from os.path import isdir
from glob import glob
import pandas as pd
import pandas_datareader as pdr
import matplotlib.pyplot as plt
from matplotlib import dates as mpl_dates
from pandas.plotting import register_matplotlib_converters
from time import sleep, perf_counter
from lxml import html
import requests
from random import randint

register_matplotlib_converters()
plt.style.use("seaborn")
# %%
TotalStart_Time = perf_counter()

Base_Dir = r'A:\_Projetos\AnotacoesEstudosBackPythonLSP\Home\fii'
folder = 'logFiles'

chdir(Base_Dir)

if isdir(Base_Dir) == False:
    print('Necessário implementar outro diretorio...')
    quit()

data_sheet = pd.read_excel(Base_Dir + '/' + 'Lista_FII.xlsx')

if isdir(folder) == False:
    mkdir(folder)
    pass

# %%
Web_Search_Link = 'https://www.fundsexplorer.com.br/funds/'
Rent_XPath = '//*[@id="dividends"]/div/div/div[2]/div[1]/div/div/table/tbody/tr[1]/td[2]'

# %%

if __name__ == '__main__':
    for item in data_sheet['Ticker']:
        start = perf_counter()
        try:
            ticker = f'{item}11.SA'

            print(f'Começando {ticker}...', end='')
            df = pdr.DataReader(
                ticker, data_source='yahoo', start='2019-01-01')

            # Media Movel Aritimetica

            df['MMA10'] = df['Adj Close'].rolling(10).mean()
            df['MMA30'] = df['Adj Close'].rolling(30).mean()
            df['MMA60'] = df['Adj Close'].rolling(60).mean()

            try:
                df.to_csv(Base_Dir + '/' + folder + '/' + ticker + '.csv')
            except Exception as error:
                print(error, end='')

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

            plt.close()

            AluguelMes = '-'

            try:
                page = requests.get(Web_Search_Link + ticker)
                tree = html.fromstring(page.content)
                AluguelMes = tree.xpath(Rent_XPath)[0].text
                AluguelMes = AluguelMes.split(' ')
                AluguelMes = AluguelMes[1]
                AluguelMes = AluguelMes.replace(',', '.')
                pass
            except Exception as error:
                print(error, end='')

            with open(folder + '/Report.txt', 'a+') as ReportFile:
                ReportFile.write(item + '11')
                ReportFile.write('\t')
                ReportFile.write(AluguelMes)
                ReportFile.write('\t')
                ReportFile.write(str(df['Adj Close'][-1]))
                ReportFile.write('\n')

            print('Finalizado...', end='')

            sleep(randint(27, 45))

            pass
        except Exception as error:
            print(error)
            sleep(randint(135, 270))
            pass

        finish = perf_counter()

        print(f'Processado em {finish - start:0.2f}...')

# %%

TotalFinish_Time = perf_counter()

Total_Time = TotalFinish_Time - TotalStart_Time

print(f'\n\n\nApp Finalizado em {Total_Time:0.2f}...')
