# %%
from time import sleep, perf_counter
from PIL import Image, ImageFilter
from concurrent.futures import ProcessPoolExecutor
from requests import get as download
from os import mkdir
from os.path import isdir
from glob import glob

# %%

save_dir = 'Processed'
size = (1200, 1200)


def processingImage(img_file):
    global save_dir, size
    start = perf_counter()
    img = Image.open(img_file)
    img = img.filter(ImageFilter.GaussianBlur(15))
    img.thumbnail(size)
    img.save(f'{save_dir}/{img_file}')
    end = perf_counter()
    return f'{img_file} for executada em {end - start:0.2f} segundos...'


# %%
img_names = glob('*.jpg')


# %%

if __name__ == '__main__':
    Start = perf_counter()

    if isdir(save_dir) is not True:
        mkdir(save_dir)
        pass

    with ProcessPoolExecutor() as executor:

        results = executor.map(processingImage, img_names)

        for result in results:
            print(result)

    Finish = perf_counter()

    print(f'Finalizado em {Finish - Start:0.2f} segundo(s)...')
