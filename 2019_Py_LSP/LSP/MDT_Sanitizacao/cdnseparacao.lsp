(defun c:cdnseparacao (/
                       *error* cad Document Documents Doc1 Doc2 MSpace1 MSpace2 Doc1Elements Doc2Elements
                       SaveBase SaveCount FatorElevacaoPairOdd FatorElevacao Count Vlao Coordinates
                       Elevation VlaoEntity ObjectName fator msg
                       )
  
  (vl-load-com)
  
  (defun *error* (msg)
    (princ msg)
    (vla-endundomark Document)
    
    (foreach item (list Vlao VlaoEntity MSpace2 MSpace1 Doc2 Doc1 Documents Document cad)
      (vl-catch-all-apply 'vlax-release-object (list item))
    )
    
    (LogReport nil (strcat "<Erro fatal> (" (rtos (getvar 'Cdate) 2 6) ")" ))
    
    (princ)
  )
  
  (defun LogReport(fileNew msg)
    (setq
      FileNameMem (if FileNameMem FileNameMem nil)
      FileNameMem (if fileNew nil FileNameMem)
    )
    (if 
      (= fileNew t)
      (setq
        LogFilePath(strcat(getvar 'dwgprefix)"LogReport("(vl-string-right-trim ".dwg" (getvar 'dwgname))")-"(vl-string-translate "." "_" (rtos (getvar 'cdate) 2 6) )".log")
        FileNameMem LogFilePath
      )
      (setq
        LogFilePath FileNameMem
      )
    )
    (setq LogFileOpened(open LogFilePath "a+"))
    (princ
      (strcat "Log[" (vl-string-translate "." "_" (rtos (getvar 'cdate) 2 6) ) "]:> " (if msg msg "...") "\n" )
      LogFileOpened
    )
    (close LogFileOpened)
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
    (vlax-release-object Vlao)
    (LogReport nil (strcat "Curva (" (rtos Reg 2 0) ") recriada..." ))
  )
  
  (defun SmartFunction(fator / VlaoEntity ObjectName)
    (LogReport nil (strcat "Analize da curva (" (rtos (setq Reg(1+ Reg)) 2 0) ")" ))
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
           (if (= (rem Elevation 2.) 0.)
             (lwPolyline Coordinates Elevation)
           )
           )
          ((= fator "Impar")
           (if (= (rem Elevation 2.) 1.)
             (lwPolyline Coordinates Elevation)
           )
           )
          ((= fator "5")
           (if (= (rem Elevation 5.) 0.)
             (lwPolyline Coordinates Elevation)
           )
           )
          ((= fator "10")
           (if (= (rem Elevation 10.) 0.)
             (lwPolyline Coordinates Elevation)
           )
           )
          ((= fator "25")
           (if (= (rem Elevation 25.) 0.)
             (lwPolyline Coordinates Elevation)
           )
           )
        )
      )
    )
    
    (vlax-release-object VlaoEntity)
    
    ;;;
    (if (= SaveCount 0)
      (progn
        (vl-catch-all-apply 'vlax-invoke (list Doc2 'Save))
        (setq SaveCount SaveBase)
      )
    )
  )
  
  (defun main()
    (initget "Par Impar 5 10 25")
    (setq
      fator (getkword "\nFator de elevacao [Par/Impar/5/10/25] : ")
      Reg 0
    )
    (LogReport nil "Inicio operação de longo prazo...")
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
    (LogReport nil "Final operação de longo prazo...")
    (vl-catch-all-apply 'vlax-invoke (list Doc2 'Save))
    ;(vlax-invoke Doc2 'Activate)
  )
  
  (LogReport t "Inicio do processo...")
  
  (setq
    cad (vlax-get-acad-object)
    Document  (vla-get-activedocument cad)
    Documents (vlax-get cad 'Documents)
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
  
  (vla-startundomark Document)
  (LogReport nil "Inicio (MAIN)...")
  (main)
  (LogReport nil "Final (MAIN)...")
  (vla-endundomark Document)
  
  (foreach item (list Vlao VlaoEntity MSpace2 MSpace1 Doc2 Doc1 Documents Document cad)
      (vl-catch-all-apply 'vlax-release-object (list item))
    )
  
  (LogReport nil "Finalização do processo!")
  
  (princ)
  ;(vlax-invoke-method Doc2 'Sendcommand "zoom\ne\n")
  
)

;|EDG(2025)[https://www.linkedin.com/in/ericdrumond]{https://github.com/ed9bh}|;