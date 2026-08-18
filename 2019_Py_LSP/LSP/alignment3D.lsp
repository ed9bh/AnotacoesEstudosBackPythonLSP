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
  
  (defun add->to_file(filename inplace content / file_open)
    (if (= inplace t)
        (setq file_open(open (strcat (getvar'dwgprefix) filename) "a"))
        (setq file_open(open filename "a"))
        )
    (write-line content file_open)
    (close file_open)
  )
  
  ;;; --------------------------------------> Main
  
  (defun main ()
    
    (setq
      ename_profile(entsel "\nSelecione o perfil : ")
      vlao_profile(vlax-ename->vla-object (car ename_profile))
      distancia(getdist "\tDistancia entre pontos : ")
      data_points (point_getter vlao_profile distancia)
      data_points (reverse data_points)
      table_points data_points
      data_points (apply'append(list data_points))
      data_points (apply'append data_points)
      fname (strcat "Pontos_" (rtos(getvar'cdate)2 6) ".txt")
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
    
    (foreach point table_points
      (add->to_file fname t (strcat (rtos (car point) 2)"\t" (rtos (cadr point) 2)"\t" (rtos (caddr point) 2) ) )
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