from os import chdir
from sys import argv
from glob import glob
from exif import Image
from numpy import array
import utm

# --- Funções

def decimal_coords(coords, ref):
    conv_decimal_coord = coords[0] + coords[1] / 60 + coords[2] / 3600
    if ref == "S" or ref == "W":
        return -conv_decimal_coord
    else:
        return conv_decimal_coord

def latlon_extract_from_image(imagefile)->list:
    with open(imagefile, 'rb') as src:
        metadata_origin = Image(src)
        pass
    lat, lon, alt = metadata_origin.gps_latitude, metadata_origin.gps_longitude, metadata_origin.gps_altitude
    rlat, rlon = metadata_origin.gps_latitude_ref, metadata_origin.gps_longitude_ref
    dlat = decimal_coords(lat, rlat)
    dlon = decimal_coords(lon, rlon)
    return dlat, dlon, alt

def utm_coord(img):
    geocord = latlon_extract_from_image(img)
    utmcoord = utm.from_latlon(geocord[0], geocord[1])
    return utmcoord[0], utmcoord[1], geocord[2]

# --- Main

if __name__ == '__main__':

    replace = lambda x : x.replace(',', '.')

    folder = argv[1]

    chdir(folder)

    with open('coordenadas_das_imagens.txt', 'w+') as tfile:
        tfile.write('')
        pass

    with open('coordenadas_para_autocad.txt', 'w+') as tfile:
        tfile.write('(setq model(vla-get-modelspace (vla-get-activedocument (vlax-get-acad-object))))\n')

    imgs = glob('*.jpg')

    for img in imgs:
        try:
            coord = utm_coord(img)
            este = str(coord[0]).replace('.', ',')
            norte = str(coord[1]).replace('.', ',')
            elevacao = str(coord[2]).replace('.', ',')

            with open('coordenadas_das_imagens.txt', 'a+') as tfile:
                tfile.write(f'{img}\t{este}\t{norte}\t{elevacao}\n')
                pass
            with open('coordenadas_para_autocad.txt', 'a+') as tfile:
                tfile.write(f'(vla-add (vla-get-layers (vla-get-activedocument (vlax-get-acad-object ))) \"{img}\")\n')
                tfile.write(f'(setq temppoint(vla-addpoint model(vlax-3d-point (list {replace(este)} {replace(norte)} {replace(elevacao)}))))\n')
                tfile.write(f'(vla-put-layer temppoint \"{img}\")\n')
                #tfile.write(f'(vla-add (vla-get-hyperlinks temppoint) \"{img}\" \"{folder}\\{img}\")\n')
                tfile.write(f'(vla-add (vla-get-hyperlinks temppoint) \"{img}\" \".\\{img}\")\n')
                if coord[2] == 0:
                    tfile.write(f'(vla-put-color temppoint 1)\n')
                    pass
                pass

            print(f'{img} : {coord}')
        except Exception as err:
            print(f'{img} : {err}')