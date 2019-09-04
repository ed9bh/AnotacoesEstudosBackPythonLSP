;;;TRANSFORMA CIRCULOS E ARCOS EM POLYLINHA 3D:::BY ERIC DRUMOND:::LOOK FOR ME ON LINKEDIN... ;) >>>http://br.linkedin.com/in/ericdrumond<<<
(defun c:capoly();(/ sslist model o l n p p2d a)
  (vl-load-com)
  (setq
    ssList
     (ssget"x"'((0 . "arc,circle")(410 . "model")))
    ssList
     (if ssList
       (mapcar'(lambda(x)(vlax-ename->vla-object(cadr x)))(ssnamex ssList))
       (quit)
       )
    model
     (vla-get-modelspace(vla-get-activedocument(vlax-get-acad-object)))
    )
  (initget 1 "2D 3D")
  (setq a(getkword"\nPolylinha 2D ou 3D?: "))
  (repeat(length ssList)
    (setq
      o
       (car ssList)
      l
       (if(=(vlax-get o 'ObjectName)"AcDbCircle")
	 (vlax-get o 'Circumference)
	 (vlax-get o 'ArcLength)
	 )
      n
       -1
      p
       nil
      p2d
       nil
      )
    (repeat(fix l)
      (setq
	p(vl-list*
	   (vlax-curve-getpointatdist o (setq n(1+ n)))
	   p
	   )
	p2d
	 (vl-list*
	   (list(car(vlax-curve-getpointatdist o n))(cadr(vlax-curve-getpointatdist o n)))
	   p2d
	   )
	)
      )
    (if(>= l 2)
      (if(= a "3D")
	(vla-add3dpoly
	  model
	  (vlax-make-variant
	    (vlax-safearray-fill
	      (vlax-make-safearray vlax-vbdouble(cons 0(1-(*(length p)3))))
	      (apply'append(reverse p))
	      )
	    )
	  )
	(vla-addlightweightpolyline
	  model
	  (vlax-make-variant
	    (vlax-safearray-fill
	      (vlax-make-safearray vlax-vbdouble(cons 0(1-(*(length p2d)2))))
	      (apply'append(reverse p2d))
	      )
	    )
	  )
	)
      )
    (if(>= l 2)
      (progn
	(if(=(vlax-get o 'ObjectName)"AcDbCircle")
	  (vlax-put(vlax-ename->vla-object(entlast))'Closed 1)
	  )
	(entdel(vlax-vla-object->ename o))
	)
      )
    (setq
      ssList
       (cdr ssList)
      )
   )
  (princ)
  )