;;;Converter Bulge para Raio
(/ (* (distance '(2615.1954 1526.6858) '(2741.7792 1533.4535)) (1+ (* -0.3574 -0.3574))) 4 (abs -0.3574))
(/ (* (distance PontoInicialArco PontoFinalArco) (1+ (* Bulge Bulge))) 4 (abs Bulge))



; Bulge is tangent of 1/4 of the included angle. Positive value is CounterClockwise in Direction:
; bulge = tan( ang/4 )
; raio = cotg(bulge) * 4 ??? Precisa ser confirmado...


;;;???Reverso???
(* (/ (distance PontoInicialArco PontoFinalArco) (1- (sqrt Raio))) 4 (abs Raio))
;;;???Não Confirmado

;|
(setq coo(progn
	   (setq
	     coo nil
	     c -1
	     vcoo(vlax-get aaa'coordinates)
	     )
	   (repeat(/(length vcoo)2)
	     (setq coo(vl-list*
			(list
			  (nth(setq c(1+ c))vcoo)
			  (nth(setq c(1+ c))vcoo)
			  )
			coo
			)
		   )
	     )
	   )
      coo(reverse coo)
      n nil
      )
(repeat(length coo)
  (if n(setq n(1+ n))(setq n 0))
  (princ(setq bull(vla-getbulge aaa n)))
  (if(/= bull 0.0)
    (progn
      (setq pa(nth n coo)
	    pb(nth(1+ n)coo)
	    dist(distance pa pb)
	    raio(/(* dist (1+(* bull bull)))4(abs bull))
	    )
      (princ"\n")
      (princ raio)
      )
    )
  (princ"\n")
  )
|;