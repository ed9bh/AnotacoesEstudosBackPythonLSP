(vlax-curve-getDistAtPoint (car (entsel)) (getpoint));descobrir distancia em um ponto especifico

(entmake(list(cons 0"point")(cons 10 (vlax-curve-getClosestPointToProjection (car(entsel)) '(20 10 0) '(20 10 0)))))