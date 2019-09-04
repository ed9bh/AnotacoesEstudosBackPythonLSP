(defun c:pasbuilt(/ CoordsSoldaLista n pt mspace LineSoldaLista line PLTub PLTer)
  (vl-load-com)
  (if arq+(progn(close arq+)(setq arq+ nil)))
  (if(setq del(ssget"x"'((0 . "Point,Text,Line")(8 . "SoldaLista"))))
    (mapcar'(lambda(x)(entdel(cadr x)))(ssnamex del))
    )
  (if(/=(tblsearch"Layer""SoldaLista")t)
    (entmake'((0 . "LAYER")(100 . "AcDbSymbolTableRecord")(100 . "AcDbLayerTableRecord")(2 . "SoldaLista")(6 . "Continuous")(62 . 250)(70 . 0)))
    )
  (setq PLTer(car(entsel"\nSelecione a polilinha do terreno: "))
	PLTub(car(entsel"\nSelecione a polilinha da tubulação: "))
	REG -1 DesTub 0 DesTer 0 Prog 0
	)
  (vla-zoomextents(vlax-get-acad-object))
  (princ"\nAguarde!!! Esta operação irá demorar!!!")
  (setq CoordsSoldaLista(mapcar'(lambda(x)
				  (vlax-get(vlax-ename->vla-object(cadr x))'InsertionPoint)
				  )
			       (ssnamex(ssget"x"'((0 . "insert")(2 . "solda"))))
			       )
	DivisorPranchaLine(mapcar'(lambda(x)
				    (vlax-get(vlax-ename->vla-object(cadr x))'StartPoint)
				    )
				 (ssnamex(ssget"x"'((0 . "line")(8 . "Divisor de Prancha"))))
				 )
	DivisorPranchaText(mapcar'(lambda(x)
				    (list
				      (vlax-get(vlax-ename->vla-object(cadr x))'InsertionPoint)
				      (vlax-get(vlax-ename->vla-object(cadr x))'TextString)
				      )
				    )
				 (ssnamex(ssget"x"'((0 . "text")(8 . "Divisor de Prancha"))))
				 )
	CoordsSoldaLista(vl-sort CoordsSoldaLista'(lambda(x1 x2)(<(car x1)(car x2))))
	DivisorPranchaLine(vl-sort DivisorPranchaLine'(lambda(x1 x2)(<(car x1)(car x2))))
	DivisorPranchaText(vl-sort DivisorPranchaText'(lambda(x1 x2)(<(car(car x1))(car(car x2)))))
	mspace(vla-get-modelspace(vla-get-activedocument(vlax-get-acad-object)))
	arq+(open(setq arq-(strcat(getvar"dwgprefix")"Planilha AsBuilt - "(vl-string-translate".""_"(rtos(getvar"cdate")2 4))".asc"))"w")
	LineSoldaLista nil
	ptLast nil
	n -1
	)
  (vla-zoomextents(vlax-get-acad-object))
  (repeat(length CoordsSoldaLista)
    ;;;Inserção de Linha ->
    (setq pt(nth(setq n(1+ n))CoordsSoldaLista));(vla-addcircle mspace (vlax-3d-point pt)5000)
    (if ptLast;(or ptLast(if ptLast(/=(car pt)(car ptLast))))
      (progn
	(setq
	  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	  line(vla-addline mspace (vlax-3d-point(list(car ptLast)5000)) (vlax-3d-point(list(car ptLast)-12000)))
	  ;LineSoldaLista(vl-list* line LineSoldaLista)
	  ;;;Pega pontos para desenvolvido e Elevação
	  ptInterTub(vlax-invoke(vlax-ename->vla-object PLTub)'IntersectWith line acExtendNone)
	  ptInterTub(list(car ptInterTub)(cadr ptInterTub))
	  ptInterTer(vlax-invoke(vlax-ename->vla-object PLTer)'IntersectWith line acExtendNone)
	  ptInterTer(list(car ptInterTer)(cadr ptInterTer))
	  ElevTub(cadr ptInterTub)ElevTer(cadr ptInterTer)
	  ;;;Elevação Final***************************************Solicitado Pelo Jay
	  lineElvFin(vla-addline mspace (vlax-3d-point(list(car pt)5000)) (vlax-3d-point(list(car pt)-12000)))
	  ElevTubFin(cadr(vlax-invoke(vlax-ename->vla-object PLTub)'IntersectWith lineElvFin acExtendNone))
	  ;;;
	  ;;;Pega distancia desenvolvida
	  Prog(car ptLast)
	  DesTub(vlax-curve-getdistatpoint PLTub(vlax-curve-getClosestPointTo PLTub ptInterTub))
	  DesTer(vlax-curve-getdistatpoint PLTer(vlax-curve-getClosestPointTo PLTer ptInterTer))
	  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	  )
	(entdel(vlax-vla-object->ename line))
	(entdel(vlax-vla-object->ename lineElvFin))
	(setq
	  ;;;Solda
	  InfoSolda(ssget"f"(list ptLast pt)'((0 . "line")(8 . "InfoJuntasLista")))
	  InfoSolda(if InfoSolda(cadr(car(ssnamex InfoSolda))))
	  InfoSolda(if infoSolda(cdr(nth 1(car(cdr(assoc -3(entget InfoSolda'("TXT"))))))))
	  ;;;Espessura
;;;	  InfoEsp(ssget"f"(list ptLast pt)'((0 . "line")(8 . "InfoEspessurasLista")))
;;;	  InfoEsp(if infoEsp(mapcar'(lambda(x)
;;;				      (cdr(nth 1(car(cdr(assoc -3(entget(cadr x)'("TXT")))))))
;;;				      )
;;;				   (ssnamex InfoEsp)
;;;				   )
;;;		   nil
;;;		   )
	  ;;;Jaqueta de Concreto
;;;	  InfoJC(ssget"f"(list ptLast pt)'((0 . "line")(8 . "InfoJCLista")))
;;;	  InfoJC(if InfoJC(mapcar'(lambda(x)
;;;				      (cdr(nth 1(car(cdr(assoc -3(entget(cadr x)'("TXT")))))))
;;;				      )
;;;				   (ssnamex InfoJC)
;;;				   )
;;;		   nil
;;;		   )
	  ;;;Interferencia
	  InfoInter(ssget"f"(list ptLast pt)'((0 . "line")(8 . "InfoInterferenciaLista")))
	  InfoInter(if InfoInter(mapcar'(lambda(x)
				      (cdr(nth 1(car(cdr(assoc -3(entget(cadr x)'("TXT")))))))
				      )
				   (ssnamex InfoInter)
				   )
		   nil
		   )
	  )
	;(princ
	(write-line
	  (strcat
		(rtos(setq REG(1+ REG))2 0)"\t"
		(vl-string-translate"."","(strcat
					    (rtos Prog 2 3)"\t"
					    (rtos DesTub 2 3)"\t"
					    (rtos ElevTub 2 3)"\t";Elevação Inicial do Tubo
					    (rtos ElevTubFin 2 3)"\t";Elevação Final do Tubo
					    (rtos DesTer 2 3)"\t"
					    (rtos ElevTer 2 3)"\t"
					    (rtos(- ElevTer ElevTub)2 3)"\t"
					    )
		  )
		(if InfoSolda InfoSolda"\t\t\t\t\t\t")"\t"
		;(if InfoEsp (car InfoEsp)"")"\t"
		;(if InfoJC (car InfoJC)"")"\t"
		(if InfoInter (car InfoInter)"")"\t";"\n"
		(if(car DivisorPranchaText)
		  (if(<(car pt)(car(car DivisorPranchaLine)))
		    (cadr(car DivisorPranchaText))
		    (progn
		      (setq DivisorPranchaLine(cdr DivisorPranchaLine)
			    DivisorPranchaText(cdr DivisorPranchaText)
			    )
		      (if(cadr(car DivisorPranchaText))(cadr(car DivisorPranchaText))"")
		      )
		    )
		  ""
		  )
		)
	  arq+
	  )
	(setq ptLast pt
	      RegPoint(vla-addpoint mspace (vlax-3d-point ptInterTub))
	      RegText(vla-addtext mspace (strcat"Registro:"(rtos REG 2 0)) (vlax-3d-point ptInterTub) 1)
	      )
	(vlax-put RegPoint 'Color 250)(vlax-put RegText 'Color 250)
	(vlax-put RegPoint 'Layer "SoldaLista")(vlax-put RegText 'Layer "SoldaLista")
	)
      (setq ptLast pt)
      )
    ;;;Inserção de Linha <-

    ;;;Layers -> "InfoJuntasLista" - "InfoEspessurasLista" - "InfoJCLista" - "InfoInterferenciaLista"
    )
  (close arq+)
  (command"notepad"arq-)
  ;(mapcar'(lambda(x)(command"draworder"(vlax-vla-object->ename x)"""back"""))LineSoldaLista)
  (princ)
  )

;(mapcar'(lambda(x)(entdel(cadr x)))(ssnamex(ssget"x"'((0 . "line" )(8 . "SoldaLista")))))

;Informações de Solda quando estão em bloco
(defun c:solda(/ mspace info TxtObjVla TxtObjPt TxtStrList TxtStr LinVla c)
  (entmake'((0 . "LAYER")(100 . "AcDbSymbolTableRecord")(100 . "AcDbLayerTableRecord")(2 . "InfoJuntasLista")(6 . "Continuous")(62 . 250)(70 . 0)))
  (setq mspace(vla-get-modelspace(vla-get-activedocument(vlax-get-acad-object))))
  (while(setq info(ssget'((0 . "insert")(2 . "Inf_Tubos"))))
    (setq info(mapcar'(lambda(x)(cadr x))(ssnamex info)))
    (repeat(1-(length info))
      ;;;
      (setq TxtObjVla(vlax-ename->vla-object(car info))
	    info(cdr info)
	    TxtObjPt(vlax-get TxtObjVla 'InsertionPoint)
	    TxtStrList nil c -1
	    TxtStrList(progn
			(while(setq x(nth(setq c(1+ c))(vlax-safearray->list(vlax-variant-value(vla-getattributes TxtObjVla))))
				    )
			  (setq TxtStrlist(vl-list*(vla-get-textstring x)TxtStrlist))
			  )
			(reverse TxtStrList)
			)
	    TxtStr ""
	    TxtStr(progn(repeat(length TxtStrList)
			  ;(setq TxtStr(strcat TxtStr(car TxtStrList)(if(cadr TxtStrList)" - " ""))
			  (setq TxtStr(strcat TxtStr(car TxtStrList)(if(cdr TxtStrList)"\t"""))
				TxtStrList(cdr TxtStrList)
				)
			  )
		    TxtStr
		    )
	    )
      ;;;
      (setq LinVla(vla-addline mspace (vlax-3d-point(list(car TxtObjPt)5000)) (vlax-3d-point(list(car TxtObjPt)-12000))))
      (vlax-put LinVla 'Color 202)
      (vlax-put LinVla 'Layer "InfoJuntasLista")
      (regapp"TXT")(entmod(append(entget(vlax-vla-object->ename LinVla))(list(cons -3(list(list"TXT"(cons 1000 TxtStr)))))))
      ;;;
      )
    )
  (command"draworder"(ssget"x"'((8 . "InfoJuntasLista")))"""back")
  (princ)
  )

;;;Espessura do Duto
(defun c:esp(/ mspace ptA ptB EspTxt dist d LinEsp)
  (vl-load-com)
  (entmake'((0 . "LAYER")(100 . "AcDbSymbolTableRecord")(100 . "AcDbLayerTableRecord")(2 . "InfoEspessurasLista")(6 . "Continuous")(62 . 250)(70 . 0)))
  (setq mspace(vla-get-modelspace(vla-get-activedocument(vlax-get-acad-object))))
  (while(setq ptA(getpoint"\nClique no ponto inicial das espessuras: "))
    (setq ptB(getpoint ptA"\nClique no ponto final das espessuras: ")
	  EspTxt(vlax-get(vlax-ename->vla-object(car(entsel"\nSelecione o texto das espessuras: ")))'TextString)
	  dist(distance(list(car ptA)0.0)(list(car ptB)0.0))
	  d -1
	  )
    (repeat(1+(abs(fix dist)))
      (setq LinEsp(vla-addline mspace (vlax-3d-point(list(+(car ptA)(setq d(1+ d)))5000))(vlax-3d-point(list(+(car ptA)d)-12000))))
      (vlax-put LinEsp 'Color 30)
      (vlax-put LinEsp 'Layer "InfoEspessurasLista")
      (regapp"TXT")(entmod(append(entget(vlax-vla-object->ename LinEsp))(list(cons -3(list(list"TXT"(cons 1000 EspTxt)))))))
      )
    )
  (command"draworder"(ssget"x"'((8 . "InfoEspessurasLista")))"""back")
  (princ)
  )

;;;Jaqueta de Concreto
(defun c:jc(/ mspace ptA ptB JCTxt dist d LinJC)
  (vl-load-com)
  (entmake'((0 . "LAYER")(100 . "AcDbSymbolTableRecord")(100 . "AcDbLayerTableRecord")(2 . "InfoJCLista")(6 . "Continuous")(62 . 250)(70 . 0)))
  (setq mspace(vla-get-modelspace(vla-get-activedocument(vlax-get-acad-object))))
  (while(setq ptA(getpoint"\nClique no ponto inicial da Jaqueta de Concreto: "))
    (setq ptB(getpoint ptA"\nClique no ponto final da Jaqueta de Concreto: ")
	  JCTxt(vlax-get(vlax-ename->vla-object(car(entsel"\nSelecione o texto da Jaqueta de Concreto: ")))'TextString)
	  ;JCTxt(substr EspTxt (1-(vl-string-search "-" JCTxt)))
	  dist(distance(list(car ptA)0.0)(list(car ptB)0.0))
	  d -1
	  )
    (repeat(1+(abs(fix dist)))
      (setq LinJC(vla-addline mspace (vlax-3d-point(list(+(car ptA)(setq d(1+ d)))5000))(vlax-3d-point(list(+(car ptA)d)-12000))))
      (vlax-put LinJC 'Color 80)
      (vlax-put LinJC 'Layer "InfoJCLista")
      (regapp"TXT")(entmod(append(entget(vlax-vla-object->ename LinJC))(list(cons -3(list(list"TXT"(cons 1000 JCTxt)))))))
      )
    )
  (command"draworder"(ssget"x"'((8 . "InfoJCLista")))"""back")
  (princ)
  )

;;;Interferencia
(defun c:int(/ mspace ptA ptB IntTxt dist d LinInt)
  (vl-load-com)
  (entmake'((0 . "LAYER")(100 . "AcDbSymbolTableRecord")(100 . "AcDbLayerTableRecord")(2 . "InfoInterferenciaLista")(6 . "Continuous")(62 . 250)(70 . 0)))
  (setq mspace(vla-get-modelspace(vla-get-activedocument(vlax-get-acad-object))))
  (while(setq ptA(getpoint"\nClique no ponto inicial da Interferencia: "))
    (setq ptB(getpoint ptA"\nClique no ponto final da Interferencia: ")
	  IntTxt(entsel"\nSelecione o Texto, o Objeto para extrair o layer ou tecle enter para digitar: ")
	  IntTxt(if IntTxt
		  (if(=(vlax-get(vlax-ename->vla-object(car IntTxt))'ObjectName)"AcDbText")
		    (vlax-get(vlax-ename->vla-object(car IntTxt))'TextString)
		    (vlax-get(vlax-ename->vla-object(car IntTxt))'Layer)
		    )
		  (getstring"\Digite o tipo de interferencia: "T)
		  )
	  dist(if ptB(distance(list(car ptA)0.0)(list(car ptB)0.0)))
	  d -1
	  )
    (if ptB
      (repeat(1+(abs(fix dist)))
	(setq LinInt(vla-addline mspace (vlax-3d-point(list(+(car ptA)(setq d(1+ d)))5000))(vlax-3d-point(list(+(car ptA)d)-12000))))
	(vlax-put LinInt 'Color 150)
	(vlax-put LinInt 'Layer "InfoInterferenciaLista")
	(regapp"TXT")(entmod(append(entget(vlax-vla-object->ename LinInt))(list(cons -3(list(list"TXT"(cons 1000 IntTxt)))))))
	)
      (progn
	(setq LinInt(vla-addline mspace(vlax-3d-point(list(car ptA)5000))(vlax-3d-point(list(car ptA)-12000))))
	(vlax-put LinInt 'Color 150)
	(vlax-put LinInt 'Layer "InfoInterferenciaLista")
	(regapp"TXT")(entmod(append(entget(vlax-vla-object->ename LinInt))(list(cons -3(list(list"TXT"(cons 1000 IntTxt)))))))
	)
      )
    )
  (command"draworder"(ssget"x"'((8 . "InfoInterferenciaLista")))"""back")
  (princ)
  )

;Insere Bloco de Solda
(defun c:blksolda(/ mspace ptA ptB vlaSolda n ptS ptE ptI)
  (setq mspace(vla-get-modelspace(vla-get-activedocument(vlax-get-acad-object))))
  (while(setq ptA(getpoint"\nClique no primeiro ponte de seleção das soldas: "))
    (setq ptB(getcorner ptA "\tClique no ponto final: ")
	  vlaSolda(ssget"w"ptA ptB'((0 . "line")))
	  vlaSolda(if vlaSolda(mapcar'(lambda(x)(vlax-ename->vla-object(cadr x)))(cdr(reverse(ssnamex vlaSolda)))))
	  n -1
	  )
    (repeat(length vlaSolda)
      (setq ptS(vlax-get(nth(setq n(1+ n))vlaSolda)'StartPoint)
	    ptE(vlax-get(nth n vlaSolda)'EndPoint)
	    ptI(list(/(+(car ptS)(car ptE))2)(/(+(cadr ptS)(cadr ptE))2))
	    )
      (vla-insertblock mspace(vlax-3d-point ptI)"Solda"1 1 1 0)
      (entdel(vlax-vla-object->ename(nth n vlaSolda)))
      )
    )
  )

;Informações de Solda quando estão em texto
(defun c:isolda(/ SSBjtTxt mspace TxtStr xt LinVla)
  (setvar"cmdecho"0)
  (princ"\nSelecione os textos de informações de juntas: ")
  (while(setq SSBjtTxt(ssget'((0 . "Text"))))
    (setq SSBjtTxt(if SSBjtTxt(mapcar'(lambda(x)(cadr x))(ssnamex SSBjtTxt)))
	  SSBjtTxt(if SSBjtTxt(reverse(cdr(reverse SSBjtTxt))))
	  SSBjtTxt(if SSBjtTxt(mapcar'(lambda(x)(list(vlax-get(vlax-ename->vla-object x)'InsertionPoint)(vlax-get(vlax-ename->vla-object x)'TextString)))SSBjtTxt))
	  SSBjtTxt(if SSBjtTxt(vl-sort SSBjtTxt'(lambda(y1 y2)(>(cadr(car y1))(cadr(car y2))))))
	  )
    ;;;
    (setq mspace(vla-get-modelspace(vla-get-activedocument(vlax-get-acad-object)))
	  TxtStr(mapcar'(lambda(x)(cadr x))SSBjtTxt)
	  TxtStr(strcat(nth 2 TxtStr)"\t"(nth 1 TxtStr)"\t"(nth 0 TxtStr)"\t"(nth 3 TxtStr)"\tNA\tNA\tNA")
	  xT(car(car(car SSBjtTxt)))
	  LinVla(vla-addline mspace(vlax-3d-point(list xT 5000)) (vlax-3d-point(list xT -12000)))
	  )
    (vlax-put LinVla 'Color 202)
    (vlax-put LinVla 'Layer "InfoJuntasLista")
    (regapp"TXT")(entmod(append(entget(vlax-vla-object->ename LinVla))(list(cons -3(list(list"TXT"(cons 1000 TxtStr)))))))
    ;;;
    )
  (setvar"cmdecho"1)
  (command"draworder"(ssget"x"'((8 . "InfoJuntasLista")))"""back")
  (princ)
  )