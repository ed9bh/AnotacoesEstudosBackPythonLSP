# %%
from os import chdir
import utm
from time import sleep
# %%
### Configurações Iniciais

folder = r'C:\Users\Eric.Gomes\OneDrive - Ausenco\Documents\Ausenco\Proj\Vale\105425-33\Visita_20230724'

cliente = 'Vale'
projeto_num = '105425-33'
projeto_tit = 'Barragem do Trovao'
autor = 'Eric Drumond Gomes'
dia = '20230724'

fuso = 23
quadrante = 'k'
emisferio = 's'

# %%
chdir(folder)

arquivo_nome_coordenadas_imagens = 'coordenadas_das_imagens.txt'

with open(arquivo_nome_coordenadas_imagens, mode='r') as table:
    dados_do_arquivo = table.read()
    dados_do_arquivo = dados_do_arquivo.split('\n')
# %%
dados_do_arquivo
# %%
header = f'''<?xml version=\"1.0\" encoding=\"UTF-8\"?>
<kml xmlns=\"http://www.opengis.net/kml/2.2\" xmlns:gx=\"http://www.google.com/kml/ext/2.2\" xmlns:kml=\"http://www.opengis.net/kml/2.2\" xmlns:atom=\"http://www.w3.org/2005/Atom\">
<Folder><name>AUSENCO DO BRASIL - Cliente: {cliente} - Num. Proj: {projeto_num} - Proj: {projeto_tit}</name>
\n
'''

foot = '\n</Folder>\n</kml>'

# %%
kml = 'mpa_de_fotos.kml'

with open (kml, mode='+w', encoding='UTF-8') as target:
    target.write(header)
# %%
for n, i in enumerate(dados_do_arquivo):

    if i == '':
        continue

    foto_name, este, norte, elevation = i.split('\t')
    norte = float(norte.replace(',', '.'))
    este = float(este.replace(',', '.'))
    elevation = float(elevation.replace(',', '.'))
    aspecto = 720 / 2
    #elevation = 0
    LAT, LON = utm.to_latlon(
                northing=norte,
                easting=este,
                zone_number=fuso,
                zone_letter=quadrante
                )

    PHOTO = f'''<PhotoOverlay>
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
        <href>{folder}\\{foto_name}</href>
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
    with open (kml, mode='a', encoding='UTF-8') as target:
        target.write(PHOTO)
    
    sleep(0.1)
# %%
with open (kml, mode='a', encoding='UTF-8') as target:
    target.write(foot)
# %%

print('Finalizado...')

quit()

'''
Originais

<href>http://maps.google.com/mapfiles/kml/shapes/camera-lv.png</href>
<href>:/camera_mode.png</href>

'''
# %%