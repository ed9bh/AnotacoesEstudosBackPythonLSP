(defun c:xlen (/ acad doc model main *error*)
  (setq
    acad(vlax-get-acad-object)
    doc(vla-get-activedocument acad)
    model(vla-get-modelspace doc)
  )
  
  (defun *error* (msg)
    (princ msg)
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
    
  (defun main ()
    
    (setq
      eo(entsel "\tSelecione a entidade : ")
      vlao(vlax-ename->vla-object (car eo))
      xsep (if xsep xsep ",")
    )
    
    (if
      (vlax-property-available-p vlao 'Length)
      (setq
        len
         (vl-catch-all-apply 'vlax-get (list vlao "Length"))
      )
      (setq len t)
    )
    
    (if (=(vl-catch-all-error-p len) nil)
      (progn
        (princ
          (vl-string-translate "." xsep
                               (strcat
                                 "Extencao (m): "
                                 (rtos len 2)
                                 " - Extencao (km) : "
                                 (rtos (/ len 1000) 2)
                                 " - Polegadas : "
                                 (rtos (/ len 0.0254) 2)
                                 " - Pes : "
                                 (rtos (/ len 0.3048) 2)
                                 " - Milhas : "
                                 (rtos (/ len 1609.34) 2)
                                 " - Léguas : "
                                 (rtos (/ len 6000) 2)
                               )
          )
        )
        (info_to_clipBoard (vl-string-translate "." xsep (rtos len 2)))
       )
      (princ "\nEntidade sem comprimento...")
    )
  )
  
  (vla-startundomark doc)
  (main)
  (vla-endundomark doc)
  (princ)
)

(defun c:xlensep ()
  (setq
    xsep (getstring "\tDigite o separador decimal : ")
    xsep (if xsep xsep ",")
  )
)