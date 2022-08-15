#%%
from pytube import YouTube
from os import chdir, remove, getcwd
from os.path import isfile, dirname
from time import sleep
from tkinter import Tk
from re import findall
from sys import argv
# %%
if __name__ == '__main__':
    folder = argv[-1]
    chdir(folder)
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
        from os import system
        system('pip install pytube --no-cache-dir --upgrade --force')
        print('App atualizado, rode novamente...')
        print(f'{er}')
        pass

    print('Finalizado...')
    sleep(9)


    quit()

#%%
# pip install pytube --upgrade --force
# pip install setuptools --force
# https://github.com/nficano/pytube

# import pkg_resources as pkg
# installed = [p.key for p in pkg.working_set]

# if 'pytube' not in installed:
#     try:
#         from os import system
#         system('pip install pytube --no-cache-dir --upgrade --force')
#         pass
#     except Exception as err:
#         print(err)
