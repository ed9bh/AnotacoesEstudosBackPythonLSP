(defun c:xcircle (/ *error* main doc)
    (vl-load-com)
    (defun main ()
        (vla-StartUndoMark (setq doc (vla-get-ActiveDocument (vlax-get-acad-object))))
        
        (setq
            centerPoint(getpoint "\nClique no ponto central : ")
            radious(getdist centerPoint "\tInsira o Raio : ")
            pointList nil
            c 0
            model (vla-get-ModelSpace doc)
        )

        (repeat 360
            (setq
                ang (angtof (rtos c 2 0) 0)
                x (+ (*(sin ang) radious) (nth 0 centerPoint))
                y (+ (*(cos ang) radious) (nth 1 centerPoint))
                pointList(vl-list* (list x y) pointList)
                c (1+ c)
            )
        )

        (setq pointList(reverse pointList))

        ;(princ pointList)

        (vla-addLightweightPolyline
	   model
	   (vlax-make-variant
	     (vlax-safearray-fill
	       (vlax-make-safearray vlax-vbdouble (cons 0 (1-(length (apply'append(reverse pointList))))))
	       (apply'append(reverse pointList))
	       )
	     )
	   )

        (vla-EndUndoMark doc)
        (princ)
    )
    (defun *error*(s)
        (princ s)
        (vla-EndUndoMark doc)
        (princ)
    )
    (main)
)
