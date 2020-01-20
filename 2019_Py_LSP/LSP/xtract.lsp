(defun c:xtract (/ *error* main doc);
    (vl-load-com)

    (defun ED9BH:Aligment_Extraction(x)
        (setq
            vlao(vlax-ename->vla-object x)
        )
        (vlax-invoke vlao 'GetLWPolyline)
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
        (princ "\n\t...N?o implementado ainda...")
    )

            


    (defun main ()
        (vla-StartUndoMark (setq doc (vla-get-ActiveDocument (vlax-get-acad-object))))

        (setq model(vla-get-ModelSpace doc))

        (prompt "\n\tSelecione o Alinhamento/FeatureLine/Corredor para extra??o : ")
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


;|
(setq
    x(car(entsel))
    vlao(vlax-ename->vla-object x)
    Base_Lines(vlax-get vlao 'Baselines)
    Base_Lines_Item(vlax-invoke Base_Lines 'Item 0); F_1
    Base_Lines_MainBaselineFeatureLines(vlax-get Base_Lines_Item 'MainBaselineFeatureLines)
    Base_Lines_FeatureLinesCol(vlax-get Base_Lines_MainBaselineFeatureLines 'FeatureLinesCol)
    Base_Lines_Item_1(vlax-invoke Base_Lines_FeatureLinesCol 'Item 0); F_2
    Base_Lines_Item_2(vlax-invoke Base_Lines_Item_1 'Item 0); F_3
    Feature_Points(vlax-get Base_Lines_Item_2 'FeatureLinePoints)
    Count_Points(vlax-get Feature_Points 'Count)
    Point(vlax-get(vlax-invoke Feature_Points 'Item 0)'xyz); F_4
)

(vlax-dump-Object Feature_Points t)
|;