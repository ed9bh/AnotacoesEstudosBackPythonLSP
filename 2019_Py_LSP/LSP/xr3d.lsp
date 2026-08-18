(defun c:xr3d ()
  
  (princ "\nSelecione as entitdades a rotacionar : ")
  
  (setq
    ss(ssget)
    p1(getpoint "\nSelecione o ponto 1 : ")
    p2(getpoint p1 "\tSelecione o ponto 2 : ")
    os(getvar"osmode")
  )
  
  (setvar"osmode"0)
  
  (command "rotate3d" ss "" p1 p2 -90)
  (command "rotate" ss "" p1 "r" p1 p2 (angle p1 (list (1+(car p1)) (cadr p1) (caddr p1))))
  (command "plan" "")
  
  (setvar"osmode"os)
  (princ)
  
)

;|EDG(2025)[https://www.linkedin.com/in/ericdrumond]{https://github.com/ed9bh}|;