(defun c:drawprofile (/ *error* acad doc model)
  
  ;;; --------------------------------------> Funcoes
  
  (defun *error* (msg)
    
    (princ msg)
    (vla-endundomark doc)
    (princ)
  
  )
  
  (defun coordlist (epoly)
    
    (setq
      vpoly(vlax-ename->vla-object (car epoly))
      coords(vlax-get vpoly 'Coordinates)
      total(length coords)
      coordinateList nil
      n -1
    )
    
     (if (= (vlax-get vpoly 'ObjectName) "AcDb3dPolyline")
       (setq
         vetores 3
       )
       (setq
         vetores 2
       )
     )
    
    (while (> (- total 1) n)
      
      (if(= vetores 3)
        (setq
          x(nth (setq n(1+ n)) coords)
          y(nth (setq n(1+ n)) coords)
          z(nth (setq n(1+ n)) coords)
        )
        (setq
          x(nth (setq n(1+ n)) coords)
          y(nth (setq n(1+ n)) coords)
          z 0
          )
        )
      
      (setq coordinateList (vl-list* (list x y z) coordinateList))
      
     )
    
    (reverse coordinateList)
  )
  
  (defun profilerCoords (coordinateList)
    
    (setq
      cursor 0
      distAcum 0
      lastPoint nil
      profileCoords nil
    )
    
    
    (while (setq point(nth cursor coordinateList))
      
      (princ (strcat "\nRound : " (rtos cursor 2 0)"\n"))
      
      (setq
        x (car point)
        y (cadr point)
        z (caddr point)
        point (list x y)
      )
      
      (if lastPoint
        (setq
          d (distance lastPoint point)
          distAcum (+ d distAcum)
        )
      )
      
      (setq
        profileCoords (vl-list* (list distAcum z) profileCoords)
        lastPoint point
        cursor (1+ cursor)
      )
      
    (reverse profileCoords)
      
    )
  )

  ;;; --------------------------------------> Main
  
  (defun main ()
    
    (setq
      ePolyline (entsel "\tSelecione a polylinha 3D : ")
    )
    
    (princ "\nInicio CoordList\n")
    
    (setq
      EixoCoords (coordlist ePolyline)
    )
    
    (princ "\nInicio ProfileCoord\n")
    
    (setq
      ProfileCoord (profilerCoords
                     EixoCoords
                   )
      ProfileCoord (apply 'append profileCoords)
    )
    
    (vla-addlightweightpolyline model
                                (vlax-make-variant
                                  (vlax-safearray-fill
                                    (vlax-make-safearray vlax-vbdouble
                                                         (cons 0
                                                               (1-(length ProfileCoord))
                                                         )
                                    )ProfileCoord)
                                )
    )
    
    (princ ProfileCoord)
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