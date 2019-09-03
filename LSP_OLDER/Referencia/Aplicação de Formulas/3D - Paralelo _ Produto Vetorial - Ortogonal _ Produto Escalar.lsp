;|           NOTAS PRINCIPAIS                  
                                               
OBS.: APLICAÇÃO DE PRODUTO VETORIAL COM O      
PRODUTO ESCALAR PARA TETERMINAR SE LINHAS SÃO  
PERPENDICULARES(ORTOGONAIS)                    
-----------------------------------------------
                                               
                    k (0 , 0 , 1)              
                    |                          
                    |                          
                    |                          
                    |                          
                   / \                         
                  /   \                        
                 /     \                       
                /       \                      
  (1 , 0 , 0)  i         j (0 , 1 , 0)         
                                               
-----------------------------------------------
PRODUTO VETORIAL                               
U-> X V-> = |  i  /  j  /  k  |  i  /  j       
            |                 |                
            |  x1 /  y1 /  z1 |  x1 / y1       
            |                 |                
            |  x2 /  y2 /  z2 |  x2 / y2       
            |                 |                
            | car /cadr /caddr| car / cadr     
                                               
i = (y1 * z2) + -(y2 * z1)                     
j = (z1 * x2) + -(z2 * x1)                     
k = (x1 * y2) + -(x2 * y1)                     
-----------------------------------------------
PRODUTO ESCALAR - PARA ACHAR LINHAS PERPEND.   
                                               
(U-> X V->) = W->                              
                                               
W-> . U-> = ( Xw * X1 + Yw * Y1 + Zw * Z1)     
                                               
OU                                             
                                               
W-> . V-> = ( Xw * X2 + Yw * Y2 + Zw * Z2)     
                                               
SE IGUAL A "0,000..." AS LINHAS SÃO ORTOGONAIS 
                                               
|;
(vl-load-com)
(defun c:perp();PERPENDICULAR _|_ (PRODUTO ESCALAR)
  (setq
    a(vlax-ename->vla-object(car(entsel"\nLinha A: ")))
    aI(vlax-curve-getstartpoint a) aF(vlax-curve-getendpoint a)
    b(vlax-ename->vla-object(car(entsel"\tLinha B: ")))
    bI(vlax-curve-getstartpoint b) bF(vlax-curve-getendpoint b)
    ;A->
    x1(-(car aF)(car aI)) y1(-(cadr aF)(cadr aI)) z1(-(caddr aF)(caddr aI))
    ;(list x1 y1 z1)
    ;B->
    x2(-(car bF)(car bI)) y2(-(cadr bF)(cadr bI)) z2(-(caddr bF)(caddr bI))
    ;(list x2 y2 z2)
    ;PRODUTO ESCALAR
    orto(+(* x1 x2)(* y1 y2)(* z1 y2))
    )
  (princ"\nOrto=")(princ(if(equal orto 0 16)"Perpendicular...\n""Não é perpendicular...\n"))
  (princ(rtos orto 2 3))
  (princ)
  )

(defun c:paral();LINHAS PARALELAS // (PRODUTO VETORIAL)
  (setq
    a(vlax-ename->vla-object(car(entsel"\nLinha A: ")))
    aI(vlax-curve-getstartpoint a) aF(vlax-curve-getendpoint a)
    b(vlax-ename->vla-object(car(entsel"\tLinha B: ")))
    bI(vlax-curve-getstartpoint b) bF(vlax-curve-getendpoint b)
    ;A->
    x1(-(car aF)(car aI)) y1(-(cadr aF)(cadr aI)) z1(-(caddr aF)(caddr aI))
    ;(list x1 y1 z1)
    ;B->
    x2(-(car bF)(car bI)) y2(-(cadr bF)(cadr bI)) z2(-(caddr bF)(caddr bI))
    ;PRODUTO VETORIAL
    i(+(* y1 z2)(*(* y2 z1)-1))
    j(+(* z1 x2)(*(* z2 x1)-1))
    k(+(* x1 y2)(*(* x2 y1)-1))
    )
  (princ"\n")
  (princ(if(and(= i 0)(= j 0)(= k 0))"Paralelo...""Não paralelo..."))
  (princ)
  )


;|
(repeat 3
(progn
(setq a(vlax-ename->vla-object(car(entsel"\nLinha A: ")))
      aI(vlax-curve-getstartpoint a)
      aF(vlax-curve-getendpoint a)
      )
(princ
  (vl-string-translate"."","(strcat
			      "\n"(rtos(car aI)2 6)"\t"(rtos(cadr aI)2 6)"\t"(rtos(caddr aI)2 6)
			      "\t"(rtos(car aF)2 6)"\t"(rtos(cadr aF)2 6)"\t"(rtos(caddr aF)2 6)
			      )
    )
  )
)
)
|;