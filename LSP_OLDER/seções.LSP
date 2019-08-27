(defun c:secsing()
  (vl-load-com)
  (setq
    model
     (vla-get-modelspace(vla-get-activedocument(vlax-get-acad-object)))
    pA
     (getpoint"\nClique no ponto inicial da Seção: ")
    pB
     (getpoint pA"\tClique no ponto final da seção: ")
    MDT
     (if MDT
       MDT
       (progn
	 (princ"\nSelecione as curvas de nivel: ")
	 (setq SS(ssget'((0 . "lwpolyline"))))
	 (if(cdr(reverse(ssnamex SS)))
	   (progn
	     (setq MDT(mapcar'(lambda(x)(strcat(vlax-get(vlax-ename->vla-object(cadr x))'Layer)","))(cdr(reverse(ssnamex SS))))
		   )
	     (vl-string-right-trim","(apply'strcat MDT))
	     )
	   (setq MDT(vlax-get(vlax-ename->vla-object(cadr(car(ssnamex SS))))'Layer))
	   )
	 )
       )
    elvList
     (ssget"f"(list pA pB)(list'(0 . "lwpolyline")(cons 8 MDT)))
    elvList
     (if elvList
       (mapcar'(lambda(x)(vlax-get(vlax-ename->vla-object(cadr x))'Elevation))
	      (ssnamex elvList))
       (quit)
       )
    PointList nil
    )
  (repeat(length elvList)
    (setq
      ss
       (ssget"f"(list pA pB)(list'(0 . "lwpolyline")(cons 38(car elvList))))
      l
       (vla-addline
	 model
	 (vlax-3d-point(list(car pA)(cadr pA)(car elvList)))
	 (vlax-3d-point(list(car pB)(cadr pB)(car elvList)))
	 )
      intPointList
       (mapcar'(lambda(x)
		 (vlax-invoke l 'IntersectWith (vlax-ename->vla-object(cadr x)) acExtendNone))
	      (ssnamex ss)
	      )
      intPointList
       (apply'append intPointList)
      elvList
       (cdr elvList)
      )
    (repeat(/(length intPointList)3)
      (setq
	x(car intPointList)intPointList(cdr intPointList)
	y(car intPointList)intPointList(cdr intPointList)
	z(car intPointList)intPointList(cdr intPointList)
	PointList(vl-list*(list x y z)PointList)
	)
      )
    (entdel(vlax-vla-object->ename l))
    )
  (setq
    DistElevList
     (mapcar'(lambda(x)
	       (list
		 (distance pA (list(car x)(cadr x)))
		 (caddr x)
		 )
	       )
	    PointList
	    )
    DistElevList
     (vl-sort DistElevList(function(lambda(a1 a2)(<(car a1)(car a2)))))
    ElevMin
     (cadr(car(vl-sort DistElevList (function(lambda(a1 a2)(<(cadr a1)(cadr a2)))))))
    )
  (setq
    BasePoint
     (getpoint"\nClique no ponto de insersão da seção: ")
    PointList
     (apply'append(setq PointListT(mapcar'(lambda(x)(list(+(car BasePoint)(car x))(+(-(cadr x)ElevMin)(cadr BasePoint))0.000))DistElevList)))
    )
  (vla-addpolyline model(vlax-make-variant(vlax-safearray-fill(vlax-make-safearray vlax-vbdouble(cons 0(1-(length PointList))))PointList)))
  (mapcar'(lambda(a b)(vla-addtext model(rtos(cadr b)2 3)(vlax-3d-point a)0.1))PointListT DistElevList)
  (vla-addline model(vlax-3d-point pA)(vlax-3d-point pB))
  (princ)
  )
