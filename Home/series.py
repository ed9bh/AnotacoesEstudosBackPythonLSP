#%%
# pip install py7zr rarfile
from os import chdir, mkdir, remove, rename, listdir, walk, system, makedirs
from os.path import isdir, isfile
from glob import glob
from zipfile import ZipFile
from rarfile import RarFile
from py7zr import SevenZipFile
from re import findall, search
from time import sleep
#%%

class Color():
    system('color')
    
    HEADER = '\033[95m'
    OKBLUE = '\033[94m'
    OKGREEN = '\033[92m'
    WARNING = '\033[93m'
    FAIL = '\033[91m'
    END = '\033[0m'
    BOLD = '\033[1m'
    UNDERLINE = '\033[4m'

    BLACK = '\033[30m'
    RED = '\033[31m'
    GREEN = '\033[32m'
    YELLOW = '\033[33m'
    BLUE = '\033[34m'
    MAGENTA = '\033[35m'
    CYAN = '\033[36m'
    WHITE = '\033[37m'

    BG_BLACK = '\033[99m'
    BG_WHITE = '\033[100m'
    BG_RED = '\033[101m'
    BG_GREEN = '\033[102m'
    BG_YELLOW = '\033[103m'
    BG_BLUE = '\033[104m'
    BG_PINK = '\033[105m'
    BG_CYAN = '\033[106m'
    BG_GREY = '\033[107m'
    pass

def Translate_Name(raw_name:str):
    file_type = findall('\.[a-zA-Z0-9]{3,7}', raw_name)[-1][1:]

    name = raw_name.replace('.' + file_type, '')
    name = name.upper()

    se_ep = findall('S\d[0-9]E\d[0-9]', name)[0]
    season = findall('S\d[0-9]', name)
    epsode = findall('E\d[0-9]', name)

    name_list = name.split('.')
    temp_list = []
    final_name = ''

    for item in name_list:
        if item == se_ep:
            break
        else:
            temp_list.append(item)
            pass
        pass
    for item in temp_list:
        final_name += item + ' '
        pass
    title = final_name[0:-1]
    se_ep = se_ep.replace('E', '_E')
    final_name = title + '_' + se_ep

    return final_name, title, season[0], epsode[0], file_type

def XCopy(_xname, *destinations):
    with open(_xname, mode='rb') as ofile:
        result = Translate_Name(_xname)
        data = ofile.read()

        print(f'{Color.YELLOW}---> 0.00% <---')

        for c, item in enumerate(destinations):
            name = f'{item}\\{result[0]}.{result[4]}'
            name = name.title()
            with open(name, 'wb+') as dfile:
                try:
                    dfile.write(data)
                except:
                    return False
                pass
            print(f'{Color.YELLOW}---> {(100 / len(destinations) * (c + 1)):.2f}% <---')
            pass
        pass
    return True

# from os.path import getsize
# tname = 'reinst.txt'
# test = open(tname, 'r')
# test.readline()
# test.close()
# getsize(tname)

#%%
folders = {
    'Download' : 'C:\\Users\\ericd\\Downloads\\Filmes\\Series',
    'Torrent' : '\\\\DNS-320\\P2P\\Torrent',
    'Complete' : '\\\\DNS-320\\P2P\\Complete',
    'A_Series' : 'A:\\Series',
    'X_Series' : '\\\\DNS-320\\Volume_1\\VIDEOS\\Series'
}
#%%
_dir = folders['Download']

chdir(_dir)

_zfiles = glob('*.zip')
_zfiles.extend(glob('*.rar'))

for item in sorted(_zfiles):
    
    if item.endswith('zip'):
        with ZipFile(item, 'r') as zfile:
            zfile.extractall()
            pass
        pass
    elif  item.endswith('rar'):
        with RarFile(item, 'r') as rfile:
            rfile.extractall()
            pass
        pass

    rename(item, item + '_')

    _del_files = glob('*.1080p.*')
    _del_files.extend(glob('*.2160p.*'))
    _del_files.extend(glob('*.720p.*'))
    _del_files

    for x in _del_files:
        remove(x)
        print(f'{Color.RED}O arquivo {x} foi deletado...')
        pass

    for x in glob('*.torrent'):
        XCopy(x, folders['Torrent'])
        print(f'{Color.GREEN}O arquivo {x} foi movido...')
        remove(x)
        pass

    for x in glob('*.srt'):
        result = Translate_Name(x)

        dest_1 = folders['X_Series'] + '\\' + result[1]
        dest_2 = folders['A_Series'] + '\\' + result[1]

        for d in [dest_1, dest_2]:
            try:
                mkdir(d)
            except:
                pass

        dest_1 = dest_1 + '\\' + result[2]
        dest_2 = dest_2 + '\\' + result[2]

        for d in [dest_1, dest_2]:
            try:
                mkdir(d)
                print(f'{Color.CYAN}O Diretorio {d} foi criado...')
            except:
                pass

        XCopy(x, dest_1, dest_2)
        print(f'{Color.OKGREEN}A Legenda {result[0]} foi copiada para \n\t{dest_1}\n\t{dest_2}')

        remove(x)
    pass

# %%
all_folders = []

for folder, b, c in walk(folders['Complete']):
    all_folders.append(folder)

all_folders = sorted(all_folders)

for folder in all_folders:

    chdir(folder)

    destine = folders['A_Series']
    backup = folders['X_Series']
    copiado = False

    video_files = []
    for extension in ('mp4', 'mkv', 'avi', 'mov'):
        video_files.extend(glob(f'*.{extension}'))

    for item in sorted(video_files):
        try:
            result = Translate_Name(item)
            dest_1 = f'{destine}\\{result[1]}\\{result[2]}'
            dest_2 = f'{backup}\\{result[1]}\\{result[2]}'
            log = f'{destine}\\{result[1]}\\update.log'
            ### Log de Update
            # with open(log, 'a+') as logfile:
            #     logfile.write(f'{result[3]}\n')
        except Exception as er:
            #print(f'{Color.WARNING}Aviso : {Color.FAIL}{er}')
            pass

        try:
            makedirs(dest_1)
            makedirs(dest_2)
        except Exception as er:
            #print(f'{Color.WARNING}Aviso : {Color.FAIL}{er}')
            #sleep(9)
            pass

        try:
            print(f'{Color.WHITE}Copiando : {Color.CYAN}{result[0]}')
            copiado = XCopy(item, dest_1, dest_2)
            print(f'{Color.WHITE}Arquivo copiado para {Color.OKGREEN}\n\t{dest_1}\n\t{dest_2}')
            with open(log, 'a+') as logfile:
                logfile.write(f'{result[2]}_{result[3]}\n')
            pass
        except Exception as er:
            print(f'{Color.WHITE}Erro : {Color.FAIL}{er}')
        
        if copiado == True:
            try:
                remove(item)
            except Exception as er:
                print(f'{Color.WHITE}Erro : {Color.FAIL}{er}')

# %%
print(f'{Color.END}')
print('\n' * 9)
print('Processo finalizado...')
print('\n' * 9)
sleep(99)