(defun c:HatchSecaoGeo ( / *error* cad doc space)


;;; ------------------------------------------------------
;;; ----Por Eric Drumond : egomes@telluscompany.com.br----
;;; ------------------------------------------------------


  (setq
    cad(vlax-get-acad-object)
    doc(vla-get-activedocument cad)
    space(vla-get-modelspace doc)
    myReport(strcat (getvar'dwgprefix) "report.log")
    user(vl-registry-read "HKEY_CURRENT_USER\\VOLATILE ENVIRONMENT" "USERNAME")
    date(rtos(getvar"cdate")2 6)
  )
  
  ; (defun *error*(msg)
  ;   (setq
  ;     reportFile(open myReport "a+")
  ;     ErrorTextReport(strcat "Usuario : " user " \\ App : HatchSecaoGeo \\ " date " \\ Descricao de Erro : " msg)
  ;   )
  ;   (print ErrorTextReport reportFile)
  ;   (close reportFile)
  ;   (vla-endUndoMark doc)
  ;   (princ)
  ; )
  
  (defun main()
    (princ "\n\n\n\tSelecione os poligonos da secao : ")
    (setq
      ss(ssget '((0 . "*polyline")))
      DrawOrder(vla-addObject (vla-getextensiondictionary space) "ACAD_SORTENTS" "AcDbSortentsTable")
     )
    (foreach item (ssnamex ss)
      (if
        (>= (car item) 0)
        (progn
          (setq
            vlao(vlax-ename->vla-object (cadr item))
            layer(vla-get-layer vlao)
            color(vla-get-color vlao)
            hatch(vla-addhatch space acHatchPatternTypePredefined "SOLID" :vlax-true)
          )
          (vlax-put vlao 'Closed 1)
          (vlax-invoke hatch 'AppendOuterLoop (list vlao))
          (vla-evaluate hatch)
          (vla-put-color hatch color)
          (vla-put-layer hatch layer)
          (vlax-invoke DrawOrder 'MoveToBottom (list hatch))
          (setq hatch(vlax-release-object hatch))
        )
      )
    )
  )

  (vla-startundomark doc)
	(setvar 'cmdecho 0)
	(main)
  (vla-Regen doc :vlax-true)
	(setvar 'cmdecho 1)
	(vla-endundomark doc)
	(princ)
  
)