(defun c:AnaliseDrenagem ( / *error*)
  
  (vl-load-com)
  
  (defun *error* (msg)
    (princ msg)
    (vla-endundomark C3Ddoc)
    (princ)
  )
  
  (defun callback-modified (notifier-object reactor-object parameter-list / tempList)
    (Analise VlaoEixo VlaoGreideProfileEntity)
  )
  
  
  (defun Analise (BaseLine ProfileDesign)
    (c:AnaliseReset)
    (setq
      ListOfPVIs(vlax-get ProfileDesign 'PVIs)
      ListOfPVIsPoints nil
    )
    (vlax-for item ListOfPVIs
              (setq
                ListOfPVIsPoints
                 (vl-list*
                   (list
                     (vlax-get item 'Station)
                     (vlax-get item 'Elevation)
                   )
                   ListOfPVIsPoints
                  )
              )
    )
    (setq
      ListOfPVIsPoints(reverse ListOfPVIsPoints)
    )
    (foreach end (cdr ListOfPVIsPoints)
      (progn
        (setq
          start(nth (1-(vl-position end ListOfPVIsPoints)) ListOfPVIsPoints)
          Cursor (car start)
          CoordList nil
        )
        (vlax-invoke-method BaseLine 'PointLocation (car start) direcaoValor 'StartEastCoordinate 'StartNorthCoordinate)
        (vlax-invoke-method BaseLine 'PointLocation (car end) direcaoValor 'EndEastCoordinate 'EndNorthCoordinate)
        (setq
          Desn (- (cadr end) (cadr start) )
          Dist (- (car  end) (car  start) )
          Incl (/ Desn Dist)
          MidStation (+ Cursor (/ Dist 2))
          StrText(strcat "EXT: " (rtos Dist 2) "m - INC: " (rtos (* Incl 100.) 2) "%" )
          LengthHighText (cadr(textBox (list(cons 1 StrText))))
          LengthText (car LengthHighText)
          LengthText (if (> LengthText (* Dist 2)) (/(abs direcaoValor)2) (abs direcaoValor))
        )
        (vlax-invoke-method BaseLine 'PointLocation MidStation (* direcaoValor 2) 'MidEastCoordinate 'MidNorthCoordinate)
        (vlax-invoke-method BaseLine 'PointLocation (+ MidStation 0.01) (* direcaoValor 2) 'AjusteEastCoordinate 'AjusteNorthCoordinate)
        (setq
          Ang (if
                (< MidEastCoordinate AjusteEastCoordinate)
                (angle (list MidEastCoordinate MidNorthCoordinate) (list AjusteEastCoordinate AjusteNorthCoordinate) )
                (angle (list AjusteEastCoordinate AjusteNorthCoordinate) (list MidEastCoordinate MidNorthCoordinate) )
              )
        )
        (progn ; Text Insertion Information
          (setq
            VlaoText
             (vla-addtext
               BLKSpace
               StrText
               (vlax-3d-point MidEastCoordinate MidNorthCoordinate 0)
               (if (> LengthText (/ (abs direcaoValor) 4.)) (/ (abs direcaoValor) 4.) LengthText)
             )
            EraseListVlao(vl-list* VlaoText EraseListVlao)
          )
          (vla-put-alignment VlaoText acAlignmentMiddleCenter)
          (vla-put-textalignmentpoint VlaoText (vlax-3d-point MidEastCoordinate MidNorthCoordinate 0) )
          (vla-put-rotation VlaoText Ang)
          (vla-put-layer VlaoText nameLayer)
        )
        (while
          (< Cursor (car end))
          (vlax-invoke-method BaseLine 'PointLocation Cursor direcaoValor 'CursorEastCoordinate 'CursorNorthCoordinate)
          (setq
            CoordList(vl-list* (list CursorEastCoordinate CursorNorthCoordinate) CoordList)
            Cursor(1+ Cursor)
          )
        )
        (if
          CoordList
          (progn
            (setq
              LwPolyLine(vla-addLightweightPolyline
                          BLKSpace ;C3DMSpace
                          (vlax-make-variant
                            (vlax-safearray-fill
                              (vlax-make-safearray vlax-vbdouble (cons 0 (1-(length (apply'append(reverse CoordList))))))
                              (apply'append(reverse CoordList))
                            )
                          )
                        )
              EraseListVlao(vl-list* LwPolyLine EraseListVlao)
              VectorCount(1-(1-(length CoordList)))
              SetaHeadHigh(if (< Dist (abs direcaoValor) ) (/ Dist 4.)  (abs direcaoValor))
              SetaHeadLeng(if (<= (length CoordList) (fix(abs direcaoValor))) (fix(abs(1-(length CoordList)))) (fix(abs direcaoValor)) )
            )
            (vlax-put LwPolyLine 'Layer nameLayer)
            (vla-getwidth LwPolyLine VectorCount 'WInicio 'WFinal)
            (if (> (cadr end) (cadr start) )
              (progn
                (vla-setwidth LwPolyLine 0 0. SetaHeadHigh)
                (vla-setwidth LwPolyLine VectorCount 0. SetaHeadHigh)
              )
              (progn
                (vla-setwidth LwPolyLine 0 SetaHeadHigh 0.)
                (vla-setwidth LwPolyLine VectorCount SetaHeadHigh 0.)
              )
            )
          )
        )
      )
    )
    (vla-regen (vla-get-ActiveDocument(vlax-get-acad-object)) acAllViewports)
  )
  
  (defun main ()
    
    (initget -1 "Esquerda Direita")
    (setq
      direcao (getkword "\nSelecio a direcao das setas [Esquerda/Direita]:>")
      direcaoValor (if (= direcao "Esquerda") -5. 5.)
      Layer (vla-add
              (vla-get-layers C3Ddoc)
              (setq nameLayer (strcat "__AnaliseDeDrenagem"(if (= direcao "Esquerda") "-ESQ" "-DIR" )"__"))
            )
    )
    (if
      (= direcao "Esquerda")
      (vlax-put Layer 'Color 40)
      (vlax-put Layer 'Color 141)
    )
    
    (setq
      EobjEixo(entsel "\nSelecione o Eixo : ")
      VlaoEixo(if EobjEixo (vlax-ename->vla-object(car EobjEixo)) (exit))
      VlaoEixoName(vla-get-name VlaoEixo)
      VlaoEixoHANDLE(vla-get-handle VlaoEixo)
      BLKDataBase(vla-get-blocks C3Ddoc)
      BLKSpace(vla-add BLKDataBase (vlax-3d-point 0 0 0) (strcat VlaoEixoName "_" direcao) )
    )
    
    (setq BLKAnaliseInserted(vla-insertblock C3DMSpace (vlax-3d-point 0. 0. 0.) (strcat VlaoEixoName "_" direcao) 1 1 1 0))
    
    (setq
      VlaoProfiles(vlax-get VlaoEixo 'Profiles)
      VlaoProfileList nil
      VlaoProfileNameList nil
      VlaoProfileNameListOptions ""
    )
    
    (vlax-for item VlaoProfiles
      (setq
        VlaoProfileList(vl-list* item VlaoProfileList)
        VlaoProfileNameList(vl-list* (strcase (vlax-get item 'Name)) VlaoProfileNameList)
        VlaoProfileNameListOptions(strcat
                                    (strcase (vl-string-translate ProfileStrOld ProfileStrNew (vlax-get item 'Name)))
                                    " "
                                    VlaoProfileNameListOptions
                                  )
      )
    )
    
    (initget 64 VlaoProfileNameListOptions)
    (setq
      VlaoGreideProfileName (getkword (strcat "\nSelecione o Greide [" (vl-string-translate " " "/" VlaoProfileNameListOptions) "] :> " ))
    )
    
    (vlax-for item VlaoProfiles
              (if
                (= (vl-string-translate ProfileStrOld ProfileStrNew(strcase(vla-get-name item))) VlaoGreideProfileName)
                (setq
                  VlaoGreideProfileHANDLE(vla-get-handle item)
                  VlaoGreideProfileEntity item
                )
                (princ)
              )
    )
    
    (Analise VlaoEixo VlaoGreideProfileEntity)
    
    ;;;
    (if
      *reator-modificacao*
      (vlr-remove *reator-modificacao*)
    )
    (setq
      *reator-modificacao*
       (vlr-object-reactor
         (list
           VlaoEixo
           VlaoGreideProfileEntity
         )
         "ReatorAnaliseDrenagem"
         '(
           (:vlr-modified . callback-modified)
           
           )
       )
    )
    ;;;
    
  )
  
  (setq
    C3DReg (strcat "HKEY_LOCAL_MACHINE\\" (if vlax-user-product-key (vlax-user-product-key) (vlax-product-key)))
    C3DCode (vl-registry-read C3DReg "Release")
    VerString (substr C3DCode 1 (vl-string-search "." C3DCode (1+(vl-string-search "." C3DCode))))
    ProdutString (strcat "AeccXUiLand.AeccApplication." VerString)
    DataString (strcat "AeccXLand.AeccTinCreationData." VerString)
    C3D (vl-catch-all-apply 'vlax-invoke (list (vlax-get-acad-object) 'GetInterfaceObject ProdutString))
    C3Ddoc (vla-get-activedocument C3D)
    C3DMSpace (vla-get-modelspace C3Ddoc)
    ProfileStrOld " _-"
    ProfileStrNew "..."
    EraseListVlao (if EraseListVlao EraseListVlao nil)
  )
  
  
  (vla-startundomark C3Ddoc)
  (setvar 'cmdecho 0)
  ;;;
  (initget -1 "Selecionar Consolidar Resetar")
  (setq MenuInicial(getkword "\tSelecione a opcao [Selecionar/Consolidar/Resetar]:> "))
  (if
    (= MenuInicial "Selecionar")
    (main)
    (if
      (= MenuInicial "Consolidar")
      (c:AnaliseConsolidada)
      (if
        (= MenuInicial "Resetar")
        (c:AnaliseReset)
        (eixt)
      )
    )
  )
  ;;;
  (vla-endundomark C3Ddoc)
  (setvar 'cmdecho 1)
  (princ)
  
)

(defun c:AnaliseReset ()
  (foreach erase EraseListVlao (vl-catch-all-apply 'vla-delete (list erase)) )
  (setq EraseListVlao nil)
  (vl-catch-all-apply 'vlr-remove (list *reator-modificacao*))
  (princ)
)

(defun c:AnaliseConsolidada ()
  (vlr-remove *reator-modificacao*)
  (setq EraseListVlao nil BLKAnaliseInserted nil)
  (princ)
)