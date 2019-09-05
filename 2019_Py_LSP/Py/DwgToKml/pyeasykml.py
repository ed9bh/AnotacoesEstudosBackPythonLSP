def InicioKML():
    return ('<?xml version="1.0" encoding="UTF-8"?>\n'
            '<kml xmlns="http://www.opengis.net/kml/2.2">\n'
            #'<Placemark>\n'
            '<Document>\n'
            '<name>DWGtoKML</name>'
            '<atom:author>Eric Drumond - ed9bh</atom:author>'
            '<phoneNumber>+55(31)9 9758-2378</phoneNumber>\n'
            '<description>DWGtoKML foi elaborado por Eric Drumond em 2017/04. Programa gratuito. Quer sua marca aqui, outras opções de DATUM e mais personalização? Entre em contato e solicite um orçamento.</description>\n'
            '<address>"http://br.linkedin.com/in/ericdrumond"</address>\n'
            '<atom:link href="http://br.linkedin.com/in/ericdrumond"/>\n'
            + Styles
            )
def FinalKML():
    return ('</Document>\n'
            '</kml>')

def Ponto(Descricao=str, Latitude=float, Longitude=float):#
    ponto = ('\n<Placemark>\n'
             '<name>{}</name>\n'
             '<description>DWGtoPDF - RS(ed9bh) - By:Eric Drumond(2017/04)</description>\n'
             '<Point>'
             '<coordinates>{},{}</coordinates>'
             '</Point>\n'
             '</Placemark>\n'
             ).format(Descricao, Latitude, Longitude)
    return ponto

def Polilinha(Descricao=str, Cor=str, ListaLatitudeLongitude=[]):
    polylinha = ('\n<Placemark>\n'
                 '<name>{}</name>\n'
                 '<description>DWGtoPDF - RS(ed9bh) - By:Eric Drumond(2017/04)</description>\n'
                 '<styleUrl>{}</styleUrl>'
                 '<LineString id="LAYER">\n'
                 '<tessellate>1</tessellate>\n'
                 '<altitudeMode>clampToGround</altitudeMode>\n'
                 '<coordinates>'
                 ).format(Descricao, Cor)

    for coord in ListaLatitudeLongitude:
        polylinha += ("\n{},{}".format(coord[0], coord[1]))
    polylinha = polylinha + ('\n</coordinates>\n'
                             '</LineString>\n'
                             '</Placemark>\n'
                             )
    return polylinha


def Hatch(Descricao=str, Cor=str, ListaLatitudeLongitude=[]):
    hatch = ('\n<Placemark>\n'
             '<name>{}</name>\n'
             '<description>DWGtoPDF - RS(ed9bh) - By:Eric Drumond(2017/04)</description>\n'
             '<styleUrl>{}</styleUrl>\n'
             '<Polygon id="LAYER">\n'
             '<extrude>1</extrude>\n'
             #'<tessellate>1</tessellate>\n'
             '<altitudeMode>clampToGround</altitudeMode>\n'
             '<outerBoundaryIs>\n'
             '<LinearRing>'
             ).format(Descricao, Cor)

    for coord in ListaLatitudeLongitude:
            hatch += ("\n{},{}".format(coord[0], coord[1]))
    hatch = hatch + ('\n</LinearRing>\n'
                     '</outerBoundaryIs>\n'
                     '<innerBoundaryIs>\n'
                     '<LinearRing>'
                     )
    for coord in ListaLatitudeLongitude:
            hatch += ("\n{},{}".format(coord[0], coord[1]))
    hatch = hatch +('\n</LinearRing>\n'
                    '</innerBoundaryIs>\n'
                    '</Polygon>\n'
                    '</Placemark>\n'
                    )
    return hatch


def corCadHex(cor=int):
    if cor == 1:
        return "red"
    elif cor == 2:
        return "yellow"
    elif cor == 3:
        return "green"
    elif cor == 4:
        return "cyan"
    elif cor == 5:
        return "blue"
    elif cor == 6:
        return "magenta"
    elif cor == 7:
        return "white"
    elif cor == 8:
        return "grey"
    elif cor == 9:
        return "darkGrey"
    elif cor == 10:
        return "darkRed"
    else:
        return "black"

