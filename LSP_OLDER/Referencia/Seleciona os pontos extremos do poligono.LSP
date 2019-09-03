(defun horario(p1 p2 p3)
  (<(-(*(-(car  p2)(car  p1))(-(cadr p3)(cadr p1)))
      (*(-(cadr p2)(cadr p1))(-(car p3)(car p1)))
      )
    1e-8
    )
  )
(defun bordas(lst);Algoritimo Graham scan
  (setq	lst(if lst(mapcar'(lambda(x)(vlax-get(vlax-ename->vla-object(cadr x))'Coordinates))(ssnamex lst))(quit))
	p0(car lst)
	)
  (if(<=(length lst)3)(quit))
  (foreach p1(cdr lst)(if(or(<(cadr p1)(cadr p0))(and(equal(cadr p1)(cadr p0)1e-8)(<(car p1)(car p0))))
			(setq p0 p1)))
  (setq lst(vl-sort lst(function(lambda( a b / c d )(if
						      (equal(setq c(angle p0 a))(setq d(angle p0 b))1e-8)
						      (< (distance p0 a) (distance p0 b))
						      (< c d))))))
  (setq ch(list(caddr lst)(cadr lst)(car lst)))
  (foreach pt(cdddr lst)(setq ch (cons pt ch))(while(and(caddr ch)(horario(caddr ch)(cadr ch)pt))
						(setq ch (cons pt (cddr ch)))))
  ch
  )

(setq lis(apply'append(bordas (ssget"x"'((0 . "point"))) )))
(vla-addpolyline(vla-get-modelspace(vla-get-activedocument(vlax-get-acad-object)))
   (vlax-make-variant(vlax-safearray-fill(vlax-make-safearray vlax-vbdouble(cons 0(1-(length lis))))lis))
    )
(vlax-put(vlax-ename->vla-object(entlast))'Closed 1)