; Malha de Coordenadas - By: Eric Drumond / https://github.com/ed9bh
(defun c:malha (/ *error*)
  (defun *error* (msg)
    (princ msg)
    (vla-endundomark doc)
    (princ)
  )
  
  (defun ed:add_layer(name color ltype / vlayer)
    (setq
      vlayer (vla-add (vla-get-layers (vla-get-activedocument (vlax-get-acad-object ) ) ) name)
     )

    (if color
        (vla-put-color vlayer color)
        (vla-put-color vlayer 250)
        )

    (if ltype
        (vla-put-linetype vlayer ltype)
        (vla-put-linetype vlayer "continuous")
        )
    (vlax-release-object vlayer)
  )
  
  (defun ed:idpoint(point dist_malha)
    (setq
      x (car point)
      x (if (= (setq i(rem x dist_malha)) 0) x (- x i))
      y (cadr point)
      y (if (= (setq i(rem y dist_malha)) 0) y (- y i))
     )
    (list x y)
   )
  
  (defun ed:drawlines (xmin xmax ymin ymax dist lay)
    (setq
      echoY ymin
      echoX xmin
      pad (* dist 0.01)
      font_h (* dist 0.025)
     )
    (while (< echoY ymax)
      (setq line
             (vla-addline
               model
               (vlax-3d-point (list xmin echoY))
               (vlax-3d-point (list xmax echoY))
             )
            text
             (vla-addtext
               model
               (strcat "N:"(rtos echoY 2 0))
               (vlax-3d-point (list (+ xmin pad) (+ echoY pad)))
               font_h
             )
            echoY (+ echoY dist)
      )
      (vlax-put line 'Layer lay)
      (vlax-put text 'Layer lay)
    )
    (while (< echoX xmax)
      (setq
        line
         (vla-addline
           model
           (vlax-3d-point (list echoX ymin))
           (vlax-3d-point (list echoX ymax))
         )
        text
         (vla-addtext
           model
           (strcat "E:"(rtos echoX 2 0))
           (vlax-3d-point (list (+ echoX (* pad 2)) (+ ymin pad)))
           font_h
         )
        echoX(+ echoX dist)
      )
      (vlax-put line 'Layer lay)
      (vlax-put text 'Layer lay)
      (vla-put-rotation text (/ pi 2))
    )
  )
  
  (defun main ()
    
    (setq
      drawingScale (getdist "\tDigite o 'X' da escala do desenho (1/x): ")
      drawingScale (if drawingScale drawingScale 1000)
      windowPointA (getpoint "\nClique no primeiro ponto do canto da Malha : ")
      windowPointB (getcorner windowPointA "\tClique no segundo ponto do canto da Malha : ")
      sPoint (list
               (min(car windowPointA)(car windowPointB))
               (min(cadr windowPointA)(cadr windowPointB))
             )
      fPoint (list
               (max(car windowPointA)(car windowPointB))
               (max(cadr windowPointA)(cadr windowPointB))
             )
      dist_malha (* drawingScale 0.10)
      sPoint (ed:idpoint sPoint dist_malha)
      fPoint (ed:idpoint fPoint dist_malha)
      lay (strcat "Malha-1_" (rtos drawingScale 2 0))
    )
    
    (ed:add_layer
      lay
      7
      nil
    )
    (ed:drawlines
      (car sPoint)
      (car fPoint)
      (cadr sPoint)
      (cadr fPoint)
      dist_malha
      lay
    )
    ; (xmin xmax ymin ymax dist lay)
  )
  
  ;;; --------------------------------------> Rotina
  
  (setq
    acad (vlax-get-acad-object)
    doc (vla-get-activedocument acad)
    model (vla-get-modelspace doc)
  )
  
  (vla-startundomark doc)
  (setvar 'cmdecho 0)
  (main)
  (vla-endundomark doc)
  (setvar 'cmdecho 1)
  (princ)
  
)
; Malha de Coordenadas - By: Eric Drumond / https://github.com/ed9bh
