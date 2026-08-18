(defun c:DynamicArea ()

  (vl-load-com)

  (defun *error* (msg)
    (princ msg)
    (killReactors)
    (princ)
  )

  ;; 1. Função que apenas printa a área
  (defun princ-area (vlao)
    (if (vlax-read-enabled-p vlao)
      (princ
        (strcat
          "\n[Atualizado] Area: " (rtos (vlax-get vlao 'Area) 2 2)
          "m² | Extensão: " (rtos (vlax-get vlao 'Length) 2 2) "m"
        )
      )
    )
  )
  
  ;; 2. Callback do Objeto: Ele não printa nada! Só prepara o terreno.
  (defun Area-Object-Callback (vlao reactor params)
    ;; Guarda o objeto que foi mexido em uma variável global temporária
    (setq *ModifyingObj* vlao)
    
    ;; Remove temporariamente o reator do objeto para evitar loops nativos
    (vlr-remove reactor)
    
    ;; Cria o reator de comando que vai esperar o usuário soltar o mouse
    (if (not *CmdReactor*)
      (setq *CmdReactor*
        (vlr-command-reactor (list reactor) ;; Passa o reator de objeto junto
          '(
            (:vlr-commandended . Area-Command-Ended)
            (:vlr-commandcancelled . Area-Command-Cancelled)
            (:vlr-commandfailed . Area-Command-Cancelled)
          )
        )
      )
    )
    (princ)
  )

  ;; 3. Callback de Fim de Comando: Aqui a mágica acontece com segurança
  (defun Area-Command-Ended (cmdReactor params / objReactor)
    ;; Recupera o reator de objeto que guardamos ali em cima
    (setq objReactor (car (vlr-data cmdReactor)))
    
    ;; Agora que o comando acabou, printamos a área com segurança
    (if *ModifyingObj*
      (progn
        (princ-area *ModifyingObj*)
        (setq *ModifyingObj* nil)
      )
    )
    
    ;; Reativa o reator do objeto para a próxima modificação
    (if objReactor (vlr-add objReactor))
    
    ;; Remove este reator de comando temporário da memória
    (vlr-remove cmdReactor)
    (setq *CmdReactor* nil)
    (princ)
  )

  ;; 4. Se o usuário cancelar o comando (ex: apertar ESC no meio do arrasto)
  (defun Area-Command-Cancelled (cmdReactor params / objReactor)
    (setq objReactor (car (vlr-data cmdReactor)))
    (if objReactor (vlr-add objReactor))
    (vlr-remove cmdReactor)
    (setq *CmdReactor* nil)
    (setq *ModifyingObj* nil)
    (princ)
  )
  
  (defun AreaErased (vlao reactor params)
    (killReactors)
  )
  
  (defun killReactors ()
    (if (and *PoligonalReactor* (vlr-added-p *PoligonalReactor*))
      (vlr-remove *PoligonalReactor*)
    )
    (if *CmdReactor*
      (vlr-remove *CmdReactor*)
    )
    (setq *PoligonalReactor* nil *CmdReactor* nil *ModifyingObj* nil)
  )
  
  ;; --- Fluxo Principal ---
  (killReactors)
  
  (setq Poligonal (entsel "\tEntidade a Extrair Area Dynamica:> "))
  
  (if Poligonal
    (progn
      (setq vlaObj (vlax-ename->vla-object (car Poligonal)))
      
      (setq *PoligonalReactor*
        (vlr-object-reactor
          (list vlaObj)
          "ReatorDeArea"
          '(
            (:vlr-modified . Area-Object-Callback)
            (:vlr-erased . AreaErased)
          )
        )
      )
      (princ-area vlaObj)
    )
    (princ "\nNenhuma entidade selecionada.")
  )
  (princ)
)