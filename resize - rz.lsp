(vl-load-com)
(defun c:rz()(c:resize))
(defun c:resize(/ entE entV crds crdsX crdsY n pnts len len+)
  (setvar'cmdecho 0)
  (setq
    entE(entsel"\nSelecione a entidade a receber nova escala: ")
    entV(if entE(vlax-ename->vla-object(car entE))(quit))
    crds(progn
	  (setq
	    crdsX nil
	    crdsY nil
	    n(-(setq len+(/(setq len(vlax-get entV
					      (cond
						((=(vlax-get entV 'ObjectName)"AcDbCircle")
						 "Circumference"
						 )
						((/=(vlax-get entV 'ObjectName)"AcDbCircle")
						 "Length"
						 )
						)
					      )
				 )
			   100)
		     )
	       )
;;;	    pnts(vlax-get entV 'Coordinates)
	    )
;;;	  (repeat(/(length pnts)2)
;;;	    (setq
;;;	      crdsX(vl-list*
;;;		     (nth(setq n(1+ n))pnts)
;;;		     crdsX
;;;		     )
;;;	      crdsY(vl-list*
;;;		     (nth(setq n(1+ n))pnts)
;;;		     crdsY
;;;		     )
;;;	      )
;;;	    )
	  (repeat 100
	    (setq
	      crdsX(vl-list*
		     (car(vlax-curve-getpointatdist entV (setq n(+ n len+))))
		     crdsX
		     )
	      crdsY(vl-list*
		     (cadr(vlax-curve-getpointatdist entV n))
		     crdsY
		     )
	      )
	    )
	  )
    )
  (princ
    (strcat
      "\tClique ou digite para definir nova escala. < "
      (rtos(distance(list(apply'min crdsX)(apply'min crdsY))(list(apply'max crdsX)(apply'max crdsY)))2 6)
      " >: "
      )
    )
  (command"scale"
	  entE
	  ""
	  (list
	    (/(+(apply'min crdsX)(apply'max crdsX))2)
	    (/(+(apply'min crdsY)(apply'max crdsY))2)
	    )
	  "r"
	  (list
	    (apply'min crdsX)
	    (apply'min crdsY)
	    )
	  (list
	    (apply'max crdsX)
	    (apply'max crdsY)
	    )
	  )
  (while(= 1(logand 1(getvar'cmdactive)))(command"\\"))
  (setvar'cmdecho 1)(princ)
  )