(defun c:PaintFaces (/ *error* main doc)
    (vl-load-com)
    (defun main ()
        (vla-StartUndoMark (setq doc (vla-get-ActiveDocument (vlax-get-acad-object))))

        (setq baseFace (entsel "\n Selecionar a 3D Face Base : ")
            )
        
        (if (= baseFace nil)
            (quit)
            (setq
                eBase(entget(car baseFace))
                baseLayer(cdr (assoc 8 eBase))
		;baseColor(cdr (assoc 62 eBase))
                faces(ssget "x" (list '(0 . "3DFACE")(cons 8 baseLayer)))
            )
        )

        (setq lay(vla-add (vla-get-layers (vla-get-activedocument (vlax-get-acad-object))) "_Plataforma-Pista"))
        (vla-put-Color lay 251)
        (setq lay(vla-add (vla-get-layers (vla-get-activedocument (vlax-get-acad-object))) "_TaludeCorte"))
        (vla-put-Color lay 20)
        (setq lay(vla-add (vla-get-layers (vla-get-activedocument (vlax-get-acad-object))) "_TaludeAterro"))
        (vla-put-Color lay 80)
        (setq lay(vla-add (vla-get-layers (vla-get-activedocument (vlax-get-acad-object))) "_Contencao-Muro-SoloGrampeado-Gabiao-TerraArmada"))
        (vla-put-Color lay 249)

        (foreach e (ssnamex faces)
            (progn
                (setq
                    v(vlax-ename->vla-object (cadr e))
                    coords(vlax-get v 'Coordinates)
                    n -1
                    P1 (list (nth (setq n(1+ n)) coords) (nth (setq n(1+ n)) coords) (nth (setq n(1+ n)) coords))
                    P2 (list (nth (setq n(1+ n)) coords) (nth (setq n(1+ n)) coords) (nth (setq n(1+ n)) coords))
                    P3 (list (nth (setq n(1+ n)) coords) (nth (setq n(1+ n)) coords) (nth (setq n(1+ n)) coords))
                    
                    DistA (distance (list (car P1) (cadr P1)) (list (car P2) (cadr P2)) )
                    DistB (distance (list (car P2) (cadr P2)) (list (car P3) (cadr P3)) )
                    DistC (distance (list (car P3) (cadr P3)) (list (car P1) (cadr P1)) )
                    
                    DesnA (- (caddr P1) (caddr P2) )
                    DesnB (- (caddr P2) (caddr P3) )
                    DesnC (- (caddr P3) (caddr P1) )

                    Percent (* (max (/ DesnA DistA) (/ DesnB DistB) (/ DesnC DistC) ) 100)

		    Percent (abs Percent)
                )

	      (vl-catch-all-apply 'vla-put-Color (list v 256))

	      (cond
          ; Pista
		((< Percent 15)
		 (vl-catch-all-apply 'vlax-put (list v 'Layer "_Plataforma-Pista"))
		 )
         ; Aterro
		((and (> Percent 15) (< Percent 55) ) ; 50.0 %
		 (vl-catch-all-apply 'vlax-put (list v 'Layer "_TaludeAterro"))
		 )
         ; Muro
		((> Percent 160)
		 (vl-catch-all-apply 'vlax-put (list v 'Layer "_Contencao-Muro-SoloGrampeado-Gabiao-TerraArmada"))
		 )
         ; Corte
		((and (> Percent 56) (< Percent 160) ) ; 66.666666 %
		 (vl-catch-all-apply 'vlax-put (list v 'Layer "_TaludeCorte"))
		 )
		)
            )
        )
        
        
        (vla-EndUndoMark doc)
        (princ)
    )
    (defun *error*(s)
        (gc)
        (princ s)
        (vla-EndUndoMark doc)
        (princ)
    )
    (main)
)
