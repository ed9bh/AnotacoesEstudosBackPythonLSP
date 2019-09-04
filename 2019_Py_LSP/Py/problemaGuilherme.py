# %%
# Formula : https://pt.quora.com/Como-voc%C3%AA-calcula-a-dist%C3%A2ncia-entre-duas-localiza%C3%A7%C3%B5es-geogr%C3%A1ficas-expressas-em-coordenadas-de-latitude-e-longitude-usando-Python-ou-Java
from numpy import pi, sin, cos, arccos as acos, abs, radians, arctan2 as atan2

# %%
# Constantes
rad = pi / 180
R = 6371.0

# %%
# Funcoes


def Formula_001(lat1, lon1, lat2, lon2):
    dlat = lat1 - lat2
    dlon = lon1 - lon2
    a = sin(dlat / 2)**2 + cos(lat1) * cos(lat2) * sin(dlon / 2)**2
    c = 2 * atan2(a**0.5, (1 - a)**0.5)
    return R * c

# %%


baseCity = {
    0: {
        'Name': 'Belo Horizonte',
        'Coords': {'lat': -20, 'lon': -45},
    },
}
citys = {
    0: {
        'Name': 'Buenos Aires',
        'Coords': {'lat': -34.6, 'lon': -58.4},
    },
    1: {
        'Name': 'Paris',
        'Coords': {'lat': 49.0, 'lon': 4},
    },
    2: {
        'Name': 'Montreal',
        'Coords': {'lat': 45, 'lon': -72},
    },
    3: {
        'Name': 'Tokio',
        'Coords': {'lat': 36, 'lon': 140},
    },
    4: {
        'Name': 'Sydney',
        'Coords': {'lat': -33, 'lon': 151},
    },
    5: {
        'Name': 'New York',
        'Coords': {'lat': 40, 'lon': -74},
    },
    6: {
        'Name': 'Cape Town',
        'Coords': {'lat': -33, 'lon': 18.5},
    },
}
aaa = 0
bbb = 0

# %%

for i in baseCity:
    BaseName = baseCity[i]['Name']
    BaseLat = radians(baseCity[i]['Coords']['lat'])
    BaseLon = radians(baseCity[i]['Coords']['lon'])
    print(f'{BaseName} : {BaseLat} / {BaseLon}')
    for j in citys:
        Name = citys[j]['Name']
        Lat = radians(citys[j]['Coords']['lat'])
        Lon = radians(citys[j]['Coords']['lon'])

        dist = Formula_001(BaseLat, BaseLon, Lat, Lon)

        print('A distancia entre {0} e a cidade {1} é de {2:0.3f}'.format(
            BaseName,
            Name,
            dist
        ))
