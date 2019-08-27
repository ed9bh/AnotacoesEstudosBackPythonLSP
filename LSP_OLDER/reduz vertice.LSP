(defun c:rv()
  (vl-load-com)
  (setq plEnt(entsel"\nSelecione a polyline: ")
	plVEnt(vlax-ename->vla-object(car plEnt))
	plCoo(progn
		(setq plCoo nil
		      n -1
		      )
		(repeat(/(length(vlax-get plVEnt 'Coordinates))2)
		  (setq plCoo
			 (vl-list*
			   (list
			     (nth(setq n(1+ n))(vlax-get plVEnt 'Coordinates))
			     (nth(setq n(1+ n))(vlax-get plVEnt 'Coordinates))
			     0.000
			     )
			   plCoo)
			)
		  )
		(reverse plCoo)
		)
	n -1
	c 0
	plCooRed(list(nth 0 plCoo))
	ang(angle(nth(setq n(1+ n))plCoo)(nth(setq n(1+ n))plCoo))
	)
  (repeat(-(length plCoo)2)
    (setq XXX(if(/=(setq XangX(angle(nth n plCoo)(nth(setq n(1+ n))plCoo)))ang)
		 (setq plCooRed(vl-list*(nth n plCoo)plCooRed))
		 nil
		 )
	  ang XangX
	  )
    )
  (setq r(rtos(-(length plCoo)(-(length plCoo)(length plCooEd)))2 0)
	plCooRed(apply 'append plCooRed)
	)
  (vla-addpolyline
    (vla-get-modelspace(vla-get-activedocument(vlax-get-acad-object)))
    (vlax-make-variant(vlax-safearray-fill(vlax-make-safearray vlax-vbdouble(cons 0(1-(length plCooRed))))plCooRed))
    )
  (vlax-put(vlax-ename->vla-object(entlast))'Color 2)
  (princ(strcat"\nTotal de Vertices = "(rtos(length PlCoo)2 0)"\nTotal reduzido = "r))
  (princ)
  )
