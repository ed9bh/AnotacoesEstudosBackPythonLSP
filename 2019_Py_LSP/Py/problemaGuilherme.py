#%%
from numpy import pi, sin, cos, arccos as acos, abs

#%%

rad = pi / 180
bh = [-20,-45]
cidade = ['Buenos Aires', 'Paris', 'Montreal', 'Tokio', 'Sydney', 'New York', 'Cape Town']
lat = [-34.6,49.,45.,36.,-33.,40.,-33.]
lon = [-58.4,4.,-72.,140.,151.,-74.,18.5]
aaa = 0
bbb = 0

#%%
def calcCCC(w, x, y, z):
    global rad
    return (sin(w * rad) * sin(y * rad)) + (cos(w * rad) * cos(y * rad)) * cos((x - z) * rad)
#%%

for i in range(0, len(cidade)):
    ccc = calcCCC(bh[0], bh[1], lat[i], lon[i])
    ddd = acos(ccc) / rad
    eee = ccc * ddd

    print(f'A distancia entre BH e {cidade[i]} é de {abs(eee):.3f}')

    if eee > aaa:
        aaa = eee
    else:
        bbb = eee
