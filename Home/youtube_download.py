#%%
# pip install pytube --upgrade --force
# https://github.com/nficano/pytube
try:
    from pytube import YouTube
except:
    from os import system
    system('pip install pytube --no-cache-dir --upgrade --force')
    from pytube import YouTube
from os import chdir, remove, getcwd
from os.path import isfile, dirname
from time import sleep
from tkinter import Tk
from re import findall
# %%
rt = Tk()
link = rt.clipboard_get()
# %%
try:
    print(f'Baixando - {link}')
    YouTube(link).streams.get_highest_resolution().download()
except Exception as er:
    import webbrowser
    wb = webbrowser.WindowsDefault()
    URL = f'https://pt.savefrom.net/{link}'
    print(f'Baixando pelo site (Modulo Youtube Inoperante) : {URL}')
    wb.open(url=URL)
    erro = True
    print(f'{er}')
    from os import system
    system('pip install pytube --no-cache-dir --upgrade --force')
    print('App atualizado, rode novamente...')
print('Finalizado...')
sleep(30)
