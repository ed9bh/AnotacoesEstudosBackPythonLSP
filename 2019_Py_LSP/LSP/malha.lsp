(defun c:mlh (/
                *error* main EnameMoldura VlaoMoldura DistanciaEntreLinhas
                XMin XMax YMin YMax X Y
                RefLine InterPoints PontoOrigem PontoDestino
                vlaoLine vlaoTxtO vlaoTxtD A B
                LogReport FileNameMem LogFilePath LogFileOpened msg
                )
  
  (defun *error* (msg)
    (ucsSetter)
    (setvar 'cmdecho 1)
    (vla-endundomark doc)
    (LogReport nil msg)
    (princ)
  )
  
  ; Log
  (defun LogReport(fileNew msg)
    (setq
      FileNameMem (if FileNameMem FileNameMem nil)
      FileNameMem (if fileNew nil FileNameMem)
    )
    (if 
      (= fileNew t)
      (setq
        LogFilePath(strcat(getvar 'dwgprefix)"LogReport("(vl-string-right-trim ".dwg" (getvar 'dwgname))")-"(vl-string-translate "." "_" (rtos (getvar 'cdate) 2 6) )".log")
        FileNameMem LogFilePath
      )
      (setq
        LogFilePath FileNameMem
      )
    )
    (setq LogFileOpened(open LogFilePath "a+"))
    (princ
      (strcat "Log[" (vl-string-translate "." "_" (rtos (getvar 'cdate) 2 6) ) "]:> " (if msg msg "...") "\n" )
      LogFileOpened
      )
    (close LogFileOpened)
  )
  
  ;---
  
  (defun ucsGetter ()
    (LogReport nil "ucsGetter")
    (setq UCSs (vla-get-UserCoordinateSystems doc))
    (if
      (= (vlax-variant-value (vla-GetVariable doc "UCSNAME")) "")
      (progn
        (setq Utility (vla-get-utility doc)
              currUCS(vla-add UCSs
                              (vla-GetVariable doc "UCSORG")
                              (vla-translatecoordinates Utility (vla-GetVariable doc "UCSXDIR") acUCS acWorld :vlax-false)
                              (vla-translatecoordinates Utility (vla-GetVariable doc "UCSYDIR") acUCS acWorld :vlax-false)
                              "OriginalUCS"
                     )
        )
      )
      (setq currUCS (vla-get-ActiveUCS doc))
    )
  )
  
  (defun ucsSetter ()
    (LogReport nil "ucsSetter")
    (if
      currUCS
      (vla-put-ActiveUCS doc currUCS)
      (princ)
    )
  )
  
  (defun main ()
    (LogReport nil "main")
    (setq
      EnameMoldura(entsel "\nSelecione a moldura para aplicar a malha de coordenadas : ")
      VlaoMoldura(if EnameMoldura (vlax-ename->vla-object (car EnameMoldura)) (progn (princ "\tNenhuma entidade selecionada, encerrando aplicacao...") (exit)))
    )

    (cond
      ((=(vla-get-ObjectName VlaoMoldura) "AcDbLine")
       (alert (setq msg "¡¡¡Alerta!!!\n\n\nNao foi selecionado uma entidade valida!!!\nNecessario que seja Polyline 2D em formato retangular!!!"))
       (LogReport nil msg)
       (exit)
       )
    )
    
    (if
      (/=(vla-get-elevation VlaoMoldura)0.)
      (progn
        (progn
          (alert (setq msg "¡¡¡Moldura com elevação, é necessario estar\nna eleveção zero!!!"))
          (LogReport nil msg)
          (exit)
        )
      )
    )
    
    (setq
      DistanciaEntreLinhas (getreal "\nDigite a distancia da malha (100): ")
      DistanciaEntreLinhas (if DistanciaEntreLinhas DistanciaEntreLinhas 100)
      TextScale (* DistanciaEntreLinhas 0.020)
    )
    
    (LogReport nil (strcat "DistanciaEntreLinhas=" (rtos DistanciaEntreLinhas 2)) )
    (LogReport nil (strcat "TextScale=" (rtos TextScale 2)) )
    
    (if (or (not DistanciaEntreLinhas) (<= DistanciaEntreLinhas 0.))
      (progn
        (LogReport nil "\nDistancia entre linhas invalida.")
        (exit)
      )
    )
    
    (LogReport nil "Moldura")
    (vlax-invoke-method VlaoMoldura 'GetBoundingBox 'XYMin 'XYMax)
    
    (setq
      XMin (car (vlax-safearray->list XYMin))
      XMax (car (vlax-safearray->list XYMax))
      YMin (cadr (vlax-safearray->list XYMin))
      YMax (cadr (vlax-safearray->list XYMax))
    )
    
    (setq
      X (- XMin (rem XMin DistanciaEntreLinhas))
      Y (- YMin (rem YMin DistanciaEntreLinhas))
    )
    
    (setq
      XTextsI nil
      XTextsS nil
      YTextsE nil
      YTextsD nil
    )
    
    (LogReport nil "Repetição While X")
    (while
      (< X XMax)
      (setq
        RefLine(vla-addxline MSpace (vlax-3d-point(list X YMin)) (vlax-3d-point(list X YMax)) )
        InterPoints(vlax-invoke VlaoMoldura 'IntersectWith RefLine acextendnone)
        PontoOrigem(if InterPoints (list (nth 0 InterPoints) (nth 1 InterPoints) (nth 2 InterPoints)) nil)
        PontoDestino(if PontoOrigem (if (>= (length InterPoints) 5) (list (nth 3 InterPoints) (nth 4 InterPoints) (nth 5 InterPoints))) nil)
      )
      (vla-delete RefLine)
      (if PontoOrigem
        (if PontoDestino
          (progn
            (setq vlaoLine(vla-addline MSpace (vlax-3d-point PontoOrigem) (vlax-3d-point PontoDestino) ))
            (vlax-invoke-method vlaoLine 'GetBoundingBox 'A 'B)
            (setq
              A (vlax-safearray->list A) B (vlax-safearray->list B)
              A (list (-(car A) (* DistanciaEntreLinhas 0.01)) (cadr A))
              B (list (-(car B) (* DistanciaEntreLinhas 0.01)) (cadr B))
            )
            ;
            (setq vlaoTxtO(vla-addtext Mspace (strcat "E="(rtos X 2 0)) (vlax-3d-point A) TextScale))
            (vla-put-alignment vlaoTxtO acAlignmentLeft)
            (vl-catch-all-apply 'vla-put-textalignmentpoint (list vlaoTxtO (vlax-3d-point (car A) (cadr A))))
            (vla-put-rotation vlaoTxtO 1.5708)
            ;
            (setq vlaoTxtD(vla-addtext Mspace (strcat "E="(rtos X 2 0)) (vlax-3d-point B) TextScale))
            (vla-put-alignment vlaoTxtD acAlignmentRight)
            (vl-catch-all-apply 'vla-put-textalignmentpoint (list vlaoTxtD (vlax-3d-point (car B) (cadr B))))
            (vla-put-rotation vlaoTxtD 1.5708)
            ;
            (vla-put-layer vlaoline LayLin)
            (vla-put-layer vlaoTxtO LayText)
            (vla-put-layer vlaoTxtD LayText)
            (setq
              XTextsI (vl-list* vlaoTxtO XTextsI)
              XTextsS (vl-list* vlaoTxtD XTextsS)
            )
          )
          (LogReport nil "Sem Destino...")
        )
        (LogReport nil "Sem Origem...")
      )
      (setq X (+ X DistanciaEntreLinhas))
    )
    
    (LogReport nil "Repetição While Y")
    (while
      (< Y YMax)
      (setq
        RefLine(vla-addxline MSpace (vlax-3d-point(list XMin Y)) (vlax-3d-point(list XMax Y)) )
        InterPoints(vlax-invoke VlaoMoldura 'IntersectWith RefLine acextendnone)
        PontoOrigem(if InterPoints (list (nth 0 InterPoints) (nth 1 InterPoints) (nth 2 InterPoints)) nil)
        PontoDestino(if PontoOrigem (if (>= (length InterPoints) 5) (list (nth 3 InterPoints) (nth 4 InterPoints) (nth 5 InterPoints))) nil)
      )
      (vla-delete RefLine)
      (if PontoOrigem
        (if PontoDestino
          (progn
            (setq vlaoLine(vla-addline MSpace (vlax-3d-point PontoOrigem) (vlax-3d-point PontoDestino) ))
            (vlax-invoke-method vlaoLine 'GetBoundingBox 'A 'B)
            (setq
              A (vlax-safearray->list A) B (vlax-safearray->list B)
              A (list (car A) (+(cadr A) (* DistanciaEntreLinhas 0.01)) )
              B (list (car B) (+(cadr B) (* DistanciaEntreLinhas 0.01)) )
            )
            ;
            (setq vlaoTxtO(vla-addtext Mspace (strcat "N="(rtos Y 2 0)) (vlax-3d-point A) TextScale))
            (vla-put-alignment vlaoTxtO acAlignmentLeft)
            (vl-catch-all-apply 'vla-put-textalignmentpoint (list vlaoTxtO (vlax-3d-point (car A) (cadr A))))
            ;
            (setq vlaoTxtD(vla-addtext Mspace (strcat "N="(rtos Y 2 0)) (vlax-3d-point B) TextScale))
            (vla-put-alignment vlaoTxtD acAlignmentRight)
            (vl-catch-all-apply 'vla-put-textalignmentpoint (list vlaoTxtD (vlax-3d-point (car B) (cadr B))))
            ;
            (vla-put-layer vlaoline LayLin)
            (vla-put-layer vlaoTxtO LayText)
            (vla-put-layer vlaoTxtD LayText)
            (setq
              YTextsE (vl-list* vlaoTxtO YTextsE)
              YTextsD (vl-list* vlaoTxtD YTextsD)
            )
          )
          (LogReport nil "Sem Destino...")
        )
        (LogReport nil "Sem Origem...")
      )
      (setq Y (+ Y DistanciaEntreLinhas))
    )
    
    ; Corrigir Posicionamento ao Cruzar Informações
    (LogReport nil "Corrigir Posicionamento ao Cruzar Informações")
    (setq FatorMove 0.005)
    
    (foreach item YTextsD
      (foreach interferencia (append XTextsI XtextsS (list VlaoMoldura))
        (progn
          (while
            (setq
              TesteDeColisao(vlax-invoke item 'IntersectWith interferencia acextendnone)
            )
            (vlax-invoke-method item 'GetBoundingBox 'A 'B)
            (setq A(vlax-safearray->list A))
            (vla-move item (vlax-3d-point A) (vlax-3d-point (list (-(car A)(* DistanciaEntreLinhas FatorMove)) (cadr A))) )
          )
        )
      )
    )
    
    (foreach item YTextsE
      (foreach interferencia (append XTextsI XtextsS (list VlaoMoldura))
        (progn
          (while
            (setq
              TesteDeColisao(vlax-invoke item 'IntersectWith interferencia acextendnone)
            )
            (vlax-invoke-method item 'GetBoundingBox 'A 'B)
            (setq B(vlax-safearray->list B))
            (vla-move item (vlax-3d-point B) (vlax-3d-point (list (+(car B)(* DistanciaEntreLinhas FatorMove)) (cadr B))) )
          )
        )
      )
    )
    
    (foreach item XTextsI
      (foreach interferencia (append YTextsE YTextsD (list VlaoMoldura))
        (progn
          (while
            (setq
              TesteDeColisao(vlax-invoke item 'IntersectWith interferencia acextendnone)
            )
            (vlax-invoke-method item 'GetBoundingBox 'A 'B)
            (setq A(vlax-safearray->list A))
            (vla-move item (vlax-3d-point A) (vlax-3d-point (list (car A) (+(cadr A)(* DistanciaEntreLinhas FatorMove)) )) )
          )
        )
      )
    )
    
    (foreach item XtextsS
      (foreach interferencia (append YTextsE YTextsD (list VlaoMoldura))
        (progn
          (while
            (setq
              TesteDeColisao(vlax-invoke item 'IntersectWith interferencia acextendnone)
            )
            (vlax-invoke-method item 'GetBoundingBox 'A 'B)
            (setq B(vlax-safearray->list B))
            (vla-move item (vlax-3d-point B) (vlax-3d-point (list (car B) (-(cadr B)(* DistanciaEntreLinhas FatorMove)) )) )
          )
        )
      )
    )
    
    ; Conversão e Acabamento
    (LogReport nil "Conversão e Acabamento")
    (foreach item (append XTextsI XTextsS YTextsE YTextsD)
      (progn
        ; Extract
        (setq
          TextString (vla-get-TextString item)
          PointInsert (vla-get-InsertionPoint item)
          PointInsertAlignment (vla-get-TextAlignmentPoint item)
          Layer (vla-get-Layer item)
          Height (vla-get-Height item)
          Color (vla-get-Color item)
          Style (vla-get-StyleName item)
          Rotation (vla-get-rotation item)
        )
        ; Convert
        (setq
          NeoMTextEntity (vla-addmtext MSpace PointInsert 0 TextString)
        )
        (vl-catch-all-apply 'vla-put-TextAlignmentPoint (list NeoMTextEntity PointInsertAlignment))
        (vla-put-Rotation NeoMTextEntity Rotation)
        (vla-put-Color NeoMTextEntity Color)
        (vla-put-Layer NeoMTextEntity Layer)
        (vla-put-Height NeoMTextEntity Height)
        (vla-put-StyleName NeoMTextEntity Style)
        (vla-put-BackGroundFill NeoMTextEntity -1)
      )
      (vlax-invoke-method item 'GetBoundingBox 'D1 'D2)
      (vlax-invoke-method NeoMTextEntity 'GetBoundingBox 'O1 'O2)
      (setq
        O1 (vlax-safearray->list O1)
        O2 (vlax-safearray->list O2)
        D1 (vlax-safearray->list D1)
        D2 (vlax-safearray->list D2)
        O3 (list (car O1) (cadr O2) (caddr O2) )
        D3 (list (car D1) (cadr D2) (caddr D2) )
        EnameObj (entget(vlax-vla-object->ename NeoMTextEntity))
      )
      (entmod (subst (cons 45 1) (assoc 45 EnameObj) EnameObj))
      (vla-move NeoMTextEntity (vlax-3d-point O3) (vlax-3d-point D3) )
      ; Delete Old Text
      (vla-delete item)
    )
    
  )
  
  ;---
  
  (LogReport t "Incio do Ciclo...")
  
  (setq
    acad (vlax-get-acad-object)
    doc (vla-get-activedocument acad)
    MSpace (vla-get-modelspace doc)
    LayLin "TL-GER-MA"
    LayText "TL-GER-P02"
    LayerLine(if (=(tblsearch "layer" LayLin)nil) (vla-add (vla-get-layers (vla-get-activedocument (vlax-get-acad-object ) ) ) LayLin))
    LayerText(if (=(tblsearch "layer" LayText)nil) (vla-add (vla-get-layers (vla-get-activedocument (vlax-get-acad-object ) ) ) LayText))
  )
  
  (if LayerLine (vla-put-color LayerLine 252))
  (if LayerLine (vla-put-linetype LayerLine "Continuous"))
  (if LayerText (vla-put-color LayerText 2))
  (if LayerText (vla-put-linetype LayerText "Continuous"))
  
  (vla-startundomark doc)
  (setvar 'cmdecho 0)
  (ucsGetter)
  (vl-cmdf "ucs" "" "")
  (main)
  (ucsSetter)
  (setvar 'cmdecho 1)
  (vla-endundomark doc)
  (LogReport nil "Fim do Ciclo...")
  (princ)
  
)

(defun c:malha ()
  (c:mlh)
)

(defun c:malhaCoordenadas ()
  (c:mlh)
)

;|EDG(2026)[https://www.linkedin.com/in/ericdrumond]{https://github.com/ed9bh}|;