(defun c:ComparaPerfisC3D (/ *error* main doc prof1 prof2 begin end factor station excel workbooks book sheet sheets cells roll)
    (vl-load-com)
    (defun ed:main ()
        (vla-StartUndoMark (setq doc (vla-get-ActiveDocument (vlax-get-acad-object))))
        
        (setq
            prof1(entsel "\nSelecione o Perfil 1 : ")
            prof2(entsel "\nSelecione o Perfil 2 : ")
            prof1(vlax-ename->vla-object ( car prof1 ))
            prof2(vlax-ename->vla-object ( car prof2 ))
            begin(max (vlax-get prof1 'StartingStation) (vlax-get prof2 'StartingStation))
            end(min  (vlax-get prof1 'EndingStation) (vlax-get prof2 'EndingStation))
            factor 1
            station 0
        )

        (while (< station begin) (setq station (+ factor station)))

        ;Excel
        (setq
            excel(vlax-get-or-create-object "Excel.Application")
            workbooks(vlax-get excel 'workbooks)
            book(vlax-invoke-method workbooks 'add)
            sheets(vlax-get book 'sheets)
            sheet(vlax-get-property sheets 'Item 1)
            cells(vlax-get sheet "cells")
            roll 1
        )

        (vla-put-Visible excel :vlax-true)
        
        (while (and (>= station begin) (< station end))
            (progn
                (setq
                    elev1(vlax-invoke prof1 'ElevationAt station)
                    elev2(vlax-invoke prof2 'ElevationAt station)
                )

                (vlax-put-property cells 'Item roll 1 station)
                (vlax-put-property cells 'Item roll 2 elev1)
                (vlax-put-property cells 'Item roll 3 elev2)
                (vlax-put-property cells 'Item roll 4 (abs (- elev1 elev2) ) )
                (vlax-put-property cells 'Item roll 5 (- elev1 elev2) )

                (princ (strcat "\n" (rtos station 2 2) "\t" (rtos elev1 2 2) "\t" (rtos elev2 2 2)) )

                (setq
                    station(+ station factor)
                    roll (1+ roll)
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
    (ed:main)
)