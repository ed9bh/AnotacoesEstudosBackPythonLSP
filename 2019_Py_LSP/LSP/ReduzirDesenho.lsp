(defun c:limp()

	(setq error *error*
		echo(getvar"cmdecho")
	)

	(setvar"cmdecho"0)

	(defun *error*(msg)
		(setq *error* error)
		(setvar"cmdecho"echo)
		(princ msg)
	)

	(setq 
		ssAll(ssget"x")
	)

	(if ssAll (setq ssAll(ssnamex ssAll)))

	;(princ (length(ssnamex (ssget"x"))))
	;(princ "\n")

	(foreach x ssAll
		(progn
			(setq x(vlax-ename->vla-object (cadr x))
				  del nil
				)

			(cond
				((= (vla-get-ObjectName x) "AcDbLine")
					(if (< (vlax-get x 'Length) 0.5)
						(setq del t)
					)
				)

				((= (vla-get-ObjectName x) "AcDbCircle")
					(if (< (vlax-get x 'Radius) 1)
						(setq del t)
					)
				)

				((= (vla-get-ObjectName x) "AcDbPolyline")
					(if (< (vlax-get x 'length) 1)
						(setq del t)
					)
				)

				((= (vla-get-ObjectName x) "AcDbPoint")
					(setq del t)
				)

				((= (vla-get-ObjectName x) "AcDbText")
					(setq del t)
				)

				((= (vla-get-ObjectName x) "AcDbMText")
					(setq del t)
				)

				((= (vla-get-ObjectName x) "AcDbSpline")
					(setq del t)
				)

				((= (vla-get-ObjectName x) "AcDbEllipse")
					(setq del t)
				)

				((= (vla-get-ObjectName x) "AcDbSolid")
					(setq del t)
				)

				((= (vla-get-ObjectName x) "AcDbHatch")
					(setq del t)
				)
				;|
				((and(= (vla-get-ObjectName x) "AcDbBlockReference" )(= (vla-get-Name x) "TANQUES" ))
					(setq del t)
				)|;
			)
			(if (= del t) (vla-Delete x))
		)
	)

;(princ (length(ssnamex (ssget"x"))))
(setq *error* error)
(setvar"cmdecho"echo)
(princ)
)

(defun c:innerblock()
	(setq error *error*
		echo(getvar"cmdecho")
	)

	(setvar"cmdecho"0)

	(defun *error*(msg)
		(setq *error* error)
		(setvar"cmdecho"echo)
		(princ msg)
	)

	(setq blk (tblnext "block" t))

	(while blk
		(setq blkname(cdr(assoc 2 blk)))

		(command "-bedit" blkname)

		(c:limp)

		(vla-ZoomExtents(vlax-get-acad-object))

		(command "-mapclean" "geral")

		(command "bsave")

		(command "bclose")

		(command "-PURGE" "all" "*" "n")

		(setq blk (tblnext "block"))

	)
	
(command "-PURGE" "all" "*" "n")
(command "bclose")
(setq *error* error)
(setvar"cmdecho"echo)
(princ)
)