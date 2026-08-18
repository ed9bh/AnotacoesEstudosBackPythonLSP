(defun c:add2blk ( / blkEnt blkObj blkName blkDef ss i ents arr doc blks ins rot sclX p0 insPt obj)
  (vl-load-com)
  (setq doc (vla-get-ActiveDocument (vlax-get-acad-object)))
  (setq blks (vla-get-Blocks doc))

  ;; 1. Seleciona o bloco de destino
  (setq blkEnt (car (entsel "\nSelecione o bloco de destino: ")))
  (if (and blkEnt (= (cdr (assoc 0 (entget blkEnt))) "INSERT"))
    (progn
      (setq blkObj (vlax-ename->vla-object blkEnt))
      
      ;; Identifica o nome do bloco (suporta blocos dinâmicos)
      (setq blkName (if (vlax-property-available-p blkObj 'EffectiveName)
                      (vla-get-EffectiveName blkObj)
                      (vla-get-Name blkObj)
                    )
      )
      (setq blkDef (vla-Item blks blkName))

      ;; Obtém propriedades do bloco para transformação geométrica
      (setq ins (vlax-get blkObj 'InsertionPoint))
      (setq rot (vla-get-Rotation blkObj))
      (setq sclX (vla-get-XScaleFactor blkObj))
      (setq p0 (vlax-3d-point '(0.0 0.0 0.0)))
      (setq insPt (vlax-3d-point ins))

      ;; 2. Seleciona as entidades a serem movidas
      (prompt "\nSelecione as entidades para mover para o bloco: ")
      (if (setq ss (ssget))
        (progn
          (setq ents nil i 0)
          (while (< i (sslength ss))
            (setq obj (vlax-ename->vla-object (ssname ss i)))

            ;; Move o objeto para a origem relativa ao bloco
            (vla-Move obj insPt p0)
            ;; Ajusta a rotação
            (if (/= rot 0.0) (vla-Rotate obj p0 (- rot)))
            ;; Ajusta a escala (considera escala uniforme)
            (if (/= sclX 1.0) (vla-ScaleEntity obj p0 (/ 1.0 sclX)))

            (setq ents (cons obj ents))
            (setq i (1+ i))
          )

          ;; Prepara as entidades para cópia (SafeArray exigido pelo ActiveX)
          (setq arr (vlax-make-safearray vlax-vbObject (cons 0 (1- (length ents)))))
          (vlax-safearray-fill arr ents)

          ;; Copia os objetos direto para a definição do bloco
          (if (not (vl-catch-all-error-p
                     (vl-catch-all-apply 'vla-CopyObjects (list doc arr blkDef))
                   ))
            (progn
              ;; Exclui os originais que foram transformados (efetivando a operação "Mover")
              (foreach ent ents (vla-Delete ent))
              
              ;; Regenera o desenho para exibir as mudanças imediatamente
              (vla-Regen doc acAllViewports)
              (princ (strcat "\n" (itoa (length ents)) " entidade(s) movida(s) para o bloco '" blkName "' com sucesso!"))
            )
            (princ "\nErro: Não foi possível adicionar as entidades à definição do bloco.")
          )
        )
        (princ "\nNenhuma entidade selecionada.")
      )
    )
    (princ "\nErro: O objeto selecionado não é um bloco.")
  )
  (princ)
)