Styles = (
            # Estilos de Linha
            # Vermelho / 1
            '<Style id="red">\n'
            '<LineStyle>\n'
            '<color>ff0000ff</color>\n'
            '<width>2</width>\n'
            '</LineStyle>\n'
            '<PolyStyle>\n'
            '<color>ff0000ff</color>\n'
            '<colorMode>normal</colorMode>\n'
            '<fill>1</fill>\n'
            '<outline>1</outline>\n'
            '</PolyStyle>\n'
            '</Style>\n'
            # Amarelo / 2
            '<Style id="yellow">\n'
            '<LineStyle>\n'
            '<color>ff00ffff</color>\n'
            '<width>2</width>\n'
            '</LineStyle>\n'
            '<PolyStyle>\n'
            '<color>ff00ffff</color>\n'
            '<colorMode>normal</colorMode>\n'
            '<fill>1</fill>\n'
            '<outline>1</outline>\n'
            '</PolyStyle>\n'
            '</Style>\n'
            # Verde / 3
            '<Style id="green">\n'
            '<LineStyle>\n'
            '<color>ff00ff00</color>\n'
            '<width>2</width>\n'
            '</LineStyle>\n'
            '<PolyStyle>\n'
            '<color>ff00ff00</color>\n'
            '<colorMode>normal</colorMode>\n'
            '<fill>1</fill>\n'
            '<outline>1</outline>\n'
            '</PolyStyle>\n'
            '</Style>\n'
            # Cyan / 4
            '<Style id="cyan">\n'
            '<LineStyle>\n'
            '<color>ffff7e10</color>\n'
            '<width>2</width>\n'
            '</LineStyle>\n'
            '<PolyStyle>\n'
            '<color>ffff7e10</color>\n'
            '<colorMode>normal</colorMode>\n'
            '<fill>1</fill>\n'
            '<outline>1</outline>\n'
            '</PolyStyle>\n'
            '</Style>\n'
            # Blue / 5
            '<Style id="blue">\n'
            '<LineStyle>\n'
            '<color>ffff0010</color>\n'
            '<width>2</width>\n'
            '</LineStyle>\n'
            '<PolyStyle>\n'
            '<color>ffff0010</color>\n'
            '<colorMode>normal</colorMode>\n'
            '<fill>1</fill>\n'
            '<outline>1</outline>\n'
            '</PolyStyle>\n'
            '</Style>\n'
            # Magenta / 6
            '<Style id="magenta">\n'
            '<LineStyle>\n'
            '<color>ffff00cc</color>\n'
            '<width>2</width>\n'
            '</LineStyle>\n'
            '<PolyStyle>\n'
            '<color>ffff00cc</color>\n'
            '<colorMode>normal</colorMode>\n'
            '<fill>1</fill>\n'
            '<outline>1</outline>\n'
            '</PolyStyle>\n'
            '</Style>\n'
            # Branco / 7
            '<Style id="white">\n'
            '<LineStyle>\n'
            '<color>ffffffff</color>\n'
            '<width>2</width>\n'
            '</LineStyle>\n'
            '<PolyStyle>\n'
            '<color>ffffffff</color>\n'
            '<colorMode>normal</colorMode>\n'
            '<fill>1</fill>\n'
            '<outline>1</outline>\n'
            '</PolyStyle>\n'
            '</Style>\n'
            # Cinza claro / 8
            '<Style id="grey">\n'
            '<LineStyle>\n'
            '<color>ff808080</color>\n'
            '<width>2</width>\n'
            '</LineStyle>\n'
            '<PolyStyle>\n'
            '<color>ff808080</color>\n'
            '<colorMode>normal</colorMode>\n'
            '<fill>1</fill>\n'
            '<outline>1</outline>\n'
            '</PolyStyle>\n'
            '</Style>\n'
            # Cinza Escuro / 9
            '<Style id="darkGrey">\n'
            '<LineStyle>\n'
            '<color>ff505050</color>\n'
            '<width>2</width>\n'
            '</LineStyle>\n'
            '<PolyStyle>\n'
            '<color>ff505050</color>\n'
            '<colorMode>normal</colorMode>\n'
            '<fill>1</fill>\n'
            '<outline>1</outline>\n'
            '</PolyStyle>\n'
            '</Style>\n'
            # Vermelho Escuro / 10
            '<Style id="darkRed">\n'
            '<LineStyle>\n'
            '<color>ff0000ff</color>\n'
            '<width>2</width>\n'
            '</LineStyle>\n'
            '<PolyStyle>\n'
            '<color>ff000000</color>\n'
            '<colorMode>normal</colorMode>\n'
            '<fill>1</fill>\n'
            '<outline>1</outline>\n'
            '</PolyStyle>\n'
            '</Style>\n'
            # Preto / > 10
            '<Style id="black">\n'
            '<LineStyle>\n'
            '<color>ff000000</color>\n'
            '<width>2</width>\n'
            '</LineStyle>\n'
            '<PolyStyle>\n'
            '<color>ff000000</color>\n'
            '<colorMode>normal</colorMode>\n'
            '<fill>1</fill>\n'
            '<outline>1</outline>\n'
            '</PolyStyle>\n'
            '</Style>\n'
)






'''
<Polygon id="ID">
  <!-- specific to Polygon -->
  <extrude>0</extrude>                       <!-- boolean -->
  <tessellate>0</tessellate>                 <!-- boolean -->
  <altitudeMode>clampToGround</altitudeMode>
        <!-- kml:altitudeModeEnum: clampToGround, relativeToGround, or absolute -->
        <!-- or, substitute gx:altitudeMode: clampToSeaFloor, relativeToSeaFloor -->
  <outerBoundaryIs>
    <LinearRing>
      <coordinates>...</coordinates>         <!-- lon,lat[,alt] -->
    </LinearRing>
  </outerBoundaryIs>
  <innerBoundaryIs><LinearRing>
      <coordinates>...</coordinates>         <!-- lon,lat[,alt] -->
    </LinearRing></innerBoundaryIs>
</Polygon>
'''

'''
<Polygon>
      <extrude>1</extrude>
      <altitudeMode>relativeToGround</altitudeMode>
      <outerBoundaryIs>
        <LinearRing>
          <coordinates>
            -122.3662784465226,37.81884427772081,30
            -122.3652480684771,37.81926777010555,30
            -122.365640222455,37.81986126286519,30
            -122.36666937925,37.81942987753481,30
            -122.3662784465226,37.81884427772081,30
          </coordinates>
        </LinearRing>
      </outerBoundaryIs>
      <innerBoundaryIs>
        <LinearRing>
          <coordinates>
            -122.366212593918,37.81897719083808,30
            -122.3654241733188,37.81929450992014,30
            -122.3657048517827,37.81973175302663,30
            -122.3664882465854,37.81940249291773,30
            -122.366212593918,37.81897719083808,30
          </coordinates>
        </LinearRing>
      </innerBoundaryIs>
    </Polygon>
'''