(defun c:ExcelVolDashBoard()
  ; Erro
  (setq error *error*)
  (defun *error*(msg)
    (setq *error* error)
    (princ msg)
    (if ExcelObj
      (progn
	(vla-put-visible ExcelObj :vlax-true)
	)
      )
    (initget 8 "Continuar Help")
    (if (=(getkword"Deseja [ver o Help / Continuar] : ")"Help")
      (princ"Video deve ficar aqui...")
      (princ"\tSaindo da operação...")
      )
    (princ)
    )
  ; Erro

  ; Excel Preparação
  (setq ExcelObj(vlax-get-or-create-object "Excel.Application")
	WorkBooks(vlax-get ExcelObj 'workbooks)
	Book(vlax-invoke-method WorkBooks 'add)
	Sheets(vlax-get Book 'sheets)
	Sheet(vlax-get-property Sheets 'Item 1)
	Cells(vlax-get Sheet "cells")
	Row 1
	Col 1
	)
  (vla-put-visible ExcelObj :vlax-true)

  
  (vlax-put-property Cells 'Item Row Col (strcat "Volume Dash Board - " (getvar'Dwgname)))
  (vlax-invoke (vlax-get-property (vlax-get-property Sheet 'Cells) 'Range "A1:F1") 'Merge)

  (setq Row (1+ Row))
  (vlax-put-property Cells 'Item Row Col "ITEM")
  	(setq Col (1+ Col))
  	(vlax-put-property Cells 'Item Row Col "Area 2D")
  	(setq Col (1+ Col))
  	(vlax-put-property Cells 'Item Row Col "Area 3D")
  	(setq Col (1+ Col))
  	(vlax-put-property Cells 'Item Row Col "Corte")
  	(setq Col (1+ Col))
  	(vlax-put-property Cells 'Item Row Col "Aterro")
  	(setq Col (1+ Col))
  	(vlax-put-property Cells 'Item Row Col "Diferença")
  
  (setq Col 1)
  
  
  ; Excel Preparação

  ; Excel Preenchimento
  (foreach x (ssnamex(ssget"x"'((0 . "AECC_TIN_SURFACE"))))
    (progn
      (setq
	e(cadr x)
	v(vlax-ename->vla-object(cadr x))
	)
      (if (=(VLAX-PROPERTY-AVAILABLE-P (vlax-get v 'Statistics)'CutVolume)t)
	(progn
	  
	  (setq Row (1+ Row))
	  (vlax-put-property Cells 'Item Row Col (vlax-get v 'Name))
	  
	  (setq Col (1+ Col))
	  (if (=(VLAX-PROPERTY-AVAILABLE-P (vlax-get(vlax-get(vlax-get v 'Statistics)'TopSurface)'Statistics)'Area2D)t)
	    (vlax-put-property Cells 'Item Row Col (vlax-get(vlax-get(vlax-get(vlax-get v 'Statistics)'TopSurface)'Statistics)'Area2D))
	    (vlax-put-property Cells 'Item Row Col "-")
	    )
	  
	  (setq Col (1+ Col))
	  (if (=(VLAX-PROPERTY-AVAILABLE-P (vlax-get(vlax-get(vlax-get v 'Statistics)'TopSurface)'Statistics)'Area3D)t)
	    (vlax-put-property Cells 'Item Row Col (vlax-get(vlax-get(vlax-get(vlax-get v 'Statistics)'TopSurface)'Statistics)'Area3D))
	    (vlax-put-property Cells 'Item Row Col "-")
	    )
	  
	  (setq Col (1+ Col))
	  (vlax-put-property Cells 'Item Row Col (vlax-get(vlax-get v 'Statistics)'CutVolume))
	  
	  (setq Col (1+ Col))
	  (vlax-put-property Cells 'Item Row Col (vlax-get(vlax-get v 'Statistics)'FillVolume))
	  
	  (setq Col (1+ Col))
	  (vlax-put-property Cells 'Item Row Col (vlax-get(vlax-get v 'Statistics)'NetVolume))

	  ;|
	  (vlax-dump-object v t)
	  (vlax-dump-object (vlax-get v 'Statistics) t)
	  (vlax-dump-object (vlax-get v 'SurfaceAnalysis) t)
	  (vlax-dump-object (vlax-get v 'DefinitionProperties) t)
	  (vlax-dump-object (vlax-get v 'Boundaries) t)
	  (vlax-dump-object (vlax-get(vlax-get(vlax-get v 'Statistics)'TopSurface)'Statistics) t)
	  |;
	  )
	)
      (setq Cuterro nil)
      (setq Col 1)
      )
    )
  ; Excel Preenchimento

  (vla-put-visible ExcelObj :vlax-true)
  (setq error *error*)
  (princ"\nProcesso concluido com sucesso...")
  (princ)
  )


(princ "\nBy Eric Drumond - https://www.youtube.com/channel/UCIG9FBilGznGdNp-_WzHM7g")
(princ "\nExcelVolDashBoard")
(princ)