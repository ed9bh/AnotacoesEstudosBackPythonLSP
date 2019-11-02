(defun c:curve(/ *error*)
  (defun *error*(msg)
    (setq *error* err)
    (if VR
      (setvar"FILLETRAD"VR)
      )
    (princ (strcat "Error : " msg))
    (setvar'cmdecho 1)
    (princ)
    )

  (setvar'cmdecho 0)
  
  (setq
    Raio(vlax-get(vlax-ename->vla-object(car(entsel"\nSelecione o Dimension do Raio : ")))'Measurement)
    VR(getvar'FILLETRAD)
    )
  
  (setvar"FILLETRAD"Raio)

  (prompt"\tSelecione as duas retas para o Raio : ")
  (command"fillet")(while(= 1(logand 1(getvar'cmdactive)))(command"\\"))

  (setvar"FILLETRAD"VR)
  
  (setvar'cmdecho 1)
  (princ)
  )

;;; By Eric Drumond - https://www.youtube.com/channel/UCIG9FBilGznGdNp-_WzHM7g