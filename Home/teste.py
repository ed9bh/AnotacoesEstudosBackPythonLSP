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

# %%
from os import system
# %%
system("netsh interface show interface")
# %%
system("netsh interface set interface 'Wifi' disabled") 
# %%
system("netsh interface set interface 'Wifi' enabled")
# %%
