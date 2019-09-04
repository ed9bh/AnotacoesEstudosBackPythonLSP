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

from numpy import cos, sin, pi, arccos as acos

#%%
rad = pi / 180
bh = [-20, -45]
cidade = ['Buenos', 'Paris', 'Montreal', 'Tokio','Sydney ', 'New York', 'Cape Town']
lat = [-34.6, 49, 45, 36, -33, 40, -33]
lon = [-58.4, 4., -72, 140, 151, -74, 18.5]
aaa = 0
bbb = 0

#%%
for i in range(0 , len(cidade)):
    try:
        ccc = (sin(bh[0] * rad) * sin(lat[i] * rad)) + (cos(bh[0] * rad) * cos(lat[i] * rad) * cos((bh[0] - lon[i]) * rad))
        ddd = acos(ccc) / rad
        print(ccc)
        print(ddd)
    except:
        pass