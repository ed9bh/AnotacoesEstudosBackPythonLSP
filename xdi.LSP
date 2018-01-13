;|
XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
ESTE LISP FOI DESENVOLVIDO PARA OTIMIZAR A OBTENÇÃO DAS DISTANCIAS DE FORMA MAIS INTELIGENTE E AGIL.                               
ESTA ROTINA FOI FEITA PARA DEDUZIR SUAS OPÇÕES, VOCÊ PODE SELECIONAR UMA ENTIDADE E OBTER TODO O COMPRIMENTO DELA DE UMA UNICA VEZ,
OU DENTRO DE UMA ENTIDADE DESCOBRIR UMA DISTANCIA DE UM PONTO "A" AO "B", TAMBEM PODE SER USADO DE FORMA TRADICIONAL DA DISTANCIA. 
INFORMA INCLINAÇÃO EM UMA DISTANCIAS EM 3D E TAMBÉM INDICA ÁREA DE UMA ENTIDADE FECHADA.                                           
XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
|;

(defun c:xdi(/ obj objE pt1 pt2 dist dist2D dist3D azi inc area est1 est2)
  (vl-load-com)
  (mapcar'(lambda(x)(setvar(car x)(cadr x)))'(("lunits"2)("aunits"1)("angdir"1)("angbase"1.5708)("insunits"0)("dimzin"0)))
  (setq obj(progn(princ"\nSelecione a entidade a medir ou <enter/botão dir.>: ")(ssget":s"'((0 . "line,lwpolyline,circle,spline,arc"))))
	obj(if obj (ssname obj 0) nil)
	objE(if obj (vlax-ename->vla-object obj) nil)
	objName(if objE(vlax-get objE 'ObjectName))
	est1 nil
	est2 nil
	pt2A nil
	)
  (if obj
    (setq pt1(getpoint"\nClique no ponto inicial ou <enter/botão dir.> para comprimento total da entidade: ")
	  pt2(if pt1(getpoint"\tClique no ponto final ou <enter/botão dir.>: "))
	  pt2A pt2
	  pt2(if(and(/= pt1 nil)(= pt2 nil))(vlax-curve-getstartpoint objE)pt2)
	  )
    (progn
      (while(= pt1 nil)(setq pt1(getpoint"\nClique no primeiro ponto: ")))
      (while(= pt2 nil)(setq pt2(getpoint pt1"\nClique no ultimo ponto: ")))
      )
    )
  (if obj
    (progn
      (setq dist(if pt1(vlax-curve-getdistatpoint obj(vlax-curve-getClosestPointTo obj pt1))nil)
	    est1(if(and dist pt1)(progn(setq est1(read(substr (rtos dist 2 0) 1 (1-(strlen(rtos dist 2 0)))))
					     est1(if(=(rem est1 2)0)
						   (setq est1(strcat(rtos(/(read(rtos dist 2 0))20)2 0)"+"(substr(rtos dist 2 3) (vl-string-search "." (rtos dist 2)))))
						   (setq est1(strcat(rtos(/(-(read(rtos dist 2 0))10)20)2 0)"+1"(substr(rtos dist 2 3) (vl-string-search "." (rtos dist 2)))))
						   )
					     )
				   )
		  )
	    dist(if pt2(abs(-(vlax-curve-getdistatpoint obj(vlax-curve-getClosestPointTo obj pt2))dist))nil)
	    est2(if(and dist pt2)(progn(setq est2(read(substr (rtos dist 2 0) 1 (1-(strlen(rtos dist 2 0)))))
					     est2(if(=(rem est2 2)0)
						   (setq est2(strcat(rtos(/(read(rtos dist 2 0))20)2 0)"+"(substr(rtos dist 2 3) (vl-string-search "." (rtos dist 2)))))
						   (setq est2(strcat(rtos(/(-(read(rtos dist 2 0))10)20)2 0)"+1"(substr(rtos dist 2 3) (vl-string-search "." (rtos dist 2)))))
						   )
					     )
				   )
		  )
	    dist(if dist
		  dist
		  (cond
		    ((= objName"AcDbPolyline")(vlax-get objE 'Length))
		    ((= objName"AcDbLine")(vlax-get objE 'Length))
		    ((= objName"AcDbArc")(vlax-get objE 'ArcLength))
		    ((= objName"AcDbCircle")(vlax-get objE 'Circumference))
		    ((= objName"AcDbSpline")(vlax-curve-getdistatpoint obj(vlax-curve-getendpoint obj)))
		    )
		  )
	    area(if(vlax-curve-isclosed obj)(vlax-curve-getarea obj)nil)
	    )
      (if(and pt1 pt2)
	(princ(strcat"\nDistancia de ponto \"A\" ao \"B\" na entidade: "(rtos dist 2)))
	(princ(strcat"\nDistancia total da entidade: "(rtos dist 2)(if area(strcat" - Area: "(rtos area 2))"")))
	)
      )
    (progn
      (setq dist2D(distance(list(car pt1)(cadr pt1))(list(car pt2)(cadr pt2)))
	    dist3D(distance pt1 pt2)
	    azi(angle pt1 pt2)
	    deltaX(-(car pt2)(car pt1))
	    deltaY(-(cadr pt2)(cadr pt1))
	    inc(*(/(-(caddr pt2)(caddr pt1))dist2D)100)
	    )
      (princ
	(strcat"\nDistancia 2D: "(rtos dist2D 2)" - Azimute: "(vl-string-translate"d""°"(angtos azi 1))
	       " - Delta X: "(rtos deltaX 2)" / Delta Y: "(rtos deltaY 2)
	       (if(= dist2d dist3D)""(strcat"\nDistancia 3D: "(rtos dist3D 2)" - Iclinação: "(rtos inc 2)"% - Delta Z: "(rtos(-(caddr pt2)(caddr pt1))2)))
	       )
	)
      )
    )
  ;(if pt1(princ(strcat"\nSe for Eixo, Estaca 1 = "est1)))
  ;(if pt2A(princ(strcat"\tSe for Eixo, Estaca 2 = "est2)))
  (princ)
  )

;|
DESENVOLVEDOR: ERIC DRUMOND - 07/2013
CONTATO:
	EMAIL:	ericdrumond@gmail.com
	
Este Lisp foi importante pra você e quer fazer uma doação? https://goo.gl/5yor73
-----------------------------------------------------------------------------------------------
OBRIGADO POR UTILIZAR ESTE LISP, DIVULGUE E MODIFIQUE MÁS NÃO TIRE A PROPRIEDADE DESTE LISP. :)
-----------------------------------------------------------------------------------------------
|;