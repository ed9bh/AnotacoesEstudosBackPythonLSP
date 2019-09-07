# %%
# Modulos
from os import chdir, remove, rename, walk, listdir
from os.path import isfile, isdir
from shutil import move, copyfile
from glob import glob
from time import sleep
from datetime import datetime
from zipfile import ZipFile
from re import findall, search
from json import load, dump
from rarfile import RarFile
# %%
# Diretorios
dir_001 = r'C:\Users\ericd\Downloads\Filmes\Series'
dir_002 = r'\\DNS-320\P2P\Torrent'
dir_003 = r'\\DNS-320\P2P\Complete'
dir_004 = r'\\DNS-320\Volume_1\VIDEOS\Series'
dir_005 = r'A:\Series'
dir_006 = r'\\DNS-320\P2P\incomplete'
# %%
# Funções

srt_files, tor_files, interess_files = None, None, None
file_checkpoint = 'checkpoint.json'
series_checkpoint = {}


def locateBase():
    global srt_files, tor_files, interess_files
    srt_files = glob('*.srt')
    tor_files = glob('*.torrent')
    srt_files.sort()
    tor_files.sort()
    interess_files = srt_files + tor_files
    sleep(3)
    pass


def unzipFiles():
    zip_files = glob('*.zip')
    rar_files = glob('*.rar')
    for z in zip_files:
        with ZipFile(z) as target:
            target.extractall()
            pass
        pass
    for r in rar_files:
        with RarFile(r) as target:
            target.extractall()
        pass
    for root, folder, arch in walk(dir_001):
        print(root)
        for k in glob(root + '\\*'):
            try:
                move(k, dir_001)
            except:
                pass
            pass
        pass
    sleep(3)
    pass


def checkpoint():
    global srt_files, tor_files
    count = 0
    for s, t in zip(srt_files, tor_files):
        if s.replace('.srt', '') == t.replace('.torrent', ''):
            raw_name = s.replace('.srt', '')
            se_ep = findall('S\d[0-9]E\d[0-9]', raw_name)[0]
            season = findall('S\d[0-9]', raw_name)
            epsode = findall('E\d[0-9]', raw_name)
            list_name = raw_name.split('.')
            list_temp = []
            final_name = ''
            for i in list_name:
                if i == se_ep:
                    break
                else:
                    list_temp.append(i)
                    pass
                pass
            for j in list_temp:
                final_name += j + ' '
                pass
            title = final_name[0:-1]
            se_ep = se_ep.replace('E', '_E')
            final_name = title + '_' + se_ep

            series_checkpoint[count] = {}
            series_checkpoint[count]['Title'] = title
            series_checkpoint[count]['Season'] = season[0]
            series_checkpoint[count]['Episode'] = epsode[0]
            series_checkpoint[count]['raw_name'] = raw_name
            series_checkpoint[count]['OriginalTorName'] = t
            series_checkpoint[count]['OriginalSrtName'] = s
            series_checkpoint[count]['NewVidName'] = final_name
            series_checkpoint[count]['NewSrtName'] = final_name + '.srt'

            count += 1
            pass
        pass
    with open(file_checkpoint, 'w+') as CHECK:
        dump(series_checkpoint, CHECK)
        pass
    sleep(3)
    pass


def garbage():
    global interess_files
    for f in interess_files:
        try:
            if search('.1080p.', f) or search('.720p.', f):
                remove(f)
                pass
            pass
        except Exception as error:
            print(error)
    pass


def deleteline_DICT_JSON(x):
    global series_checkpoint
    del(series_checkpoint[x])
    with open(file_checkpoint, 'w') as target:
        dump(series_checkpoint)
        pass


# %%
chdir(dir_001)
unzipFiles()
locateBase()
garbage()
locateBase()
# %%
locateBase()
checkpoint()
