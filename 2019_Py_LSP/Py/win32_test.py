# %%
'''
Regedit
Computador\HKEY_LOCAL_MACHINE\SOFTWARE\Classes\CLSID
gencache.EnsureModule('{420B2830-E718-11CF-893D-00A0C9054228}', 0, 1, 0)
'''

# %%
import win32com.client
from win32com.client import Dispatch, combrowse, gencache
from array import array
import pythoncom
import numpy as np

n = 0

# %%
combrowse.main()
# %%
# help(win32com.client)
# help(gencache.EnsureModule)
# help(gencache.GetModuleForCLSID)
n += 1
print(n)
try:
    id = '{0002DF01-0000-0000-C000-000000000046}'  # Iexplorer
    id = '{3476FAB2-687F-4EA6-9AC2-88D72DC7D7FC}'  # Google Earth
    id = '{5370C727-1451-4700-A960-77630950AF6D}'  # Autocad

    app_name = gencache.GetModuleForProgID(id)
    app_ensure = gencache.EnsureDispatch(id)
    app = Dispatch(app_ensure)
    pass
except Exception as error:
    app_name, app_ensure = None, None
    print(error)

print(f'Nome : {app_name} \nEnsure : {app_ensure}')

# %%
app.Visible = True

# %%
app.Quit()

# %%

# ------------
# --- Acad ---
# ------------

acad = app
doc = acad.ActiveDocument
model = doc.ModelSpace


def POINT(x, y, z):
    return win32com.client.VARIANT(pythoncom.VT_ARRAY | pythoncom.VT_R8, (x, y, z))


# %%
help(acad)
# %%
help(doc)
# %%
help(model)
# %%
help(model.AddLine)
# %%

l = model.AddLine(
    StartPoint=POINT(0, 0, 0),
    EndPoint=POINT(1, 12, 0)
)

help(l)

# %%
app.ZoomExtents()

l.color = 1

# %%
l.Rotate(POINT(0, 0, 0), np.pi / 2)

app.ZoomExtents()
