;(vlisp-compile 'st "C:\\Users\\ericd\\OneDrive\\2 - Work\\1 - TOOLBOX\\Programas\\C3D\\NotasDeServicoCivil3D.LSP" "C:\\Users\\ericd\\OneDrive\\2 - Work\\1 - TOOLBOX\\Programas\\C3D\\NotasDeServicoCivil3D_FreeVersion")
;(vlisp-compile 'st "C:\\Users\\GOMEE11\\Documents\\_LISP\\EDG_Lisps\\NotasDeServicoCivil3D.LSP" "C:\\Users\\GOMEE11\\Documents\\_LISP\\EDG_Lisps\\NotasDeServicoCivil3D_FreeVersion")
(defun c:NotaServico()
  
  ; *** Seleção e Cast ***
  
  ; Ename Entity
  (setq
    Ajuda(progn
	   (initget 11 "Ajuda Continuar")
	   (getkword "\nPrecisa de [Ajuda / Continuar] ? : ")
	   )
    Ajuda(if (= Ajuda "Ajuda")
	   (progn
	     (setq
	       iex(vlax-get-or-create-object "InternetExplorer.Application")
	       )
	     (vla-put-visible iex :vlax-true)
	     (vlax-invoke-method iex 'Navigate2 "https://www.youtube.com/watch?v=a5Olpr-mdCQ")
	     )
	   )
    ExcelIdioma(progn
		 (initget 11 "Portugues Ingles")
		 (getkword "\nQual o idioma do seu excel? [Portugues / Ingles] : ")
		 )
    eTerrenoNatural(car(entsel"\nSelecione o Terreno Natural na Seção : "))
    eGreideProjeto(car(entsel"\tSelecione o Greide de Projeto na Seção : "))
    TerrenoNaturalType(cdr(assoc 0(entget eTerrenoNatural)))
    GreideProjetoType(cdr(assoc 0(entget eGreideProjeto)))
    )

  ;https://support.office.com/en-ie/article/excel-functions-translator-f262d0c0-991c-485b-89b6-32cc8d326889

  ; *** Inicializa Excel ***
  (setq
    excel(vlax-get-or-create-object "Excel.Application")
    )
  ;|
(vlax-dump-object excel t)
(vlax-dump-object (vlax-get excel 'LanguageSettings) t)
|;
  (if (= excel nil)
    (progn
      (alert"Necessário ter o Excel Instalado!!!")
      (quit)
      )
    (princ"\nExcel iniciado com sucesso...")
    )
  ; Configura Planilha
  (setq
    workbooks(vlax-get excel 'workbooks)
    book(vlax-invoke-method workbooks 'add)
    sheets(vlax-get book 'sheets)
    sheet1(vlax-get-property sheets 'Item 1)
    cells(vlax-get sheet1 "cells")
    )
  ; Define Colunas e Linhas
  (setq
    row 1
    col 1
    )

  (vla-put-visible excel :vlax-false)
  ;(vla-put-visible excel :vlax-TRUE)

  (setq
    eltxt(vl-princ-to-string "Elevação")
    dstxt(vl-princ-to-string "Distancia")
    )
  ; *** Cabeçalho ***

  (vlax-put-property cells 'Item row 1 (vl-princ-to-string "ID") )
  (vlax-invoke (vlax-get-property (vlax-get-property sheet1 'Cells) 'Range "A1:B1" ) 'Merge)
  ; OffSet Esquerdo
  (vlax-put-property cells 'Item row 3 (vl-princ-to-string "OffSet Esquerdo") )
  (vlax-invoke (vlax-get-property (vlax-get-property sheet1 'Cells) 'Range "C1:D1" ) 'Merge)
  ; Bordo Esquerdo
  (vlax-put-property cells 'Item row 5 (vl-princ-to-string "Bordo Esquerdo") )
  (vlax-invoke (vlax-get-property (vlax-get-property sheet1 'Cells) 'Range "E1:F1" ) 'Merge)
  ; Eixo
  (vlax-put-property cells 'Item row 7 (vl-princ-to-string "Ponto Central") )
  (vlax-invoke (vlax-get-property (vlax-get-property sheet1 'Cells) 'Range "G1:J1" ) 'Merge)
  ; Bordo Direito
  (vlax-put-property cells 'Item row 11 (vl-princ-to-string "Bordo Direito") )
  (vlax-invoke (vlax-get-property (vlax-get-property sheet1 'Cells) 'Range "K1:L1" ) 'Merge)
  ; OffSet Direito
  (vlax-put-property cells 'Item row 13 (vl-princ-to-string "OffSet Direito") )
  (vlax-invoke (vlax-get-property (vlax-get-property sheet1 'Cells) 'Range "M1:N1" ) 'Merge)

  (setq row(1+ row))
  
  (vlax-put-property cells 'Item row 1 (vl-princ-to-string "Quilometragem"))
  (vlax-put-property cells 'Item row 2 (vl-princ-to-string "ESTACA") )
  ; OffSet Esquerdo
  (vlax-put-property cells 'Item row 3 dstxt )
  (vlax-put-property cells 'Item row 4 eltxt )
  ; Bordo Esquerdo
  (vlax-put-property cells 'Item row 5 dstxt )
  (vlax-put-property cells 'Item row 6 eltxt )
  ; Eixo
  (vlax-put-property cells 'Item row 7 (vl-princ-to-string "Eixo") )
  (vlax-put-property cells 'Item row 8 (vl-princ-to-string "Greide") )
  (vlax-put-property cells 'Item row 9 (vl-princ-to-string "Terreno Natural") )
  (vlax-put-property cells 'Item row 10 (vl-princ-to-string "Cota Vermelha") )
  ; Bordo Direito
  (vlax-put-property cells 'Item row 11 dstxt )
  (vlax-put-property cells 'Item row 12 eltxt )
  ; OffSet Direito
  (vlax-put-property cells 'Item row 13 dstxt )
  (vlax-put-property cells 'Item row 14 eltxt )

  ; Cast To VlaObject de Seleção Base
  (setq
    vTerrenoNatural(vlax-ename->vla-object eTerrenoNatural)
    vGreideProjeto(vlax-ename->vla-object eGreideProjeto)
    TerrenoNaturalGrupoDeSecoes(vlax-get (vlax-get (vlax-get vTerrenoNatural 'Parent) 'Parent) 'DisplayName)
    TerrenoNaturalStyle(vlax-get vTerrenoNatural 'StyleName)
    GreideProjetoGrupoDeSecoes(vlax-get (vlax-get (vlax-get vGreideProjeto 'Parent) 'Parent) 'DisplayName)
    GreideProjetoStyle(vlax-get vGreideProjeto 'StyleName)
    )
  
  ; Seleção de de Todas as Seções e Cast para VlaObject
  (setq
    eTerrenoList(ssnamex(ssget"x"(list(cons 0 TerrenoNaturalType))))
    vTerrenoList nil
    eGreideList(ssnamex(ssget"x"(list(cons 0 GreideProjetoType))))
    vGreideList nil
    )

  (foreach GP eGreideList
    (setq
      vG(vlax-ename->vla-object (cadr GP))
      )
    (if (and (= (vlax-get(vlax-get(vlax-get vG 'Parent)'Parent)'DisplayName) GreideProjetoGrupoDeSecoes)  (=(vlax-get vG 'StyleName) GreideProjetoStyle) )
      (setq vGreideList (vl-list* vG vGreideList))
      (princ)
      )
    )
  
  (foreach TN eTerrenoList
    (setq
      vT(vlax-ename->vla-object (cadr TN))
      )
    (if (and (= (vlax-get(vlax-get(vlax-get vT 'Parent)'Parent)'DisplayName) TerrenoNaturalGrupoDeSecoes) (=(vlax-get vT 'StyleName) TerrenoNaturalStyle) )
      (setq vTerrenoList (vl-list* vT vTerrenoList))
      (princ)
      )
    )

  ; *** Seleção de Dados ***

  ;;; Inicio do Bloco

  (setq SecCount 0
	)

  (foreach secGRD vGreideList
    (progn
      (setq SideCount 0 Total(vlax-get(vlax-get secGRD 'Links)'Count) Km(vlax-get secGRD 'Station)
	    OffSetEsq nil
	    OffSetDir nil
;;;	    OffSetEsq(list
;;;		       (vlax-get(vlax-invoke-method (vlax-get secGRD 'Links) 'Item 1)'StartPointX)
;;;		       (vlax-get(vlax-invoke-method (vlax-get secGRD 'Links) 'Item 1)'StartPointY)
;;;		       )
;;;	    OffSetDir(list
;;;		       (vlax-get(vlax-invoke-method (vlax-get secGRD 'Links) 'Item (- total 2))'EndPointX)
;;;		       (vlax-get(vlax-invoke-method (vlax-get secGRD 'Links) 'Item (- total 2))'EndPointY)
;;;		       )
	    EsqPoints nil DirPoints nil EchoPoint nil
	    )
      (foreach x vTerrenoList
	(setq c -1
	      tt(vlax-get(vlax-get x 'Links)'Count)
	      )
	(repeat (1- tt)
	  (if(=(vlax-get x 'Station) km)
	    (if (= (read(rtos (vlax-get(vlax-invoke-method (vlax-get x 'Links) 'Item (setq c(1+ c)) )'EndPointX) 2 3)) 0)
	      (setq CotaNatural(list
				 (vlax-get(vlax-invoke-method (vlax-get x 'Links) 'Item c) 'EndPointX)
				 (vlax-get(vlax-invoke-method (vlax-get x 'Links) 'Item c) 'EndPointY)
				 )
		    )
	      )
	    )
	  )
	)
      
      (repeat Total;(- Total 2)

	(cond
	  (
	   (= (read(rtos (vlax-get(vlax-invoke-method (vlax-get secGRD'Links) 'Item SideCount)'EndPointX) 2 3)) 0)
	   (if
	     (and
		(>= (vlax-get(vlax-invoke-method (vlax-get secGRD 'Links) 'Item SideCount) 'EndPointX) (vlax-get secGRD 'LengthLeft) )
		(<= (vlax-get(vlax-invoke-method (vlax-get secGRD 'Links) 'Item SideCount) 'EndPointX) (vlax-get secGRD 'LengthRight))
		)
	     (setq
	       EchoPoint(vl-list*
			  (list
			    (vlax-get(vlax-invoke-method (vlax-get secGRD 'Links) 'Item SideCount) 'EndPointX)
			    (vlax-get(vlax-invoke-method (vlax-get secGRD 'Links) 'Item SideCount) 'EndPointY)
			    )
			  EchoPoint
			  )
	       )
	     )
	   )
	  (
	   (< (vlax-get(vlax-invoke-method (vlax-get secGRD 'Links) 'Item SideCount)'EndPointX) 0)
	   (if
	     (and
		(>= (vlax-get(vlax-invoke-method (vlax-get secGRD 'Links) 'Item SideCount) 'EndPointX) (vlax-get secGRD 'LengthLeft) )
		(<= (vlax-get(vlax-invoke-method (vlax-get secGRD 'Links) 'Item SideCount) 'EndPointX) (vlax-get secGRD 'LengthRight))
		)
	     (if (= OffSetEsq nil)
	       (setq
		 OffSetEsq(list
			    (vlax-get(vlax-invoke-method (vlax-get secGRD 'Links) 'Item SideCount) 'EndPointX)
			    (vlax-get(vlax-invoke-method (vlax-get secGRD 'Links) 'Item SideCount) 'EndPointY)
		       )
		 )
	       (setq
		 EsqPoints(vl-list*
			    (list
			      (vlax-get(vlax-invoke-method (vlax-get secGRD 'Links) 'Item SideCount) 'EndPointX)
			      (vlax-get(vlax-invoke-method (vlax-get secGRD 'Links) 'Item SideCount) 'EndPointY)
			      )
			    EsqPoints
			    )
		 )
	       )
	     )
	   )
	  (
	   (> (vlax-get(vlax-invoke-method (vlax-get secGRD 'Links) 'Item SideCount)'EndPointX) 0)
	   (if
	     (and
		(>= (vlax-get(vlax-invoke-method (vlax-get secGRD 'Links) 'Item SideCount) 'EndPointX) (vlax-get secGRD 'LengthLeft) )
		(<= (vlax-get(vlax-invoke-method (vlax-get secGRD 'Links) 'Item SideCount) 'EndPointX) (vlax-get secGRD 'LengthRight))
		)
	     (if (= OffSetDir nil)
	       (setq
		 OffSetDir(list
			    (vlax-get(vlax-invoke-method (vlax-get secGRD 'Links) 'Item SideCount) 'EndPointX)
			    (vlax-get(vlax-invoke-method (vlax-get secGRD 'Links) 'Item SideCount) 'EndPointY)
		       )
		 )
	       (setq
		 DirPoints(vl-list*
			    OffSetDir
;;;			    (list
;;;			      (vlax-get(vlax-invoke-method (vlax-get secGRD 'Links) 'Item SideCount) 'EndPointX)
;;;			      (vlax-get(vlax-invoke-method (vlax-get secGRD 'Links) 'Item SideCount) 'EndPointY)
;;;			      )
			    DirPoints
			    )
		 OffSetDir(list
			    (vlax-get(vlax-invoke-method (vlax-get secGRD 'Links) 'Item SideCount) 'EndPointX)
			    (vlax-get(vlax-invoke-method (vlax-get secGRD 'Links) 'Item SideCount) 'EndPointY)
		       )
		 )
	       )
	     )
	   )
	  )

	(setq SideCount(1+ SideCount))

	)
      (setq
	row(1+ row)
	;col(1+ col)
	LeftRow row
	RightRow row
	;EsqPoints(reverse EsqPoints)
	DirPoints(reverse DirPoints)
	Station(if(= ExcelIdioma "Portugues")
		 (strcat "=CONCATENAR((TRUNCAR((SE(ÉIMPAR(INT(A"(rtos row 2 0)"/10));((INT(A"(rtos row 2 0)"/10)/2));(INT(A"(rtos row 2 0)"/20))));0));\"+\";((ARRED(((A"(rtos row 2 0)"/10)-(INT(A"(rtos row 2 0)"/10)))*10;3))+(SE((ÉIMPAR(INT(A"(rtos row 2 0)"/10)));10;0))))")
		 (strcat "=CONCATENATE((TRUNC((IF(ISODD(INT(A"(rtos row 2 0)"/10));((INT(A"(rtos row 2 0)"/10)/2));(INT(A"(rtos row 2 0)"/20))));0));\"+\";((ROUND(((A"(rtos row 2 0)"/10)-(INT(A"(rtos row 2 0)"/10)))*10;3))+(IF((ISODD(INT(A"(rtos row 2 0)"/10)));10;0))))")
		 )
	)
      ; Identificações
      (vlax-put-property cells 'Item row 1 Km)
      (vlax-put-property cells 'Item row 2 Station ); Estaca
      ; OffSet Esquerdo
      (vlax-put-property cells 'Item row 3 (nth 0 OffSetEsq) )
      (vlax-put-property cells 'Item row 4 (nth 1 OffSetEsq) )
      ; Bordo Esquerdo
      (foreach bordo EsqPoints
	(vlax-put-property cells 'Item LeftRow 5 (car bordo) )
	(vlax-put-property cells 'Item LeftRow 6 (cadr bordo) )
	(if bordo
	  (setq LeftRow(1+ LeftRow))
	  )
	)
      ; Eixo
      (vlax-put-property cells 'Item row 7 (vl-princ-to-string (rtos(nth 0 (car EchoPoint))2 0)) ) ; Eixo
      (vlax-put-property cells 'Item row 8 (nth 1 (car EchoPoint)) ) ; Cota de Projeto
      (vlax-put-property cells 'Item row 9 (cadr CotaNatural) ) ; Terreno Natural
      (vlax-put-property cells 'Item row 10 (read(rtos(- (nth 1 (car EchoPoint)) (cadr CotaNatural) )2 3)) ) ; Cota Vermelha
      ; Bordo Direito
      (foreach bordo DirPoints
	(vlax-put-property cells 'Item RightRow 11 (car bordo) )
	(vlax-put-property cells 'Item RightRow 12 (cadr bordo) )
	(if bordo
	  (setq RightRow(1+ RightRow))
	  )
	)
      ; OffSet Direito
      (vlax-put-property cells 'Item row 13 (nth 0 OffSetDir) )
      (vlax-put-property cells 'Item row 14 (nth 1 OffSetDir) )

      (setq row(max (1- LeftRow) (1- RightRow)))
      (setq SecCount (1+ SecCount))
      )
    )

  (vla-put-visible excel :vlax-true)
  (princ"\nProcesso Finalizado...")
  (princ)
  )

(princ "\tO Comando é NotaServico...")