#%%
#from comtypes.client import GetActiveObject, CreateObject
import pandas_datareader as pdr
from matplotlib import pyplot as plt
from scipy import interpolate
import numpy as np
from win32com.client import GetActiveObject, Dispatch
#%%
n = 0
#%%
try:
    acad = GetActiveObject('AutoCAD.Application.23')
    #acad = CreateObject('AutoCAD.Application.23')
    doc = acad.ActiveDocument
    model = doc.ModelSpace
except Exception as error:
    print(error)
#%%
try:
    n += 1
    c3d1 = acad.GetInterfaceObject("AeccXUiLand.AeccApplication.9.0")
    n += 1
    c3d2 = acad.GetInterfaceObject("AeccXUiRoadway.AeccRoadwayApplication.9.0")
    n += 1
    #c3d1 = CreateObject("AeccXUiLand.AeccApplication.9.0")
    #c3d2 = CreateObject("AeccXUiRoadway.AeccRoadwayApplication.9.0")
    pass
except Exception as error:
    print(error)
    print('\n' + str(n))

try:
    acad.Visible = True
    pass
except:
    pass

print('\33aaaaa')

# %%
x = np.linspace(0, 4, 12)
y = np.cos(x**2 / 3 + 4)
print(x, y)
plt.plot(x, y)
#%%
