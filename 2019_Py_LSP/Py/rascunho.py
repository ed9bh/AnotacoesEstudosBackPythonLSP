# %%
%matplotlib inline
from numpy import array
import pandas as pd
# %%
dtsheet = pd.read_csv('./teste.csv', delimiter=';', header=None)

# %%
dtsheet

# %%
dtsheet.plot(x=0, y=1, figsize=(12,12), grid=True)

#%%
