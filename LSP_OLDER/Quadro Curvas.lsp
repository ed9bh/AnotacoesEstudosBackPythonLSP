;;;Pc Pt Raio Ac Tang Desenv
(defun c:qcurva()
  (defun asin (x)
    (cond
      ((equal x 1.0 1.0e-16)(* pi 0.5))
      ((equal x -1.0 1.0e-16)(* pi -0.5))
      ((< (abs x) 1.0)(atan (/ x (sqrt (- 1.0 (* x x))))))
      (T(prompt "*ERROR* (abs x) > 1.0 from ASIN function"))
      )
    )
  (setq
    sseixo(entsel"\nSelecione o Eixo: ")
    qinsertpoint(getpoint"\tClique no ponto para inserir o quadro: ")
    vleixo(if sseixo(vlax-ename->vla-object(car sseixo))(exit))
    model(vla-get-modelspace(vla-get-activedocument(vlax-get-acad-object)))
    coords(progn
	   (setq
	     coords nil
	     n -1
	     )
	   (repeat(/(length(vlax-get vleixo 'coordinates))2)
	     (setq
	       coords(vl-list*
		       (list
			 (nth(setq n(1+ n))(vlax-get vleixo 'coordinates))
			 (nth(setq n(1+ n))(vlax-get vleixo 'coordinates))
			 )
		       coords
		       )
	       )
	     )
	   (reverse coords)
	   )
    bulges(progn
	    (setq
	      bulges nil
	      n -1
	      )
	    (repeat(length coords)
	      (setq bulges(vl-list*(vla-getbulge vleixo (setq n(1+ n)))bulges))
	      )
	    (reverse bulges)
	    )
    curva 0
    n -1
    b 0
    prin nil
    p1 nil p2 nil p3 nil p4 nil
    tablist nil
    tablist(vl-list*(vla-get-layer vleixo)tablist)
    tablist(vl-list*"CURVA\t\tPC\tPI\tPT\tRAIO\tAC\tTANGENTE\tDESENVOLVIMENTO"tablist)
    tablist
     (vl-list*
       (strcat
	 "INICIO\t\t"
	 "-\t"
	 "-\t"
	 "-\t"
	 "-\t"
	 "-\t"
	 "-\t"
	 "-\n\tN\t"
	 "-\t"
	 (rtos(cadr(vlax-curve-getstartpoint vleixo))2 3)"\t"
	 "-\n\tE\t"
	 "-\t"
	 (rtos(car(vlax-curve-getstartpoint vleixo))2 3)"\t-"
	 )
       tablist)
    ncurva 0
    )
  ;;;
  ;;;
  ;CABEÇALHO DO QUADRO DE CURVAS
  (qpi_cabecalho qinsertpoint (vla-get-layer vleixo))
  (setq qinsertpoint(list(car qinsertpoint)(+(cadr qinsertpoint)-15)(caddr qinsertpoint)))
  ;INICIO
  (qpi_lfirst qinsertpoint "INICIO" (rtos(cadr(vlax-curve-getstartpoint vleixo))2 3) (rtos(car(vlax-curve-getstartpoint vleixo))2 3))
  (setq qinsertpoint(list(car qinsertpoint)(+(cadr qinsertpoint)-2.5)(caddr qinsertpoint)))
  ;;;
  (repeat(length coords)
    (setq
      p4(nth(setq n(1+ n))coords)
      )
    (if p1
      (setq
	lenI(vlax-curve-getdistatpoint vleixo p2)
	est1(if
	     (zerop(rem(read(substr(rtos lenI 2 0)(1-(strlen(rtos lenI 2 0)))1))2))
	     (strcat(rtos(/(setq Lint(read(strcat(substr(rtos lenI 2 0)1(-(strlen(rtos lenI 2 0))1))"0")))20)2 0)"+"(rtos(- lenI Lint)2 3))
	     (strcat(rtos(/(setq Lint(-(read(strcat(substr(rtos lenI 2 0)1(-(strlen(rtos lenI 2 0))1))"0"))10))20)2 0)"+"(rtos(- lenI Lint)2 3))
	     )
	)
      )
    (if p1
      (setq
	lenI(vlax-curve-getdistatpoint vleixo p3)
	est2(if
	     (zerop(rem(read(substr(rtos lenI 2 0)(1-(strlen(rtos lenI 2 0)))1))2))
	     (strcat(rtos(/(setq Lint(read(strcat(substr(rtos lenI 2 0)1(-(strlen(rtos lenI 2 0))1))"0")))20)2 0)"+"(rtos(- lenI Lint)2 3))
	     (strcat(rtos(/(setq Lint(-(read(strcat(substr(rtos lenI 2 0)1(-(strlen(rtos lenI 2 0))1))"0"))10))20)2 0)"+"(rtos(- lenI Lint)2 3))
	     )
	)
      )
    (if(and p1 p4)
      (progn
	(setq ppi(inters p1 p2 p3 p4 nil)
	      raio nil
	      )
	(if ppi
	  (setq
	    da(distance p1 p2);Reta 1
	      db(distance p3 p4);Reta 2
	      dc(distance p3 p2);Tang 1
	      dd(distance p2 ppi);Tang 2
	      de(distance ppi p3);Tang 3
	      des(-(vlax-curve-getdistatpoint vleixo p3)(vlax-curve-getdistatpoint vleixo p2))
	      f1(-(expt dc 2)(expt dd 2)(expt de 2))
	      f2(*(* dd de)2)
	      f3(/ f1 f2)
	      ac(angtos(asin f3)1 4)
	      raio(if(=(setq bul(nth(setq b(1+ b))bulges))0)
		   nil
		   (/(*(distance p2 p3)(1+(* bul bul)))4(abs bul))
		   )
	      )
	  (setq b(1+ b))
	  )
	(if raio
	  (progn
	  	  (setq tablist(vl-list*
			 (strcat
			   "C-"(rtos(setq ncurva(1+ ncurva))2 0)"\t\t"
			   est1"\t"
			   "PI-"(rtos ncurva 2 0)"\t"
			   est2"\t"
			   (rtos raio 2 3)"\t"
			   ac"\t"
			   (rtos dc 2 3)"\t"
			   (rtos des 2 3)"\n\tN\t"
			   (rtos(cadr p2)2 3)"\t"
			   (rtos(cadr ppi)2 3)"\t"
			   (rtos(cadr p3)2 3)"\n\tE\t"
			   (rtos(car p2)2 3)"\t"
			   (rtos(car ppi)2 3)"\t"
			   (rtos(car p3)2 3)
			   )
			 tablist
			 )
			

		)
	    (qpi_curvas qinsertpoint
	      (strcat"C-"(rtos ncurva 2 0))
	      est1
	      (rtos(cadr p2)2 3)
	      (rtos(car p2)2 3)
	      (strcat"PI-"(rtos ncurva 2 0))
	      (rtos(cadr ppi)2 3)
	      (rtos(car ppi)2 3)
	      est2
	      (rtos(cadr p3)2 3)
	      (rtos(car p3)2 3)
	      (rtos raio 2 3)
	      ac
	      (rtos dc 2 3)
	      (rtos des 2 3)
	      "-"
	      )
	    (setq qinsertpoint(list(car qinsertpoint)(+(cadr qinsertpoint)-10)(caddr qinsertpoint)))
	    )
	  )
	)
      )
    
    (setq
      p1 p2
      p2 p3
      p3 p4
      )
    )
  (setq
    tablist
     (vl-list*
       (strcat
	 "FINAL\t\t"
	 "-\t"
	 "-\t"
	 "-\t"
	 "-\t"
	 "-\t"
	 "-\t"
	 "-\n\tN\t"
	 "\t"
	 (rtos(cadr(vlax-curve-getendpoint vleixo))2 3)"\t"
	 "-\n\tE\t"
	 "-\t"
	 (rtos(car(vlax-curve-getendpoint vleixo))2 3)"\t-"
	 )
       tablist)
    tablist(vl-list*(vla-get-layer vleixo)tablist)
    arq(open(strcat(getvar'dwgprefix)(vla-get-layer vleixo)"-QuadroCurvas.txt")"w")
    )
  (mapcar'(lambda(x)(write-line(vl-string-translate"d""°"(vl-string-translate"."","x))arq))(reverse tablist))
  (close arq)
  (vl-catch-all-apply'vlax-invoke(list(setq app(vla-getInterfaceObject(vlax-get-acad-object)"Shell.Application"))'open
				      (strcat(getvar'dwgprefix)(vla-get-layer vleixo)"-QuadroCurvas.txt"))
    )
  (vlax-release-object app)
  (princ)
  )

;;;CABEÇALHO
(defun qpi_cabecalho(bpoint ID);(qpi_cabecalho bpoint ID)
  (vla-addline model(vlax-3d-point(list(+(car bpoint)76.42839999999998)(+(cadr bpoint)-9.000000000000000)))(vlax-3d-point(list(+(car bpoint)76.42840000000001)(+(cadr bpoint)-12.00000000000000))))
  (vla-addline model(vlax-3d-point(list(+(car bpoint)65.35699999999998)(+(cadr bpoint)-9.000000000000000)))(vlax-3d-point(list(+(car bpoint)65.35700000000002)(+(cadr bpoint)-12.00000000000000))))
  (vla-addline model(vlax-3d-point(list(+(car bpoint)54.28560000000000)(+(cadr bpoint)-9.000000000000000)))(vlax-3d-point(list(+(car bpoint)54.28560000000001)(+(cadr bpoint)-12.00000000000000))))
  (vla-addline model(vlax-3d-point(list(+(car bpoint)43.21419999999998)(+(cadr bpoint)-3.000000000000007)))(vlax-3d-point(list(+(car bpoint)43.21420000000002)(+(cadr bpoint)-12.00000000000000))))
  (vla-addline model(vlax-3d-point(list(+(car bpoint)32.14280000000001)(+(cadr bpoint)-9.000000000000000)))(vlax-3d-point(list(+(car bpoint)32.14280000000002)(+(cadr bpoint)-12.00000000000000))))
  (vla-addline model(vlax-3d-point(list(+(car bpoint)21.07140000000002)(+(cadr bpoint)-9.000000000000000)))(vlax-3d-point(list(+(car bpoint)21.07140000000002)(+(cadr bpoint)-12.00000000000000))))
  (vla-addline model(vlax-3d-point(list(+(car bpoint)10.00000000000000)(+(cadr bpoint)-3.000000000000007)))(vlax-3d-point(list(+(car bpoint)10.00000000000003)(+(cadr bpoint)-12.00000000000000))))
  (vla-addline model(vlax-3d-point(list(+(car bpoint)0.000000000000000)(+(cadr bpoint)-12.00000000000000)))(vlax-3d-point(list(+(car bpoint)87.50000000000000)(+(cadr bpoint)-12.00000000000000))))
  (vla-addline model(vlax-3d-point(list(+(car bpoint)0.000000000000000)(+(cadr bpoint)-15.00000000000000)))(vlax-3d-point(list(+(car bpoint)87.50000000000000)(+(cadr bpoint)-15.00000000000000))))
  (vla-addline model(vlax-3d-point(list(+(car bpoint)10.00000000000002)(+(cadr bpoint)-9.000000000000000)))(vlax-3d-point(list(+(car bpoint)87.50000000000000)(+(cadr bpoint)-9.000000000000000))))
  (vla-addline model(vlax-3d-point(list(+(car bpoint)10.00000000000001)(+(cadr bpoint)-6.000000000000000)))(vlax-3d-point(list(+(car bpoint)43.21420000000002)(+(cadr bpoint)-6.000000000000007))))
  (vla-addline model(vlax-3d-point(list(+(car bpoint)0.000000000000000)(+(cadr bpoint)-3.000000000000000)))(vlax-3d-point(list(+(car bpoint)87.50000000000000)(+(cadr bpoint)-3.000000000000000))))
  (vla-addline model(vlax-3d-point(list(+(car bpoint)0.000000000000000)(+(cadr bpoint)0.000000000000000)))(vlax-3d-point(list(+(car bpoint)87.50000000000000)(+(cadr bpoint)0.000000000000000))))
  (vla-addline model(vlax-3d-point(list(+(car bpoint)87.50000000000000)(+(cadr bpoint)0.000000000000000)))(vlax-3d-point(list(+(car bpoint)87.50000000000000)(+(cadr bpoint)-14.99999999999999))))
  (vla-addline model(vlax-3d-point(list(+(car bpoint)0.000000000000000)(+(cadr bpoint)0.000000000000000)))(vlax-3d-point(list(+(car bpoint)0.0000000000000284)(+(cadr bpoint)-14.99999999999999))))
  (vla-addtext model ID (vlax-3d-point(list(+(car bpoint)41.24999999208810)(+(cadr bpoint)-14.25000000000000)))1.0000)
  (vla-addtext model"D(m)"(vlax-3d-point(list(+(car bpoint)79.71419999208809)(+(cadr bpoint)-11.25000000000000)))1.0000)
  (vla-addtext model"T(m)"(vlax-3d-point(list(+(car bpoint)68.64269999999999)(+(cadr bpoint)-11.25000000000000)))1.0000)
  (vla-addtext model"AC"(vlax-3d-point(list(+(car bpoint)58.57130000000001)(+(cadr bpoint)-11.25000000000000)))1.0000)
  (vla-addtext model"R(m)"(vlax-3d-point(list(+(car bpoint)46.49990000000001)(+(cadr bpoint)-11.25000000000000)))1.0000)
  (vla-addtext model"PT"(vlax-3d-point(list(+(car bpoint)36.42850000000001)(+(cadr bpoint)-11.25000000000000)))1.0000)
  (vla-addtext model"PI"(vlax-3d-point(list(+(car bpoint)25.60710000000003)(+(cadr bpoint)-11.25000000000000)))1.0000)
  (vla-addtext model"PC"(vlax-3d-point(list(+(car bpoint)14.28570000000002)(+(cadr bpoint)-11.25000000000000)))1.0000)
  (vla-addtext model"ELEMENTOS DE CURVAS"(vlax-3d-point(list(+(car bpoint)51.10709999208808)(+(cadr bpoint)-6.750000000000000)))1.0000)
  (vla-addtext model"ESTACAS / COORDENADAS"(vlax-3d-point(list(+(car bpoint)11.10710000000000)(+(cadr bpoint)-8.250000000000000)))1.0000)
  (vla-addtext model"PONTOS NOTÁVEIS"(vlax-3d-point(list(+(car bpoint)15.60710000000000)(+(cadr bpoint)-5.250000000000000)))1.0000)
  (vla-addtext model"CURVA"(vlax-3d-point(list(+(car bpoint)1.250000000000014)(+(cadr bpoint)-8.250000000000000)))1.0000)
  (vla-addtext model"QUADRO DE CURVAS"(vlax-3d-point(list(+(car bpoint)31.74999999208810)(+(cadr bpoint)-2.250000000000000)))1.0000)
  )
;;;CABEÇALHO

;PRIMEIRA LINHA
(defun qpi_lfirst(bpoint IE IX IY)
  (vla-addtext model IX (vlax-3d-point(list(+(car bpoint)71.25003332546788)(+(cadr bpoint)-1.749999999729993)))1.0000)
  (vla-addtext model IY (vlax-3d-point(list(+(car bpoint)42.08338333337978)(+(cadr bpoint)-1.749999999729993)))1.0000)
  (vla-addtext model IE (vlax-3d-point(list(+(car bpoint)12.91668333337980)(+(cadr bpoint)-1.749999999729993)))1.0000)
  (vla-addline model(vlax-3d-point(list(+(car bpoint)58.33340000009290)(+(cadr bpoint)-2.499999999459987)))(vlax-3d-point(list(+(car bpoint)58.33340000000001)(+(cadr bpoint)0.000000000000000))))
  (vla-addline model(vlax-3d-point(list(+(car bpoint)29.16670000009290)(+(cadr bpoint)-2.499999999459987)))(vlax-3d-point(list(+(car bpoint)29.16670000000002)(+(cadr bpoint)0.000000000000000))))
  (vla-addline model(vlax-3d-point(list(+(car bpoint)0.0000000000929106)(+(cadr bpoint)-2.499999999459987)))(vlax-3d-point(list(+(car bpoint)0.0000000000000142)(+(cadr bpoint)0.000000000000000))))
  (vla-addline model(vlax-3d-point(list(+(car bpoint)87.49999998426909)(+(cadr bpoint)-2.499999999459987)))(vlax-3d-point(list(+(car bpoint)87.49999998417619)(+(cadr bpoint)0.000000000000000))))
  (vla-addline model(vlax-3d-point(list(+(car bpoint)0.000000000000000)(+(cadr bpoint)0.000000000000000)))(vlax-3d-point(list(+(car bpoint)87.49999998417619)(+(cadr bpoint)0.000000000000000))))
  (vla-addline model(vlax-3d-point(list(+(car bpoint)0.0000000000929106)(+(cadr bpoint)-2.499999999459987)))(vlax-3d-point(list(+(car bpoint)87.49999998426909)(+(cadr bpoint)-2.499999999459987))))
  )

;CURVAS
(defun qpi_curvas(bpoint NCURVA PC PCN PCE PPI PPIN PPIE PT PTN PTE R AC TAN D DAZ)
  (vla-addline model(vlax-3d-point(list(+(car bpoint)87.500)(+(cadr bpoint)-10.000)))(vlax-3d-point(list(+(car bpoint)87.500)(+(cadr bpoint)0.000))))
  (vla-addline model(vlax-3d-point(list(+(car bpoint)76.428)(+(cadr bpoint)0.000)))(vlax-3d-point(list(+(car bpoint)76.428)(+(cadr bpoint)-7.500))))
  (vla-addline model(vlax-3d-point(list(+(car bpoint)65.357)(+(cadr bpoint)0.000)))(vlax-3d-point(list(+(car bpoint)65.357)(+(cadr bpoint)-7.500))))
  (vla-addline model(vlax-3d-point(list(+(car bpoint)54.285)(+(cadr bpoint)0.000)))(vlax-3d-point(list(+(car bpoint)54.285)(+(cadr bpoint)-7.500))))
  (vla-addline model(vlax-3d-point(list(+(car bpoint)43.214)(+(cadr bpoint)0.000)))(vlax-3d-point(list(+(car bpoint)43.214)(+(cadr bpoint)-7.500))))
  (vla-addline model(vlax-3d-point(list(+(car bpoint)32.142)(+(cadr bpoint)0.000)))(vlax-3d-point(list(+(car bpoint)32.142)(+(cadr bpoint)-7.500))))
  (vla-addline model(vlax-3d-point(list(+(car bpoint)21.071)(+(cadr bpoint)0.000)))(vlax-3d-point(list(+(car bpoint)21.071)(+(cadr bpoint)-7.500))))
  (vla-addline model(vlax-3d-point(list(+(car bpoint)10.000)(+(cadr bpoint)0.000)))(vlax-3d-point(list(+(car bpoint)10.000)(+(cadr bpoint)-7.500))))
  (vla-addline model(vlax-3d-point(list(+(car bpoint)5.000)(+(cadr bpoint)-7.500)))(vlax-3d-point(list(+(car bpoint)5.000)(+(cadr bpoint)0.000))))
  (vla-addline model(vlax-3d-point(list(+(car bpoint)0.000)(+(cadr bpoint)-10.000)))(vlax-3d-point(list(+(car bpoint)0.000)(+(cadr bpoint)0.000))))
  (vla-addline model(vlax-3d-point(list(+(car bpoint)0.000)(+(cadr bpoint)-10.000)))(vlax-3d-point(list(+(car bpoint)87.500)(+(cadr bpoint)-10.000))))
  (vla-addline model(vlax-3d-point(list(+(car bpoint)0.000)(+(cadr bpoint)-7.500)))(vlax-3d-point(list(+(car bpoint)87.500)(+(cadr bpoint)-7.500))))
  (vla-addline model(vlax-3d-point(list(+(car bpoint)0.000)(+(cadr bpoint)0.000)))(vlax-3d-point(list(+(car bpoint)87.500)(+(cadr bpoint)0.000))))
  (vla-addline model(vlax-3d-point(list(+(car bpoint)5.000)(+(cadr bpoint)-5.000)))(vlax-3d-point(list(+(car bpoint)43.214)(+(cadr bpoint)-5.000))))
  (vla-addline model(vlax-3d-point(list(+(car bpoint)5.000)(+(cadr bpoint)-2.500)))(vlax-3d-point(list(+(car bpoint)43.214)(+(cadr bpoint)-2.500))))
  (vla-addtext model DAZ (vlax-3d-point(list(+(car bpoint)37.250)(+(cadr bpoint)-9.250)))1.0000)
  (vla-addtext model D (vlax-3d-point(list(+(car bpoint)80.630)(+(cadr bpoint)-4.250)))1.0000)
  (vla-addtext model TAN(vlax-3d-point(list(+(car bpoint)69.559)(+(cadr bpoint)-4.250)))1.0000)
  (vla-addtext model AC (vlax-3d-point(list(+(car bpoint)57.988)(+(cadr bpoint)-4.250)))1.0000)
  (vla-addtext model R(vlax-3d-point(list(+(car bpoint)47.416)(+(cadr bpoint)-4.250)))1.0000)
  (vla-addtext model PTE(vlax-3d-point(list(+(car bpoint)35.345)(+(cadr bpoint)-6.750)))1.0000)
  (vla-addtext model PTN(vlax-3d-point(list(+(car bpoint)35.345)(+(cadr bpoint)-4.250)))1.0000)
  (vla-addtext model PT(vlax-3d-point(list(+(car bpoint)35.845)(+(cadr bpoint)-1.750)))1.0000)
  (vla-addtext model PPIE(vlax-3d-point(list(+(car bpoint)24.440)(+(cadr bpoint)-6.750)))1.0000)
  (vla-addtext model PPIN(vlax-3d-point(list(+(car bpoint)24.440)(+(cadr bpoint)-4.250)))1.0000)
  (vla-addtext model PPI(vlax-3d-point(list(+(car bpoint)24.940)(+(cadr bpoint)-1.750)))1.0000)
  (vla-addtext model PCE(vlax-3d-point(list(+(car bpoint)13.202)(+(cadr bpoint)-6.750)))1.0000)
  (vla-addtext model PCN(vlax-3d-point(list(+(car bpoint)13.202)(+(cadr bpoint)-4.250)))1.0000)
  (vla-addtext model PC(vlax-3d-point(list(+(car bpoint)13.702)(+(cadr bpoint)-1.750)))1.0000)
  (vla-addtext model"E(E)"(vlax-3d-point(list(+(car bpoint)6.000)(+(cadr bpoint)-6.750)))1.0000)
  (vla-addtext model"N(Y)"(vlax-3d-point(list(+(car bpoint)6.000)(+(cadr bpoint)-4.250)))1.0000)
  (vla-addtext model"EST"(vlax-3d-point(list(+(car bpoint)6.166)(+(cadr bpoint)-1.750)))1.0000)
  (vla-addtext model NCURVA(vlax-3d-point(list(+(car bpoint)0.667)(+(cadr bpoint)-4.250)))1.0000)
  )
