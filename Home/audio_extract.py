#%%
import os
from moviepy.editor import VideoFileClip
from os.path import dirname, join
from os import remove, listdir
from time import sleep
#%%
# video = VideoFileClip(os.path.join("path","to","movie.mp4"))
# video.audio.write_audiofile(os.path.join("path","to","movie_sound.mp3"))
def audio_extract(file_name:str):
    nu_name = file_name.replace('.mp4', '.mp3')
    here = dirname(__file__)
    video = VideoFileClip(join(here, file_name))
    video.audio.write_audiofile(join(here, nu_name))
    del(video)
# %%
rem = False
in_folder_files = listdir()
in_folder_files = [x for x in in_folder_files if x.endswith('.mp4')]
count = len(in_folder_files)
# %%
for f in enumerate(in_folder_files):
    print(f'Arquivo {f[0] + 1}\\{count} - {f[1]}')
    if f[1].endswith('.mp4'):
        audio_extract(f[1])
        if rem == True:
            try:
                sleep(3)
                remove(join(dirname(__file__), f[1]))
            except Exception as err:
                print(err)
                sleep(30)
# %%
print('Finalizado...')
sleep(60)