from win32com.client import GetActiveObject, Dispatch, CastTo, GetObject
# (vla-getinterfaceobject (vlax-get-acad-object) "AeccXUiLand.AeccApplication.13.2")
try:
    acad = GetActiveObject('AutoCAD.Application.23')
    pass
except Exception as error:
    print(error)
    quit()

doc = acad.ActiveDocument
model = doc.ModelSpace

doc.Utility.Prompt('\nSelecione uma Polylinha : ')
poly = doc.Utility.GetEntity()

limit = list(poly[0].GetBoundingBox())
x1, y1 = limit[0][0], limit[0][1]
x2, y2 = limit[1][0], limit[1][1]

for p in [x1, y1, x2, y2]:
    print(p)
    pass

n = 0

while n != -1:
    try:
        c = poly[0].Coordinate(n)
        print(c)
        n += 1
        pass
    except:
        n = -1
        pass



print('\n\nFim...')
