# %%
from os import chdir, remove
import utm
from collections import defaultdict
from comtypes.client import GetActiveObject
from glob import glob
from time import sleep
import array
from lxml import html, etree

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

        layer = '_' + str(file).replace('.kml', '')

        try:
            doc.Layers.Add(layer)
        except:
            pass

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
            Points.append([])
            for w in coords:
                try:
                    LonLatElev = w.split(',')
                    XY = utm.from_latlon(
                        float(LonLatElev[1]), float(LonLatElev[0]))
                    Points[-1].append(XY[0])
                    Points[-1].append(XY[1])

                except Exception as error:
                    pass
                pass
            pass

        for coords in Points:
            try:
                CoordList = array.array('d', coords)

                lw = model.AddLightWeightPolyline(VerticesList=CoordList)

                lw.layer = layer

                acad.ZoomExtents()

                sleep(0.3)
            except Exception as error:
                pass
            pass

        for e in kmlFiles:
            try:
                sleep(0.1)
                remove(e)
                txt = ' Foi Bem Sucedida...'
            except Exception as error:
                print(error)
                txt = ' Falhou...'
            finally:
                print(f'Tentativa de apagar o arquivo {txt}')

print('\n\nFinalizado...')
sleep(9)
