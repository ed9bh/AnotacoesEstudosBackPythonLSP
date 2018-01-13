;;;2dto3d = Transforma polinha 2d em 3d
;;;3dto2d = Transforma polinha 3d em 2d

(defun c:2dto3d()
  (vl-load-com)
  ;Elevation
  (initget 128"Tudo")
  (setq
    lwp
     (entsel"\nSelecione a polilinha[Tudo]: ")
    model
     (vla-get-modelspace(vla-get-activedocument(vlax-get-acad-object)))
    )
  (if
    (= lwp "Tudo")
    (mapcar'(lambda(x)
	      (progn
		(setq lwp(vlax-ename->vla-object(cadr x))
		      coords(vlax-get lwp 'Coordinates)
		      elev(vlax-get lwp 'Elevation)
		      clist nil
		      n -1)
		(repeat(/(length coords)2)
		  (setq
		    clist
		     (vl-list*
		       (list
			 (nth(setq n(1+ n))coords)
			 (nth(setq n(1+ n))coords)
			 elev
			 )
		       clist
		       )
		    )
		  )
		(setq coords(apply'append(reverse clist)))
		(vla-add3dpoly model
		  (vlax-make-variant(vlax-safearray-fill(vlax-make-safearray vlax-vbdouble (cons 0 (1-(length coords))))coords))))
	      (entdel(vlax-vla-object->ename lwp))
	      )
	   (ssnamex(ssget"x"'((0 . "lwpolyline")))))
    (progn
      (setq lwp(vlax-ename->vla-object(car lwp))
	    coords(vlax-get lwp 'Coordinates)
	    elev(vlax-get lwp 'Elevation)
	    clist nil
	    n -1)
      (repeat(/(length coords)2)
	(setq
	  clist
	   (vl-list*
	     (list
	       (nth(setq n(1+ n))coords)
	       (nth(setq n(1+ n))coords)
	       elev
	       )
	     clist
	     )
	  )
	)
      (setq coords(apply'append(reverse clist)))
      (vla-add3dpoly model
	(vlax-make-variant(vlax-safearray-fill(vlax-make-safearray vlax-vbdouble (cons 0 (1-(length coords))))coords)))
      (entdel(vlax-vla-object->ename lwp))
      )
    )
  (princ)
  )

(defun c:3dto2d()
  (vl-load-com)
  (initget 128"Tudo")
  (setq
    lwp
     (entsel"\nSelecione a polilinha 3D[Tudo]: ")
    model
     (vla-get-modelspace(vla-get-activedocument(vlax-get-acad-object)))
    )
  (if
    (= lwp "Tudo")
    (mapcar'(lambda(x)
	      (progn
		(setq lwp(vlax-ename->vla-object(cadr x))
		      coords(vlax-get lwp 'Coordinates)
		      elev(nth 2 coords)
		      clist nil
		      n -1)
		(repeat(/(length coords)3)
		  (setq
		    clist
		     (vl-list*
		       (list
			 (nth(setq n(1+ n))coords)
			 (nth(setq n(1+ n))coords)
			 0
			 )
		       clist
		       )
		    n(1+ n)
		    )
		  )
		(setq coords(apply'append(reverse clist)))
		(setq newpoly
		       (vla-addpolyline model
			 (vlax-make-variant(vlax-safearray-fill(vlax-make-safearray vlax-vbdouble (cons 0 (1-(length coords))))coords)))
		      )
		(vlax-put newpoly 'Elevation elev)
		(vlax-put newpoly 'Layer(vlax-get lwp 'Layer))
		(vlax-put newpoly 'Color(vlax-get lwp 'Color))
		(command"convert""p""s"(vlax-vla-object->ename newpoly)"")
		(entdel(vlax-vla-object->ename lwp))
		)
	      )
	   (ssnamex(ssget"x"'((0 . "POLYLINE")))))
    (progn
      (setq lwp(vlax-ename->vla-object(car lwp))
	    coords(vlax-get lwp 'Coordinates)
	    elev(nth 2 coords)
	    clist nil
	    n -1)
      (repeat(/(length coords)3)
	(setq
	  clist
	   (vl-list*
	     (list
	       (nth(setq n(1+ n))coords)
	       (nth(setq n(1+ n))coords)
	       0
	       )
	     clist
	     )
	  n(1+ n)
	  )
	)
      (setq coords(apply'append(reverse clist)))
      (setq newpoly
      (vla-addpolyline model
	(vlax-make-variant(vlax-safearray-fill(vlax-make-safearray vlax-vbdouble (cons 0 (1-(length coords))))coords)))
       )
      (vlax-put newpoly 'Elevation elev)
      (vlax-put newpoly 'Layer(vlax-get lwp 'Layer))
      (vlax-put newpoly 'Color(vlax-get lwp 'Color))
      (command"convert""p""s"(vlax-vla-object->ename newpoly)"")
      (entdel(vlax-vla-object->ename lwp))
      )
    )
  (princ)
  )