# %%
from os import chdir
import utm
from collections import defaultdict

# %%

# chdir(r'')

with open('LinhasLatLongElev.txt', 'r') as file:
    Raw = file.readlines()

# %%

Lines = defaultdict(list)

n = 0

for r in Raw:
    Tratamento = r.split(' ')
    del(Tratamento[-1])
    for t in Tratamento:
        Separacao = t.split(',')
        try:
            X = float(Separacao[0])
            Y = float(Separacao[1])
            Z = float(Separacao[2])
            Lines[n].append([X, Y, Z])
        except:
            pass
        pass
    n += 1
    pass
Lines

# %%

Items = list(Lines.keys())
Points = []

for item in Items:
    with open('Linha_' + str(item) + '.scr', 'w+') as file:
        file.write('pline\n')
        for x, y, elev in Lines[item]:
            point = utm.from_latlon(
                latitude=y, longitude=x, force_zone_number=23, force_zone_letter='k')
            Points.append(point[0:2])
            file.write(str(point[0]) + ',' + str(point[1]) + '\n')
            pass
        pass

Points
