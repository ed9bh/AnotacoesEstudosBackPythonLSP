(defun c:xid()
	(setq	Emlh(entsel "\nSelecione a Malha Triangular : ")
		Vmlh(vlax-ename->vla-object (car Emlh) )
		Point(getpoint "\tClique no ponto : ")
	 )

	(setq	xPoint(vlax-invoke Vmlh 'FindElevationAtXY (car Point) (cadr Point) ))

	(princ (strcat "x : "(rtos(car Point)2)" // y : "(rtos(cadr Point)2)" // z : "(rtos xPoint 2) ))
	(princ (strcat "\n\n" (rtos(car Point)2)","(rtos(cadr Point)2)","(rtos xPoint 2) ))
(princ)
)