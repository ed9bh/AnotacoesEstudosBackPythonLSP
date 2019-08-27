(defun c:elevCota (/ *error* main doc point elev txt vltxt)
    (vl-load-com)
    (defun ed:main ()
        (vla-StartUndoMark (setq doc (vla-get-ActiveDocument (vlax-get-acad-object))))
        
        (setq 
            point (getpoint "\nClique no ponto : ")
            elev (cadr (trans point 1 1))
            txt (entsel "\tSelecione o texto para inserir a elevação : ")
            vltxt (vlax-ename->vla-object (car txt))
        )

        (vla-put-TextString vltxt (rtos elev 2 3))
        
        (vla-EndUndoMark doc)
        (princ)
    )
    (defun *error*(s)
        (princ s)
        (vla-EndUndoMark doc)
        (princ)
    )
    (ed:main)
)
