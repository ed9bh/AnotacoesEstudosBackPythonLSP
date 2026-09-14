; =========================================================================================
; INFORMAÇÕES
; Objetivo: Obter distância, deltas (X, Y), inclinação (%) e proporção Run:Rise (H:V) ;[cite: 1, 2]
; 2026-03-30 - Elaborador Eric Drumond (ED Serviços & Projetos) - Gemini 2.5 Pro ;[cite: 2]
; 2026-03-30 / Rev 03 ;[cite: 2]
; Exclusividade/Compatibilidade: AutoCAD [X] / Civil 3D [X] / Plant [X] / Architeture [X] ;[cite: 2]
; Compatibilidade Adicional: ZWCAD [X] / BricsCAD [X] / IntelliCAD [X] ;[cite: 2]
; Referencia Externa: Não [X] / AutoLisp / DWG(Assets) [ ] / CSV [ ] / TXT [ ] / Excel [ ] ;[cite: 2]
; DCL: Sim [ ] / Não [X] ;[cite: 2]
; =========================================================================================

(vl-load-com) ;[cite: 2]

(defun c:pdi ( / *error* acad doc mspace oldCmdecho iedg:LogReport ia:FormatRunRise ia:CalculatePDI main ) ;[cite: 1, 2, 3]
  (vl-load-com) ;[cite: 2]

  ;;; --------------------------------------> SubFunções: Erro e Registro

  ;;; Sub-Função 1.0: Manipulador de erro resiliente com ID e gravação em log ;[cite: 2, 3]
  (defun *error* ( msg / errId logFolder logPath logFile ) ;[cite: 2, 3]
    (if (and doc (= 1 (logand 1 (getvar 'cmdactive)))) ;[cite: 3]
      (vl-catch-all-apply 'vla-endundomark (list doc)) ;[cite: 3]
    )
    (if oldCmdecho (setvar 'cmdecho oldCmdecho))

    (if (not (member msg '("Function cancelled" "quit / exit abort"))) ;[cite: 3]
      (progn
        (setq errId (strcat "ERR-" (vl-string-translate "." "_" (rtos (getvar 'cdate) 2 6)))) ;[cite: 2, 3]
        (princ (strcat "\n[PDI-" errId "] Erro: " msg)) ;[cite: 2, 3]
        (setq logFolder (getvar 'dwgprefix)) ;[cite: 3]
        (if (not (vl-file-directory-p logFolder)) ;[cite: 2]
          (setq logFolder (strcat (getenv "TEMP") "\\")) ;[cite: 2]
        )
        (setq logPath (strcat logFolder "PDI_ErrorReport.log"))
        (if (setq logFile (open logPath "a")) ;[cite: 3]
          (progn
            (write-line (strcat "[" (rtos (getvar 'cdate) 2 6) "] [" errId "] " msg) logFile) ;[cite: 2, 3]
            (close logFile) ;[cite: 3]
          )
        )
      )
    )
    (princ) ;[cite: 1, 3]
  )

  ;;; Sub-Função 2.0: Gravação do histórico de medições adaptada de LogReport ;[cite: 2, 3]
  (defun iedg:LogReport ( msg / logFolder logPath logFileOpened ) ;[cite: 2, 3]
    (setq logFolder (getvar 'dwgprefix)) ;[cite: 3]
    (if (not (vl-file-directory-p logFolder)) ;[cite: 2]
      (setq logFolder (strcat (getenv "TEMP") "\\")) ;[cite: 2]
    )
    (setq logPath (strcat logFolder "LogReport(" (vl-string-right-trim ".dwg" (getvar 'dwgname)) ").log")) ;[cite: 3]
    (if (setq logFileOpened (open logPath "a+")) ;[cite: 3]
      (progn
        (write-line (strcat "Log[" (vl-string-translate "." "_" (rtos (getvar 'cdate) 2 6)) "]:> " (if msg msg "...")) logFileOpened) ;[cite: 3]
        (close logFileOpened) ;[cite: 3]
      )
    )
  )

  ;;; --------------------------------------> SubFunções: Geometria e Formatação

  ;;; Sub-Função 3.0: Formatação de inclinação na proporção Run:Rise (Horizontal:Vertical) ;[cite: 2]
  ;|
     Run = DeltaX (Afastamento Horizontal)
     Rise = DeltaY (Afastamento Vertical)
     Proporção H:V = (DeltaX / DeltaY) : 1 ou 1 : (DeltaY / DeltaX)
     Se DeltaX = 0 -> Vertical / Infinito
     Se DeltaY = 0 -> Nível Plano (1:0.00)
  |; ;[cite: 2]
  (defun ia:FormatRunRise ( dx dy / absX absY ) ;[cite: 2]
    (setq absX (abs dx) ;[cite: 1]
          absY (abs dy) ;[cite: 1]
    )
    (cond
      ((equal absX 0.0 1e-6) "1:Infinito (Vertical)")
      ((equal absY 0.0 1e-6) "1:0.00 (Plano)")
      ((>= absX absY)
        (strcat (rtos (/ absX absY) 2 2) ":1 (H:V)")
      )
      (t
        (strcat "1:" (rtos (/ absY absX) 2 2) " (H:V)")
      )
    )
  )

  ;;; Sub-Função 4.0: Cálculo de distâncias, deltas, percentual e montagem de relatório ;[cite: 1, 2]
  ;|
     LinearDist = sqrt((X2 - X1)^2 + (Y2 - Y1)^2)
     DeltaX = X2 - X1
     DeltaY = Y2 - Y1
     Inclinacao (%) = (DeltaY / DeltaX) * 100.0
  |; ;[cite: 1, 2]
  (defun ia:CalculatePDI ( pt1 pt2 / linearDist deltaX deltaY pct runRiseStr outStr ) ;[cite: 1, 2]
    (setq linearDist (distance (list (car pt1) (cadr pt1)) (list (car pt2) (cadr pt2))) ;[cite: 1]
          deltaX     (- (car pt2) (car pt1)) ;[cite: 1]
          deltaY     (- (cadr pt2) (cadr pt1)) ;[cite: 1]
    )
    (if (equal deltaX 0.0 1e-6)
      (setq pct "Infinito")
      (setq pct (strcat (rtos (* (/ deltaY deltaX) 100.0) 2 2) "%")) ;[cite: 1]
    )
    (setq runRiseStr (ia:FormatRunRise deltaX deltaY)) ;[cite: 2]
    (setq outStr
      (strcat
        "\nDistancia: " (rtos linearDist 2 3) "m" ;[cite: 1]
        " | Delta X: " (rtos deltaX 2 3) "m" ;[cite: 1]
        " | Delta Y: " (rtos deltaY 2 3) "m" ;[cite: 1]
        " | Inclinacao: " pct ;[cite: 1]
        " | Run:Rise: " runRiseStr
      )
    )
    (princ outStr) ;[cite: 1]
    (iedg:LogReport (strcat "PDI executado: " outStr)) ;[cite: 2, 3]
  )

  ;;; --------------------------------------> Main

  ;;; Sub-Função 5.0: Fluxo principal de interação e coleta de pontos ;[cite: 1, 2, 3]
  (defun main ( / point1 point2 ) ;[cite: 1, 2, 3]
    (setq point1 (getpoint "\nClique no primeiro ponto: ")) ;[cite: 1]
    (if point1
      (progn
        (setq point2 (getpoint point1 "\nClique no segundo ponto: ")) ;[cite: 1]
        (if point2
          (ia:CalculatePDI point1 point2) ;[cite: 1, 2]
          (princ "\nSegundo ponto não informado.")
        )
      )
      (princ "\nPrimeiro ponto não informado.")
    )
  )

  ;;; --------------------------------------> Inicialização e Execução

  (setq acad   (vlax-get-acad-object) ;[cite: 3]
        doc    (vla-get-activedocument acad) ;[cite: 3]
        mspace (vla-get-modelspace doc) ;[cite: 3]
  )

  (vla-startundomark doc) ;[cite: 3]
  (setq oldCmdecho (getvar 'cmdecho))
  (setvar 'cmdecho 0) ;[cite: 3]

  (main) ;[cite: 3]

  (setvar 'cmdecho oldCmdecho)
  (vla-endundomark doc) ;[cite: 3]
  (princ) ;[cite: 1, 2, 3]
)