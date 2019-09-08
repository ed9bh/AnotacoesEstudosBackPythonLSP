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
# Variaveis

srt_files, tor_files, interess_files = None, None, None
checkpoint_file = 'checkpoint.json'
checkpoint_serie = {}
# %%
# Funções


def locateBase():
    print('Listando arquivos...')
    global srt_files, tor_files, interess_files
    try:
        srt_files = glob('*.srt')
        tor_files = glob('*.torrent')
        srt_files.sort()
        tor_files.sort()
        interess_files = srt_files + tor_files
        pass
    except:
        pass
    sleep(3)
    pass


def unzipFiles():
    print('Descompactando arquivos...')
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
    sleep(9)
    for root, folder, arch in walk(BaseDownloadFolder):
        chdir(root)
        arqs = glob('*.srt') + glob('*.torrent')
        for k in arqs:
            print('Arquivo Encontrado : ' + k)
            try:
                move(root + '\\' + k, BaseDownloadFolder)
            except:
                pass
            pass
        pass
    chdir(BaseDownloadFolder)
    sleep(60)
    pass


def checkpoint():
    global srt_files, tor_files
    print('Criando Checkpoint...')
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

            reg = str(count)

            checkpoint_serie[reg] = {}
            checkpoint_serie[reg]['Title'] = title
            checkpoint_serie[reg]['Season'] = season[0]
            checkpoint_serie[reg]['Episode'] = epsode[0]
            checkpoint_serie[reg]['raw_name'] = raw_name
            checkpoint_serie[reg]['OriginalTorName'] = t
            checkpoint_serie[reg]['OriginalSrtName'] = s
            checkpoint_serie[reg]['NewVidName'] = final_name
            checkpoint_serie[reg]['NewSrtName'] = final_name + '.srt'

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
    print('Removendo o lixo...')
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
    print('Deletando o registro bem sucedido...')
    del(checkpoint_serie[x])
    with open(checkpoint_file, 'w') as target:
        dump(checkpoint_serie, target)
        pass
    pass


def load_checkpoint():
    global checkpoint_serie
    print('Carregando Checkpoint Existente...')
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
            print('Criando diretorio...')
            try:
                mkdir(d)
                pass
            except Exception as error:
                print(error)
            pass
        pass
    pass


def srtMoveCopy(reg):
    vidOriginalName = checkpoint_serie[reg]['OriginalSrtName']
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
    # Copia legenda...
    print(f'Copiando : {destiny}')
    try:
        copyfile(origin, destiny)
        pass
    except Exception as error:
        print('Erro ocorrido : ', str(error))
        pass
    sleep(3)
    # Move legenda...
    print(f'Copiando : {destinyStorage}')
    try:
        move(origin, destinyStorage)
        pass
    except Exception as error:
        print('Erro ocorrido : ', str(error))
    sleep(3)
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
    print(f'Iniciando torrente : {destiny}')
    try:
        move(origin, destiny)
        pass
    except Exception as error:
        print('Erro ocorrido : ', str(error))
        pass
    sleep(3)
    pass


def vidMoveCopy(reg, folder):
    vidOriginalName = checkpoint_serie[reg]['OriginalVidName']
    vidOriginalName = vidOriginalName.replace('.torrent', '')
    title = checkpoint_serie[reg]['Title']
    season = checkpoint_serie[reg]['Season']
    episode = checkpoint_serie[reg]['NewVidName']

    origin = '{0}\\{1}'.format(
        folder,
        vidOriginalName
    )

    destinyStorage = '{0}\\{1}\\{2}\\{3}'.format(
        BaseFirstPermanentBackup,
        title,
        season,
        episode
    )

    destiny = '{0}\\{1}\\{2}\\{3}'.format(
        BaseSecondKeep,
        title,
        season,
        episode
    )

    # Copia video...
    try:
        print('Copiando para pasta Series...')
        print(f'... {destiny} ...')
        print(f'Iniciado em {datetime.now()}')
        copyfile(origin, destiny)
        print(f'Finalizado em {datetime.now()}')
        pass
    except Exception as error:
        print('Erro ocorrido : ', str(error))
        pass
    sleep(3)
    # Move video...
    try:
        print('Copiando para Backup...')
        print(f'... {destinyStorage} ...')
        print(f'Iniciado em {datetime.now()}')
        move(origin, destinyStorage)
        print(f'Finalizado em {datetime.now()}')
        pass
    except Exception as error:
        print('Erro ocorrido : ', str(error))
    sleep(3)
    pass

    pass


