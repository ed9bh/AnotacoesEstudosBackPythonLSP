#%%
import pandas as pd
import matplotlib.pyplot as plt
%matplotlib inline
#%%
Lista_de_FII = pd.read_csv('https://raw.githubusercontent.com/ed9bh/AnotacoesEstudosBackPythonLSP/master/Home/fii/Report.csv')
# %%
Lista_de_FII.head()

#%%
Lista_de_FII.describe()

#%%
Lista_de_FII['RendimentoAluguel'].plot()

#%%
Lista_de_FII['PrecoTitulo'].plot()
#%%
Lista_de_FII['Porcent'] = ((100 / Lista_de_FII['PrecoTitulo']) * Lista_de_FII['RendimentoAluguel'])

#%%
Lista_de_FII['Porcent'].head()

#%%
Lista_de_FII['Porcent'].plot()


#%%
fig, (ax1, ax2) = plt.subplots(nrows=2, ncols=1, sharex=True)

ax1.plot(Lista_de_FII['Ticker'][1:10], Lista_de_FII['Porcent'][1:10])
ax2.plot(Lista_de_FII['Ticker'][1:10], Lista_de_FII['RendimentoAluguel'][1:10])

ax1.legend()
ax2.legend()

fig.tight_layout()
plt.gcf().autofmt_xdate()
fig.show()