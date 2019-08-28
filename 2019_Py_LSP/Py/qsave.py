# %%
# from win32com.client import Dispatch, GetActiveObject as GAO, selecttlb
from win32com.client import GetActiveObject as GAO
from datetime import datetime
from time import sleep
# %%
acad = GAO('AutoCAD.Application.23')
sleep(10)
#doc = acad.ActiveDocument
#model = doc.ModelSpace
# %%
count = 0
final = 6
WaitTime = 300
while count is not final:
    now = str(datetime.now().hour) + ':' + str(datetime.now().minute)
    try:
        doc = acad.ActiveDocument
        #doc.SetVariable("cmdecho", 0)
        doc.SendCommand('_QSAVE\n')
        print(f'Save {count} complete...{now}')
        #doc.SetVariable("cmdecho", 1)
        doc = None
        pass
    except Exception as error:
        print(error)
        pass
    count += 1
    if final != count:
        sleep(WaitTime)
    pass
print('Comando finalizado...')
# (setq model(vla-get-modelspace(setq doc(vla-get-activedocument(setq cad(vlax-get-acad-object))))))
