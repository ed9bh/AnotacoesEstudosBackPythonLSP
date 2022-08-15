# %%

try:
    import libtorrent as lt
except ImportError:
    from os import system
    system('pip install libtorrent --no-cache-dir --upgrade --force')
    import libtorrent as lt
    pass
from os import mkdir, chdir, getcwd
from os.path import isdir
import time
import datetime
from tkinter import Tk

# %%

rt = Tk()
link = rt.clipboard_get()

print(f'Link do  Torrent : {link}')

# %%

dirname = getcwd() + '\\' + 'Torrent_Downloads'
if isdir(dirname) == False:
    mkdir(dirname)

# %%

ses = lt.session()
ses.listen_on(6881, 6891)

params = {

    'save_path' : dirname,
    'storage_mode' : lt.storage_mode_t(2),
    'paused' : False,
    'auto_managed' : True,
    'duplicate_is_error' : True

}

# %%

handle = lt.add_magnet_uri(ses, link, params)
ses.start_dht()

begin = time.time()
print(datetime.datetime.now())

# %%

print('\n\nStatus : Obtendo Metadata', end='')

while(not handle.has_metadata()):
    print('.', end='')
    time.sleep(9)
    pass

# %%

print('\n\n\nStatus : Metadata Concluído, Iniciando o Download...\n')
print(f'Iniciando : {handle.name()}\n\n\n')

while (handle.status().state != lt.torrent_status.seeding):
    s = handle.status()
    state_str = [
        'queued',
        'checking',
        'downloading metadata',
        'downloading',
        'finished',
        'seeding',
        'allocating'
        ]
    
    print(f'\r{s.progress * 100}% completo (down: {s.download_rate / 1000}kb/s / up: {s.upload_rate / 1000}kb/s peers: {s.num_peers}), {state_str[s.state]}')

    time.sleep(18)

    pass

end = time.time()
print(handle.name(), 'Completo...')
print(f'Tempo total : {int((end - begin) // 60)} hrs, {int((end - begin) % 60)} mins')