;;;TRANSFORMA PONTOS TG - COLOCA LAYER DE ACORDO COM DESCRIÇÃO - COLOCA ELEVAÇÃO NOS PONTOS
(defun c:tgp(/ ss s l e p)
  (vl-load-com)
  (setq
    ss(ssget"x"'((0 . "insert")(2 . "SIMB_PONTO")))
    ss(if ss
	(ssnamex ss)
	(quit)
	)
    )
  (mapcar'(lambda(x)
	    (progn
	      (setq
		s(vlax-ename->vla-object(cadr x))
		l(vla-get-textstring(nth 1(vlax-safearray->list(vlax-variant-value(vla-getattributes s)))))
		e(vla-get-textstring(nth 2(vlax-safearray->list(vlax-variant-value(vla-getattributes s)))))
		p(vlax-get s 'InsertionPoint)
		)
	      (if(tblsearch"layer"(STRCAT"_"l))
		(princ)
		(entmake(list'(0 . "LAYER")'(100 . "AcDbSymbolTableRecord")'(100 . "AcDbLayerTableRecord")
			     (cons 2 (STRCAT"_"l))
			     '(6 . "Continuous")'(62 . 250)'(70 . 0)))
		)
	      (if e
		(setq e(read(vl-string-translate",""."e))
		      p(list(car p)(cadr p) e)
		      )
		)
	      (vlax-put s 'InsertionPoint p)
	      (vlax-put s 'Layer(STRCAT"_"l))
	      )
	    )
	 ss
	 )
  (princ)
  )


;;;Encontra maio e menor elevação de pontos
(defun c:tgmm()
  (vl-load-com)
  (setq
    ss(ssget"x"'((0 . "insert")(2 . "SIMB_PONTO")))
    ss(if ss
	(ssnamex ss)
	(quit)
	)
    maior(progn
	   (setq n -1)
	   (repeat(length ss)
	     (setq maior(if maior
			  (max(caddr(vlax-get(vlax-ename->vla-object(cadr(nth(setq n(1+ n))ss)))'InsertionPoint))maior)
			  (caddr(vlax-get(vlax-ename->vla-object(cadr(nth(setq n(1+ n))ss)))'InsertionPoint))
			  )
		   )
	     )
	   )
    menor(progn
	   (setq n -1)
	   (repeat(length ss)
	     (setq menor(if menor
			  (min(caddr(vlax-get(vlax-ename->vla-object(cadr(nth(setq n(1+ n))ss)))'InsertionPoint))menor)
			  (caddr(vlax-get(vlax-ename->vla-object(cadr(nth(setq n(1+ n))ss)))'InsertionPoint))
			  )
		   )
	     )
	   )
    )
  (princ(strcat"Maior = "(rtos maior 2 3)" - Menor = "(rtos menor 2 3)" - Desnivel = "(rtos(- maior menor)2 3)))
  (princ)
  )
  