def clearMess(x):
    print('Apagando Checkpoint...')
    if x == True:
        remove(BaseDownloadFolder + '\\' + checkpoint_file)
    else:
        delList = glob(BaseDownloadFolder + '\\' + '*.*')
        for erase in delList:
            try:
                remove(erase)
                pass
            except Exception as error:
                print(error)
            pass
    pass


def playlist(reg):
    day = datetime.now().day
    month = datetime.now().month
    year = datetime.now().year

    title = checkpoint_serie[reg]['Title']
    season = checkpoint_serie[reg]['Season']
    episode = checkpoint_serie[reg]['NewVidName']
    vidFile = f'{title}/{season}/{episode}'

    plName = f'{year}_{month:02d}_{day:02d}-TV.m3u'

    print(f'Criando Playtist : ... {plName} ...')

    arq = BaseSecondKeep + '\\' + plName

    with open(arq, 'a+') as target:
        target.write(vidFile)
        target.write('\n')
        pass
    pass


def directDownload():
    print('Não implementado...')
    pass


# %%
# Programa
if __name__ == '__main__':

    # Acessa pasta principal
    print(f'Progresso {datetime.now()}')
    chdir(BaseDownloadFolder)

    # Descompacta arquivos
    print(f'Progresso {datetime.now()}')
    unzipFiles()

    # Localiza arquivos de interesse
    print(f'Progresso {datetime.now()}')
    locateBase()

    # Limpa arquivos indesejaveis
    print(f'Progresso {datetime.now()}')
    garbage()

    # Atualiza lista de arquivos
    print(f'Progresso {datetime.now()}')
    locateBase()

    # Cria ou Carrega o cronograma de downloads
    print(f'Progresso {datetime.now()}')
    if isfile(BaseDownloadFolder + '\\' + checkpoint_file):
        reStart = True
        load_checkpoint()
        pass
    else:
        checkpoint()
        reStart = False
        pass

    for item in checkpoint_serie:

        folderCreation(item)

        torMove(item)

        srtMoveCopy(item)

        pass

    # Tratamento para nomes errados
    print(f'Progresso {datetime.now()}')
    chave = True
    if chave is True:
        chdir(BaseCompletDownload)
        corrigir = glob(pathname='*.mkv') + \
            glob(pathname='*.mp4') + glob(pathname='*.avi')
        errados = ['Nine.Nine']
        corretos = ['Nine-Nine']
        for c in corrigir:
            for e, c in zip(errados, corretos):
                new = c.replace(e, c)
                try:
                    rename(c, new)
                    pass
                except:
                    pass

    # Move os Videos para a pasta correta...
    print(f'Progresso {datetime.now()}')
    sleep(600 * 6)

    done = []

    for item in checkpoint_serie:
        vidExt = ['.mp4', '.mkv', '.avi']
        vidName = checkpoint_serie[item]['OriginalSrtName']
        vidName = vidName.replace('.srt', '')
        vidNewName = checkpoint_serie[item]['NewVidName']

        for root, folder, arq in walk(BaseCompletDownload):
            for i in vidExt:
                if isfile(root + '\\' + vidName + i) and not vidName.endswith('.mp4'):
                    checkpoint_serie[item]['OriginalVidName'] = vidName + i
                    checkpoint_serie[item]['NewVidName'] = vidNewName + i
                    print(checkpoint_serie[item]['OriginalVidName'])
                    print(checkpoint_serie[item]['NewVidName'])
                    pass
                pass
            try:
                if isfile(root + '\\' + checkpoint_serie[item]['OriginalVidName']):
                    vidMoveCopy(item, root)
                    playlist(item)
                    done.append(item)
                    pass
                pass
            except Exception as error:
                print('Erro : Arquivo pode já ter sido copiado ou (' + str(error) + ')')
            pass
        pass

    for item in checkpoint_serie:
        playlist(item)
        pass

    for d in done:
        chdir(BaseDownloadFolder)
        deleteline_DICT_JSON(d)

    print(f'Progresso {datetime.now()}')
    if reStart == True:
        clearMess(True)
    elif reStart == False:
        clearMess(False)
