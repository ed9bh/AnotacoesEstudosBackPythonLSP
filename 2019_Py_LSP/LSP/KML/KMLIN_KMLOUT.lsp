(defun load-functions()

  (defun kmlStarts ()
    (list
      "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n"
      "<kml xmlns=\"http://www.opengis.net/kml/2.2\">\n"
      ;"# '<Placemark>\n"
      "<Document>\n"
      "<name>DWGtoKML</name>\n"
      "<atom:author>Eric Drumond - ed9bh</atom:author>\n"
      ;"#<phoneNumber>+55(31)9 9758-2378</phoneNumber>\n"
      "<description>DWGtoKML foi elaborado por Eric Drumond em 2017/04. Programa gratuito. Quer sua marca aqui, outras opções de DATUM e mais personalização? Entre em contato e solicite um orçamento.</description>\n"
      "<address>\"http://br.linkedin.com/in/ericdrumond\"</address>\n"
      "<atom:link href=\"http://br.linkedin.com/in/ericdrumond\"/>\n"
      (kmlStyle "defaultStyle" "ffffffff" 2)
    )
  )

  (defun kmlEnds ()
    "</Document>\n</kml>"
  )

  (defun kmlHexColor (R G B Transparence)
    (strcat Transparence "x" (rtos B 2 0) "x" (rtos G 2 0) "x" (rtos R 2 0) )
  )

  (defun kmlStyle (Name HexColor Width)
    (strcat
      "<Style id=\"" Name "\">\n"
      "<LineStyle>\n"
      "<color>" HexColor "</color>\n"
      "<width>" (rtos Width 2) "</width>\n"
      "</LineStyle>\n"
      "<PolyStyle>\n"
      "<color>" HexColor "</color>\n"
      "</PolyStyle>\n"
      "</Style>\n"
    )
  )

  (defun kmlLines (CoordinatesList Fuso Emisferio Datum ColorHex / Header Footer Body StyleName)
    (setq
      StyleName (strcat "style_" ColorHex)
      Header
       (strcat
         "<Placemark>\n"
         "<name>AutoCADLines</name>\n"
         "<description>By:EricDrumond</description>\n"
         "<styleUrl>#" StyleName "</styleUrl>\n"
         "<LineString>\n"
         "<tessellate>1</tessellate>\n"
         "<altitudeMode>clampToGround</altitudeMode>\n"
         "<coordinates>\n"
       )
      Footer
       (strcat
         "</coordinates>\n"
         "</LineString>\n"
         "</Placemark>\n"
       )
      Body ""
    )
    (foreach UTMPoint CoordinatesList
      (setq
        LatLon(UTM->GEO (car UTMPoint) (cadr UTMPoint) (read Fuso) Emisferio Datum)
        Body(strcat
              Body (rtos (cdr(assoc "LONGITUDE" LatLon)) 2 15) "," (rtos (cdr(assoc "LATITUDE" LatLon)) 2 15) "\n"
            )
       )
    )
    (strcat Header Body Footer)
  )

  (defun kmlPoints (CoordinatesList Fuso Emisferio Datum ColorHex / KmlPointCoordinates StyleName)
    (setq StyleName (strcat "style_" ColorHex))
    (foreach UTMPoint CoordinatesList
      (setq
        LatLon(UTM->GEO (car UTMPoint) (cadr UTMPoint) (read Fuso) Emisferio Datum)
        KmlPointCoordinates
         (vl-list*
           (strcat
             "\n<Placemark>"
             "<name>Ponto de Referencia</name>"
             "<description>Sem Descricao</description>"
             "<styleUrl>#" StyleName "</styleUrl>\n"
             "<Point>"
             "<coordinates>"(rtos (cdr(assoc "LONGITUDE" LatLon)) 2 15)","(rtos (cdr(assoc "LATITUDE" LatLon)) 2 15)"</coordinates>"
             "</Point>"
             "</Placemark>"
           )
           KmlPointCoordinates
         )
      )
    )
    KmlPointCoordinates
  )

  (defun kmlPointText (UTMPoint Text Fuso Emisferio Datum ColorHex / LatLon KmlPointCoordinate StyleName)
    (setq
      StyleName (strcat "style_" ColorHex)
      LatLon (UTM->GEO (car UTMPoint) (cadr UTMPoint) (read Fuso) Emisferio Datum)
      KmlPointCoordinate
        (strcat
          "\n<Placemark>"
          "<name>" Text "</name>"
          "<description>" Text "</description>"
          "<styleUrl>#" StyleName "</styleUrl>\n"
          "<Point>"
          "<coordinates>" (rtos (cdr (assoc "LONGITUDE" LatLon)) 2 15) "," (rtos (cdr (assoc "LATITUDE" LatLon)) 2 15) "</coordinates>"
          "</Point>"
          "</Placemark>"
        )
    )
    KmlPointCoordinate
  )

  (defun get-entity-coordinates (vla-obj / obj-name coord-list count)
    (setq obj-name (vla-get-objectname vla-obj))
    (cond
      ((= obj-name "AcDbLine")
      (list
        (vlax-safearray->list (vlax-variant-value (vla-get-startpoint vla-obj)))
        (vlax-safearray->list (vlax-variant-value (vla-get-endpoint vla-obj)))
      ))
      ((= obj-name "AcDbPolyline")
      (setq coord-list nil count -1)
      (repeat (/ (length (vlax-get vla-obj 'Coordinates)) 2)
        (setq coord-list
                (vl-list*
                  (vlax-safearray->list
                    (vlax-variant-value (vlax-get-property vla-obj 'Coordinate (setq count (1+ count))))
                  )
                  coord-list)))
      (if (= (vla-get-closed vla-obj) :vlax-true)
        (setq coord-list (vl-list* (vlax-curve-getstartpoint vla-obj) coord-list)))
      (reverse coord-list))
      ((= obj-name "AcDb3dPolyline")
      (setq coord-list nil count -1)
      (repeat (/ (length (vlax-get vla-obj 'Coordinates)) 3)
        (setq coord-list
                (vl-list*
                  (vlax-safearray->list
                    (vlax-variant-value (vlax-get-property vla-obj 'Coordinate (setq count (1+ count))))
                  )
                  coord-list)))
      (if (= (vla-get-closed vla-obj) :vlax-true)
        (setq coord-list (vl-list* (vlax-curve-getstartpoint vla-obj) coord-list)))
      (reverse coord-list))
      ((= obj-name "AcDbPoint")
        (list (vlax-safearray->list (vlax-variant-value (vla-get-coordinates vla-obj)))))
      ((= obj-name "AcDbText")
        (list (vlax-safearray->list (vlax-variant-value (vla-get-insertionpoint vla-obj)))))
    )
  )

  (defun aci->rgb (aci)
    ;; Converts an AutoCAD Color Index (ACI) to an RGB color triplet.
    ;; This is a self-contained version with a hardcoded palette
    ;; to avoid dependency on vl-acad-color->rgb.
    (if (not *aci-rgb-map*)
      (setq *aci-rgb-map*
        '(
          (1 . (255 0 0)) (2 . (255 255 0)) (3 . (0 255 0)) (4 . (0 255 255))
          (5 . (0 0 255)) (6 . (255 0 255)) (7 . (255 255 255)) (8 . (128 128 128))
          (9 . (192 192 192)) (10 . (255 0 0)) (11 . (255 127 127)) (12 . (191 0 0))
          (13 . (191 95 95)) (14 . (127 0 0)) (15 . (127 63 63)) (16 . (76 0 0))
          (17 . (76 38 38)) (18 . (38 0 0)) (19 . (38 19 19)) (20 . (255 63 0))
          (21 . (255 159 127)) (22 . (191 47 0)) (23 . (191 119 95)) (24 . (127 31 0))
          (25 . (127 79 63)) (26 . (76 19 0)) (27 . (76 47 38)) (28 . (38 9 0))
          (29 . (38 23 19)) (30 . (255 127 0)) (31 . (255 191 127)) (32 . (191 95 0))
          (33 . (191 143 95)) (34 . (127 63 0)) (35 . (127 95 63)) (36 . (76 38 0))
          (37 . (76 57 38)) (38 . (38 19 0)) (39 . (38 28 19)) (40 . (255 191 0))
          (41 . (255 223 127)) (42 . (191 143 0)) (43 . (191 167 95)) (44 . (127 95 0))
          (45 . (127 111 63)) (46 . (76 57 0)) (47 . (76 66 38)) (48 . (38 28 0))
          (49 . (38 33 19)) (50 . (255 255 0)) (51 . (255 255 127)) (52 . (191 191 0))
          (53 . (191 191 95)) (54 . (127 127 0)) (55 . (127 127 63)) (56 . (76 76 0))
          (57 . (76 76 38)) (58 . (38 38 0)) (59 . (38 38 19)) (60 . (191 255 0))
          (61 . (223 255 127)) (62 . (143 191 0)) (63 . (167 191 95)) (64 . (95 127 0))
          (65 . (111 127 63)) (66 . (57 76 0)) (67 . (66 76 38)) (68 . (28 38 0))
          (69 . (33 38 19)) (70 . (127 255 0)) (71 . (191 255 127)) (72 . (95 191 0))
          (73 . (143 191 95)) (74 . (63 127 0)) (75 . (95 127 63)) (76 . (38 76 0))
          (77 . (57 76 38)) (78 . (19 38 0)) (79 . (28 38 19)) (80 . (63 255 0))
          (81 . (159 255 127)) (82 . (47 191 0)) (83 . (119 191 95)) (84 . (31 127 0))
          (85 . (79 127 63)) (86 . (19 76 0)) (87 . (47 76 38)) (88 . (9 38 0))
          (89 . (23 38 19)) (90 . (0 255 0)) (91 . (127 255 127)) (92 . (0 191 0))
          (93 . (95 191 95)) (94 . (0 127 0)) (95 . (63 127 63)) (96 . (0 76 0))
          (97 . (38 76 38)) (98 . (0 38 0)) (99 . (19 38 19)) (100 . (0 255 63))
          (101 . (127 255 159)) (102 . (0 191 47)) (103 . (95 191 119)) (104 . (0 127 31))
          (105 . (63 127 79)) (106 . (0 76 19)) (107 . (38 76 47)) (108 . (0 38 9))
          (109 . (19 38 23)) (110 . (0 255 127)) (111 . (127 255 191)) (112 . (0 191 95))
          (113 . (95 191 143)) (114 . (0 127 63)) (115 . (63 127 95)) (116 . (0 76 38))
          (117 . (38 76 57)) (118 . (0 38 19)) (119 . (19 38 28)) (120 . (0 255 191))
          (121 . (127 255 223)) (122 . (0 191 143)) (123 . (95 191 167)) (124 . (0 127 95))
          (125 . (63 127 111)) (126 . (0 76 57)) (127 . (38 76 66)) (128 . (0 38 28))
          (129 . (19 38 33)) (130 . (0 255 255)) (131 . (127 255 255)) (132 . (0 191 191))
          (133 . (95 191 191)) (134 . (0 127 127)) (135 . (63 127 127)) (136 . (0 76 76))
          (137 . (38 76 76)) (138 . (0 38 38)) (139 . (19 38 38)) (140 . (0 191 255))
          (141 . (127 223 255)) (142 . (0 143 191)) (143 . (95 167 191)) (144 . (0 95 127))
          (145 . (63 111 127)) (146 . (0 57 76)) (147 . (38 66 76)) (148 . (0 28 38))
          (149 . (19 33 38)) (150 . (0 127 255)) (151 . (127 191 255)) (152 . (0 95 191))
          (153 . (95 143 191)) (154 . (0 63 127)) (155 . (63 95 127)) (156 . (0 38 76))
          (157 . (38 57 76)) (158 . (0 19 38)) (159 . (19 28 38)) (160 . (0 63 255))
          (161 . (127 159 255)) (162 . (0 47 191)) (163 . (95 119 191)) (164 . (0 31 127))
          (165 . (63 79 127)) (166 . (0 19 76)) (167 . (38 47 76)) (168 . (0 9 38))
          (169 . (19 23 38)) (170 . (0 0 255)) (171 . (127 127 255)) (172 . (0 0 191))
          (173 . (95 95 191)) (174 . (0 0 127)) (175 . (63 63 127)) (176 . (0 0 76))
          (177 . (38 38 76)) (178 . (0 0 38)) (179 . (19 19 38)) (180 . (63 0 255))
          (181 . (159 127 255)) (182 . (47 0 191)) (183 . (119 95 191)) (184 . (31 0 127))
          (185 . (79 63 127)) (186 . (19 0 76)) (187 . (47 38 76)) (188 . (9 0 38))
          (189 . (23 19 38)) (190 . (127 0 255)) (191 . (191 127 255)) (192 . (95 0 191))
          (193 . (143 95 191)) (194 . (63 0 127)) (195 . (95 63 127)) (196 . (38 0 76))
          (197 . (57 38 76)) (198 . (19 0 38)) (199 . (28 19 38)) (200 . (191 0 255))
          (201 . (223 127 255)) (202 . (143 0 191)) (203 . (167 95 191)) (204 . (95 0 127))
          (205 . (111 63 127)) (206 . (57 0 76)) (207 . (66 38 76)) (208 . (28 0 38))
          (209 . (33 19 38)) (210 . (255 0 255)) (211 . (255 127 255)) (212 . (191 0 191))
          (213 . (191 95 191)) (214 . (127 0 127)) (215 . (127 63 127)) (216 . (76 0 76))
          (217 . (76 38 76)) (218 . (38 0 38)) (219 . (38 19 38)) (220 . (255 0 191))
          (221 . (255 127 223)) (222 . (191 0 143)) (223 . (191 95 167)) (224 . (127 0 95))
          (225 . (127 63 111)) (226 . (76 0 57)) (227 . (76 38 66)) (228 . (38 0 28))
          (229 . (38 19 33)) (230 . (255 0 127)) (231 . (255 127 191)) (232 . (191 0 95))
          (233 . (191 95 143)) (234 . (127 0 63)) (235 . (127 63 95)) (236 . (76 0 38))
          (237 . (76 38 57)) (238 . (38 0 19)) (239 . (38 19 28)) (240 . (255 0 63))
          (241 . (255 127 159)) (242 . (191 0 47)) (243 . (191 95 119)) (244 . (127 0 31))
          (245 . (127 63 79)) (246 . (76 0 19)) (247 . (76 38 47)) (248 . (38 0 9))
          (249 . (38 19 23)) (250 . (89 89 89)) (251 . (115 115 115)) (252 . (140 140 140))
          (253 . (165 165 165)) (254 . (191 191 191)) (255 . (217 217 217))
        )
      )
    )
    (cdr (assoc aci *aci-rgb-map*))
  ) 

  (defun dec->hex (n / hexchars res)
    (if (zerop n)
      "00"
      (progn
        (setq hexchars "0123456789ABCDEF")
        (setq res "")
        (while (> n 0)
          (setq res (strcat (substr hexchars (1+ (rem n 16)) 1) res)
                n   (fix (/ n 16))))
        (if (= 1 (strlen res)) (setq res (strcat "0" res)))
        res
      )
    )
  )

  (defun get-all-layer-colors (/ layers-map layer-obj aci rgb)
    (princ "\n--- Construindo Mapa de Cores das Camadas ---")
    (vlax-for layer (vla-get-layers (vla-get-activedocument (vlax-get-acad-object)))
      ;; Obter diretamente o ACI (AutoCAD Color Index) da camada.
      ;; As camadas podem ter um ACI negativo se estiverem desligadas, então usamos abs.
      (setq aci (abs (vla-get-color layer)))
      (setq rgb (aci->rgb aci))
      
      ;; Garante que uma cor válida seja sempre definida, usando branco como padrão.
      (if (not rgb) (setq rgb '(255 255 255)))
      
      (princ (strcat "\nCamada: '" (vla-get-name layer) "' -> ACI: " (itoa aci) " -> RGB: " (vl-princ-to-string rgb)))
      (setq layers-map (cons (cons (vla-get-name layer) rgb) layers-map))
    )
    (princ "\n--- Mapa de Cores das Camadas Concluído ---")
    layers-map
  )

  (defun RGB_Getter (vla-obj layer-colors-map / color-obj aci-color rgb layer-name transparency alpha hex-alpha hex-blue hex-green hex-red r g b)
    (princ "\n--- Executando RGB_Getter para uma entidade ---")
    (setq color-obj (vla-get-truecolor vla-obj))
    (princ (strcat "\n  Método de Cor da Entidade: " (itoa (vla-get-colormethod color-obj))))

    (cond
      ;; Case 1: Color is ByLayer or ByBlock -> Use the layer color from the map
      ((or (= (vla-get-colormethod color-obj) 193) ; acColorMethodByLayer
           (= (vla-get-colormethod color-obj) 192)) ; acColorMethodByBlock
       (setq layer-name (vla-get-layer vla-obj))
       (princ (strcat "\n  Modo: ByLayer/ByBlock. Usando cor da camada: '" layer-name "'"))
       (setq rgb (cdr (assoc layer-name layer-colors-map)))
       (princ (strcat "\n  Resultado do mapa de camadas: " (vl-princ-to-string rgb))))

      ;; Case 2: Color is defined by RGB value (TrueColor)
      ((= (vla-get-colormethod color-obj) 194) ; acColorMethodByRGB
       (princ "\n  Modo: ByRGB (TrueColor)")
       (setq rgb (list (vla-get-red color-obj) (vla-get-green color-obj) (vla-get-blue color-obj))))

      ;; Case 3: Color is defined by ACI
      ((= (vla-get-colormethod color-obj) 195) ; acColorMethodByACI
       (princ (strcat "\n  Modo: ByACI. Índice ACI: " (itoa (vla-get-colorindex color-obj))))
       (setq rgb (aci->rgb (vla-get-colorindex color-obj))))
         
      ;; Case 4: Other/Fallback, default to white
      (t 
       (princ "\n  Modo: Padrão (outro)")
       (setq rgb '(255 255 255)))
    )

    ;; Fallback in case rgb is nil (e.g. layer not found in map)
    (if (not rgb) (progn (princ "\n  A cor resultou em NULO, usando branco como padrão.") (setq rgb '(255 255 255))))

    ;; Handle Transparency
    (if (vlax-property-available-p vla-obj "Transparency")
      (setq transparency (vla-get-transparency vla-obj))
      (setq transparency 0.0)
    )
    (if (not (numberp transparency)) (setq transparency 0.0))

    ;; Set RGB components
    (setq r (car rgb) g (cadr rgb) b (caddr rgb))

    ;; Calculate Alpha from transparency
    (setq alpha (fix (* 255.0 (- 1.0 (/ transparency 100.0)))))
    (if (< alpha 0) (setq alpha 0))
    (if (> alpha 255) (setq alpha 255))
    
    ;; Convert to hex
    (setq hex-alpha (dec->hex alpha)
          hex-blue  (dec->hex b)
          hex-green (dec->hex g)
          hex-red   (dec->hex r))

    (princ (strcat "\n  Cor Hex Final (AABBGGRR): " hex-alpha hex-blue hex-green hex-red))
    ;; Return KML color string
    (strcat hex-alpha hex-blue hex-green hex-red)
  )

  (defun RGB_Setter (vla-obj color_hex / alpha blue green red r g b a true-color-obj)
    (if (vlax-property-available-p vla-obj "TrueColor")
      (progn
        (setq alpha (substr color_hex 1 2)
              blue (substr color_hex 3 2)
              green (substr color_hex 5 2)
              red (substr color_hex 7 2))

        (setq r (read (strcat "#x" red))
              g (read (strcat "#x" green))
              b (read (strcat "#x" blue))
              a (read (strcat "#x" alpha)))
        
        (setq true-color-obj (vla-get-truecolor vla-obj))
        (vla-setrgb true-color-obj r g b)
        (vla-put-colormethod true-color-obj acTrueColor)
        (vla-put-truecolor vla-obj true-color-obj)
        (if (vlax-property-available-p vla-obj "Transparency")
          (vla-put-transparency vla-obj (* 100.0 (- 1.0 (/ a 255.0))))
        )
      )
    )
  )

  (defun string->list (str-in str-del / lst-out str-tmp)
    (while (vl-string-search str-del str-in)
      (setq str-tmp (substr str-in 1 (vl-string-search str-del str-in)))
      (if (/= "" str-tmp)
        (setq lst-out (append lst-out (list str-tmp)))
      )
      (setq str-in (substr str-in (+ (strlen str-tmp) (strlen str-del) 1)))
    )
    (if (/= "" str-in)
      (setq lst-out (append lst-out (list str-in)))
    )
    lst-out
  )

  (defun kml-parser (StringDocument / placemarks placemark start end name-start name-end desc-start desc-end coord-start coord-end style-start style-end styleUrl)
    (setq start 0)
    (while (setq start (vl-string-search "<Placemark>" StringDocument start))
      (setq end (vl-string-search "</Placemark>" StringDocument start))
      (setq placemark_str (substr StringDocument start (+ end 12)))

      (setq name-start (vl-string-search "<name>" placemark_str))
      (setq name-end (vl-string-search "</name>" placemark_str))
      (setq name (substr placemark_str (+ name-start 6) (- name-end (+ name-start 6))))

      (setq desc-start (vl-string-search "<description>" placemark_str))
      (setq desc-end (vl-string-search "</description>" placemark_str))
      (setq description (substr placemark_str (+ desc-start 13) (- desc-end (+ desc-start 13))))

      (setq style-start (vl-string-search "<styleUrl>" placemark_str))
      (setq style-end (vl-string-search "</styleUrl>" placemark_str))
      (setq styleUrl (substr placemark_str (+ style-start 10) (- style-end (+ style-start 10))))
      (setq styleUrl (vl-string-subst "" "#" styleUrl))
      
      (setq coord-start (vl-string-search "<coordinates>" placemark_str))
      (setq coord-end (vl-string-search "</coordinates>" placemark_str))
      (setq coordinates_str (substr placemark_str (+ coord-start 13) (- coord-end (+ coord-start 13))))
      
      (setq coordinates_str (vl-string-translate "\n" " " coordinates_str))
      (setq coordinates_str (vl-string-translate "\t" " " coordinates_str))
      (while (vl-string-search "  " coordinates_str)
          (setq coordinates_str (vl-string-subst " " "  " coordinates_str))
      )
      (setq coordinates_str (vl-string-right-trim " " (vl-string-left-trim " " coordinates_str)))
      
      (setq coordinates (string->list coordinates_str " "))
      (setq points nil)
      (foreach coord-pair coordinates
          (setq LLE (string->list coord-pair ","))
          (setq ENZ (GEO->UTM (read (cadr LLE)) (read (car LLE)) Datum (read Fuso) Emisferio))
          (setq points (cons (list (cdr (assoc "E" ENZ)) (cdr (assoc "N" ENZ)) (if (caddr LLE) (read (caddr LLE)) 0.0)) points))
      )

      (setq placemark (list (cons "name" name) (cons "description" description) (cons "points" (reverse points)) (cons "styleUrl" styleUrl)))
      (setq placemarks (cons placemark placemarks))
      (setq start end)
    )
    (reverse placemarks)
  )
  
  (defun kml-style-parser (StringDocument / styles style start end id-start id-end color-start color-end style-id color)
    (setq start 0)
    (while (setq start (vl-string-search "<Style id=\"" StringDocument start))
      (setq end (vl-string-search "</Style>" StringDocument start))
      (setq style_str (substr StringDocument start (+ end 8)))

      (setq id-start (vl-string-search "<Style id=\"" style_str))
      (setq id-end (vl-string-search "\">" style_str))
      (setq style-id (substr style_str (+ id-start 11) (- id-end (+ id-start 11))))

      (setq color-start (vl-string-search "<color>" style_str))
      (setq color-end (vl-string-search "</color>" style_str))
      (setq color (substr style_str (+ color-start 7) (- color-end (+ color-start 7))))

      (setq style (list (cons "id" style-id) (cons "color" color)))
      (setq styles (cons style styles))
      (setq start end)
    )
    (reverse styles)
  )

  ) ; <<<--- load-functions


  (defun c:kmlOUT (/ *error* cad doc model file KMLFile Fuso Emisferio DATUM SS
                      entity_data_list unique_colors color_hex style_name
                      layer-colors-map KmlContent)

    (defun *error* (msg)
      (if KMLFile (close KMLFile))
      (if doc (vla-endundomark doc))
      (if msg (princ (strcat "\nErro: " msg)))
      (princ)
    )

    (defun main (/ ent_name vla-obj obj-name coords text-string i)
      (if (setq conv_lsp (findfile "utm-geo_conversor.lsp"))
          (load conv_lsp)
          (progn (alert "utm-geo_conversor.lsp not found!") (exit))
      )

      (load-functions)

      (initget -1 (setq Fusos "17 18 19 20 21 22 23 24 25"))
      (setq Fuso(getkword (strcat "\nSelecione o FUSO [" (vl-string-translate " " "/" Fusos) "]:> ")))
        (if (not Fuso) (exit))

      (initget -1 (setq Emisferios "S N"))
      (setq Emisferio (getkword "\nEmisferio [Sul/Norte]:> "))
        (if (not Emisferio) (exit))


      (initget -1 (setq DATUMList "Sirgas-2000 sAd-69 Corrego"))
      (setq DATUM (strcase (getkword (strcat "\nSelecione o DATUM [" (vl-string-translate " " "/" DATUMList) "]:> "))))
        (if (not DATUM) (exit))

      (princ "\nSelecione as entidades a enviar para o google earth:> ")
      (setq SS(ssget '((0 . "*line,Point,Text"))))
      (if (not SS) (exit))

      ;; --- PRIMEIRA PASSAGEM: Coletar todos os dados ---
      (princ "\nIniciando primeira passagem: Coletando dados das entidades...")
      (setq entity_data_list nil
            unique_colors nil
            layer-colors-map (get-all-layer-colors)
            i -1
      )
      (while (< (setq i (1+ i)) (sslength SS))
        (setq ent_name (ssname SS i))
        (if ent_name
          (progn
            (setq vla-obj (vlax-ename->vla-object ent_name))
            (setq obj-name (vla-get-objectname vla-obj))
            (setq coords (get-entity-coordinates vla-obj))
            (setq color-hex (RGB_Getter vla-obj layer-colors-map))
            (setq text-string (if (= obj-name "AcDbText") (vla-get-textstring vla-obj) nil))
            (if coords
              (progn
                ;; Adiciona a cor à lista de cores únicas se ainda não estiver lá
                (if (not (member color-hex unique_colors))
                  (setq unique_colors (cons color-hex unique_colors))
                )
                ;; Adiciona os dados da entidade à lista principal
                (setq entity_data_list 
                  (cons 
                    (list 
                      (cons 'obj-name obj-name)
                      (cons 'coords coords)
                      (cons 'color-hex color-hex)
                      (cons 'text text-string)
                    )
                    entity_data_list
                  )
                )
              )
            )
          )
        )
      )
      (setq entity_data_list (reverse entity_data_list))
      (princ (strcat "\n...Primeira passagem concluída. " (itoa (length entity_data_list)) " entidades processadas."))
      
      ;; --- SEGUNDA PASSAGEM: Escrever o arquivo KML ---
      (princ "\nIniciando segunda passagem: Escrevendo arquivo KML...")
      (if (not (setq file (getfiled "Salvar arquivo KML..." (getvar 'dwgprefix) "kml" 1)))
        (exit)
      )
      (setq KMLFile (open file "w"))

      ;; Escreve o cabeçalho do KML
      (foreach line (kmlStarts)
        (write-line line KMLFile)
      )
      
      ;; Escreve todos os estilos coletados
      (foreach color_hex unique_colors
        (setq style_name (strcat "style_" color_hex))
        (write-line (kmlStyle style_name color_hex 2.0) KMLFile)
      )

      ;; Escreve os placemarks
      (foreach entity_data entity_data_list
        (progn
          (setq obj-name (cdr (assoc 'obj-name entity_data)))
          (setq coords (cdr (assoc 'coords entity_data)))
          (setq color-hex (cdr (assoc 'color-hex entity_data)))
          (setq text-string (cdr (assoc 'text entity_data)))
          (setq KmlContent nil)
          (cond
            ((= obj-name "AcDbText")
              (setq KmlContent (kmlPointText (car coords) text-string Fuso Emisferio Datum color-hex))
              (write-line KmlContent KMLFile)
            )
            ((= obj-name "AcDbPoint")
              (setq KmlContent (kmlPoints coords Fuso Emisferio Datum color-hex))
              (foreach point KmlContent
                (write-line point KMLFile)
              )
            )
            (t ; Linhas, Polilinhas, etc.
              (setq KmlContent (kmlLines coords Fuso Emisferio Datum color-hex))
              (write-line KmlContent KMLFile)
            )
          )
        )
      )

      ;; Escreve o final do KML
      (write-line (kmlEnds) KMLFile)
      (close KMLFile)
      (princ (strcat "\nArquivo KML '" file "' salvo com sucesso."))
    )

    (setq
      cad (vlax-get-acad-object)
      doc (vla-get-activedocument cad)
      MSpace (vla-get-modelspace doc)
    )

    (vla-startundomark doc)
    (setvar 'cmdecho 0)
    (main)
    (setvar 'cmdecho 1)
    (vla-endundomark doc)
    (princ)

  )

  (defun c:kmlIN (/ *error* cad doc model file KMLFile)

    (defun main (/ conv_lsp Fusos Fuso Emisferios Emisferio DATUMList DATUM file KMLFile StringDocument line styles placemarks placemark points styleUrl style ent pt DrawLine ent_point ent_text)
      (if (setq conv_lsp (findfile "utm-geo_conversor.lsp"))
          (load conv_lsp)
          (progn (alert "utm-geo_conversor.lsp not found!") (exit))
      )

      (load-functions)

      (initget -1 (setq Fusos "17 18 19 20 21 22 23 24 25"))
      (setq Fuso(getkword (strcat "\nSelecione o FUSO [" (vl-string-translate " " "/" Fusos) "]:> ")))

      (initget -1 (setq Emisferios "S N"))(setq Emisferio (getkword "\nEmisferio [Sul/Norte]:"))

      (initget -1 (setq DATUMList "Sirgas-2000 sAd-69 Corrego"))
      (setq
        DATUM
         (strcase (getkword (strcat "\nSelecione o DATUM [" (vl-string-translate " " "/" DATUMList) "]")) )
      )

      (setq
        file(getfiled "Selecione o arquivo KML..." (getvar'dwgprefix) "KML" 8)
        KMLFile(open file "r" "utf8")
        StringDocument ""
      )

      (while
        (setq line(read-line KMLFile))
        (setq
          StringDocument (strcat StringDocument line "\n")
        )
      )

      (setq styles (kml-style-parser StringDocument))
      (setq placemarks (kml-parser StringDocument))

      (foreach placemark placemarks
        (setq points (cdr (assoc "points" placemark))
              styleUrl (cdr (assoc "styleUrl" placemark))
              style (assoc styleUrl (mapcar '(lambda (x) (list (cdr (assoc "id" x)) (cdr (assoc "color" x)))) styles))
        )

        ;; Process placemark only if it contains coordinate points
        (if (and points (> (length points) 0))
          (if (= 1 (length points))
            ;; Handle Placemark with a single point
            (progn
              (setq pt (car points))
              (setq ent_point (vla-addpoint MSpace (vlax-3d-point pt)))
              (if (and ent_point style) (RGB_Setter ent_point (cadr style)))
              (setq ent_text (vla-addtext MSpace (cdr (assoc "name" placemark)) (vlax-3d-point pt) 2.5))
              (if (and ent_text style) (RGB_Setter ent_text (cadr style)))
            )
            ;; Handle Placemark with multiple points (line)
            (progn
              (setq DrawLine nil)
              (foreach pt points
                (setq DrawLine (append DrawLine pt))
              )
              (setq ent (vla-add3DPoly
                MSpace
                (vlax-make-variant
                  (vlax-safearray-fill
                    (vlax-make-safearray vlax-vbdouble (cons 0 (1- (length DrawLine))))
                    DrawLine
                  )
                )
              ))
              ;; Apply style only if the entity was created successfully
              (if (and ent style)
                (RGB_Setter ent (cadr style))
              )
            )
          )
        )
      )
    )

    (setq
      cad (vlax-get-acad-object)
      doc (vla-get-activedocument cad)
      MSpace (vla-get-modelspace doc)
    )

    (vla-startundomark doc)
    (setvar 'cmdecho 0)
    (main)
    (setvar 'cmdecho 1)
    (vla-endundomark doc)
    (princ)

  )