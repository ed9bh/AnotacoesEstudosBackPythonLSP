(defun c:RenMySelf (/ *error* main doc)
    (vl-load-com)
    (defun main ()
        (vla-StartUndoMark (setq doc (vla-get-ActiveDocument (setq cadObj(vlax-get-acad-object)))))
        
        (setq
            myFolder(getvar "dwgprefix")
            myOldName(getvar "dwgname")
            myNewName(getstring "\nDigite o novo nome do arquivo : ")
        )

        (setvar "lispinit" 0)

        (vlax-invoke doc 'save)
        (vlax-invoke doc 'close)
        

        
        (setvar "lispinit" 1)
        (vla-EndUndoMark doc)
        (princ)
    )
    (defun *error*(s)
        (princ s)
        (setvar "lispinit" 1)
        (vla-EndUndoMark doc)
        (princ)
    )
    (main)
)
