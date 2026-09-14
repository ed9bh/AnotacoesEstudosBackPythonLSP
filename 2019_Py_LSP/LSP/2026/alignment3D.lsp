(defun c:alignment3D (/ *error* acad doc model)
  
  ;;; --------------------------------------> Funcoes
  
  (defun *error* (msg)
    
    (princ msg)
    (vla-endundomark doc)
    (princ)
  
  )
  
  (defun ElevationAt (profile cursor)
    (setq
      elevation(vlax-invoke profile 'ElevationAt cursor)
    )
    elevation
  )
  
  (defun point_getter (profile distancia / cursor alignment point_list r ne este norte bearing)
    
    (setq
      alignment (vlax-get profile 'Alignment)
      cursor (vlax-get alignment 'StartingStation)
      total_length (vlax-get alignment 'EndingStation)
      r (fix(/ (vlax-get alignment 'Length) distancia))
      point_list nil
    )
    
    (repeat r
      (princ (strcat "\r Ponto : " (rtos cursor 2 0)))
      (setq
        ne(vlax-invoke-method alignment 'PointLocationEx cursor 0 0 'este 'norte 'bearing)
        elev(vl-catch-all-apply 'ElevationAt (list profile cursor))
        point_list(vl-list*
                    (list
                      este
                      norte
                      (if (=(vl-catch-all-error-p elev)t) 0 elev)
                    )
                    point_list
                   )
        cursor(+ cursor distancia)
      )
    )
    
    (setq
      ne(vlax-invoke-method alignment 'PointLocationEx total_length 0 0 'este 'norte 'bearing)
      elev(vl-catch-all-apply 'ElevationAt (list profile total_length))
      point_list
       (vl-list*
         (list
           este
           norte
           (if (=(vl-catch-all-error-p elev)t) 0 elev)
         )
         point_list
       )
    )
    
    point_list
    
  )
  
  ;;; --------------------------------------> Main
  
  (defun main ()
    
    (setq
      ename_profile(entsel "\nSelecione o perfil : ")
      vlao_profile(vlax-ename->vla-object (car ename_profile))
      distancia(getdist "\tDistancia entre pontos : ")
      data_points (point_getter vlao_profile distancia)
      data_points (reverse data_points)
      data_points (apply'append(list data_points))
      data_points (apply'append data_points)
    )
    
    (setq 3dpoly
           (vla-add3DPoly
             model
             (vlax-make-variant
               (vlax-safearray-fill
                 (vlax-make-safearray vlax-vbdouble (cons 0 (1-(length data_points))))
                 data_points
               )
             )
           )
    )
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