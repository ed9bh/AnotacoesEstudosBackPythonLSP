(defun c:mp(/ Folder SubFolderList File N l mp_r mp_w C)
  (vl-load-com)(setvar"sdi"1)(setvar"lispinit"0)
  (setq Folder"S:\\Proj\\1014-01-MANABI\\CAD\\WORK AREA\\J\\Folhas de Alinhamento"
	SubFolderList(cdr(cdr(vl-directory-files Folder nil -1)))
	)
  ;;;Inicio Memoria
  (if(findfile"S:\\Proj\\1014-01-MANABI\\CAD\\WORK AREA\\J\\Checklist\\mp_SubFolderList.asc")
    (progn
      (setq mp_r(open"S:\\Proj\\1014-01-MANABI\\CAD\\WORK AREA\\J\\Checklist\\mp_SubFolderList.asc""r")
	    SubFolderList nil
	    )
      (while(setq l(read-line mp_r))
	(setq SubFolderList(vl-list* l SubFolderList))
	)
      (setq SubFolderList(reverse SubFolderList))
      (close mp_r)
      )
    (progn
      (setq mp_w(open"S:\\Proj\\1014-01-MANABI\\CAD\\WORK AREA\\J\\Checklist\\mp_SubFolderList.asc""w")
	    C -1
	    )
      (repeat(length SubFolderList)(write-line(nth(setq C(1+ c))SubFolderList)mp_w))
      (close mp_w)
      )
    )
  ;;;Final Memoria
  (repeat(length SubFolderList)
    (setq N 10)
    ;;;
    (mapcar
      '(lambda(x)(vl-file-rename(strcat Folder"\\"(car SubFolderList)"\\"x)(strcat Folder"\\"(car SubFolderList)"\\"(substr x 1 (-(strlen x)4))".gpj")))
      (vl-directory-files(strcat Folder"\\"(car SubFolderList))"*.jpg"1))
    (mapcar
      '(lambda(x)(vl-file-rename(strcat Folder"\\"(car SubFolderList)"\\"x)(strcat Folder"\\"(car SubFolderList)"\\"(substr x 1 (-(strlen x)4))".wce")))
      (vl-directory-files(strcat Folder"\\"(car SubFolderList))"*.ecw"1))
    ;;;
    (while(=(setq File(vl-directory-files(strcat Folder"\\"(car SubFolderList))(strcat"*R"(rtos(setq N(1- N))2 0)".dwg")1))nil))
    (command"open"(strcat Folder"\\"(car SubFolderList)"\\"(car File)))
    ;;;========>Comandos
    ;(espcaso)
    ;(desref)
    (kmIniFin)
    (vol)
    ;(nota6)
    ;(nota7)
    ;;;<================
    ;;;
    (mapcar'(lambda(x)(vl-file-rename(strcat Folder"\\"(car SubFolderList)"\\"x)(strcat Folder"\\"(car SubFolderList)"\\"(substr x 1 (-(strlen x)4))".jpg")))
	   (vl-directory-files(strcat Folder"\\"(car SubFolderList))"*.gpj"1))
    (mapcar'(lambda(x)(vl-file-rename(strcat Folder"\\"(car SubFolderList)"\\"x)(strcat Folder"\\"(car SubFolderList)"\\"(substr x 1 (-(strlen x)4))".ecw")))
	   (vl-directory-files(strcat Folder"\\"(car SubFolderList))"*.wce"1))
    ;;;
    (vla-zoomextents(vlax-get-acad-object))
    (command"layout""set"(car(layoutlist)))
    (vla-zoomextents(vlax-get-acad-object))
    (command"qsave")
;;;    (if(findfile(strcat Folder"\\"(car SubFolderList)"\\""EDG-TESTE-LISP.dwg"))
;;;      (vl-file-delete(strcat Folder"\\"(car SubFolderList)"\\""EDG-TESTE-LISP.dwg"))
;;;      )
;;;    (setvar"filedia"0)(command"saveas""LT2007"(strcat Folder"\\"(car SubFolderList)"\\""EDG-TESTE-LISP.dwg"))(setvar"filedia"1)
    ;;;
    (setq mp_w(open"S:\\Proj\\1014-01-MANABI\\CAD\\WORK AREA\\J\\Checklist\\mp_SubFolderList.asc""w")C -1)
    (repeat(length SubFolderList)(write-line(nth(setq C(1+ c))SubFolderList)mp_w))(close mp_w)
    (setq SubFolderList(cdr SubFolderList))
    )
  (vl-file-delete"S:\\Proj\\1014-01-MANABI\\CAD\\WORK AREA\\J\\Checklist\\mp_SubFolderList.asc")
  (setvar"sdi"0)(setvar"lispinit"1)(command"close")
  (princ)
  )
