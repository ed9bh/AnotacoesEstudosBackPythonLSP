(defun c:mlh (/
                *error* main EnameMoldura VlaoMoldura DistanciaEntreLinhas
                XMin XMax YMin YMax X Y
                RefLine InterPoints PontoOrigem PontoDestino
                vlaoLine vlaoTxtO vlaoTxtD A B
                )
  (defun *error* (msg)
    (princ msg)
    (setvar 'cmdecho 1)
    (vla-endundomark doc)
    (princ)
  )
  
  ;---
  
  (defun main ()
    (setq
      EnameMoldura(entsel "\nSelecione a moldura para aplicar a malha de coordenadas : ")
      VlaoMoldura(if EnameMoldura (vlax-ename->vla-object (car EnameMoldura)) (progn (princ "\tNenhuma entidade selecionada, encerrando aplicacao...") (exit)))
    )
    
    (setq
      DistanciaEntreLinhas (getreal "\nDigite a distancia da malha (100): ")
      DistanciaEntreLinhas (if DistanciaEntreLinhas DistanciaEntreLinhas 100)
      TextScale (* DistanciaEntreLinhas 0.020)
    )
    
    (if (or (not DistanciaEntreLinhas) (<= DistanciaEntreLinhas 0.0))
      (progn
        (princ "\nDistancia entre linhas invalida.")
        (exit)
      )
    )
    
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
      XTexts nil
      YTexts nil
    )
    
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
            (setq A (vlax-safearray->list A) B (vlax-safearray->list B))
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
              XTexts (vl-list* vlaoTxtO XTexts)
              XTexts (vl-list* vlaoTxtD XTexts)
            )
          )
          (princ "\tSem Destino...")
        )
        (princ "\tSem Origem...")
      )
      (setq X (+ X DistanciaEntreLinhas))
    )
    
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
            (setq A (vlax-safearray->list A) B (vlax-safearray->list B))
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
              YTexts (vl-list* vlaoTxtO YTexts)
              YTexts (vl-list* vlaoTxtD YTexts)
            )
          )
          (princ "\tSem Destino...")
        )
        (princ "\tSem Origem...")
      )
      (setq Y (+ Y DistanciaEntreLinhas))
    )
    
    (foreach item (append XTexts YTexts)
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
  (main)
  (setvar 'cmdecho 1)
  (vla-endundomark doc)
  (princ)
  
)

(defun c:malha ()
  (c:mlh)
)

(defun c:malhaCoordenadas ()
  (c:mlh)
)

;|EDG(2026)[https://www.linkedin.com/in/ericdrumond]{https://github.com/ed9bh}|;