;;; ==========================================================================
;;; Nome da Rotina: AREA2D
;;; Objetivo: Calcular a área 2D (planimétrica) de uma 3D Polyline.
;;; Data e Hora da Última Modificação: 03 de Agosto de 2026 às 14:34:52 -03
;;; Localização: Belo Horizonte, Estado de Minas Gerais, Brasil
;;; Compatibilidade: ZWCAD / AutoCAD (Visual LISP)
;;; ==========================================================================

(vl-load-com)

;;; --------------------------------------> Funções de Suporte (Base: ___Exemplo.txt)
(defun c:Area2D (/ acad doc MSpace)
;;; Função de Tratamento de Erro [cite: 1]
(defun error (msg)
  (vla-endundomark doc)
  (if (not (member msg '("Function cancelled" "quit / exit abort")))
    (princ (strcat "\nErro: " msg))
  )
  (princ)
)

;;; Listar Coordenadas de Polyline 3D [cite: 2]
(defun ListCoords3D (VLAO_3DPoly / Coords CoordsSanitized XYZ X Y Z)
  (setq Coords (vlax-get VLAO_3DPoly 'Coordinates)
        XYZ 0 X nil Y nil Z nil CoordsSanitized nil
  )
  (foreach item Coords
    (cond
      ((equal XYZ 0) (setq X item XYZ (1+ XYZ)))
      ((equal XYZ 1) (setq Y item XYZ (1+ XYZ)))
      ((equal XYZ 2)
       (setq Z item
             ;; Omitido o 'princ' original para não poluir a linha de comando durante a extração matemática
             CoordsSanitized (vl-list* (list X Y Z) CoordsSanitized) 
             XYZ 0 X nil Y nil Z nil
       )
      )
    )
  )
  (reverse CoordsSanitized)
)

;;; --------------------------------------> Funções Auxiliares (Cálculo)

;;; Calcular Área 2D usando a Fórmula de Shoelace (Teorema de Gauss)
;;; Inspiração matemática baseada em métodos convencionais (ex: Lee Mac)
(defun CalcArea2D ( ptList / area i j p1 p2 )
  (setq area 0.0
        i 0
        j (1- (length ptList))
  )
  (while (< i (length ptList))
    (setq p1 (nth i ptList)
          p2 (nth j ptList)
    )
    ;; Multiplicação cruzada de X e Y ignorando a coordenada Z
    (setq area (+ area (- (* (car p1) (cadr p2)) (* (car p2) (cadr p1)))))
    (setq j i
          i (1+ i)
    )
  )
  ;; Retorna o valor absoluto da metade da área resultante
  (abs (/ area 2.0))
)

;;; --------------------------------------> Main [cite: 17]
(defun main (/ ent vlao objpts area)
  (setq ent (entsel "\nSelecione a 3D Polyline para calcular a area 2D: "))
  (if ent
    (progn
      (setq vlao (vlax-ename->vla-object (car ent)))
      ;; Verifica se a entidade selecionada é realmente uma Polilinha 3D
      (if (= (vlax-get-property vlao 'ObjectName) "AcDb3dPolyline")
        (progn
          (setq objpts (ListCoords3D vlao))
          (setq area (CalcArea2D objpts))
          (princ (strcat "\n>> A Area 2D (Planimetrica) calculada e: " (rtos area 2 4) " <<"))
          ;(alert (strcat "Area 2D da 3D Polyline: \n\n" (rtos area 2 4)))
        )
        (princ "\nErro: O objeto selecionado nao e uma 3D Polyline.")
      )
    )
    (princ "\nNenhum objeto selecionado.")
  )
)

;;; --------------------------------------> Rotina [cite: 17, 18]

  ;; Configuração do ambiente AutoCAD / ZWCAD
  (setq acad (vlax-get-acad-object)
        doc  (vla-get-activedocument acad)
        MSpace (vla-get-modelspace doc)
  )
  
  ;; Início da rotina com agrupamento de Undo [cite: 18]
  (vla-startundomark doc) 
  (setvar 'cmdecho 0) 
  
  (main) 
  
  (setvar 'cmdecho 1) 
  (vla-endundomark doc) 
  (princ) 
)