;|
(mapcar'(lambda(x)(vl-file-delete(strcat"S:\\Proj\\1014-01-MANABI\\CAD\\WORK AREA\\J\\Folhas de Alinhamento\\" x "\\EDG-TESTE-LISP.dwg")))
       (cdr(cdr(vl-directory-files "S:\\Proj\\1014-01-MANABI\\CAD\\WORK AREA\\J\\Folhas de Alinhamento" nil -1)))
       )
(vl-file-delete"S:\\Proj\\1014-01-MANABI\\CAD\\WORK AREA\\J\\Checklist\\mp_SubFolderList.asc")
(setvar"sdi"0)(setvar"lispinit"1)
|;



;;;========================================================================================================
;;;========================================================================================================
;;;========================================================================================================
;;;========================================================================================================
;;;========================================================================================================
;;;========================================================================================================
;;;========================================================================================================
;;;Altera Volume===========================================================================================
;;;========================================================================================================
(defun vol(/ arq dwgname volume name vparc vacum l vpOld blk kmatt)
  (vl-load-com)(setvar"cmdecho"0)
  (command"layout""set"(car(layoutlist)))
  (vla-zoomwindow(vlax-get-acad-object)(vlax-3d-point'(860.902 438.529))(vlax-3d-point'(1055.744 460.142)))
  (setq arq(open"S:\\Proj\\1014-01-MANABI\\CAD\\WORK AREA\\J\\Checklist\\volumes.txt""r")
	dwgname(substr(getvar"dwgname") 1 23)
	volume nil
	)
  (while(setq l(read-line arq))
    (setq name(substr l 1(vl-string-search"\t"l))
	  l(substr l(+(vl-string-search"\t"l)2)(strlen l))
	  vparc(read(vl-string-translate",""."(substr l 1(vl-string-search"\t"l))))
	  l(substr l(+(vl-string-search"\t"l)2)(strlen l))
	  vacum(read(vl-string-translate",""."(substr l 1(vl-string-search"\t"l))))
	  )
    (if(= dwgname name)(setq volume(list name vparc vacum)))
    )
  (close arq)
  ;;;
  (setq vpOld(vlax-get(vlax-ename->vla-object(ssname(ssget"w"'(1017.138 447.995)'(1041.000 452.995)'((0 . "text")))0))'TextString)
	vaOld(vlax-get(vlax-ename->vla-object(ssname(ssget"w"'(1017.138 442.995)'(1041.000 447.995)'((0 . "text")))0))'TextString)
	)
  ;;;
  (vlax-put(vlax-ename->vla-object(ssname(ssget"w"'(1017.138 447.995)'(1041.000 452.995)'((0 . "text")))0))'TextString(vl-string-translate"."","(rtos(cadr volume)2 3)))
  (vlax-put(vlax-ename->vla-object(ssname(ssget"w"'(1017.138 442.995)'(1041.000 447.995)'((0 . "text")))0))'TextString(vl-string-translate"."","(rtos(caddr volume)2 3)))
  (setq blk(vlax-ename->vla-object(ssname(ssget"x"'((0 . "insert")(2 . "CARIMBO MANABI")))0)))
  (setq kmatt(if(=(substr(vla-get-textstring(nth 4(vlax-safearray->list(vlax-variant-value(vla-getattributes blk)))))1 20)"FOLHA DE ALINHAMENTO")
	       (substr(vla-get-textstring(nth 4(vlax-safearray->list(vlax-variant-value(vla-getattributes blk)))))22)
	       (substr(vla-get-textstring(nth 4(vlax-safearray->list(vlax-variant-value(vla-getattributes blk)))))16)
	       )
	)
  (vlax-put(vlax-ename->vla-object(ssname(ssget"w"'(866.340 448.443)'(1006.713 452.820)'((0 . "text,mtext")))0))'TextString(strcat"VOLUME DE CORTE "kmatt))
  (setvar"cmdecho"1)(princ)
  )




;;;========================================================================================================
;;;========================================================================================================
;;;========================================================================================================
;;;========================================================================================================
;;;========================================================================================================
;;;========================================================================================================
;;;========================================================================================================
;;;Altera o Km Inicial e Final do Perfil e do Carimbo======================================================
;;;========================================================================================================
(defun kmIniFin(/ txts coords pt PROGINI DESEINI PROGFIN DESEFIN DESEFOL
		l name ProgIniTxt DeseIniTxt ProgFinTxt DeseFinTxt DeseFolTxt
		arq vlaMSpace dwgname blk
		)
  (vl-load-com)
  (command"layout""set""model")(command"-vports""single")(command"ucs""")(command"plan""")(vla-zoomextents(vlax-get-acad-object))
  ;;;===========================================================================================
  (setq vlaMSpace(vla-get-modelspace(vla-get-activedocument(vlax-get-acad-object)))
	arq(open"S:\\Proj\\1014-01-MANABI\\CAD\\WORK AREA\\J\\Checklist\\km_prog_volume.txt""r")
	dwgname(substr(getvar"dwgname") 1 23)
	)
  (while(setq l(read-line arq))
    (setq name(substr l 1(vl-string-search"\t"l))l(substr l(+(vl-string-search"\t"l)2)(strlen l))
	  ProgIniTxt(substr l 1(vl-string-search"\t"l))l(substr l(+(vl-string-search"\t"l)2)(strlen l))
	  ProgFinTxt(substr l 1(vl-string-search"\t"l))l(substr l(+(vl-string-search"\t"l)2)(strlen l))
	  DeseIniTxt(substr l 1(vl-string-search"\t"l))l(substr l(+(vl-string-search"\t"l)2)(strlen l))
	  DeseFinTxt(substr l 1(vl-string-search"\t"l))
	  ;
	  l(substr l(+(vl-string-search"\t"l)2)(strlen l))
	  DeseFolTxt(substr l 1(vl-string-search"\t"l))
	  )
    (if(= dwgname name)(setq kmIniFinTXT(list name ProgIniTxt DeseIniTxt ProgFinTxt DeseFinTxt DeseFolTxt)))
    )
  (close arq)
  ;;;===========================================================================================
  (setq txts(mapcar'(lambda(x)(cadr x))(ssnamex(ssget"x"'((0 . "TEXT")(1 . "PROGRESSIVA (km),DESENVOLVIDA (km)")))))
	coords(mapcar'(lambda(x)(cdr(assoc 10(entget x))))txts)
	pt(list(min(car(nth 0 coords))(car(nth 1 coords)))(min(cadr(nth 0 coords))(cadr(nth 1 coords)))))
  (setq PROGINI(vlax-ename->vla-object(cadr(nth 0(ssnamex(ssget"w"(list(+(car pt)57.953)(+(cadr pt)8.322))(list(+(car pt)264.807)(+(cadr pt)20.322))'((0 . "text")))))))
	DESEINI(vlax-ename->vla-object(cadr(nth 0(ssnamex(ssget"w"(list(+(car pt)57.953)(+(cadr pt)-3.678))(list(+(car pt)264.807)(+(cadr pt)8.322))'((0 . "text")))))))
	PROGFIN(vlax-ename->vla-object(cadr(nth 0(ssnamex(ssget"w"
							       ;(list(+(car pt)1864.807)(+(cadr pt)8.322))
							       ;(list(+(car pt)2064.807)(+(cadr pt)20.322))
							       (list(+(car pt)1200.0)(+(cadr pt)8.322))
							       (list(+(car pt)2700.0)(+(cadr pt)20.322))
							       '((0 . "text")))))))
	DESEFIN(vlax-ename->vla-object(cadr(nth 0(ssnamex(ssget"w"
							       ;(list(+(car pt)1864.807)(+(cadr pt)-3.678))
							       ;(list(+(car pt)2064.807)(+(cadr pt)8.322))
							       (list(+(car pt)1200.0)(+(cadr pt)-3.678))
							       (list(+(car pt)2700.0)(+(cadr pt)8.322))
							       '((0 . "text")))))))
	;DESEFOL(vlax-ename->vla-object(cadr(nth 0(ssnamex(ssget"w"(list(+(car pt)62.807)(+(cadr pt)-71.679))(list(+(car pt)2066.807)(+(cadr pt)-51.679))'((0 . "text")))))))
	)
  ;ProgIni
  (vla-put-textstring PROGINI(vl-string-translate".""+"(nth 1 kmIniFinTXT)))
  (vla-put-alignment PROGINI acAlignmentLeft)
  (vla-put-InsertionPoint PROGINI(vlax-3d-point(list(+(car pt)71.259)(+(cadr pt)12.472))))
  ;DeseIni
  (vla-put-textstring DESEINI(vl-string-translate".""+"(nth 2 kmIniFinTXT)))
  (vla-put-alignment DESEINI acAlignmentLeft)
  (vla-put-InsertionPoint DESEINI(vlax-3d-point(list(+(car pt)71.259)(+(cadr pt)0.472))))
  ;ProgFin
  (vla-put-textstring PROGFIN(vl-string-translate".""+"(nth 3 kmIniFinTXT)))
  (vla-put-alignment PROGFIN acAlignmentRight)
  (vla-put-textalignmentpoint PROGFIN(vlax-3d-point(list(+(car pt)2060.460)(+(cadr pt)12.307))))
  ;DeseFin
  (vla-put-textstring DESEFIN(vl-string-translate".""+"(nth 4 kmIniFinTXT)))
  (vla-put-alignment DESEFIN acAlignmentRight)
  (vla-put-textalignmentpoint DESEFIN(vlax-3d-point(list(+(car pt)2060.460)(+(cadr pt)0.307))))
  ;DeseFol - Removido pois não funcionaria em todas as folhas
  ;(vla-put-textstring DESEFOL(vl-string-translate".""+"(nth 5 kmIniFinTXT)))
  ;;;===========================================================================================
  ;;;km Carimbo do Formato
  (setq blk(vlax-ename->vla-object(ssname(ssget"x"'((0 . "insert")(2 . "CARIMBO MANABI")))0)))
  (vla-put-textstring(nth 4(vlax-safearray->list(vlax-variant-value(vla-getattributes blk))))
    (strcat"FLH. DE ALINH. km"
	   (vl-string-translate".""+"(nth 1 kmIniFinTXT))
	   " AO km"
	   (vl-string-translate".""+"(nth 3 kmIniFinTXT))
	   )
    )
  )
  ;(vla-addpoint vlaMSpace (vlax-3d-point pt))
  ;|
  (vla-addline vlaMSpace (vlax-3d-point(list(+(car pt)57.953)(+(cadr pt)8.322)))
                         (vlax-3d-point(list(+(car pt)264.807)(+(cadr pt)20.322)))
                         )
  |;



;;;========================================================================================================
;;;========================================================================================================
;;;========================================================================================================
;;;========================================================================================================
;;;========================================================================================================
;;;========================================================================================================
;;;========================================================================================================
;;;INCLUI NOTA 6 7 Altera Desenho de referencia============================================================
;;;========================================================================================================
(defun nota6(/ nota)
  (command"layout""set"(car(layoutlist)))(vla-zoomextents(vlax-get-acad-object))
  (setq nota(ssget"x"'((0 . "MTEXT")
		       (1 . "\\P3- MERIDIANO CENTRAL: 45 º W\\P4- DATUM VERTICAL: IMBITUBA - SC\\P5- DATUM HORIZONTAL: SAD 69}")
		       )
		  )
	nota(if nota(vlax-ename->vla-object(cadr(car(ssnamex nota))))nil)
	)
  (if nota
    (vlax-put nota 'TextString(strcat
				(setq txt(vl-string-right-trim"}"(vlax-get nota 'TextString)))
				(strcase"\\P6- Não foi fornecido o levantamento cadastral das interferências para a elaboração das Folhas de Alinhamento, portanto a localização das interferências poderá sofrer alterações após o cadastro no local.}")
				)
	      )
    )
  );(cdr(assoc 1(entget(car(entsel)))))

(defun nota7(/ nota)
  (command"layout""set"(car(layoutlist)))(vla-zoomextents(vlax-get-acad-object))
  (setq nota(ssget"x"'((0 . "MTEXT")
		       (1 . "MERIDIANO CENTRAL: 45 º W\\P4- DATUM VERTICAL: IMBITUBA - SC\\P5- DATUM HORIZONTAL: SAD 69\\P6- AGUARDANDO LEVANTAMENTO TOPOGRÁFICO.")
		       )
		  )
	nota(if nota(vlax-ename->vla-object(cadr(car(ssnamex nota))))nil)
	)
  (if nota
    (vlax-put nota 'TextString(strcat
				(setq txt(vlax-get nota 'TextString))
				(strcase"\\P7- Não foi fornecido o levantamento cadastral das interferências para a elaboração das Folhas de Alinhamento, portanto a localização das interferências poderá sofrer alterações após o cadastro no local.}")
				)
	      )
    )
  )

(defun desref()
  (setq txtref(ssget"x"'((0 . "mtext")(1 . "{\\W1;1- O LEVANTAMENTO TOPOGRÁFICO E AS ORTOFOTOS FORAM FORNECIDAS PELA MANABI.\\P2- CRITÉRIO DE PROJETO Nº CP-300-01-03-3000-PR-AUS-0001.}")))
	)
  (if txtref(vlax-put(vlax-ename->vla-object(cadr(car(ssnamex txtref))))'TextString
		    "1- AS CURVAS DE NIVEL E AS ORTOFOTOS FORAM FORNECIDAS PELA MANABI.\\P2- CRITÉRIO DE PROJETO Nº CP-300-01-03-3000-PR-AUS-0001."
		    )
    )
  )


(defun espcaso()
  ;;;Caso Especial
  (command"bedit""CARIMBO MANABI")
  (vlax-put(vlax-ename->vla-object(ssname(ssget"x"'((0 . "attdef")(10 -183.5 12.5 0.0)))0))'ScaleFactor 0.9)
  (vlax-put(vlax-ename->vla-object(ssname(ssget"x"'((0 . "attdef")(10 -183.5 28.5 0.0)))0))'ScaleFactor 0.875)
  (command"bsave""bclose")(command"attsync""s"(ssname(ssget"x"'((0 . "insert")(2 . "CARIMBO MANABI")))0)"")
  (if(and(tblsearch"layer""image")(tblsearch"layer""imagem"))(progn
							       (mapcar
								 '(lambda(x)(vlax-put(vlax-ename->vla-object(cadr x))'Layer "image"))
								 (ssnamex(ssget"x"'((8 . "imagem"))))
								 )
							       (command"-purge""la""imagem""n")
							       )
    )
  (if(tblsearch"layer""image")(command"rename""layer""image""imagem"""))
  ;;;Alterar todos os layers pra maiusculo
  (vlax-for layer(vla-get-layers(vla-get-activedocument(vlax-get-acad-object)))
    (vl-catch-all-apply(function(lambda(/ name)(setq name(vla-get-name layer))(vla-put-name layer(strcase name))))))
  ;;;
  ;;;Caso Especial
  )

(defun c:mpsingle()
  (command"undo""be")
  (espcaso)
  (desref)
  (kmIniFin)
  (vol)
  (nota6)
  (nota7)
  (command"undo""e")
  (princ)
  )


;|
(vlax-dump-object(vlax-ename->vla-object(car(entsel)))t)


(VLA-PUT-WIDTH(nth 4(vlax-safearray->list(vlax-variant-value(vla-getattributes(vlax-ename->vla-object(ssname(ssget"x"'((0 . "insert")(2 . "CARIMBO MANABI")))0))))))0.9)

(vlax-dump-object
  (nth 4(vlax-safearray->list(vlax-variant-value(vla-getattributes(vlax-ename->vla-object(ssname(ssget"x"'((0 . "insert")(2 . "CARIMBO MANABI")))0))))))
  t)


(VLA-PUT-WIDTH(vlax-ename->vla-object(car(entsel)))0.9)

(vlax-put(vlax-ename->vla-object(car(entsel)))'MTextBoundaryWidth 0.9)

(entget(car(entsel)))


|;

(defun c:mpreset()
  (mapcar'(lambda(x)(vl-file-delete(strcat"S:\\Proj\\1014-01-MANABI\\CAD\\WORK AREA\\J\\Folhas de Alinhamento\\" x "\\EDG-TESTE-LISP.dwg")))
	 (cdr(cdr(vl-directory-files "S:\\Proj\\1014-01-MANABI\\CAD\\WORK AREA\\J\\Folhas de Alinhamento" nil -1)))
	 )
  (vl-file-delete"S:\\Proj\\1014-01-MANABI\\CAD\\WORK AREA\\J\\Checklist\\mp_SubFolderList.asc")
  (setvar"sdi"0)(setvar"lispinit"1)
  )

(defun c:mpglist()
  (setq Folder"S:\\Proj\\1014-01-MANABI\\CAD\\WORK AREA\\J\\Folhas de Alinhamento"
	SubFolderList(cdr(cdr(vl-directory-files Folder nil -1)))
	)
  ;;;Inicio Memoria
  (if(findfile"S:\\Proj\\1014-01-MANABI\\CAD\\WORK AREA\\J\\Checklist\\mp_SubFolderList.asc")
    (progn
      (setq mp_r(open"S:\\Proj\\1014-01-MANABI\\CAD\\WORK AREA\\J\\Checklist\\mp_SubFolderList.asc""r")
	    SubFolderList nil
	    )
      (while(setq l(read-line mp_r))
	(setq SubFolderList(vl-list* l SubFolderList))
	)
      (setq SubFolderList(reverse SubFolderList))
      (close mp_r)
      )
    (progn
      (setq mp_w(open"S:\\Proj\\1014-01-MANABI\\CAD\\WORK AREA\\J\\Checklist\\mp_SubFolderList.asc""w")
	    C -1
	    )
      (repeat(length SubFolderList)(write-line(nth(setq C(1+ c))SubFolderList)mp_w))
      (close mp_w)
      )
    )
  )











;;;(vlax-for layer(vla-get-layers(vla-get-activedocument(vlax-get-acad-object)))
;;;  (if(=(vla-get-name layer)"0")
;;;    (princ)
;;;    (vlax-put layer 'Name (strcat"teste-"(vla-get-name layer)))
;;;    )
;;;  )