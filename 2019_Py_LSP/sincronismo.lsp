(defun c:sincronismo(/
                     *error* Acad Doc MSpace Jerry main Menu MenuOptions
                     TempCircle TempXline j JerryPoint Jerry_X Jerry_Y
                     ApparentInterPoint DistProgProfile PointEixo
                     )
  
  (defun jerry(/ inMoviment mouse)
    (setq inMoviment (setq mouse(grread 't 13 0)))
    (List (= (car inMoviment) 5) (cadr mouse))
  )
  
  (setq
    Acad(vlax-get-acad-object)
    Doc(vla-get-activedocument Acad)
    MSpace(vla-get-modelspace Doc)
  )
  
  (defun *error* (msg)
    (if TempXline (vl-catch-all-apply 'vla-delete (list TempXline)))
    (if TempCircle (vl-catch-all-apply 'vla-delete (list TempCircle)))
    (princ (strcat "\tError : " msg))
    (vla-endundomark Doc)
  )
  
  (defun main ()
    (if BasePerfil
      (progn
        (initget -1 (setq MenuOptions "Manter Reiniciar  "))
        (setq
          Menu(getkword (strcat "\tSelecao["(vl-string-translate " " "/" MenuOptions)"]:<Enter> "))
        )
      )
      (setq Menu "Reiniciar")
    )
    
    (if (= Menu "Reiniciar")
      (setq
        BasePerfil(entsel "\nSelecione a Base Perfil : ")
        BaseEixo(entsel "\tSelecione o Eixo a sincronizar : ")
        VlaoPerfil(vlax-ename->vla-object(car BasePerfil))
        VlaoEixo(vlax-ename->vla-object(car BaseEixo))
        StartProfile(vlax-curve-getstartpoint VlaoPerfil)
        EndsProfile(vlax-curve-getendpoint VlaoPerfil)
        StartEixo(vlax-curve-getstartpoint VlaoEixo)
        EndsEixo(vlax-curve-getendpoint VlaoEixo)
        RadCircus(*
                   (if
                     (= (cdr(assoc 0(entget(car BaseEixo)))) "ARC" )
                     (vla-get-arclength VlaoEixo)
                     (vla-get-length VlaoEixo)
                   )
                   0.01
                 )
      )
    )
        
    (while
      (car(setq j(jerry)))
      (if TempXline (vl-catch-all-apply 'vla-delete (list TempXline)))
      (if TempCircle (vl-catch-all-apply 'vla-delete (list TempCircle)))
      (setq
        JerryPoint(cadr j)
        Jerry_X(car JerryPoint)
        Jerry_Y(cadr JerryPoint)
      )
      (if
        (and (< (car StartProfile) Jerry_X )  (> (car EndsProfile) Jerry_X) )
        (progn
          (setq
            TempXline(vla-addxline
                       MSpace
                       (vlax-3d-point
                         Jerry_x
                         (cadr StartProfile)
                         0.000
                       )
                       (vlax-3d-point
                         Jerry_x
                         (1+(cadr StartProfile))
                         0.000
                       )
                     )
            ApparentInterPoint(inters (list Jerry_X (1- (cadr StartProfile))) (list Jerry_X (1+ (cadr StartProfile))) StartProfile EndsProfile );(inters pt1 pt2 pt3 pt4 [onseg])
            DistProgProfile(distance StartProfile ApparentInterPoint)
            PointEixo(vlax-curve-getpointatdist VlaoEixo DistProgProfile)
            TempCircle(vla-addcircle
                        MSpace
                        (vlax-3d-point (car PointEixo) (cadr PointEixo) 0.000)
                        RadCircus
                      )
          )
        )
      )
    )
    (if TempXline (vl-catch-all-apply 'vla-delete (list TempXline)))
  )
  
  (vla-startundomark Doc)
  (main)
  (vla-endundomark Doc)
  (princ)
  
)