#%%
from time import sleep
#%%
c = 0
f = 60
while c < f:
    print('\r[', end='')
    print('/' * c, end='')
    print(' ' * ((f - 1) - c), end='')
    print(']', end='')
    c += 1
    sleep(1)
