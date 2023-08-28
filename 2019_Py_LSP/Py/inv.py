# %%
#!pip install yfinance
# %%
import yfinance as yf
from datetime import datetime as dt
from pandas import DataFrame as df
import pandas as pd
import numpy as np
from matplotlib import pyplot as plt
plt.style.use('bmh')
from time import sleep
# %%
_urlbase = 'http://www.fundamentus.com.br/detalhes.php?papel='

def Fund_Data(ticker:str, url:str):
    if 'get' not in globals():
        from requests import get
        #from lxml import html
    agent = {'User-Agent':'Mozilla/5.0'}
    page = f'{url+ticker}'
    content = get(page, headers=agent).text
    return content #.encode('utf-8')

def Preco_Justo(VPA:float, LPA:float, COTACAO:float):
    if VPA > 0 and LPA > 0:
        preco_justo = (22 * LPA * VPA) ** 0.5
        fator = ((preco_justo - COTACAO) - 1) * 100
        diferenca = preco_justo - COTACAO
        return (preco_justo, fator, diferenca)
    else:
        return (0 , 0 , 0)
# %%
start = f'{dt.now().year - 1}-{dt.now().month}-{dt.now().day}'
end = f'{dt.now().year}-{dt.now().month}-{dt.now().day}'
# %%
tickerlist = ['WEGE3', 'PETR3', 'CPLE6', 'KLBN11', 'VALE3', 'TASA4', 'ELET3', 'OIBR3', 'BEEF3']
tickerlist.sort()
tickers = ''
tickers = 'BTC-USD GC=F CL=F USDBRL=X ^BVSP'
for i in tickerlist:
    tickers = tickers + ' ' + i + '.SA'
# %%
stock_data = yf.Tickers(tickers)
data = df()
data = stock_data.history(start=start, end=end)['Close']
data.ffill(inplace=True)
# %%
data.head()
# %%
data.tail()
# %%
data.info()
# %%
data.describe()
# %%
log_returns = np.log(data / data.shift(1))
std_returns = log_returns.std()
var_returns = log_returns.var() * 250 ** 0.5
cov_returns = log_returns.cov() * 250
cor_returns = log_returns.corr()
# %%
print(std_returns * 100, file=open('std_returns.txt', mode='+w', encoding='UTF-8'))
std_returns * 100
# %%
print(var_returns * 100, file=open('var_returns.txt', mode='+w', encoding='UTF-8'))
var_returns * 100
# %%
cov_returns.to_excel('cov_returns.xlsx')
cov_returns
# %%
cor_returns.to_excel('cor_returns.xlsx')
cor_returns
# %%
(data / data.iloc[0] * 100).plot(figsize=(20,10), lw=1)
plt.title('Gráfico Normalizado para Comparação de Valorização Geral')
plt.tight_layout()
plt.savefig('normalizado_em_100.png')
# %%
# ANÁLISE FUNDAMENTALISTA
print('', file=open('log.txt', mode='+w', encoding='UTF-8'))
for t in tickerlist:
    fundamentalist = {}
    fund_data = Fund_Data(t, _urlbase)
    df_page = pd.read_html(fund_data.encode('iso-8859-1'), thousands='.')
    fundamentalist[t] = {
        'Empresa' : df_page[0].iloc[2,1],
        'Setor' : df_page[0].iloc[3,1],
        'Sub-Setor' : df_page[0].iloc[4,1],
        'Cotacao' : float(df_page[0].iloc[0,3].replace(',', '.')),
        'Num_Acoes' : float(df_page[1].iloc[1,3].replace(',', '.')),
        'LPA' : float(df_page[2].iloc[1,5].replace(',', '.')),
        'VPA' : float(df_page[2].iloc[2,5].replace(',', '.'))
        }
    c = fundamentalist[t]['Cotacao']
    v = Preco_Justo(fundamentalist[t]['VPA'], fundamentalist[t]['LPA'], c)
    text1 = fundamentalist[t]
    text2 = f'Cotação de {t}: {c:.2f} (Lote={c*100:.2f})\nPreço justo de {t}: {v[0]:.2f}\nNet: {(v[0]) - c:.2f} (Net*100={((v[0]) - c)*100:.2f})\n'
    print(text1, file=open('log.txt', mode='+a', encoding='UTF-8'))
    print(text2, file=open('log.txt', mode='+a', encoding='UTF-8'))
    print(text1)
    print(text2)
# %%