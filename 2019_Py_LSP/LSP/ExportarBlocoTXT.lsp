; =========================================================================================
; INFORMAÇÕES
; Objetivo: Centralizar seleção (sem apagar a original) e exportar código LISP para recriar as entidades como Bloco.
; Data Inicial - Elaborador Eric Drumond - Gerador de AutoLISP / V1.1
; Data Revisão / 01
; Exclusividade/Compatibilidade: AutoCAD [X] / Civil 3D [X] / Plant [X] / Architeture [X]
; Referencia Externa: Não [X] / AutoLisp / DWG(Assets) [ ] / CSV [ ] / TXT [X] / Excel [ ]
; DCL: Sim [ ] / Não [X]
; Limitações: Entidades altamente complexas (Proxies, Superfícies C3D) podem não ser suportadas pela função (entmake) pura gerada. Totalmente compatível com ZWCAD/IntelliCAD.
; =========================================================================================

(vl-load-com)

(defun c:ExportarBlocoTXT ( / *error* acad doc mspace GetSSCenter MoveSS CleanDXF CopySS Main var_cmdecho )
  
  ;;; --------------------------------------> Funções de Erro
  
  (defun *error* ( msg / dateStr errID logPath f tempPath )
    (if doc (vla-endundomark doc))
    (if var_cmdecho (setvar 'cmdecho var_cmdecho))
    (if (not (member msg '("Function cancelled" "quit / exit abort")))
      (progn
        (setq dateStr (rtos (getvar "CDATE") 2 6))
        (setq errID (strcat "ERR-" (vl-string-translate "." "" dateStr)))
        (setq logPath (strcat (getvar "DWGPREFIX") "ErrorLog_LISP_" errID ".txt"))
        
        (setq f (open logPath "w"))
        (if (not f)
          (progn
            (setq tempPath (getenv "TEMP"))
            (setq logPath (strcat tempPath "\\ErrorLog_LISP_" errID ".txt"))
            (setq f (open logPath "w"))
          )
        )
        
        (if f
          (progn
            (write-line (strcat "Data/Hora: " dateStr) f)
            (write-line (strcat "ID Erro: " errID) f)
            (write-line (strcat "Mensagem: " msg) f)
            (close f)
            (princ (strcat "\nErro critico! Log salvo em: " logPath))
          )
          (princ (strcat "\nErro: " msg))
        )
      )
    )
    (princ)
  )

  ;;; --------------------------------------> SubFunções
  
  ; Calcula o Centro Geométrico da Seleção via BoundingBox
  (defun GetSSCenter ( ss / i ent vlaobj minPt maxPt lstMinX lstMinY lstMinZ lstMaxX lstMaxY lstMaxZ p1 p2 )
    (setq i 0)
    (while (< i (sslength ss))
      (setq ent (ssname ss i)
            vlaobj (vlax-ename->vla-object ent))
      (if (not (vl-catch-all-error-p (vl-catch-all-apply 'vla-GetBoundingBox (list vlaobj 'minPt 'maxPt))))
        (progn
          (setq p1 (vlax-safearray->list minPt)
                p2 (vlax-safearray->list maxPt))
          (setq lstMinX (cons (car p1) lstMinX)
                lstMinY (cons (cadr p1) lstMinY)
                lstMinZ (cons (caddr p1) lstMinZ)
                lstMaxX (cons (car p2) lstMaxX)
                lstMaxY (cons (cadr p2) lstMaxY)
                lstMaxZ (cons (caddr p2) lstMaxZ))
        )
      )
      (setq i (1+ i))
    )
    (if (and lstMinX lstMaxX)
      (list
        (/ (+ (apply 'min lstMinX) (apply 'max lstMaxX)) 2.0)
        (/ (+ (apply 'min lstMinY) (apply 'max lstMaxY)) 2.0)
        (/ (+ (apply 'min lstMinZ) (apply 'max lstMaxZ)) 2.0)
      )
      nil
    )
  )

  ; Move uma Seleção de Entidades de um Ponto a Outro
  (defun MoveSS ( ss fromPt toPt / i ent vlaobj p1 p2 )
    (setq p1 (vlax-3d-point fromPt)
          p2 (vlax-3d-point toPt)
          i 0)
    (while (< i (sslength ss))
      (setq ent (ssname ss i)
            vlaobj (vlax-ename->vla-object ent))
      (vl-catch-all-apply 'vla-Move (list vlaobj p1 p2))
      (setq i (1+ i))
    )
  )

  ; Cria uma cópia da seleção original e retorna o novo selection set
  (defun CopySS ( ss / i ent newEnt newSS )
    (setq newSS (ssadd))
    (setq i 0)
    (while (< i (sslength ss))
      (setq ent (ssname ss i))
      (setq newEnt (entmakex (entget ent)))
      (if newEnt
        (ssadd newEnt newSS)
      )
      (setq i (1+ i))
    )
    newSS
  )

  ; Limpa o DXF da entidade retirando Handles (-1, 5, 330) para evitar conflitos no entmake
  (defun CleanDXF ( ent / edata new )
    (setq edata (entget ent))
    (foreach itm edata
      (if (not (vl-position (car itm) '(-1 5 330)))
        (setq new (cons itm new))
      )
    )
    (reverse new)
  )

  ;;; --------------------------------------> Main
  
  (defun Main ( / ss ssCopy center blockname filename f i ent dxfstr )
    (princ "\nSelecione as entidades para exportar:")
    (if (setq ss (ssget))
      (progn
        (setq center (GetSSCenter ss))
        (if center
          (progn
            ; 1. Copia as entidades para manipular sem afetar as originais
            (setq ssCopy (CopySS ss))
            (princ "\n>> Cópia temporária das entidades gerada...")

            ; 2. Move a cópia para a origem (0,0,0)
            (MoveSS ssCopy center '(0.0 0.0 0.0))
            (princ "\n>> Entidades temporárias centralizadas em X=0, Y=0, Z=0...")

            ; 3. Captura Nome e Local de Salvamento
            (setq blockname (getstring "\nDigite o nome do Bloco a ser gerado via LISP: "))
            (if (or (= blockname "") (= blockname nil)) (setq blockname "BlocoGeradoAutomaticamente"))
            
            (setq filename (getfiled "Salvar Código LISP" (strcat (getvar "DWGPREFIX") blockname ".txt") "txt" 1))

            ; 4. Escreve a Rotina
            (if filename
              (progn
                (setq f (open filename "w"))
                
                ; Cabeçalho LISP no arquivo TXT
                (write-line (strcat "(defun c:CriarBloco_" blockname " ( / )") f)
                (write-line (strcat "  (entmake '((0 . \"BLOCK\") (2 . \"" blockname "\") (70 . 0) (10 0.0 0.0 0.0)))") f)

                ; Loop para extrair coordenadas e formatar DXF para (entmake) baseando-se na CÓPIA
                (setq i 0)
                (while (< i (sslength ssCopy))
                  (setq ent (ssname ssCopy i))
                  (setq dxfstr (vl-prin1-to-string (CleanDXF ent)))
                  (write-line (strcat "  (entmake '" dxfstr ")") f)
                  (setq i (1+ i))
                )

                ; Rodapé LISP no arquivo TXT
                (write-line "  (entmake '((0 . \"ENDBLK\")))" f)
                (write-line (strcat "  (command \"_.-insert\" \"" blockname "\" (getpoint \"\\nSelecione o Ponto de Insercao do Bloco: \") 1 1 0)") f)
                (write-line "  (princ)" f)
                (write-line ")" f)
                (write-line (strcat "(princ \"\\n>>> Comando [ c:CriarBloco_" blockname " ] carregado com sucesso!\")") f)
                (write-line "(princ)" f)
                
                (close f)
                (princ (strcat "\n>> Sucesso! Rotina salva em: " filename))
              )
              (princ "\n>> Exportação cancelada pelo usuário.")
            )

            ; 5. Deleta a cópia temporária usada para extrair as coordenadas
            (setq i 0)
            (while (< i (sslength ssCopy))
              (entdel (ssname ssCopy i))
              (setq i (1+ i))
            )
            (princ "\n>> Entidades temporárias removidas, seleção original intacta.")
          )
          (princ "\n>> Erro ao calcular o centro geométrico das entidades selecionadas.")
        )
      )
      (princ "\n>> Nenhuma entidade foi selecionada.")
    )
  )

  ;;; --------------------------------------> Definições Iniciais e Execução
  
  (setq
    acad (vlax-get-acad-object)
    doc (vla-get-activedocument acad)
    mspace (vla-get-modelspace doc)
    var_cmdecho (getvar 'cmdecho)
  )
  
  (vla-startundomark doc)
  (setvar 'cmdecho 0)
  
  (Main)
  
  (setvar 'cmdecho var_cmdecho)
  (vla-endundomark doc)
  (princ)
)