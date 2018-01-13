(vl-load-com)
(defun c:segregar()
  (initget 1 "Layer Tipo")
  (setq
    ???(getkword"\nSegregar por [Layer / Tipo]: ")
    )
  (cond
    ((= ??? "Layer")
     (progn
       (setq
	 layer(list(cdr(assoc 2(tblnext"layer"t))))
	 c 1
	 )
       (while(setq l(tblnext"layer"))
	 (setq layer(vl-list*(cdr(assoc 2 l))layer))
	 )
       (repeat(length layer)
	 (setq ss(ssget"x"(list(cons 8(car layer)))))
	 (if ss
	   (mapcar'(lambda(x)
		     (vlax-put
		       (vlax-ename->vla-object(cadr x))
		       'Color
		       c
		       )
		     )
		  (ssnamex ss)
		  )
	   )
	 (setq c(1+ c)layer(cdr layer))
	 )
       )
     )
    ((= ??? "Tipo")
     (progn
       (setq
	 ss(ssget"x"'((0 . "LINE,POLYLINE,LWPOLYLINE,POINT,CIRCLE,ELLIPSE,ARC,SPLINE,TEXT,MTEXT,INSERT,HATCH")))
	 c 0
	 )
       (mapcar'(lambda(x)
		 (vlax-put
		   (vlax-ename->vla-object(cadr x))
		   'Color
		   (cond
		     ((=(cdr(assoc 0(entget(cadr x))))"LINE")1)
		     ((=(cdr(assoc 0(entget(cadr x))))"POLYLINE")2)
		     ((=(cdr(assoc 0(entget(cadr x))))"LWPOLYLINE")3)
		     ((=(cdr(assoc 0(entget(cadr x))))"POINT")4)
		     ((=(cdr(assoc 0(entget(cadr x))))"CIRCLE")5)
		     ((=(cdr(assoc 0(entget(cadr x))))"ELLIPSE")6)
		     ((=(cdr(assoc 0(entget(cadr x))))"ARC")7)
		     ((=(cdr(assoc 0(entget(cadr x))))"SPLINE")8)
		     ((=(cdr(assoc 0(entget(cadr x))))"TEXT")9)
		     ((=(cdr(assoc 0(entget(cadr x))))"MTEXT")10)
		     ((=(cdr(assoc 0(entget(cadr x))))"INSERT")11)
		     ((=(cdr(assoc 0(entget(cadr x))))"HATCH")12)
		     )
		   )
		 )
	      (ssnamex ss)
	      )
       )
     )
    )
  (princ)
  )