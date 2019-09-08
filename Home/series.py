# %%
# Modulos
from os import chdir, mkdir, remove, rename, walk, listdir
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
BaseDownloadFolder = r'C:\Users\ericd\Downloads\Filmes\Series'
BaseTorrentToDownload = r'\\DNS-320\P2P\Torrent'
BaseCompletDownload = r'\\DNS-320\P2P\Complete'
BaseFirstPermanentBackup = r'\\DNS-320\Volume_1\VIDEOS\Series'
BaseSecondKeep = r'A:\Series'
BaseIncomplete = r'\\DNS-320\P2P\incomplete'
# %%
# Funções

srt_files, tor_files, interess_files = None, None, None
checkpoint_file = 'checkpoint.json'
checkpoint_serie = {}


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
    for root, folder, arch in walk(BaseDownloadFolder):
        print(root)
        for k in glob(root + '\\*'):
            try:
                move(k, BaseDownloadFolder)
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

            checkpoint_serie[count] = {}
            checkpoint_serie[count]['Title'] = title
            checkpoint_serie[count]['Season'] = season[0]
            checkpoint_serie[count]['Episode'] = epsode[0]
            checkpoint_serie[count]['raw_name'] = raw_name
            checkpoint_serie[count]['OriginalTorName'] = t
            checkpoint_serie[count]['OriginalSrtName'] = s
            checkpoint_serie[count]['NewVidName'] = final_name
            checkpoint_serie[count]['NewSrtName'] = final_name + '.srt'

            count += 1
            pass
        pass
    with open(checkpoint_file, 'w+') as CHECK:
        dump(checkpoint_serie, CHECK)
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
    global checkpoint_serie
    del(checkpoint_serie[x])
    with open(checkpoint_file, 'w') as target:
        dump(checkpoint_serie, target)
        pass
    pass


def load_checkpoint():
    global checkpoint_serie
    with open(checkpoint_file, 'r') as target:
        checkpoint_serie = load(target)
    pass


def folderCreation(reg):
    global BaseFirstPermanentBackup
    TitleDirStorage = BaseFirstPermanentBackup + \
        '\\' + checkpoint_serie[reg]['Title']
    SeasonDirStorage = TitleDirStorage + '\\' + checkpoint_serie[reg]['Season']
    TitleDir = BaseSecondKeep + '\\' + checkpoint_serie[reg]['Title']
    SeasonDir = TitleDir + '\\' + checkpoint_serie[reg]['Season']
    for d in [TitleDirStorage, TitleDir, SeasonDirStorage, SeasonDir]:
        if isdir(d) == False:
            try:
                mkdir(d)
                pass
            except Exception as error:
                print(error)
            pass
        pass
    pass


def srtMoveCopy(reg):
    vidOriginalName = checkpoint_serie['OriginalSrtName']
    title = checkpoint_serie[reg]['Title']
    season = checkpoint_serie[reg]['Season']
    episode = checkpoint_serie[reg]['NewVidName']
    ext = 'srt'

    origin = '{0}\\{1}'.format(
        BaseDownloadFolder,
        vidOriginalName
    )

    destinyStorage = '{0}\\{1}\\{2}\\{3}.{4}'.format(
        BaseFirstPermanentBackup,
        title,
        season,
        episode,
        ext
    )

    destiny = '{0}\\{1}\\{2}\\{3}.{4}'.format(
        BaseSecondKeep,
        title,
        season,
        episode,
        ext
    )

    copyfile(origin, destiny)
    move(origin, destinyStorage)
    pass


def torMove(reg):
    origin = '{0}\\{1}'.format(
        BaseDownloadFolder,
        checkpoint_serie[reg]['OriginalTorName']
    )
    destiny = '{0}\\{1}'.format(
        BaseTorrentToDownload,
        checkpoint_serie[reg]['OriginalTorName']
    )
    move(origin, destiny)
    pass


def vidMoveCopy(reg, folder, ext):
    vidOriginalName = checkpoint_serie['OriginalTorName']
    vidOriginalName = vidOriginalName.replace('.torrent', '')
    title = checkpoint_serie[reg]['Title']
    season = checkpoint_serie[reg]['Season']
    episode = checkpoint_serie[reg]['NewVidName']

    origin = '{0}\\{1}.{2}'.format(
        folder,
        vidOriginalName,
        ext
    )

    destinyStorage = '{0}\\{1}\\{2}\\{3}.{4}'.format(
        BaseFirstPermanentBackup,
        title,
        season,
        episode,
        ext
    )

    destiny = '{0}\\{1}\\{2}\\{3}.{4}'.format(
        BaseSecondKeep,
        title,
        season,
        episode,
        ext
    )

    copyfile(origin, destiny)
    move(origin, destinyStorage)

    pass


def clearMess():
    remove(BaseDownloadFolder + '\\' + checkpoint_file)
    pass


# %%
chdir(BaseDownloadFolder)
unzipFiles()
locateBase()
garbage()
locateBase()
checkpoint()
