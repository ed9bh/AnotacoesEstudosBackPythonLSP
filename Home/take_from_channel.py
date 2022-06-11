#%%
from requests import get
from lxml import html
import re
from pytube import YouTube
from os.path import isfile, isdir
from time import sleep
from random import randint
from os import remove, chdir, mkdir
# %%
def make_list(channel):
    page = get(channel).content
    videos = re.findall('watch\?v=[a-zA-Z0-9-_]{5,20}', str(page))
    links = []

    for l in set(videos):
        links.append(f'https://www.youtube.com/{l}')
        pass

    return links

# %%
file_name = 'channel.txt'

if isfile(file_name) == False:
    with open(file_name, 'w') as target:
        target.write('')
    print('Não havia arquivo')
    quit()
# %%
with open(file_name, 'r') as target:
    channel_list = target.read()
    pass

channel_list = channel_list.split('\n')
channel_list = list(filter(len, channel_list))
# %%
for num, cha in enumerate(channel_list):
    cha_ = make_list(cha)

    x = get(channel_list[num])
    x = str(x.content)
    
    y = re.findall('title[a-zA-Z=-_\s<]{1,50}', x)[0]

    z = y.replace('title>', '')
    z = z.replace('\\n', '')
    z = z.split(' ')
    z = list(filter(len, z))

    w = ''

    for item in z:
        w = w + '_' + item
        pass

    w = w[1:]

    if isdir(w):
        pass
    else:
        mkdir(w)
        pass

    chdir(w)

    sleep(1)

    for c in enumerate(cha_):
        print(f'Donwload {c[0] + 1} / {len(cha_)} : {c[1]}', end='')
        sleep(0.5)
        try:
            YouTube(c[1]).streams.get_highest_resolution().download()
            print(f'\rDonwload {c[0] + 1} / {len(cha_)} : {c[1]} <---> Pronto')
            sleep(randint(3, 36))
        except Exception as er:
            print(f' !!!\n\tOcorreu um erro : {er}')
            with open('channel_er.log', 'a+') as target:
                target.write('\n' + c[1])
            sleep(randint(3, 36))
        pass

    chdir('..')
# %%
# with open(file_name, 'w') as target:
#     target.write('')

remove(file_name)

print('Processo finalizado...')
sleep(90)