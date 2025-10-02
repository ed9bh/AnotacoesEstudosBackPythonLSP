(defun c:3DPolyProfile ()
  
  (setq
    Acad(vlax-get-acad-object)
    Doc(vla-get-activedocument Acad)
    MSpace(vla-get-modelspace Doc)
    BlockDataBase(vla-get-blocks Doc)
  )
  
  (defun *error* (msg)
    (princ (strcat "\tError : " msg))
    (vla-endundomark Doc)
  )
  
  (defun main ()
    (setq
      E3DPoly(entsel "\nSelecione a 3D Poly para transformar em Perfil : ")
      Vlao3DPoly(vlax-ename->vla-object(car E3DPoly))
      Counter (/(length(vlax-safearray->list(vlax-variant-value(vlax-get-property Vlao3DPoly 'Coordinates))))3)
      n -1
      Vlao3DPolyPointList nil
      ProfilePoints nil
      ProfilePoint_A nil
      ProfilePoint_X 0
      ProfilePoint_Y 0
    )
    (repeat (1- Counter)
      (setq
        Vlao3DPolyPoint(vlax-safearray->list(vlax-variant-value(vlax-get-property Vlao3DPoly 'Coordinate (setq n (1+ n)))))
        Vlao3DPolyPointList(vl-list* Vlao3DPolyPoint Vlao3DPolyPointList)
      )
    )
    (foreach ProfilePoint_B (reverse Vlao3DPolyPointList)
      (progn
        (if
          ProfilePoint_A
          (setq
            ProfilePoint_X(+ ProfilePoint_X (abs(-(car ProfilePoint_B)(car ProfilePoint_A))) )
            ProfilePoint_Y(caddr ProfilePoint_B)
            ProfilePoint_A ProfilePoint_B
          )
          (setq
            ProfilePoint_A ProfilePoint_B
            ProfilePoint_X 0
            ProfilePoint_Y(caddr ProfilePoint_B)
           )
        )
        (setq
          ProfilePoints(vl-list*
                         (list ProfilePoint_X ProfilePoint_Y)
                         ProfilePoints
                       )
        )
      )
    )
    (setq
      BlockSpace(vla-add BlockDataBase (vlax-3d-point 0 0 0) (setq NameBlock(strcat "ProfileBlock-"(rtos(getvar'cdate)2 8))) )
      Coordinates(apply'append (reverse ProfilePoints))
      LwPoly(vla-addlightweightpolyline
              BlockSpace
              (vlax-make-variant
                (vlax-safearray-fill
                  (vlax-make-safearray
                    vlax-vbdouble
                    (cons 0 (1- (length Coordinates))))
                  Coordinates
                )
              )
            )
      Boundpoints(vlax-invoke-method LwPoly 'GetBoundingBox 'point_min 'point_max)
      point_min(vlax-safearray->list point_min)
      point_max(vlax-safearray->list point_max)
      Regua_Menor(vla-addline BlockSpace (vlax-3d-point (car point_min) (cadr point_min) 0) (vlax-3d-point (car point_max) (cadr point_min) 0))
      Regua_Maior(vla-addline BlockSpace (vlax-3d-point (car point_min) (cadr point_max) 0) (vlax-3d-point (car point_max) (cadr point_max) 0))
      Lateral_Menor(vla-addline BlockSpace (vlax-3d-point (car point_min) (cadr point_min) 0) (vlax-3d-point (car point_min) (cadr point_max) 0))
      Lateral_Maior(vla-addline BlockSpace (vlax-3d-point (car point_max) (cadr point_min) 0) (vlax-3d-point (car point_max) (cadr point_max) 0))
      Text01(vla-addtext BlockSpace (strcat "X:" (rtos (car point_min) 2) " / Z:" (rtos (cadr point_min) 2)) (vlax-3d-point (car point_min) (cadr point_min) 0) 0.5)
      Text02(vla-addtext BlockSpace (strcat "X:" (rtos (car point_max) 2) " / Z:" (rtos (cadr point_max) 2)) (vlax-3d-point (car point_max) (cadr point_max) 0) 0.5)
      InsertPoint(getpoint "\nClique no ponto pra Inserir o Perfil : ")
    )
    (foreach item (list Regua_Menor Regua_Maior Lateral_Menor Lateral_Maior Text01 Text02)(vla-put-color item 250))
    (foreach item (list Text01 Text02)(vla-rotate item (vlax-3d-point(vlax-get item 'InsertionPoint)) (/ pi 2)))
    (vla-insertblock MSpace (vlax-3d-point (car InsertPoint) (-(cadr InsertPoint)(cadr point_min)) 0) NameBlock 1 1 1 0)
  )
  
  (vla-startundomark Doc)
  (main)
  (vla-endundomark Doc)
  (princ)
  

)
