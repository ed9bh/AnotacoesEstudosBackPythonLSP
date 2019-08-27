# %%
from datetime import time, datetime, timedelta
from secrets import token_hex
from os import chdir
import struct

# %%
h, m = datetime.now().hour, datetime.now().minute

# %%
18 - h, 60 - m

# %%
senha = token_hex(32)
with open('swordfish.asc', 'a+') as file: # 'w' 'w+' 'r'
    file.write(senha + '\n')

#%%
# https://docs.python.org/2/library/struct.html
with open('teste.dat', 'wb+') as f:
    zzz = 'Texto de teste...'
    f.write(struct.pack('azaz', zzz.split(sep=' ')))