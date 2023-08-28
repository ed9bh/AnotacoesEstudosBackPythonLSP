# %%
from os import chdir, mkdir
from os.path import isdir
import utm
from time import sleep
from glob import glob
from PIL import Image as ImageEditor
from exif import Image
# %%
### Configurações Iniciais

folder = r'C:\Users\Eric.Gomes\OneDrive - Ausenco\Documents\Ausenco\Proj\Vale\105425-33\Visita_20230724\\'
folder_out = folder + "out\\"

cliente = 'Vale'
projeto_num = '105425-33'
projeto_tit = 'Barragem do Trovao'
autor = 'Eric Drumond Gomes'
dia = '20230724'
fuso = 23
quadrante = 'k'
emisferio = 's'

# %%
# Funcoes

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

def PHOTO(n, aspecto, foto_name, LAT, LON, elevation, folder, img_name)->str:
    return f'''<PhotoOverlay>
    <name>{n + 1}</name>
    <description><![CDATA[<img style=\"max-width:{aspecto}px;\" src=\"./{foto_name}\">]]></description>
    <Camera>
        <longitude>{LON}</longitude>
        <latitude>{LAT}</latitude>
        <altitude>100</altitude>
        <heading>-6.946458584484463e-05</heading>
        <tilt>0</tilt>
        <roll>0</roll>
        <altitudeMode>relativeToGround</altitudeMode>
    </Camera>
    <Style>
        <IconStyle>
            <Icon>
                <href>https://officespace.ausenco.com/sites/all/themes/officespace/favicon.ico</href>
            </Icon>
        </IconStyle>
        <ListStyle>
            <listItemType>check</listItemType>
            <ItemIcon>
                <state>open closed error fetching0 fetching1 fetching2</state>
                <href>https://www.ausenco.com/assets/images/_1200x630_crop_center-center_none/ausenco.jpg</href>
            </ItemIcon>
            <bgColor>00ffffff</bgColor>
            <maxSnippetLines>2</maxSnippetLines>
        </ListStyle>
    </Style>
    <Icon>
        <href>{folder}\\{img_name}</href>
    </Icon>
    <rotation>-90.00000</rotation>
    <ViewVolume>
        <near>100</near>
    </ViewVolume>
    <Point>
        <altitudeMode>absolute</altitudeMode>
        <coordinates>{LON},{LAT},{elevation}</coordinates>
    </Point>
</PhotoOverlay>\n
'''

# %%
header = f'''<?xml version=\"1.0\" encoding=\"UTF-8\"?>
<kml xmlns=\"http://www.opengis.net/kml/2.2\" xmlns:gx=\"http://www.google.com/kml/ext/2.2\" xmlns:kml=\"http://www.opengis.net/kml/2.2\" xmlns:atom=\"http://www.w3.org/2005/Atom\">
<Folder><name>{projeto_num}-{projeto_tit}</name>
<description>AUSENCO DO BRASIL
Cliente: {cliente}
Numero Projeto: {projeto_num}
Titulo do Projeto: {projeto_tit}
Autor : {autor}
Data : {dia}
Referencia
    Fuso - {fuso}
    Quadrante - {quadrante}
    Emisferio - {emisferio}
</description>
\n
'''

foot = '\n</Folder>\n</kml>'

# %%
if __name__ == '__main__':
    
    chdir(folder)
    kml = folder_out + 'mapa_de_fotos.kml'
    images = glob('*.jpg')

    if isdir(folder_out) == False:
        mkdir(folder_out)

    print(kml)
    
    with open(kml, mode='+w', encoding='UTF-8') as target:
        target.write(header)
            
    for n, img in enumerate(images):
            
        LAT, LON, elevation = latlon_extract_from_image(img)
        
        aspecto = 720 / 2

        code = PHOTO(n=n, aspecto=aspecto, foto_name=img, LAT=LAT, LON=LON, folder=folder, img_name=img, elevation=elevation)
    
        with open (kml, mode='a', encoding='UTF-8') as target:
            target.write(code)
        
        i = ImageEditor.open(img)
        i = i.rotate(angle=-90, expand=True)
        i.save(folder_out + img)
            
        sleep(0.1)
                
    with open (kml, mode='a', encoding='UTF-8') as target:
        target.write(foot)

    print('Finalizado...')

    quit()
#%%

'''
Originais

<href>http://maps.google.com/mapfiles/kml/shapes/camera-lv.png</href>
<href>:/camera_mode.png</href>

'''
# %%