# %%
from os import chdir, mkdir
from os.path import isdir
from glob import glob
from PIL import Image
# %%
ang = 90
folder = r'C:\Users\Eric.Gomes\OneDrive - Ausenco\Documents\Ausenco\Proj\Vale\105425-33\Visita_20230724'
folder_out = f'{folder}\\OUT\\'
chdir(folder)
if isdir(folder_out) == False:
    mkdir(folder_out)
images = glob('*.jpg')
# %%
for i in images:
    ima = Image.open(i)
    ima = ima.rotate(angle=ang, expand=True)
    ima.save(folder_out + i)
# %%
quit()