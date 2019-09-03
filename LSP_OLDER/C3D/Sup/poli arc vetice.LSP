(vl-load-com)
(defun c:aaa()
  (setq
    ent
     (entsel
       "\nSelecione a polyline: ")
    vao
     (if ent
       (vlax-ename->vla-object
	 (car ent)
	 )
       (quit)
       )
    coords
     (progn
       (setq
	 n -0.1
	 coords nil
	 )
       (repeat(fix(/(vlax-get vao 'Length)0.1))
	 (setq
	   point
	    (vlax-curve-getpointatdist vao (setq n(+ n 0.1)))
	   coords
	    (vl-list*
	      (list(car point)(cadr point))
	      coords
	      )
	   )
	 )
       (reverse coords)
       )
    )
  (setq
    npoly
     (vla-addlightweightpolyline
       (vla-get-modelspace(vla-get-activedocument(vlax-get-acad-object)))
       (vlax-safearray-fill
	 (vlax-make-safearray vlax-vbdouble (cons 0 (1-(length (apply'append(reverse coords))))))
	 (apply'append(reverse coords))
	 )
       )
    )
  (vlax-put npoly 'Elevation (vlax-get vao 'Elevation))
  (entdel(vlax-vla-object->ename vao))
  (princ)
  )