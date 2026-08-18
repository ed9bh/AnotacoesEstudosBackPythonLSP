(defun c:centertxt(/ *error* clear middleCenterText centerFinder mtext common main
             acad doc modelSpace msg os clayer TempLayerDelete vlao
             ss s a b x y v center key north_list east_list minpoint maxpoint minX minY maxX maxY
             vlao_InsertionPoint ent_boundary vlao_boundary coordinates
             )

    (vl-load-com)

    (setq
        acad(vlax-get-Acad-object)
        doc(vla-get-ActiveDocument acad)
        modelSpace(vla-get-modelspace doc)
    )

    (defun *error*(msg)
        (vla-EndUndoMark doc)
        (princ msg)
        (vla-put-ActiveLayer doc clayer)
        (clear)
        (vla-delete TempLayerDelete)
        (setvar'osmode os)
        (setvar'cmdecho 1)
        (princ)
    )

    (defun select_points_min_max(ss_list)
        (setq x_list nil y_list nil)
        (foreach s (ssnamex ss_list)
            (if (< (car s) 0)
                (foreach e (cdr s)
                    (setq
                        point(cadr e)
                        x_list(vl-list* (car point) x_list)
                        y_list(vl-list* (cadr point) y_list)
                        )
                    )
                )
            )
      (list (list (apply 'min x_list) (apply 'min y_list) ) (list (apply 'max x_list) (apply 'max y_list) ) )
      )

    (defun big_list_problem(lst vlao)
        (if (>(length lst)20)
            (progn
                (vla-GetBoundingBox vlao 'minpoint 'maxpoint)
                (setq
                    height (vla-get-height vlao)
                    ;factor (expt (if (< height 1.5) 2 height) pi)
                    factor (* height 10)
                    minX(-(car(vlax-safearray->list minpoint))(*(-(car(vlax-safearray->list maxpoint))(car(vlax-safearray->list minpoint)))factor))
                    maxX(+(*(-(car(vlax-safearray->list maxpoint))(car(vlax-safearray->list minpoint)))factor)(car(vlax-safearray->list maxpoint)))
                    minY(-(cadr(vlax-safearray->list minpoint))(*(-(cadr(vlax-safearray->list maxpoint))(cadr(vlax-safearray->list minpoint)))factor))
                    maxY(+(*(-(cadr(vlax-safearray->list maxpoint))(cadr(vlax-safearray->list minpoint)))factor)(cadr(vlax-safearray->list maxpoint)))
                )
                (vla-zoomwindow acad (vlax-3D-point(list minX minY)) (vlax-3D-point(list maxX maxY)))
            )
        )
    )

    (defun clear()
        (setq ss (ssget "x" '((8 . "TempLayerDelete"))))
        (if ss
            (foreach s (ssnamex ss)
                (entdel (cadr s))
            )
        )
    )

    (defun middleCenterText(vlao / a b center)
        (vla-GetBoundingBox vlao 'minpoint 'maxpoint)
        (setq
            a (vlax-safearray->list minpoint)
            b (vlax-safearray->list maxpoint)
            x (/(+(car a)(car b))2)
            y (/(+(cadr a)(cadr b))2)
        )
        (list x y)
    )

    (defun centerFinder(coordinates)
        (setq
            key 0
            north_list nil
            east_list nil
        )

        (foreach e coordinates
            (if (= key 0)
                (setq
                    key 1
                    east_list (vl-list* e east_list)
                )
                (setq
                    key 0
                    north_list (vl-list* e north_list)
                )
            )
        )

        (setq
            len (length east_list)
            x (/ (apply '+ east_list) len)
            y (/ (apply '+ north_list) len)
        )

        (list x y)
    )

    (defun mtext(vlao)
        (setq
            vlao_InsertionPoint(vlax-get vlao 'InsertionPoint)
        )

        (setvar'osmode 0)
        (command "-boundary" vlao_InsertionPoint "")

        (setq
            ent_boundary(entlast)
            vlao_boundary(vlax-ename->vla-object ent_boundary)
            coordinates(vlax-get vlao_boundary 'Coordinates)
            center(centerFinder coordinates)
        )

        (vla-delete vlao_boundary)

        (vlax-put-property vlao 'InsertionPoint (vlax-3d-point center))
        (vlax-release-object vlao)
        )

    (defun common(vlao)
        (setq
            vlao_TextAlignmentPoint(middleCenterText vlao)
        )

        (setvar'osmode 0)
        (command "-boundary" vlao_TextAlignmentPoint "")

        (setq
            ent_boundary(entlast)
            vlao_boundary(vlax-ename->vla-object ent_boundary)
            coordinates(vlax-get vlao_boundary 'Coordinates)
            center(centerFinder coordinates)
        )

        (vla-delete vlao_boundary)

    (vla-put-alignment vlao acAlignmentMiddleCenter)
    (vla-put-textalignmentpoint vlao (vlax-3d-point center))

        (vlax-release-object vlao)

        ;(vlax-put-property vlao 'TextAlignmentPoint (vlax-3d-point center))
        )

    (defun main()
        (princ "\nSelecione os text's e mtext's : ")
        (setq
            ss(ssget'((0 . "TEXT,MTEXT,ATTDEF")))
            points(select_points_min_max ss)
        )
        (vla-zoomwindow acad (vlax-3D-point(car points)) (vlax-3D-point(cadr points)))

        (foreach s (ssnamex ss)
            (if (> (car s) 0)
                (progn
                    (setq
                        v(vlax-ename->vla-object(cadr s))
                    )
            ;(big_list_problem (ssnamex ss) v)
                    (cond
                        ((= (vlax-get v 'ObjectName) "AcDbMText") (mtext v))
                        ((= (vlax-get v 'ObjectName) "AcDbText") (common v))
                        ((= (vlax-get v 'ObjectName) "AcDbAttributeDefinition") (common v))
                    )
                )
            )
        )
    )

    (vla-StartUndoMark doc)
    (prompt "\n\t---> Text's & MText's & Atributos devem estar justificados em \"Middle Center\" <---")
    (setq
        os (getvar'osmode)
        clayer (vla-get-activelayer doc)
        TempLayerDelete (vla-add(vla-get-layers(vla-get-activedocument(vlax-get-acad-object))) "TempLayerDelete")
    )

    (setvar'osmode 0)
    (setvar'cmdecho 0)

    (vla-put-ActiveLayer doc TempLayerDelete)

    (main)

    (vla-put-ActiveLayer doc clayer)
    (clear)
    (vla-delete TempLayerDelete)
    (setvar'osmode os)
    (setvar'cmdecho 1)

    (vla-EndUndoMark doc)
    (princ)
)

;;; By Eric Drumond - https://www.youtube.com/channel/UCIG9FBilGznGdNp-_WzHM7g
;;; Este Lisp foi importante pra você e quer fazer uma doação? (BTC : 12b5LJqYK4EVYjVBtvxgWumRbyd5Quuq7x)