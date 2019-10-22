# %%
from os import chdir, mkdir, listdir, remove
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

try:
    remove(folder + '/Report.txt')
except:
    pass

if isdir(Base_Dir) == False:
    print('Necessário implementar outro diretorio...')
    quit()

data_sheet = pd.read_excel(Base_Dir + '/' + 'Lista_FII.xlsx')

if isdir(folder) == False:
    mkdir(folder)
    pass

# %%
Web_Search_Link = 'https://www.fundsexplorer.com.br/funds/'
Rent_Mes = '//*[@id="dividends"]/div/div/div[2]/div[1]/div/div/table/tbody/tr[1]/td[2]'
Rent_3_Meses = '//*[@id="dividends"]/div/div/div[2]/div[1]/div/div/table/tbody/tr[1]/td[3]'
Rent_6_Meses = '//*[@id="dividends"]/div/div/div[2]/div[1]/div/div/table/tbody/tr[1]/td[4]'
Rent_12_Meses = '//*[@id="dividends"]/div/div/div[2]/div[1]/div/div/table/tbody/tr[1]/td[5]'
Rent_IPO = '//*[@id="dividends"]/div/div/div[2]/div[1]/div/div/table/tbody/tr[1]/td[6]'
Aplicacao_12_Meses = '//*[@id="simulation"]/div/div/div[2]/div/div[1]/ul/li[1]/div[2]/span[2]'
Montante_Final_Poupanca = '//*[@id="simulation"]/div/div/div[2]/div/div[1]/ul/li[2]/div[2]/span[2]'
Montante_Final_Fundo = '//*[@id="simulation"]/div/div/div[2]/div/div[1]/ul/li[3]/div[2]/span[2]'
Rendimento_Insento_IRPF = '//*[@id="simulation"]/div/div/div[2]/div/div[2]/ul/li[1]/div[2]/span[2]'
Patrimonio_Inicial = '//*[@id="basic-infos"]/div/div/div[2]/div/div[1]/ul/li[4]/div[2]/span[2]'
Valorizacao_Patrimonial = '//*[@id="simulation"]/div/div/div[2]/div/div[2]/ul/li[2]/div[2]/span[2]'
Titulo_X_Poupanca = '//*[@id="simulation"]/div/div/div[2]/div/div[2]/ul/li[3]/div[2]/span[2]'
Inicio_Operacao = '//*[@id="basic-infos"]/div/div/div[2]/div/div[1]/ul/li[2]/div[2]/span[2]'
Durabilidade = '//*[@id="basic-infos"]/div/div/div[2]/div/div[2]/ul/li[5]/div[2]/span[2]'
Preco = '//*[@id="stock-price"]/span[1]'

Extra_Info_Lista = [Rent_Mes, Rent_3_Meses, Rent_6_Meses, Rent_12_Meses, Rent_IPO, Aplicacao_12_Meses, Montante_Final_Fundo,
                    Montante_Final_Poupanca, Rendimento_Insento_IRPF, Patrimonio_Inicial, Valorizacao_Patrimonial, Titulo_X_Poupanca, Preco]


with open(folder + '/Report.txt', 'w', encoding='ANSI') as ReportFile:
    ReportFile.write(
        'Ticker\tMes\tTrimes\tSemes\tAnual\tIPO\tAplic. Ano\t' +
        'Mont. Fundo\tMont. Poupanca\tRend. Insento IRPF\tPatrimonio Ini.\tVal. Patrimonial\tTitulo X Poupanca' +
        '\tPreco\tInicio\tPrazo\n'
    )

# %%

if __name__ == '__main__':
    with open(folder + '/Report.txt', 'w', encoding='ANSI') as ReportFile:
        ReportFile.write(
            'Ticker\tMes\tTrimes\tSemes\tAnual\tIPO\tAplic. Ano\t' +
            'Mont. Fundo\tMont. Poupanca\tRend. Insento IRPF\tPatrimonio Ini.\tVal. Patrimonial\tTitulo X Poupanca' +
            '\tPreco\tInicio\tPrazo\n'
        )
    
    for item in data_sheet['Ticker']:
        start = perf_counter()
        try:
            ticker = f'{item}11.SA'

            print(f'Começando {ticker}...', end='')
            try:
                df = pdr.DataReader(
                    ticker, data_source='yahoo', start='2019-01-01')

                # Media Movel Aritimetica

                df['MMA10'] = df['Adj Close'].rolling(10).mean()
                df['MMA30'] = df['Adj Close'].rolling(30).mean()
                df['MMA60'] = df['Adj Close'].rolling(60).mean()

                try:
                    df.to_csv(Base_Dir + '/' + folder + '/' + ticker + '.csv')
                except Exception as error:
                    print(error, end='...')

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
            except:
                print('Dados não encontrados no Yahoo...', end='')

            AluguelMes = '-'

            try:
                page = requests.get(Web_Search_Link + ticker)
                tree = html.fromstring(page.content)
                pass
            except Exception as error:
                print(error, end='...')

            with open(folder + '/Report.txt', 'a+', encoding='ANSI') as ReportFile:
                ReportFile.write(item + '11')
                for Item in Extra_Info_Lista:
                    try:
                        Info = tree.xpath(Item)[0].text
                        if Item is Aplicacao_12_Meses:
                            Info = Info.split(' ')
                            Info = Info[0]
                        elif Item is Titulo_X_Poupanca:
                            Info = Info.split(' ')
                            Info = Info[0]
                        elif Item is Montante_Final_Fundo:
                            Info = Info.split(' ')
                            Info = Info[-1]
                        elif Item is Preco:
                            Info = Info.replace(' ', '')
                            Info = Info.replace('\n', '')
                            Info = Info.replace('R$', '')
                            pass
                        elif Item is Patrimonio_Inicial:
                            Info = Info.replace(' ', '')
                            Info = Info.replace('\n', '')
                            Info = Info.replace('R$', '')
                            print(Info)
                        else:
                            Info = Info.split(' ')
                            Info = Info[1]
                        Info = Info.replace('.', '')
                        Info = Info.replace(',', '.')
                        ReportFile.write('\t' + Info)
                    except:
                        ReportFile.write('\tNA')
                        pass
                    pass
                ReportFile.write('\t')
                try:
                    Inicio = tree.xpath(Inicio_Operacao)[0].text
                    Prazo = tree.xpath(Durabilidade)[0].text
                    Inicio = Inicio.replace(' ', '')
                    Inicio = Inicio.replace('\n', '')
                    Inicio = Inicio.replace('de', ' de ')
                    Inicio = Inicio.replace('ç', 'c')
                    Prazo = Prazo.replace(' ', '')
                    Prazo = Prazo.replace('\n', '')
                    pass
                except:
                    Inicio, Prazo = ('NA', 'NA')
                    pass
                ReportFile.write(Inicio + '\t' + Prazo + '\n')

                # break
                
            print('Finalizado...', end='')

            sleep(randint(18, 36))

            pass
        except Exception as error:
            with open(folder + '/Report.txt', 'a+', encoding='ANSI') as ReportFile:
                ReportFile.write(item + '11')
                ReportFile.write('\tNA' * 12)
                ReportFile.write('\n')
            print(error)
            sleep(randint(108, 207))
            pass

        finish = perf_counter()

        print(f'Processado em {finish - start:0.2f}...')

# %%

TotalFinish_Time = perf_counter()

Total_Time = TotalFinish_Time - TotalStart_Time

print(f'\n\n\nApp Finalizado em {Total_Time:0.2f}...')

# %%
