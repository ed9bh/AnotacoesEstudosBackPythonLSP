#%%
from glob import glob
from os import chdir, mkdir
from os.path import isfile, isdir
from time import sleep

# %%
ori = r'\\Sli3995\dados_v\Engenharia\Transporte\Fotos confratenização 2019\Alta'
dest = r'C:\Users\GOMEE11\Documents\SNC_2019_Pictures'

# %%
if isdir(dest) == False:
    mkdir(dest)

chdir(dest)

# %%
files = glob(ori + '\\*.jpg')

# %%
n = 0
for x in files:
    try:
        with open(x, 'rb') as copy:
            with open(f'{dest}\\{n:04.0f}.jpg', 'wb') as paste:
                paste.write(copy.read())
                pass
            pass
        n += 1
        sleep(0.5)
    except Exception as error:
        print(error)
        pass
