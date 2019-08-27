(defun c:coordMalha (/ *error* main doc esc txt point x y)
    (vl-load-com)
    (defun main ()
        (vla-StartUndoMark (setq doc (vla-get-ActiveDocument (vlax-get-acad-object))))
        
        (setq
            esc(getint "Escala : 1 / ")
            esc(/ esc 10)
        )

        (while (setq txt(entsel "\nSelecione o texto da malha : "))
            (if txt
                (progn
                (setq
                    txt(vlax-ename->vla-object (car txt))
                    )
                    (if (= (vlax-property-available-p txt 'TextString) t)
                        (princ)
                        (quit)
                        )
                )
            (quit)
            )

            (setq
                point(getpoint "\tClique no ponto de referencia : ")
                x nil
                y nil
            )

            (if(=(rem (car point) esc) 0)
                (vlax-put txt 'TextString (strcat "E(X)=" (rtos (car point) 2 0)))
                (vlax-put txt 'TextString (strcat "N(Y)=" (rtos (cadr point) 2 0)))
            )
        )
        
        (vla-EndUndoMark doc)
        (princ)
    )
    (defun *error*(s)
        (princ s)
        (vla-EndUndoMark doc)
        (princ)
    )
    (main)
)
