;|
XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
ROTINA REFORMULADA E MODERNIZADA PARA OTIMIZAÇÃO DE MEDIÇÕES (DISTÂNCIAS 2D/3D, ÁREAS E ESTACAS)
DESENVOLVEDOR ORIGINAL: ERIC DRUMOND (07/2013)
XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
|;

(defun c:xdi (/ *error* acDoc sysVars oldVars obj ss pt1 pt2 pt2A objE objName dist dist2D dist3D azi deltaX deltaY inc area est1 est2 formatarEstaca)
  (vl-load-com)
  
  ;; --- SUBFUNÇÃO: TRATAMENTO DE ERROS ---
  (defun *error* (msg)
    (if (and msg (not (wcmatch (strcase msg t) "*cancel*,*exit*")))
      (princ (strcat "\nErro: " msg))
    )
    ;; Restaura as variáveis de sistema originais
    (if oldVars
      (mapcar '(lambda (v val) (setvar v val)) sysVars oldVars)
    )
    (vla-EndUndoMark acDoc)
    (princ)
  )

  ;; --- SUBFUNÇÃO: FORMATADOR DE ESTACAS (Padrão 20m) ---
  (defun formatarEstaca (distReal)
    (if distReal
      (strcat 
        (itoa (fix (/ distReal 20.0))) 
        "+" 
        (rtos (rem distReal 20.0) 2 3)
      )
      nil
    )
  )

  ;; --- CONFIGURAÇÃO INICIAL E AMBIENTE ---
  (setq acDoc (vla-get-ActiveDocument (vlax-get-acad-object)))
  (vla-StartUndoMark acDoc)
  
  (setq sysVars '("lunits" "aunits" "angdir" "angbase" "insunits" "dimzin")
        oldVars (mapcar 'getvar sysVars)
  )
  ;; Força unidades e precisões adequadas para cálculo técnico
  (mapcar '(lambda (v val) (setvar v val)) sysVars '(2 1 1 1.5708 0 0))

  ;; --- SELEÇÃO DA ENTIDADE ---
  (princ "\nSelecione a entidade a medir ou <enter/botão dir. para pontos livres>: ")
  (setq ss (ssget ":S" '((0 . "LINE,LWPOLYLINE,POLYLINE,CIRCLE,SPLINE,ARC"))))
  
  (if ss
    ;; SE SELECIONOU UMA ENTIDADE
    (progn
      (setq obj   (ssname ss 0)
            objE  (vlax-ename->vla-object obj)
            objName (vlax-get objE 'ObjectName)
      )
      
      (setq pt1 (getpoint "\nClique no ponto inicial ou <enter/botão dir.> para comprimento total: "))
      (if pt1
        (progn
          (setq pt2A (getpoint pt1 "\tClique no ponto final ou <enter/botão dir.>: "))
          (if (not pt2A)
            ;; Se não clicou no ponto final, adota o ponto inicial da curva como destino
            (setq pt2 (vlax-curve-getStartPoint objE))
            (setq pt2 pt2A)
          )
        )
      )
      
      ;; Cálculos baseados na curva
      (if pt1
        (progn
          ;; Medições parciais na entidade
          (setq dist1 (vlax-curve-getDistAtPoint objE (vlax-curve-getClosestPointTo objE pt1))
                dist2 (vlax-curve-getDistAtPoint objE (vlax-curve-getClosestPointTo objE pt2))
                dist  (abs (- dist2 dist1))
                est1  (formatarEstaca dist1)
                est2  (formatarEstaca dist2)
          )
          (if pt2A
            (princ (strcat "\nDistancia de ponto \"A\" ao \"B\" na entidade: " (rtos dist 2)))
            (princ (strcat "\nDistancia do ponto ao início da entidade: " (rtos dist 2)))
          )
          ;; Exibe estacas se a linha comentada abaixo for reativada por você
          (princ (strcat "\n[Eixo] Estaca Inicial: " est1 " | Estaca Final: " est2))
        )
        (progn
          ;; Medição Total da Entidade usando propriedades ActiveX nativas
          (setq dist
            (cond
              ((wcmatch objName "*Polyline,*Line") (vlax-get objE 'Length))
              ((= objName "AcDbArc") (vlax-get objE 'ArcLength))
              ((= objName "AcDbCircle") (vlax-get objE 'Circumference))
              (t (vlax-curve-getDistAtParam objE (vlax-curve-getEndParam objE)))
            )
          )
          (setq area (if (= (vlax-get objE 'Closed) :vlax-true) (vlax-get objE 'Area) nil))
          (princ (strcat "\nDistancia total da entidade: " (rtos dist 2) (if area (strcat " - Área: " (rtos area 2)) "")))
        )
      )
    )
    
    ;; SE NÃO SELECIONOU ENTIDADE (MODO DISTÂNCIA TRADICIONAL / PONTOS LIVRES)
    (progn
      (setq pt1 (getpoint "\nClique no primeiro ponto: "))
      (if pt1
        (progn
          (setq pt2 (getpoint pt1 "\nClique no próximo ponto: "))
          (if pt2
            (progn
              (setq dist2D (distance (list (car pt1) (cadr pt1)) (list (car pt2) (cadr pt2)))
                    dist3D (distance pt1 pt2)
                    azi    (angle pt1 pt2)
                    deltaX (- (car pt2) (car pt1))
                    deltaY (- (cadr pt2) (cadr pt1))
              )
              (princ
                (strcat
                  "\nDistancia 2D: "
                  (rtos dist2D 2)
                  " - Azimute: "
                  (vl-string-translate "d" "°" (angtos azi 1))
                  " - Delta X: "
                  (rtos deltaX 2)
                  " / Delta Y: "
                  (rtos deltaY 2))
              )
              ;; Se houver diferença de Z (3D)
              (if (not (equal dist2D dist3D 0.0001))
                (progn
                  (setq inc (* (/ (- (caddr pt2) (caddr pt1)) dist2D) 100.0))
                  (princ
                    (strcat
                      "\nDistancia 3D: "
                      (rtos dist3D 2)
                      " - Inclinação(%): "
                      (rtos inc 2)
                      " - Inclinação(H/V): "
                      (rtos (abs(/ dist2D (- (caddr pt2) (caddr pt1)) )) 2)
                      "/1 - Delta Z: "
                      (rtos (- (caddr pt2) (caddr pt1)) 2))
                  )
                )
              )
            )
          )
        )
      )
    )
  )

  ;; Finaliza restaurando as variáveis de sistema originais com segurança
  (*error* nil)
  (princ)
)