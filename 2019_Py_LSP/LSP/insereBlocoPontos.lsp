(defun c:insereBlocoPontos (/ cad doc MSpace *error*)
  
  (defun *error* (msg)
    (princ msg)
    (setvar 'cmdecho 1)
    (vla-endundomark doc)
    (princ)
  )
  
  (defun string->list ( String delimiter / len lst pos )
    (setq len (1+ (strlen delimiter)))
    (while (setq pos (vl-string-search delimiter String))
      (setq lst (cons (substr String 1 pos) lst)
            String (substr String (+ pos len))
      )
    )
    (reverse (cons String lst))
  )
  
  (defun DocReader (/ TextLine TextFullFile)
    
    
    (alert
      (strcat
        "O as colunas devem estar separadas por \";\"!!!"
        "\n"
        "A primeira linha configura a ordem da planilha!!!"
      )
    )

    (setq
      file(getfiled "Selecione o arquivo TXT..." (getvar'dwgprefix) "txt" 8)
      fso(vlax-create-object "Scripting.FileSystemObject")
    )

    (if
      file
      (if
        (vlax-invoke fso 'FileExists file)
        (setq
          fileStream
           (vlax-invoke fso 'OpenTextFile file 1)
        )
      )
    )

    (while
      (= (vlax-get-property fileStream 'AtEndOfStream) :vlax-false)
      (setq
        TextLine(vlax-invoke fileStream 'ReadLine)
        TextFullFile(vl-list* TextLine TextFullFile)
      )
    )
    (vlax-invoke fileStream 'Close)
    (vlax-release-object fileStream)
    (vlax-release-object fso)
    
    (reverse TextFullFile)
  )
  
  (defun main();DocumentDataTempStream)
    ; Nome;Tipo;Este;Norte;Elevacao;Profundidade

    (setq
      DocumentDataTempStream
       (DocReader)
      ConfigLine(nth 0 DocumentDataTempStream)
    )
    
  )
  
  (setq
    cad(vlax-get-acad-object)
    doc(vla-get-activedocument cad)
    MSpace(vla-get-modelspace doc)
  )
  
  (vla-startundomark doc)
  (setvar 'cmdecho 0)
  (main)
  (setvar 'cmdecho 1)
  (vla-endundomark doc)
  (princ)
    
)