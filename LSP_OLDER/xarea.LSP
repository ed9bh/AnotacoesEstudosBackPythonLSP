(defun c:xarea();define área
  (vl-load-com)
  (setvar"cmdecho"0)(setvar"dimzin"0)
  (if os(setvar"osmode"os))
  (setq os(getvar"osmode"))
  (setq
    limitEn(entsel"\nSelecione o limite da area: ")
    limitVl(if limitEn(vlax-ename->vla-object(car limitEn))(quit))
    prin(progn(princ"\nArea atual(m²): ")(princ(rtos(vlax-get limitVL'Area)2 2)))
    pA(getpoint"\nPrimeiro ponto da linha de divisa: ")
    pB(getpoint pA"\tPonto final da linha de divisa: ")
    model(vla-get-modelspace(vla-get-activedocument(vlax-get-acad-object)))
    lin(vla-addline model(vlax-3d-point pA)(vlax-3d-point pB))
    areaD(getreal"\nDigite o valor da área a alcançar(m²): ")
    intPoints(vlax-invoke lin 'IntersectWith limitVl acExtendThisEntity)
    p1(list(nth 0 intPoints)(nth 1 intPoints))
    p2(list(nth 3 intPoints)(nth 4 intPoints))
    lin(progn
	 (setvar"osmode"0)
	 (entdel(vlax-vla-object->ename lin))
	 (vla-addline model(vlax-3d-point p1)(vlax-3d-point p2))
	 )
    lin(progn
	 (setq
	   ang(angle p1 p2)
	   ang+(+ ang 1.5708)
	   linCalc(vla-addline model
		    (vlax-3d-point(setq point-(list
					       (/(+(car p1)(car p2))2)
					       (/(+(cadr p1)(cadr p2))2)
					       )))
		    (vlax-3d-point(polar point- ang+ 1))
		    )
	   point+(vlax-invoke linCalc'IntersectWith limitVl acextendthisentity)
	   point+(if(and(>(length point+)3)(<
					  (abs(-(nth 0 point+)(nth 3 point+)))
					  (abs(-(nth 1 point+)(nth 4 point+)))
					  ))
		     (list(nth 3 point+)(nth 4 point+))
		     (list(nth 0 point+)(nth 1 point+))
		   )
	   point(polar point+(angle point+ point-)(/(distance point+ point-)2))
	   )
	 (grdraw point-(polar point- ang+(abs(distance point- point+)))170)
	 (grdraw point-(polar point- ang+(-(abs(distance point- point+))))12)
	 (setq simb(if(=(progn(initget 1"Azul Vermelho")(getkword"\tVermelho ou Azul? "))"Vermelho")+ -))
	 (command-s"-boundary"point"")(setq
					bound(vlax-ename->vla-object(entlast))
					areaO(vlax-get bound'Area)
					)
	 (entdel(vlax-vla-object->ename linCalc))
	 (entdel(vlax-vla-object->ename lin))
	 (entdel(vlax-vla-object->ename bound))
	 (vla-addline model(vlax-3d-point p1)(vlax-3d-point p2))
	 )
    bound nil
    mpP 2
    mpN -2
    )
  (if(< areaD areaO)(setq men T)(setq men NIL))
  ;;;
  (while(/= (rtos areaD 2 2) (rtos areaO 2 2))
    (princ(strcat"Aguarde essa operação poderá demorar...Diferença entre áreas -> "(rtos(abs(- areaD areaO))2 2)"..."))(princ"\r")
    (cond
      ((<(abs(- areaO areaD))1)(setq mpP 0.00000999 mpN -0.00000999))
      ((and(=(minusp(- areaO areaD))t)(= men t))(setq mpP 0.0000999 mpN -0.0000999))
      ((and(=(minusp(- areaD areaO))t)(= men nil))(setq mpP 0.0000999 mpN -0.0000999))
      ((<(abs(-(max areaO areaD)(min areaO areaD)))5)(setq mpP 0.000999 mpN -0.000999))
      ((<(abs(-(max areaO areaD)(min areaO areaD)))50)(setq mpP 0.00999 mpN -0.00999))
      )
    (if(< areaO areaD)
      (setq p1(polar p1 ang+(simb mpP))p2(polar p2 ang+(simb mpP)))
      (setq p1(polar p1 ang+(simb mpN))p2(polar p2 ang+(simb mpN)))
      )
    (progn
      (entdel(vlax-vla-object->ename lin))
      (if bound(entdel(vlax-vla-object->ename bound)))
      (setq
	lin(vla-addline model(vlax-3d-point p1)(vlax-3d-point p2))
	intPoints(vlax-invoke lin 'IntersectWith limitVl acExtendThisEntity)
	p1(list(nth 0 intPoints)(nth 1 intPoints))
	p2(list(nth 3 intPoints)(nth 4 intPoints))
	lin(progn
	     (entdel(vlax-vla-object->ename lin))
	     (vla-addline model(vlax-3d-point p1)(vlax-3d-point p2))
	     )
	ang(angle p1 p2)
	ang+(+ ang 1.5708)
	linCalc(vla-addline model
		 (vlax-3d-point(setq point-(list
					     (/(+(car p1)(car p2))2)
					     (/(+(cadr p1)(cadr p2))2)
					     )))
		 (vlax-3d-point(polar point- ang+ 1))
		 )
	point+(vlax-invoke linCalc'IntersectWith limitVl acextendthisentity)
	point+(if(and(>(length point+)3)
		     (<
		       (abs(-(nth 0 point+)(nth 3 point+)))
		       (abs(-(nth 1 point+)(nth 4 point+)))
		       )
		     )
		     (list(nth 3 point+)(nth 4 point+))
		     (list(nth 0 point+)(nth 1 point+))
		   )
	point(if(/= simb -)
	       (progn
		 (entdel(vlax-vla-object->ename linCalc))
		 (setq point(polar point- ang+(-(*(abs(distance point- point+))1000)))
		       linCalc(vla-addline model(vlax-3d-point point-)(vlax-3d-point point))
		       point(vlax-invoke linCalc'IntersectWith limitVl acExtendNone)
		       point(list(/(+(car point)(car point-))2)(/(+(cadr point)(cadr point-))2))
		       )
		 (entdel(vlax-vla-object->ename linCalc))
		 point
		 )
	       (progn
		 (entdel(vlax-vla-object->ename linCalc))
		 (setq point(polar point- ang+(*(abs(distance point- point+))1000))
		       linCalc(vla-addline model(vlax-3d-point point-)(vlax-3d-point point))
		       point(vlax-invoke linCalc'IntersectWith limitVl acExtendNone)
		       point(list(/(+(car point)(car point-))2)(/(+(cadr point)(cadr point-))2))
		       )
		 (entdel(vlax-vla-object->ename linCalc))
		 point
		 )
	       )
	)
      (command-s"-boundary"point"")(setq
				     bound(vlax-ename->vla-object(entlast))
				     areaO(vlax-get bound'Area)
				     perim(vlax-get bound'Length)
				     )
      (vlax-put bound'Color 45)
      )
    )
  ;;;
  (entdel(vlax-vla-object->ename lin))
  (gc)
  (princ(strcat"\nArea Total Alcançada(m²) = "(rtos areaO 2 2)"\nPerimetro(m) = "(rtos perim 2 2)))
  (setvar"osmode"os)(setq os nil)
  (setvar"cmdecho"1)
  (princ)
  )


;|
(defun c:axp()
  (setq pxp1
	 (vla-addpoint model (vlax-3d-point point-))
	pxp2
	 (vla-addpoint model (vlax-3d-point point+))
	pxp3
	 (vla-addpoint model (vlax-3d-point point))
	pxp4
	 (vla-addpoint model (vlax-3d-point (polar point- ang+(simb(/(abs(distance point- point+))2)))))
	pxp5
	 (vla-addpoint model (vlax-3d-point (polar point- ang+(/(abs(distance point- point+))2))))
	)
  (mapcar'(lambda(p c)
	    (vlax-put p 'color c)
	    )
	 (list pxp1 pxp2 pxp3 pxp4 pxp5)
	 (list 1 2 3 4 5)
	 )
  (princ)
  )
|;
