#%%
# pip install pytube --upgrade --force
# https://github.com/nficano/pytube
from pytube import YouTube
from os import chdir, remove, getcwd
from os.path import isfile, dirname
from time import sleep
# %%
folder = dirname(__file__)
chdir(folder)
filename = 'down_list.txt'
# %%
if isfile(filename) == False:
    with open(filename, 'w') as target:
        target.write('')
        pass
    quit()
# %%
with open(filename, 'r') as target:
    links = target.read()
    pass
links = links.split('\n')
links = list(filter(len, links))
# %%
erro = False
total = len(links)
for c, link in enumerate(links):
    print(f'Baixando vídeo {c + 1} / {total} : {link}')
    try:
        YouTube(link).streams.get_highest_resolution().download()
    except Exception as er:
        erro = True
        print(f'{er}')
        from os import system
        system('pip install pytube --no-cache-dir --upgrade --force')
        print('App atualizado, rode novamente...')
    if ((c + 1) < total):
        sleep(36)
# %%
if erro == False:
    # with open(filename, 'w') as target:
    #     target.write('')
    #     pass
    remove(filename)
    pass
#%%
print('Finalizado...')
sleep(90)