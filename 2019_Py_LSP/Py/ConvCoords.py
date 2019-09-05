# %%
# pip install utm
from utm import from_latlon as convCoords
# %%
LatLon_List = [
    [-20.272413, -40.252885],
    [-20.272530, -40.252859],
    [-20.272558, -40.253065]
]
coords = []
for point in LatLon_List:
    p = convCoords(point[0], point[1])
    coords.append(p)
    print(p)

# %%
with open('coords.txt', '+w') as file:
    for i in coords:
        file.write(str(i[0]) + ',' + str(i[1]) + '\n')
