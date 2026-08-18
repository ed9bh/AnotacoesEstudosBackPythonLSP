(defun excel-load-com (/ *error* moduleError acad doc model)
  
  (defun *error* (msg)
    (princ msg)
    (princ (strcat "\n\t Erro no modulo : " (nth moduleError moduleList) ))
    (vla-endundomark doc)
    (princ)
  )
  
  (setq
    acad (vlax-get-acad-object)
    doc (vla-get-activedocument acad)
    model (vla-get-modelspace doc)
    moduleError -1
    moduleList '(
                 "edg:appExcel" "edg:sheetsFuncInit" "edg:sheetSelector"
                 "edg:cellPut" "edg:cellRead" "edg:excelAppVisible"
                 "edg:excelAppInvisible" "edg:quitWithoutSave" "edg:quitWithSave"
                 "edg:quitWithSaveAs" "edg:cellPutByTrueName" "edg:cellReadByTrueName"
                 "edg:SaveWithoutQuit" "edg:graphic" "edg:table" "Sem erro em Modulos"
                 )
  )
  
  (vla-startundomark doc)
  
  (setq moduleError (1+ moduleError))
  (defun edg:appExcel ()
    (setq
     app(vl-catch-all-apply 'vlax-create-object (list "Excel.Application"))
     app(if (=(vl-catch-all-error-p app) nil) app (vlax-get-or-create-object "Excel.Application"))
    )
    app
  )
  
  (setq moduleError (1+ moduleError))
  (defun edg:sheetsFuncInit (appExcel new / appExcel workbook book sheets) ; t or nil ; nil = open file
    (if new
      (setq
        workbook (vlax-get appExcel 'Workbooks)
        book (vlax-invoke-method workbook 'add)
        sheets (vlax-get book 'Sheets)
        )
      (setq
        xlsx_file (getfiled "Abrir Planilha..." (getvar'dwgprefix) "xlsx" 16)
        workbook (vlax-get appExcel 'Workbooks)
        book (vlax-invoke-method workbook 'Open xlsx_file)
        sheets (vlax-get book 'Sheets)
        )
      )
    (list workbook book sheets)
  )
  
  (setq moduleError (1+ moduleError))
  (defun edg:sheetSelector (sheets num / sheets sheetSelected)
    (if (= (type sheets) 'LIST) (setq sheets (nth 2 sheets)))
    (setq
      sheetSelected (vlax-get-property sheets 'Item num)
    )
    sheetSelected
  )
  
  (setq moduleError (1+ moduleError))
  (defun edg:cellPut(sheetSelected Row Column InfoToPut / sheetSelected)
    (if (> Row 1048576) (progn (alert "Limite de Linhas Ultrapassado...") (quit)))
    (if (> Column 16384) (progn (alert "Limite de Colunas Ultrapassado...") (quit)))
    (setq
      cellControl(vlax-get sheetSelected "cells")
    )
    (vlax-put-property cellControl 'Item Row Column InfoToPut)
  )
  
  (setq moduleError (1+ moduleError))
  (defun edg:cellRead(sheetSelected Row Column / sheetSelected)
    (if (> Row 1048576) (progn (alert "Limite de Linhas Ultrapassado...") (quit)))
    (if (> Column 16384) (progn (alert "Limite de Colunas Ultrapassado...") (quit)))
    (setq
      cellControl(vlax-get sheetSelected "cells")
      data(vlax-variant-value(vlax-get-property cellControl 'Item Row Column))
    )
    (vlax-get data 'Value2)
  )
  
  (setq moduleError (1+ moduleError))
  (defun edg:excelAppVisible (appExcel)
    (vla-put-visible appExcel :vlax-true)
  )
  
  (setq moduleError (1+ moduleError))
  (defun edg:excelAppInvisible (appExcel)
    (vla-put-visible appExcel :vlax-false)
  )

  (setq moduleError (1+ moduleError))
  (defun edg:quitWithoutSave (appExcel workbook)
    (if (= (type workbook) 'LIST) (setq workbook (nth 0 workbook)))
    (vlax-invoke-method workbook 'Close)
    (vlax-invoke appExcel 'Quit)
    (vlax-release-object appExcel)
  )
  
  (setq moduleError (1+ moduleError))
  (defun edg:quitWithSave (appExcel workbook)
    (if (= (type workbook) 'LIST) (setq workbook (nth 0 workbook)))
    (vlax-invoke-method workbook 'Save)
    (vlax-invoke-method workbook 'Close)
    (vlax-invoke appExcel 'Quit)
    (vlax-release-object appExcel)
  )

  (setq moduleError (1+ moduleError))
  (defun edg:quitWithSaveAs (appExcel workbook)
    (if (= (type workbook) 'LIST) (setq workbook (nth 0 workbook)))
    (setq xlsx_file (getfiled "Salvar Planilha..." "" "xlsx" 3))
    (vlax-invoke-method workbook 'SaveAs xlsx_file)
    (vlax-invoke-method workbook 'Close)
    (vlax-invoke appExcel 'Quit)
    (vlax-release-object appExcel)
  )
  
  (setq moduleError (1+ moduleError))
  (defun edg:cellPutByTrueName(sheetSelected Cell InfoToPut / sheetSelected)
    (setq
      cellControl (vlax-get sheetSelected "cells")
      cellData (vlax-get-property cellControl "Range" Cell)
    )
    (vlax-put-property cellData 'Value2 InfoToPut)
  )
  
  (setq moduleError (1+ moduleError))
  (defun edg:cellReadByTrueName(sheetSelected Cell / sheetSelected)
    (setq
      cellControl (vlax-get sheetSelected "cells")
      cellData (vlax-get-property cellControl "Range" Cell)
      data (vlax-variant-value(vlax-get-property cellData 'Value2))
    )
  )

  (setq moduleError (1+ moduleError))
  (defun edg:SaveWithoutQuit (appExcel workbook)
    (if (= (type workbook) 'LIST) (setq workbook (nth 0 workbook)))
    (vlax-invoke-method workbook 'Save)
  )
  
  (setq moduleError (1+ moduleError))
  (defun edg:graphic()
    (princ "\tA implementar...")
  )

  (setq moduleError (1+ moduleError))
  (defun edg:table()
    (princ "\tA implementar...")
  )
  
  (setq moduleError (1+ moduleError))
  (vla-endundomark doc)
  (princ "\tModulo Excel Carregado...")
  (princ)

;|
;;;;;; HELP
;;; Metodos iniciais...
(setq xlsTeste(edg:appExcel)) ;---> Carregar Excel
(setq sheetsFuncInit (edg:sheetsFuncInit xlsTeste t)) ;---> Carregar Planilha nova
(setq sheetsFuncInit (edg:sheetsFuncInit xlsTeste nil)) ;---> Carregar Planilha existente
(setq sheetSelected (edg:sheetSelector sheetsFuncInit 1)) ;---> Tornar planilha analisavel/editavel
(setq sheetSelected (vlax-get-property(vlax-get(nth 1 sheetsFuncInit)'Sheets)'Item tab_name))  ;---> Tornar planilha analisavel/editavel

;;; Selecionar a Aba/Tab = tab_name
(vlax-invoke-method sheetSelected 'Activate)
  
;;; Testes
(vlax-dump-object xlsTeste t)
(vlax-dump-object (nth 0 sheetsFuncInit) t)
(vlax-dump-object (nth 1 sheetsFuncInit) t)
(vlax-dump-object (nth 2 sheetsFuncInit) t)
(vlax-dump-object sheetSelected t)

;;; Inserir e Ler dados das Celulas
(edg:cellPut sheetSelected 1 1 "Teste...") ;---> Inserir dados na Linha/Coluna
(edg:cellRead sheetSelected 2 2) ;---> Ler dados na Linha/Coluna
(edg:cellPutByTrueName sheetSelected "E11" "Teste")
(edg:cellReadByTrueName sheetSelected "E11")

;;; Deixar o Excel Visivel e Invisivel
(edg:excelAppVisible xlsTeste) ;---> Tornar Excel Visivel
(edg:excelAppInvisible xlsTeste) ;---> Tornar Excel Invisivel

;;; Quit e Save do Documento
(edg:quitWithoutSave xlsTeste sheetsFuncInit) ;---> Sair do Documento sem Salvar
(edg:SaveWithoutQuit xlsTeste sheetsFuncInit) ;---> Salvar Documento
(edg:quitWithSave xlsTeste sheetsFuncInit) ;---> Salvar Documento e Sair
(edg:quitWithSaveAs xlsTeste sheetsFuncInit) ;---> Salvar Documento como e Sair
|;
)