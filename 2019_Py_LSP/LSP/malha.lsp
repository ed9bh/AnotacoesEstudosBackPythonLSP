(defun c:malha (/ *error* main)
  (defun *error* (msg)
    (princ msg)
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
            (setq vlaoTxtO(vla-addtext Mspace (strcat "E:"(rtos X 2 0)) (vlax-3d-point A) (* DistanciaEntreLinhas 0.025)))
            (vla-put-alignment vlaoTxtO acAlignmentLeft)
            (vl-catch-all-apply 'vla-put-textalignmentpoint (list vlaoTxtO (vlax-3d-point (car A) (cadr A))))
            (vla-put-rotation vlaoTxtO 1.5708)
            ;
            (setq vlaoTxtD(vla-addtext Mspace (strcat "E:"(rtos X 2 0)) (vlax-3d-point B) (* DistanciaEntreLinhas 0.025)))
            (vla-put-alignment vlaoTxtD acAlignmentRight)
            (vl-catch-all-apply 'vla-put-textalignmentpoint (list vlaoTxtD (vlax-3d-point (car B) (cadr B))))
            (vla-put-rotation vlaoTxtD 1.5708)
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
            (setq vlaoTxtO(vla-addtext Mspace (strcat "E:"(rtos X 2 0)) (vlax-3d-point A) (* DistanciaEntreLinhas 0.025)))
            (vla-put-alignment vlaoTxtO acAlignmentLeft)
            (vl-catch-all-apply 'vla-put-textalignmentpoint (list vlaoTxtO (vlax-3d-point (car A) (cadr A))))
            ;
            (setq vlaoTxtD(vla-addtext Mspace (strcat "E:"(rtos X 2 0)) (vlax-3d-point B) (* DistanciaEntreLinhas 0.025)))
            (vla-put-alignment vlaoTxtD acAlignmentRight)
            (vl-catch-all-apply 'vla-put-textalignmentpoint (list vlaoTxtD (vlax-3d-point (car B) (cadr B))))
          )
          (princ "\tSem Destino...")
        )
        (princ "\tSem Origem...")
      )
      (setq Y (+ Y DistanciaEntreLinhas))
    )
  )
  
  ;---
  
  (setq
    acad (vlax-get-acad-object)
    doc (vla-get-activedocument acad)
    MSpace (vla-get-modelspace doc)
  )
  
  (vla-startundomark doc)
  (setvar 'cmdecho 0)
  (main)
  (vla-endundomark doc)
  (setvar 'cmdecho 1)
  (princ)
  
)