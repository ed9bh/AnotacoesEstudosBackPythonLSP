(defun c:regiao()
  (vl-load-com)
  (if(setq memo(vl-file-size(strcat(getvar"dwgprefix")(getvar"dwgname"))))(alloc(* memo 4)))
  (defun RgPntBlk(obj layer)
    ;;;
    (defun horario(p1 p2 p3)
      (<(-(*(-(car  p2)(car  p1))(-(cadr p3)(cadr p1)))
	  (*(-(cadr p2)(cadr p1))(-(car p3)(car p1)))
	  )
	1e-8
	)
      )
    (defun regiao(lst);Algoritimo Graham Scan
      (setq lst(if lst(mapcar'(lambda(x)(vlax-get(vlax-ename->vla-object(cadr x))'Coordinates))(ssnamex lst))(quit))
	    p0(car lst)
	    )
      (if(<=(length lst)3)(progn(alert"Quantidade de pontos deve ser superior a 3...")(quit)))
      (foreach p1(cdr lst)(if(or(<(cadr p1)(cadr p0))(and(equal(cadr p1)(cadr p0)1e-8)(<(car p1)(car p0))))
			    (setq p0 p1)))
      (setq lst(vl-sort lst(function(lambda( a b / c d )(if
							  (equal(setq c(angle p0 a))(setq d(angle p0 b))1e-8)
							  (< (distance p0 a) (distance p0 b))
							  (< c d))))))
      (setq ch(list(caddr lst)(cadr lst)(car lst)))
      (foreach pt(cdddr lst)(setq ch (cons pt ch))(while(and(caddr ch)(horario(caddr ch)(cadr ch)pt))
						    (setq ch (cons pt (cddr ch))))
	ch
	)
      )
    (setq
      CoordLst(if(= layer "")
		(apply'append(regiao(ssget"x"(list(cons 0 obj)))))
		(apply'append(regiao(ssget"x"(list(cons 0 obj)(cons 8 layer)))))
		)
      )
    ;;;
    )
  (initget 1 "Pontos Blocos Tudo")
  (setq
    op(getkword"\nObjetos a localizar? [Blocos / Pontos / Tudo]: ")
    op(cond((= op "Pontos")"Point")((= op "Blocos")"Insert")((= op "Tudo")"Point,Insert"))
    ly(entsel"\tSelecione o Objeto do layer: ")
    ly(vlax-get(vlax-ename->vla-object(car ly))'Layer)
    )
  (setq
    limite3D(RgPntBlk op ly)
    limite2D(progn
	      (setq
		cL nil
		n -1)
	      (repeat(/(length limite3D)3)
		(setq
		  cL(vl-list*
		      (list
			(nth(setq n(1+ n))limite3D)
			(nth(setq n(1+ n))limite3D)
			)
		      cl)
		  n(1+ n)
		  )
		)
	      (apply'append(reverse cL))
	      )
    space(if(=(getvar"ctab")"Model")
	   (vla-get-modelspace(vla-get-activedocument(vlax-get-acad-object)))
	   (vla-get-paperspace(vla-get-activedocument(vlax-get-acad-object)))
	   )
    )

  (initget 1 "3D 2D")
  (setq
    opl(getkword"\n3D ou 2D? ")
    pl(if(= opl"2D")
	(vla-addLightweightPolyline
	  space
	  (vlax-make-variant(vlax-safearray-fill(vlax-make-safearray vlax-vbdouble (cons 0 (1-(length limite2D))))
			      limite2D
			      )))
	(vla-add3dpoly
	  space
	  (vlax-make-variant(vlax-safearray-fill(vlax-make-safearray vlax-vbdouble (cons 0 (1-(length limite3D))))
			      limite3D
			      )))
	)
    )
  (vlax-put pl 'Closed 1)
  ;;;
  (setq hatch(vla-addhatch space achatchpatterntypepredefined "SOLID" :vlax-true));;;CRIAR HATCH
  (vlax-invoke hatch 'AppendOuterLoop (list pl));;;CRIAR HATCH
  (vla-evaluate hatch);;;CRIAR HATCH
  (vlax-put hatch 'Color 20)
  (vlax-invoke(vla-addobject(vla-GetExtensionDictionary space)"ACAD_SORTENTS" "AcDbSortentsTable")'MoveToBottom(list hatch));;;DRAWORDER SEND TO BACK /// MoveToTop
  ;;;
  (princ(strcat
	  "\nPropriedades do poligono - Extensão(m): "(rtos(vlax-get pl 'Length)2)
	  ;" - Área(m²): "(if(= opl"2D")(rtos(vlax-get pl 'Area)2)"...")
	  " - Área(m²): "(rtos(vlax-get hatch 'Area)2)
	  " - Layer: "(vlax-get pl 'Layer)
	  " - Cor: "(rtos(vlax-get pl 'Color)2 0)
	  )
	)
  (gc)
  (princ)
  )