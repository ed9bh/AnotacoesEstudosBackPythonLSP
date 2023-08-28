(defun c:xid (/ *error* acad doc model)
  
  ;;; --------------------------------------> Funcoes
  
  (defun *error* (msg)
    
    (princ msg)
    (vla-endundomark doc)
    (princ)
  
  )
  
  (defun info_to_clipBoard(info)
    (vlax-invoke
      (vlax-get
        (vlax-get
          (setq htmlfile (vlax-create-object "htmlfile"))
          'ParentWindow
        )
        'ClipBoardData
      )
      'SetData
      "Text"
      info
    )
    (vlax-release-object htmlfile)
  )
    
  ;;; --------------------------------------> Main
  
  (defun main ()
    
    (setq
      point(getpoint "\nClique no ponto : ")
      north(rtos(cadr point)2 3)
      east(rtos(car point)2 3)
      language '(
                 ("PT-BR" "NORTE=" "ESTE=") ; 0
                 ("ENG" "NORTH=" "EAST=")   ; 1
                 ("GLOBAL" "N:" "E:")   ; 2
                 )
      language_option 2
    )
    
    (princ "\n\n\n")
    
    (info_to_clipBoard
      (setq info
             (strcat
               (nth 1 (nth language_option language))
               north
               "\n"
               (nth 2 (nth language_option language))
               east
             )
      )
    )
    
    (princ info)
    
  )
  
  ;;; --------------------------------------> Rotina
  
  (setq
    acad (vlax-get-acad-object)
    doc (vla-get-activedocument acad)
    model (vla-get-modelspace doc)
  )
  
  (vla-startundomark doc)
  (setvar 'cmdecho 0)
  (main)
  (vla-endundomark doc)
  (setvar 'cmdecho 1)
  (princ)
  
)