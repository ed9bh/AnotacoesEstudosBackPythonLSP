;;;Cria polilinha amarrada em 'points' e 'blocks' e se for sua opção também filtra por layer.
(defun c:sml3d()(c:smartline3d))
(defun c:smartline3d()
  (vl-load-com)
  (if(setq memo(vl-file-size(strcat(getvar"dwgprefix")(getvar"dwgname"))))(alloc(* memo 4)))
  (princ"\nSomente em pontos e blocos!!!")
  (initget 128"Digitar  ")
  (setq
    lay(entsel"\nFiltrar por layer? [Digitar / Selecione]<Enter para geral>: ")
    lay(if(and(/= lay "Digitar")(/= lay ""))(vlax-get(vlax-ename->vla-object(car lay))'Layer)lay)
    lay(if(= lay "Digitar")(getstring"\nDigite os layers separados por virgula: "t)lay)
    lay(if(= lay "")nil lay)
    pointList nil
    space(if(=(getvar"ctab")"Model")
	   (vla-get-modelspace(vla-get-activedocument(vlax-get-acad-object)))
	   (vla-get-paperspace(vla-get-activedocument(vlax-get-acad-object)))
	   )
    )
  (while
    (setq point(progn(initget 128"Undo")
		 (if pointList
		   (getpoint(car pointList)"\tClique proximo ao ponto<Undo>: ")
		   (getpoint"\tClique proximo ao ponto<Undo>: "))
		 )
	  )
    (if(= point "Undo")
      (if(>(length pointList)1)(setq pointList(cdr pointList)))
      (progn
	(setq
	  ss(ssget"w"
		  (list(-(car point)100)(-(cadr point)100))(list(+(car point)100)(+(cadr point)100))
		  (if lay
		    (list'(0 . "insert,point,AECC_COGO_POINT")(cons 8 lay))
		    '((0 . "insert,point,AECC_COGO_POINT"))
		    )
		  )
	  p(if ss
	     (mapcar'(lambda(x)
;		       (list(car(setq a(vlax-get(vlax-ename->vla-object(cadr x))
;;;							(if(=(vlax-get(vlax-ename->vla-object(cadr x))'ObjectName)"AcDbPoint")
;;;							  'Coordinates
;;;							  'InsertionPoint
;;;							  )
;;;							)))(cadr a) (caddr a))
;		       (if(=(vlax-get(vlax-ename->vla-object(cadr x))'ObjectName)"AcDbPoint")
;			 (vlax-get(vlax-ename->vla-object(cadr x))'Coordinates)
;			 (vlax-get(vlax-ename->vla-object(cadr x))'InsertionPoint)
;			 )
		       (cond
			 ((=(vlax-get(vlax-ename->vla-object(cadr x))'ObjectName)"AcDbPoint")(vlax-get(vlax-ename->vla-object(cadr x))'Coordinates))
			 ((=(vlax-get(vlax-ename->vla-object(cadr x))'ObjectName)"AcDbBlockReference")(vlax-get(vlax-ename->vla-object(cadr x))'InsertionPoint))
			 ((=(vlax-get(vlax-ename->vla-object(cadr x))'ObjectName)"AeccDbCogoPoint")(vlax-get(vlax-ename->vla-object(cadr x))'Location))
			 )
		       )
		    (cdr(reverse(ssnamex ss)))
		    )
	     )
	  p(if ss
	     (vl-sort p
		      (function(lambda(a1 a2)
				 (<(distance point (list (car a1) (cadr a1)))
				   (distance point (list (car a2) (cadr a2))))
				 )
			       )
		      )
	     )
	  p(if ss(car p)point)
	  )
	)
      )
    ;
    (if(= point"Undo")
      (princ)
      (if p
	(setq pointList(vl-list* p pointList)))
      )
    (if(and
	 (equal(car(car pointList))(car(cadr pointList))0)
	 (equal(cadr(car pointList))(cadr(cadr pointList))0)
	 )
      (setq pointList(cdr pointList))
      )
    ;
    (redraw)
    (if(>=(length pointList)2)(mapcar'(lambda(a b)(grdraw a b 12))(reverse(cdr(reverse pointList)))(cdr pointList)))
    )
  (setq pl
	 (vla-add3DPoly
	   space
	   (vlax-make-variant
	     (vlax-safearray-fill
	       (vlax-make-safearray vlax-vbdouble (cons 0 (1-(length (apply'append(reverse pointList))))))
	       (apply'append(reverse pointList))
	       )
	     )
	   )
	)
  (redraw)
  (vla-put-layer pl lay)
  (princ(strcat"\nExtensão = "(rtos(vlax-get pl 'Length)2)" - Layer = "(vlax-get pl 'Layer)" - Cor = "(rtos(vlax-get pl 'Color)2 0)"\n"))
  (gc)
  (princ)
  )

;|
DESENVOLVEDOR: ERIC DRUMOND - 02/2018
CONTATO:
	EMAIL:	ericdrumond@gmail.com
	
Este Lisp foi importante pra você e quer fazer uma doação? https://goo.gl/5yor73
-----------------------------------------------------------------------------------------------
OBRIGADO POR UTILIZAR ESTE LISP, DIVULGUE E MODIFIQUE MÁS NÃO TIRE A PROPRIEDADE DESTE LISP. :)
-----------------------------------------------------------------------------------------------
|;
