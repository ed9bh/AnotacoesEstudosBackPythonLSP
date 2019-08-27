(defun c:CadTextToExcel()
  (setq err *error*)
  (defun *error*(msg)
    (setq *error* err)
    (princ"\n\tErro ocorrido : ")
    (princ msg)
    (foreach x MarkList (vla-Delete x))
    (vla-put-visible excel :vlax-true)
    (vlax-release-object excel)
    (princ)
    )
  (setq
    excel(vlax-get-or-create-object "Excel.Application")
    workbooks(vlax-get excel 'workbooks)
    book(vlax-invoke-method workbooks 'add)
    sheets(vlax-get book 'sheets)
    table(vlax-get-property sheets 'Item 1)
    cells(vlax-get table "cells")
    Line 1
    MarkList nil
    )

  (vla-put-visible excel :vlax-true)

  (while (setq Pa(getpoint"\rClique no ponto inicial : "))
    (setq
      Pb(getpoint Pa "\tClique no Ponto final : ")
      text(ssget"f"(list Pa Pb) '((0 . "Text,Mtext")))
	    ssText(ssnamex text)
	    Row 1
      Mark(vla-AddLine (vla-get-ModelSpace(vla-get-ActiveDocument(vlax-get-acad-object))) (vlax-3d-point Pa) (vlax-3d-point Pb))
      MarkList(vl-list* Mark MarkList)
	  )
    (vla-put-Color Mark 20)
    (foreach txt ssText
      (if(=(car txt)4)
        (progn
          (setq
            x(vlax-ename->vla-object(cadr txt))
            str(vla-get-textString x)
          )
          (vlax-put-property cells 'Item Line Row (vl-princ-to-string str))
          (setq Row(1+ Row))
        )
      )
    )
    (setq Line(1+ Line))
    )
    (foreach x MarkList (vla-Delete x))
  (setq *error* err)
  (vlax-release-object excel)
  (princ)
  )

;;; By Eric Drumond - https://www.youtube.com/channel/UCIG9FBilGznGdNp-_WzHM7g