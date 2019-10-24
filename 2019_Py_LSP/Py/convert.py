# %%
from os import chdir, remove
import utm
from collections import defaultdict
from comtypes.client import GetActiveObject
from glob import glob
from time import sleep
import array
from lxml import html, etree
from io import StringIO, BytesIO

# %%

acad = GetActiveObject('AutoCAD.Application.23')
doc = acad.ActiveDocument
model = doc.ModelSpace

place = doc.Path

chdir(place)

kmlFiles = glob('*.kml')

# %%

if __name__ == '__main__':

    for file in kmlFiles:

        with open(file, 'r') as file:
            Raw = file.readlines()

        kml = etree.HTML(str(Raw))
        result = kml.findall('.//coordinates')

        Points = []

        for r in result:
            coords = r.text
            coords = coords.replace('\\n\', \'\\t\\t\\t\\t\\t\\t', '')
            coords = coords.replace(' \\n\', \'\\t\\t\\t\\t\\t', '')
            coords = coords.replace('\'', '')
            coords = coords.replace('\\n', '')
            coords = coords.replace('\\t', '')
            coords = coords.split(' ')
            # print(coords)
            Points.append([])
            for w in coords:
                try:
                    LonLatElev = w.split(',')
                    XY = utm.from_latlon(
                        float(LonLatElev[1]), float(LonLatElev[0]))
                    # print(XY)
                    Points[-1].append(XY[0])
                    Points[-1].append(XY[1])
                except Exception as error:
                    print(error)
                pass
            pass

        for coords in Points:
            try:
                CoordList = array.array('d', coords)

                lw = model.AddLightWeightPolyline(VerticesList=CoordList)

                acad.ZoomExtents()

                sleep(0.3)
            except Exception as error:
                print(error)

print('Finalizado...')
sleep(9)
