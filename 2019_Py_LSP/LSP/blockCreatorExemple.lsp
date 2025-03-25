(defun c:teste ()
  
  (setq
    acad  (vl-catch-all-apply 'vlax-invoke (list (vlax-get-acad-object) 'GetInterfaceObject "AeccXUiLand.AeccApplication.13.6"))
    acad  (if (=(vl-catch-all-error-p acad)nil) acad (vlax-get-acad-object))
    doc   (vla-get-activedocument acad)
    model (vla-get-modelspace doc)
  )
  
  (setq blockName "Teste")
  
  (entmake
    (list
      (cons 0 "Block") ; "Insert" "Block"
      (cons 2 blockName)
      '(8 . "0")
      '(70 . 2)
      '(10 0 0 0)
    )
  )
  
  (entmake '((0 . "line") (10 0 0 0) (11 100 100 0)) )
  
  (entmake '((0 . "ENDBLK")))
  
  (setq blk (vla-item (vla-get-blocks(vla-get-activedocument(vlax-get-acad-object))) blockName ))
  
  (vla-addline blk (vlax-3d-point 100 0 0) (vlax-3d-point 0 100 0))
  
)