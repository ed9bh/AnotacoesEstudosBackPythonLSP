# By EDG 2019
# %%
from win32com.client import GetActiveObject as GAO
from time import sleep, localtime
# %%


def qsave():
    global count, final, WaitTime
    acad = GAO('AutoCAD.Application.23')
    sleep(9)
    doc = acad.ActiveDocument
    title = doc.WindowTitle
    #model = doc.ModelSpace
    doc.SendCommand('_QSAVE\n')
    now = f'{localtime().tm_hour:02d}:{localtime().tm_min:02d}:{localtime().tm_sec:02d}'
    print(f'Save {count} complete...{now} : {title}!!!')


# %%
if __name__ == '__main__':
    count = 0
    final = 12
    WaitTime = 600
    while count is not final:
        try:
            qsave()
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
