(defun c:cdnseparacao (/ *error*)
  (defun *error* (msg)
    (princ msg)
    (vla-endundomark doc)
    (princ)
  )
  
  (defun lwPolyline(Coordinates Elevation)
    (setq
      Vlao
       (vla-addlightweightpolyline
         MSpace2
         (vlax-make-variant
           (vlax-safearray-fill
             (vlax-make-safearray
               vlax-vbdouble
               (cons 0 (1-(length Coordinates))))
             Coordinates
           )
         )
       )
    )
    (vlax-put Vlao 'Elevation Elevation)
  )
  
  (defun SmartFunction(fator)
    (setq SaveCount (1- SaveCount))
    ;;;
    (setq
      VlaoEntity(vlax-invoke MSpace1 'Item (setq Count(1+ Count)))
      ObjectName(vlax-get VlaoEntity 'ObjectName)
    )
    
    (if (= ObjectName "AcDbPolyline")
      (progn
        (setq
          Coordinates(vlax-get VlaoEntity 'Coordinates)
          Elevation(vlax-get VlaoEntity 'Elevation)
        )
        (cond
          ((= fator "Par")
           (if (= (rem Elevation 2) 0)
             (lwPolyline Coordinates Elevation)
           )
           )
          ((= fator "Impar")
           (if (= (rem Elevation 2) 1)
             (lwPolyline Coordinates Elevation)
           )
           )
          ((= fator "5")
           (if (= (rem Elevation 5) 0)
             (lwPolyline Coordinates Elevation)
           )
           )
          ((= fator "10")
           (if (= (rem Elevation 10) 0)
             (lwPolyline Coordinates Elevation)
           )
           )
          ((= fator "25")
           (if (= (rem Elevation 25) 0)
             (lwPolyline Coordinates Elevation)
           )
           )
        )
      )
    )
    
    ;;;
    (if (= SaveCount 0)
      (progn
        (vlax-invoke Doc2 'Save)
        (setq SaveCount SaveBase)
      )
    )
  )
  
  (setq
    Acad (vlax-get-acad-object)
    Document  (vla-get-activedocument Acad)
    Documents (vlax-get Acad 'Documents)
    Doc1 (vlax-invoke Documents 'Item 0)
    Doc2 (vlax-invoke Documents 'Item 1)
    MSpace1 (vla-get-modelspace Doc1)
    MSpace2 (vla-get-modelspace Doc2)
    Doc1Elements (vlax-get MSpace1 'Count)
    Doc2Elements (vlax-get MSpace2 'Count)
    SaveBase 100
    SaveCount SaveBase
    FatorElevacaoPairOdd 2
    FatorElevacao 5
    Count -1
  )
  
  (defun main()
    (initget "Par Impar 5 10 25")
    (setq fator (getkword "\nFator de elevacao [Par/Impar/5/10/25] : "))
    (princ "\n\n\n\tEsta operacao podera demorar, aguarde...")
    (cond
      ((= fator "Par")
       (repeat Doc1Elements (SmartFunction "Par"))
       )
      ((= fator "Impar")
       (repeat Doc1Elements (SmartFunction "Impar"))
       )
      ((= fator "5")
       (repeat Doc1Elements (SmartFunction "5"))
       )
      ((= fator "10")
       (repeat Doc1Elements (SmartFunction "10"))
       )
      ((= fator "25")
       (repeat Doc1Elements (SmartFunction "25"))
       )
    )
  )
  
  (main)
  
  (princ)
  
)