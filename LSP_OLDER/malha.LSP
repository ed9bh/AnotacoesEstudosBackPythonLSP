(defun c:malha()
  (vl-load-com)
  ;;;Selecionar Polylinha / Coordenadas
  (entmake'((0 . "LAYER")(100 . "AcDbSymbolTableRecord")(100 . "AcDbLayerTableRecord")(2 . "MALHA")(6 . "Continuous")(62 . 250)(70 . 0)))
  (setq polyEntVla(vlax-ename->vla-object(car(setq polyEnt(entsel"\nSelecione o poligono a inserir malha de coordenadas: "))))
	polyCoords(vlax-get polyEntVla 'Coordinates)
	polyCoordList(progn
			(setq n -1
			      polyCoordList nil
			      )
			(repeat(/(length polyCoords)2)
			  (setq polyCoordList
				 (vl-list*
				   (list
				     (nth(setq n(1+ n))polyCoords)
				     (nth(setq n(1+ n))polyCoords)
				     )
				   polyCoordList
				   )
				)
			  )
			(reverse polyCoordList)
			)
	xMax(+(car(car(setq xList(vl-sort polyCoordList(function(lambda(e1 e2)(>(car e1)(car e2))))))))10)
	xMin(-(car(car(reverse xList)))10)
	yMax(+(cadr(car(setq yList(vl-sort polyCoordList(function(lambda(e1 e2)(>(cadr e1)(cadr e2))))))))10)
	yMin(-(cadr(car(reverse yList)))10)
	)
  ;;;Propriedade da Malha
  (setq dist(getint"\nDistancia entre linhas: ")
	prefX(getstring"\nPrefixo \"X\" da coordenada [<\"E(X)=\">]: ")
	prefX(if(= prefX "")"E(X)="prefX)
	prefY(getstring"\nPrefixo \"Y\" da coordenada [<\"N(Y)=\">]: ")
	prefY(if(= prefY "")"N(Y)="prefY)
	txtH(getreal"\nAltura do Texto <1.0>: ")
	txtH(if txtH txtH 1.0)
	xBase(progn(setq xBase 0)(while(< xBase xMin)(setq xBase(+ xBase dist)))xBase)
	yBase(progn(setq yBase 0)(while(< yBase yMin)(setq yBase(+ yBase dist)))yBase)
	)
  ;X
  (while(<(- xBase dist)xMax)
    (setq mlhLine(entmakex
		   (list
		     '(0 . "line")
		     (cons 10(list(setq xBase(+ xBase dist))yMin))
		     (cons 11(list xBase yMax))
		     '(8 . "MALHA")
		     )
		   )
	  intersectCoords(vlax-invoke polyEntVla 'IntersectWith(vlax-ename->vla-object mlhLine)acExtendNone)
	  xList(progn(setq xList nil n -3)(repeat(/(length intersectCoords)3)(setq xList(vl-list*(nth(setq n(+ n 3))intersectCoords)xList)))(reverse xList))
	  yList(progn(setq yList nil n -2)(repeat(/(length intersectCoords)3)(setq yList(vl-list*(nth(setq n(+ n 3))intersectCoords)yList)))(reverse yList))
	  )
    (repeat(/(length xList)2)
      (setq XA(car xList)xList(cdr xList)
	    YA(car yList)yList(cdr yList)
	    XB(car xList)xList(cdr xList)
	    YB(car yList)yList(cdr yList)
	    )
      ;Linha
      (vla-addline(vla-get-modelspace(vla-get-activedocument(vlax-get-acad-object)))(vlax-3d-point(list XA YA 0))(vlax-3d-point(list XB YB 0)))
      (vlax-put(vlax-ename->vla-object(entlast))'Layer"MALHA")
      ;Texto "A"
      (vla-addtext(vla-get-modelspace(vla-get-activedocument(vlax-get-acad-object)))
	(strcat prefX(rtos xBase 2 0))(vlax-3d-point(list XA YA 0))txtH)
      (vla-put-rotation(vlax-ename->vla-object(entlast))1.5708)
      (vlax-put(vlax-ename->vla-object(entlast))'Layer"MALHA")
      ;Texto "B"
      (vla-addtext(vla-get-modelspace(vla-get-activedocument(vlax-get-acad-object)))
	(strcat prefX(rtos xBase 2 0))(vlax-3d-point(list XB YB 0))txtH)
      (vla-put-rotation(vlax-ename->vla-object(entlast))1.5708)
      (vlax-put(vlax-ename->vla-object(entlast))'Layer"MALHA")
      )
    (entdel mlhLine)
    )
  ;Y
  (while(<(- yBase dist)yMax)
    (setq mlhLine(entmakex
		   (list
		     '(0 . "line")
		     (cons 10(list xMin(setq yBase(+ yBase dist))))
		     (cons 11(list xMax yBase))
		     )
		   )
	  intersectCoords(vlax-invoke polyEntVla 'IntersectWith(vlax-ename->vla-object mlhLine)acExtendNone)
	  xList(progn(setq xList nil n -3)(repeat(/(length intersectCoords)3)(setq xList(vl-list*(nth(setq n(+ n 3))intersectCoords)xList)))(reverse xList))
	  yList(progn(setq yList nil n -2)(repeat(/(length intersectCoords)3)(setq yList(vl-list*(nth(setq n(+ n 3))intersectCoords)yList)))(reverse yList))
	  )
    (repeat(/(length yList)2)
       (setq XA(car xList)xList(cdr xList)
	     YA(car yList)yList(cdr yList)
	     XB(car xList)xList(cdr xList)
	     YB(car yList)yList(cdr yList)
	     )
      ;Linha
      (vla-addline(vla-get-modelspace(vla-get-activedocument(vlax-get-acad-object)))(vlax-3d-point(list XA YA 0))(vlax-3d-point(list XB YB 0)))
      (vlax-put(vlax-ename->vla-object(entlast))'Layer"MALHA")
      ;Texto "A"
      (vla-addtext(vla-get-modelspace(vla-get-activedocument(vlax-get-acad-object)))
	(strcat prefY(rtos yBase 2 0))(vlax-3d-point(list XA YA 0))txtH)
      (vlax-put(vlax-ename->vla-object(entlast))'Layer"MALHA")
      ;Texto "B"
      (vla-addtext(vla-get-modelspace(vla-get-activedocument(vlax-get-acad-object)))
	(strcat prefY(rtos yBase 2 0))(vlax-3d-point(list XB YB 0))txtH)
      (vlax-put(vlax-ename->vla-object(entlast))'Layer"MALHA")
      )
    (entdel mlhLine)
    )
  (princ)
  )


;;;      (setq XA(car intersectCoords)intersectCoords(cdr intersectCoords)
;;;	    YA(car intersectCoords)intersectCoords(cdr intersectCoords)
;;;	    Z(car intersectCoords)intersectCoords(cdr intersectCoords)
;;;	    XB(car intersectCoords)intersectCoords(cdr intersectCoords)
;;;	    YB(car intersectCoords)intersectCoords(cdr intersectCoords)
;;;	    Z(car intersectCoords)intersectCoords(cdr intersectCoords)
;;;	    )