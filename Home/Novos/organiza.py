# %%
# import pkg_resources as pkg
# installed = [p.key for p in pkg.working_set]

# if 'watchdog' not in installed:
#     from os import system
#     system('pip install watchdog --no-cache-dir --upgrade --force')

from watchdog.observers import Observer
from watchdog.events import FileSystemEventHandler
from secrets import token_hex
from time import sleep
import os, sys
# %%

def handler_fun():
    for filename in os.listdir(base_folder):
        filename = filename.lower()
        name, ext = token_hex(18), filename.rsplit('.')[-1]
        if len(filename) > 20 and ext in ['mp4', 'avi', 'jpg', 'png', 'gif']:
            new_name = f'{name}.{ext}'
        else:
            new_name = filename
        if any(filename.endswith(x) for x in file_tracks.keys()):
            src = f'{base_folder}\\{filename}'
            key = filename.split('.')[-1]
            folder_name = file_tracks[f'.{key}']
            filename = filename if len(filename) < 20 else new_name
            if filename.endswith('.webp'):
                filename = filename.replace('.webp', '.jpg')
            new_destination = f'{base_folder}\\{folder_name}\\{filename}'
            if os.path.exists(folder_name) is False:
                try:
                    new_folder = f'{base_folder}\\{folder_name}'
                    os.mkdir(new_folder)
                    print(f'Diretorio >>> {new_folder} <<< foi criado...')
                except Exception as err:
                    print(err)
            try:
                os.rename(src, new_destination)
                print(f'{new_destination} foi organizado com sucesso...')
            except Exception as err:
                print(err)

class MyHandler(FileSystemEventHandler):
    i = 1
    def on_modified(self, event):
        handler_fun()
# %%
print('Start...')

try:
    base_folder = sys.argv[-1]
except:
    base_folder = r'C:\Users\ericd\Downloads'

print(f'Iniciado em ---> {base_folder} <---')

file_tracks = {
    '.png' : 'Images',
    '.jpg' : 'Images',
    '.bmp' : 'Images',
    '.dib' : 'Images',
    '.jfif' : 'Images',
    '.jpeg' : 'Images',
    '.webp' : 'Images',
    '.tiff' : 'Images',
    '.gif' : 'Images',
    '.mp4' : 'Videos',
    '.avi' : 'Videos',
    '.mkv' : 'Videos',
    '.mp3' : 'Audio',
    '.wav' : 'Audio',
    '.mid' : 'Audio',
    '.txt' : 'Docs',
    '.doc' : 'Docs',
    '.docx' : 'Docs',
    '.xls' : 'Docs',
    '.xlsx' : 'Docs',
    '.pdf' : 'Docs',
    '.pps' : 'Docs',
    '.ppsX' : 'Docs',
    '.dwg' : 'Cad',
    '.dxf' : 'Cad',
    '.kmz' : 'Cad',
    '.kml' : 'Cad',
    '.lsp' : 'Cad',
    '.torrent' : 'Torrent',
    '.exe' : 'Apps',
    '.msi' : 'Apps',
    '.zip' : 'Compactados',
    '.rar' : 'Compactados',
    '.cbr' : 'Comics',
    '.whl' : 'Python_Modules_Back',
}
# %%
try:
    handler_fun()
except Exception as err:
    print(err)
    pass

event_handler = MyHandler()
observer = Observer()
observer.schedule(event_handler, base_folder, recursive=True)
observer.start()

try:
    while True:
        sleep(3)
except KeyboardInterrupt:
    observer.stop()
    pass
observer.join()

print('Ends...')
# %%