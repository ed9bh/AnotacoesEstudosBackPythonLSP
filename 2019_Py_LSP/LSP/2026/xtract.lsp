(defun c:xtract (/ *error* main doc);
    (vl-load-com)

    (defun ED9BH:Aligment_Extraction(x)
        (setq
            vlao(vlax-ename->vla-object x)
        )
        (setq vlaoNew(vlax-invoke vlao 'GetLWPolyline))
	(vlax-put vlaoNew 'Layer "xtract")
    )

    (defun ED9BH:FeatureLine_Extraction(x)
        (setq
            vlao(vlax-ename->vla-object x)
            Coords(vlax-invoke vlao 'GetPoints)
            len(/ (length Coords) 3)
            PList nil
            n -1
        )

        (repeat len
            (setq
                PList(vl-list*
                        (list
                            (nth (setq n(1+ n)) Coords)
                            (nth (setq n(1+ n)) Coords)
                            (nth (setq n(1+ n)) Coords)
                        )
                        PList
                )
            )
        )

        (vla-Add3DPoly model
            (vlax-make-variant
                (vlax-safearray-fill
                    (vlax-make-safearray vlax-vbDouble
                        (cons 0 (1-(length(apply'append(reverse PList))))))
                        (apply'append(reverse PList)
                        )
                )
            )
        )
    )

    (defun ED9BH:Corridor_Extraction(x)
        (princ "\n\t...Não implementado ainda...")
    )

            


    (defun main ()
        (vla-StartUndoMark (setq doc (vla-get-ActiveDocument (vlax-get-acad-object))))

        (setq
            model(vla-get-ModelSpace doc)
            mlay(GETVAR 'clayer)
        )

        (setq vla-obj (vla-add(vla-get-layers doc) "XTRACT"))
        (vla-put-color vla-obj 30)

        (setvar "clayer" "XTRACT")

        (prompt "\n\tSelecione o Alinhamento/FeatureLine/Corredor para extração : ")
        (setq
            ss(sssetfirst nil (ssget '((0 . "AECC_ALIGNMENT,AECC_FEATURE_LINE,AECC_CORRIDOR"))))
        )

        (foreach s (ssnamex (cadr ss))
            (if (>= (car s) 0)
                (cond
                    ((= (cdr(assoc 0 (entget (cadr s)))) "AECC_ALIGNMENT") (ED9BH:Aligment_Extraction (cadr s)))
                    ((= (cdr(assoc 0 (entget (cadr s)))) "AECC_FEATURE_LINE") (ED9BH:FeatureLine_Extraction (cadr s)))
                    ((= (cdr(assoc 0 (entget (cadr s)))) "AECC_CORRIDOR") (ED9BH:Corridor_Extraction (cadr s)))
                )
            )
        )
        
        (setvar "clayer" mlay)
        (vla-EndUndoMark doc)
        (princ)
    )
    (defun *error*(s)
        (setvar "clayer" mlay)
        (princ s)
        (vla-EndUndoMark doc)
        (princ)
    )
    (main)
    (sssetfirst)
    (sssetfirst nil (ssget "x" '((8 . "xtract"))))
    (princ)
)


;|EDG(2020)[https://www.linkedin.com/in/ericdrumond]{https://github.com/ed9bh}|;