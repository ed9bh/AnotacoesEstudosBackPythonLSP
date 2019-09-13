# %%
from glob import glob
from os import chdir, remove
from time import sleep


chdir('C:/Users/GOMEE11/Documents/_WorkPlace')


extencoes = ['bak', 'err', 'ac$', 'dwl', 'dwl2', '_LS']


for i in extencoes:
    eraseList = glob('**/*.' + i, recursive=True)
    for j in eraseList:
        try:
            remove(j)
            print(f'{j} foi removido com sucesso...')
            pass
        except Exception as error:
            print(error)
            pass

print('\n\n\nFinalizado...')
sleep(6)
