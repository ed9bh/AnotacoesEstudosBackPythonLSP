#%%
from os.path import dirname, join
from sys import argv
try:
    from moviepy.editor import VideoFileClip
except ImportError:
    from os import system
    system('pip install moviepy --upgrade --force')
    from moviepy.editor import VideoFileClip
#%%
def audio_extract(file_name:str):
    nu_name = file_name.replace('.mp4', '.mp3')
    here = dirname(__file__)
    video = VideoFileClip(join(here, file_name))
    video.audio.write_audiofile(join(here, nu_name))
    del(video)
# %%
try:
    fname = argv[1]
    audio_extract(fname)
except Exception as err:
    print(err)
    pass

print('Finalizado...')