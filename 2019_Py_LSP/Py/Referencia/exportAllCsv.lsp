(defun c:exportAllCsv(/ *error* acad doc model file ss3DPoly ssLine ssPoints ssPoly ssCircle sx ep sp lay po elev rad count n reg)
    (vl-load-com)

    (princ "\nAguarde essa operacao pode demorar...")

    (setq
        acad(vlax-get-acad-object)
        doc(vla-get-ActiveDocument acad)
        model(vla-get-ModelSpace doc)
        echo(getvar "cmdecho")
        reg 0
    )

    (setvar "cmdecho" 0)
    
    (vla-StartUndoMark doc)

    (defun *error*(msg)
        (vla-EndUndoMark doc)
        (princ msg)
        (setvar "cmdecho" echo)
        (if file
            (close file)
        )
        (princ)
    )

    (setq
        ssPoly(ssget "x" '((0 . "lwpolyline")))
        ssLine(ssget "x" '((0 . "line")))
        ss3DPoly(ssget "x" '((0 . "POLYLINE")))
        ssPoints(ssget "x" '((0 . "point")))
        ssCircle(ssget "x" '((0 . "circle")))
        dir (strcat (getvar "dwgprefix") "CSVExtraction_" (rtos(getvar "cdate")2 0) "\\" )
    )

    (vl-catch-all-apply 'vl-mkdir (list dir))

    ; Lines

    (if ssLine
        (foreach x (ssnamex ssLine)
            (progn
                (setq
                    sx (vlax-ename->vla-object (cadr x))
                    sp (trans (vlax-get sx 'StartPoint) 1 1)
                    ep (trans (vlax-get sx 'EndPoint) 1 1)
                    lay (vla-get-Layer sx)
                    reg (1+ reg)
                    file (open (strcat dir "Line_" lay "_" (vl-string-translate "." "_" (rtos (getvar "cdate") 2 8)) "_" (rtos reg 2 0) ".csv") "w")
                )
                (write-line "Este(x);Norte(y);Elev(z);Camada" file)
                (write-line (strcat (rtos (car sp) 2 9) ";" (rtos (cadr sp) 2 9) ";" (rtos (caddr sp) 2 9) ";" lay ) file)
                (write-line (strcat (rtos (car ep) 2 9) ";" (rtos (cadr ep) 2 9) ";" (rtos (caddr ep) 2 9) ";" lay ) file)
                (close file)
            )
        )
    )

    ; Points

    (if ssPoints
        (progn
            (setq file (open (strcat dir "Point_TODOS_" (vl-string-translate "." "_" (rtos (getvar "cdate") 2 8)) ".csv") "w"))
            (write-line "Este(x);Norte(y);Elev(z);Camada" file)
            (foreach x (ssnamex ssPoints)
                (progn
                    (setq
                        sx (vlax-ename->vla-object (cadr x))
                        po (vlax-get sx 'Coordinates)
                        po (trans po 1 1)
                        lay (vla-get-Layer sx)
                    )
                    (write-line (strcat (rtos (car po) 2 9) ";" (rtos (cadr po) 2 9) ";" (rtos (caddr po) 2 9) ";" lay ) file)
                )
            )
            (close file)
        )
    )

    ; LWPolyline

    (if ssPoly
        (foreach x (ssnamex ssPoly)
            (progn
                (setq
                    sx (vlax-ename->vla-object (cadr x))
                    lay (vla-get-Layer sx)
                    elev (vlax-get sx 'Elevation)
                    count (/(length(vlax-safearray->list (vlax-variant-value (vlax-get-property sx 'Coordinates ))))2)
                    n 0
                    reg (1+ reg)
                    closed (vlax-get sx 'Closed)
                    file (if (= closed 0)
                            (open (strcat dir "LWPolyline_" lay "_" (vl-string-translate "." "_" (rtos (getvar "cdate") 2 8)) "_" (rtos reg 2 0) ".csv") "w")
                            (open (strcat dir "Polygon2D_" lay "_" (vl-string-translate "." "_" (rtos (getvar "cdate") 2 8)) "_" (rtos reg 2 0) ".csv") "w")
                    )
                )
                (write-line "Este(x);Norte(y);Elev(z);Camada" file)
                (repeat count
                    (setq
                        po(vlax-safearray->list (vlax-variant-value (vlax-get-property sx 'Coordinate n)))
                        po (trans po 1 1)
                        n (1+ n)
                    )
                    (write-line (strcat (rtos (car po) 2 9) ";" (rtos (cadr po) 2 9) ";" (rtos elev 2 9) ";" lay ) file)
                )
                (close file)
            )
        )
    )

    ; 3DPolyline

    (if ss3DPoly
        (foreach x (ssnamex ss3DPoly)
            (progn
                (setq
                    sx (vlax-ename->vla-object (cadr x))
                    lay (vla-get-Layer sx)
                    count (/(length(vlax-safearray->list (vlax-variant-value (vlax-get-property sx 'Coordinates ))))3)
                    n 0
                    reg (1+ reg)
                    closed (vlax-get sx 'Closed)
                    file (if (= closed 0)
                            (open (strcat dir "3DPolyline_" lay "_" (vl-string-translate "." "_" (rtos (getvar "cdate") 2 8)) "_" (rtos reg 2 0) ".csv") "w")
                            (open (strcat dir "Polygon3D_" lay "_" (vl-string-translate "." "_" (rtos (getvar "cdate") 2 8)) "_" (rtos reg 2 0) ".csv") "w")
                    )
                )
                (write-line "Este(x);Norte(y);Elev(z);Camada" file)
                (repeat count
                    (setq
                        po(vlax-safearray->list (vlax-variant-value (vlax-get-property sx 'Coordinate n)))
                        po (trans po 1 1)
                        n (1+ n)
                    )
                    (write-line (strcat (rtos (car po) 2 9) ";" (rtos (cadr po) 2 9) ";" (rtos (caddr po) 2 9) ";" lay ) file)
                )
                (close file)
            )
        )
    )

    (if ssCircle
        (progn
            (setq file (open (strcat dir "Circle_TODOS_" (vl-string-translate "." "_" (rtos (getvar "cdate") 2 8)) ".csv") "w"))
            (write-line "Este(x);Norte(y);Elev(z);Raio;Camada" file)
            (foreach x (ssnamex ssCircle)
                (progn
                    (setq
                        sx (vlax-ename->vla-object (cadr x))
                        po (vlax-get sx 'Center) ; (vlax-variant-value (vla-get-Center (vlax-ename->vla-object (car (entsel) ) ) ) )
                        po (trans po 1 1)
                        rad (vlax-get sx 'Radius)
                        lay (vla-get-Layer sx)
                    ); (vlax-dump-Object(vlax-ename->vla-object ( car (entsel)))t)
                    (write-line (strcat (rtos (car po) 2 9) ";" (rtos (cadr po) 2 9) ";" (rtos (caddr po) 2 9) ";" (rtos rad 2 9) ";" lay ) file)
                )
            )
            (close file)
        )
    )



(vla-EndUndoMark doc)
(setvar "cmdecho" echo)
(princ"\tFinalizado...")
(princ)
)

;;; By Eric Drumond - https://www.youtube.com/channel/UCIG9FBilGznGdNp-_WzHM7g