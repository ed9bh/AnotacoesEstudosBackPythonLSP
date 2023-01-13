# %%
import webbrowser
from sys import argv
from tkinter import Tk
from time import sleep
# %%
wb = webbrowser.WindowsDefault()
sleep(1)
# %%
if len(argv) > 2:
    URL = argv[1]
else:
    rt = Tk()
    URL = rt.clipboard_get()

#webbrowser.open(f'savefrom.net/{URL}')

URL = f'https://igram.io/{URL}'
URL = f'https://pt.savefrom.net/{URL}'

print(URL)
wb.open(url=URL)
sleep(9)