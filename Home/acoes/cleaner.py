# %%
from os import chdir
# %%
# Tratamento de dados
chdir(r'C:\Users\GOMEE11\Documents\_Referencias\Git\AnotacoesEstudosBackPythonLSP\Home\acoes')
file1 = r'.//RAW_Lista_Bovespa.txt'
file2 = r'.//Lista_Bovespa.csv'
# %%
with open(file1, 'r') as target:
    lista = target.readlines()

# %%
title = True
Lista_Nome = []
Lista_Ticker = []

for x in lista:
    if title is True:
        Lista_Nome.append(x.replace('\n', ''))
        title = False
        pass
    else:
        Lista_Ticker.append(x.replace('\n', ''))
        title = True
        pass
    pass

Lista_Nome, Lista_Ticker

# %%

with open(file2, 'w+') as target:
    target.write('Nome,Ticker\n')
    for x, y in zip(Lista_Nome, Lista_Ticker):
        target.write(f'{x},{y}\n')
        pass
    pass
