# %%
from win32com.client import GetActiveObject as GAO
from time import sleep, localtime
from random import randint
# from concurrent.futures import ProcessPoolExecutor
# from multiprocessing import Lock
# %%


def insistente():
    done = False
    while done != True:

        try:
            done = qsave()
            pass
        except:
            done = False
            r = randint(9, 18)
            pass

        if done != True:
            print('Tentando novamente em alguns segundos...')
            sleep(r)
            pass
        pass
    pass


def qsave():
    global count, final, WaitTime
    print('Salvando o documento...', end='\t')
    acad = GAO('AutoCAD.Application.23')
    sleep(9)
    doc = acad.ActiveDocument
    title = doc.WindowTitle
    #model = doc.ModelSpace
    if (count % 2) == 0:
        audit()
        pass
    doc.SendCommand('_QSAVE\n')
    now = f'{localtime().tm_hour:02d}:{localtime().tm_min:02d}:{localtime().tm_sec:02d}'
    print(f'Save {count} complete...{now} : {title}!!!')
    return True

def audit():
    doc.SendCommand('audit\ny\n')
    pass

# %%
if __name__ == '__main__':
    count = 0
    final = 999
    WaitTime = 600
    while count is not final:
        try:
            insistente()
            pass
        except Exception as error:
            print(error)
            pass
        count += 1
        if count != final:
            sleep(WaitTime)
        else:
            break
    pass
print('Comando finalizado...')
sleep(9)
# (setq model(vla-get-modelspace(setq doc(vla-get-activedocument(setq cad(vlax-get-acad-object))))))
