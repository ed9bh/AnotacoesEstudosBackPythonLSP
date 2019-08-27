(defun c:excelTeste();(MeuExcel)
  (setq
    excel(vlax-get-or-create-object "Excel.Application")
    ;;; Pegar um excel existente
    ;book(vl-catch-all-apply 'vla-open (list(vlax-get-property excel "workbooks")) MeuExcel )
    )
  (setq
    workbooks(vlax-get excel 'workbooks)
    book(vlax-invoke-method workbooks 'add)
    sheets(vlax-get book 'sheets)
    sheet1(vlax-get-property sheets 'Item 1)
    cells(vlax-get sheet1 "cells")
    )

  (vla-put-visible excel :vlax-true)

  ;;; Inserir Dados no Excel
  (vlax-put-property cells 'Item 1 1 (vl-princ-to-string "teste...") )
  (vlax-put-property cells 'Item 1 3 550 )
  (vlax-put-property cells 'Item 2 3 13978.555 )
  ;;;
  
  ;(vlax-dump-object excel t)
  
  ;(vla-put-visible excel :vlax-false)
  )

;|

( vlax-put-property *excel-cells* "item" row col ( vl-princ-to-string x ) ) ) 

|;

;|

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;carrega uma nova seção do excel
( defun init-excel ( / excel-app wb-colletion workbook sheets sheet1 ) 
( vl-load-com ) 
( setq excel-app ( vlax-create-object "excel.application" ) 
wb-collection ( vlax-get excel-app "workbooks" ) 
workbook ( vlax-invoke-method wb-collection "add" ) 
sheets ( vlax-get workbook "sheets" ) 
sheet1 ( vlax-get-property sheets "item" 1 ) 
*excel-cells* ( vlax-get sheet1 "cells" ) ) 
( vlax-put excel-app "visible" 1 ) ) 

; escreve na linha e coluna especificada o valor x
( defun write-row-column ( row col x ) 
( vlax-put-property *excel-cells* "item" row col ( vl-princ-to-string x ) ) ) 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

use:


( init-excel ) ;abre o excel...

( write-row-column linha coluna valor )

|;



;|

(defun OpenExcel (Exfile)
(setq MyFile (findfile Exfile)) ;double check file exists at location
(if (/= MyFile nil) ;nil = file not found
(progn ;if file found open it
(setq MyXL (vlax-get-or-create-object "Excel.Application")) ;find Excel application
(vla-put-visible MyXL :vlax-false) ;hide application from view
(vlax-put-property MyXL 'DisplayAlerts :vlax-false) ;hide Excel alerts
(setq MyBook (vl-catch-all-apply 'vla-open (list (vlax-get-property MyXL "WorkBooks") MyFile)))
))
) ;return - MyFile = nil if file not found 

;--- Routine to CLOSE Excel file & Session
;--- Assumes previously opened with OpenExcel function
(defun CloseExcel
(vl-catch-all-apply 'vlax-invoke-method (list MyBook "Close"))
(vl-catch-all-apply 'vlax-invoke-method (list MyXL "Quit"))
(vl-catch-all-apply 'vlax-release-object MyCell)
(vl-catch-all-apply 'vlax-release-object MyRange)
(vl-catch-all-apply 'vlax-release-object MySheet)
(vl-catch-all-apply 'vlax-release-object MyBook) 
(vl-catch-all-apply 'vlax-release-object MyXL)
(setq MyFile nil MyXL nil MyBook nil MySheet nil MyRange nil
MyTab nil MyCell nil ExCell nil) ;clear variables from memory
(gc) ;garbage cleanup
) ;return

;--- Routine to set Worksheet Tab
;--- Call using GetTab "Tabname" (Example: GetTab Sheet1)
;--- If MySheet = nil on return then requested TAB not found in Excel file or Excel file was not open
(defun GetTab (MyTab)
(if (/= MyXL nil) ;ensure file is open
(progn ;if it is then...
(setq MySheet (vl-catch-all-apply 'vlax-get-property (list (vlax-get-property myBook "Sheets") "Item" MyTab)))
(if (not (vl-catch-all-error-p MySheet)) ;if requested tab found then...
(vlax-invoke-method MySheet "Activate") ;set the desired active tab
(setq MySheet nil))) ;if tab not found then nil MySheet
(setq MySheet nil)) ;if file wasn't open then nil MySheet
MySheet) ;return with Mysheet status

;--- Routine to READ an Excel Cell on the current active tab
;--- Call using GetCell "Cell Name" (Example: GetCell A1)
;--- MyCell returns cell value (nil = empty)
(defun GetCell (ExCell)
(if (/= MyXL nil) ;ensure file is open
(progn ;if it is then...
(setq MyRange (vlax-get-property (vlax-get-property MySheet 'Cells) "Range" ExCell))
(setq MyCell (vlax-variant-value (vlax-get-property MyRange 'Value2))))
(setq MyCell nil)) ;nill cell value if file not open
MyCell) ;return with cell value

|;