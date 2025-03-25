(defun c:inclinate (/
                       *error* main acad doc model NewPointListRotated msg
                       interpolacao eobj vlao PointRef PointDest
                       PointList PointListLength PointListSanitized NewPointListRotated
                       n Point PA PB
                       )


;;; ------------------------------------------------------
;;; ----Por Eric Drumond : egomes@telluscompany.com.br----
;;; ------------------------------------------------------

  
  (setq
    acad(vlax-get-acad-object)
    doc(vla-get-activedocument acad)
    model(vla-get-modelspace doc)
  )
  
  (defun *error* (msg)
    (princ msg)
    (vla-endundomark doc)
  )
  
  (defun interpolcao (distancia01 distancia02 distancia03 elevacao01 elevacao03
                      / f1 f2 f3 f4 f5 f6)
    (setq
      f1 (* elevacao03 (- distancia03 distancia01))
      f2 (- distancia03 distancia02)
      f3 (- elevacao03 elevacao01)
      f4 (- distancia03 distancia01)
      f5 (- f1 (* f2 f3))
      f6 (/ f5 f4)
    )
    f6
  )
  
  (defun main ()
    
    (setq
      eobj(entsel "\nSelecione a entidade a inclinar em 3D : ")
      eobjType (cdr(assoc 0 (entget (car eobj))))
      vlao(vlax-ename->vla-object (car eobj))
      PointRef(getpoint "\tClique no ponto inicial a inclinar : ")
      PointDest(getpoint PointRef "\tClique no ponto final a inclinar : ")
      PointList(vlax-get vlao 'Coordinates)
      PointListLength (length PointList)
      PointListSanitized nil
      n -1
    )
    (repeat (/ PointListLength (if (= eobjType "LWPOLYLINE") 2 3))
      (setq
        Point(list
               (nth (setq n(1+ n)) PointList)
               (nth (setq n(1+ n)) PointList)
               (if (= eobjType "LWPOLYLINE") 0 (nth (setq n(1+ n)) PointList))
             )
        PointListSanitized(vl-list* Point PointListSanitized)
      )
    )
    
    (setq PointListSanitized (reverse PointListSanitized))
    
    (foreach PB PointListSanitized
      (progn
        (if NewPointListRotated
          (progn
            (setq
              dist(vlax-curve-getdistatpoint vlao PB)
              NewElevationInterpolated(interpolcao
                                        0
                                        dist
                                        (vla-get-length vlao)
                                        (caddr PointRef)
                                        (caddr PointDest)
                                      )
              Point(list
                     (car PB)
                     (cadr PB)
                     NewElevationInterpolated
                   )
              NewPointListRotated (vl-list* Point NewPointListRotated)
            )
          )
          (progn
            (setq
              Point(list
                     (car PB)
                     (cadr PB)
                     (caddr PointRef)
                   )
              NewPointListRotated nil
              NewPointListRotated (vl-list* Point NewPointListRotated)
              PA PB
            )
          )
        )
      )
    )
    
    (setq pl
           (vla-add3DPoly
             model
             (vlax-make-variant
               (vlax-safearray-fill
                 (vlax-make-safearray vlax-vbdouble (cons 0 (1-(length (apply'append(reverse NewPointListRotated))))))
                 (apply'append(reverse NewPointListRotated))
               )
             )
           )
    )
    
  )
  
  (vla-startundomark doc)
  (main)
  (vla-endundomark doc)
  (princ)
  
)