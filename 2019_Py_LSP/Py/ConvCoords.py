# %%
# pip install utm
from utm import from_latlon as convCoords
# %%

try:
    with open('latlon.txt', 'r') as file:
        line = file.read()
        line = line.split('\n')
        LatLon_List = []
        for i in line:
            x = i.split('\t')[0]
            y = i.split('\t')[1]
            LatLon_List.append([float(x), float(y)])
    pass
except Exception as error:
    print(error)

# %%
coords = []
for point in LatLon_List:
    p = convCoords(point[0], point[1])
    coords.append(p)
    print(p)

# %%
with open('coords.txt', '+w') as file:
    for i in coords:
        file.write(str(i[0]) + ',' + str(i[1]) + '\n')
