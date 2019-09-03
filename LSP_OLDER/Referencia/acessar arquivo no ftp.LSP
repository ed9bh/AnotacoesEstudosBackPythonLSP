(vl-load-com)

;;;Ainda não :c
(vla-putremotefile
       (vla-get-utility(vla-get-activedocument(vlax-get-acad-object)))
       "ftp://guest:PiPeSyS@ftp.pipesys.com//edg"
       "c:\\edg\\teste.txt"
       )

;;;;;;Ainda não :c
;;;(vla-getremotefile
;;;       (vla-get-utility(vla-get-activedocument(vlax-get-acad-object)))
;;;       "ftp://guest:PiPeSyS@ftp.pipesys.com//edg"
;;;       "teste.txt"
;;;       )

;;;Esse Funcionou :D
(vla-getremotefile
       (vla-get-utility(vla-get-activedocument(vlax-get-acad-object)))
       "http://2.bp.blogspot.com/-91lbritDxgc/UCJefFUstXI/AAAAAAAAHHw/C95Sz_ctfoM/s400/Skull+Wallpapers+1.jpg"
       'locfile :vlax-true
       )

;;;Site: ftp.pipesys.com
;;;user: guest
;;;password: PiPeSyS (note as letras maíusculas)
;;;
;;;<ftp://[User Name]:[Password]@[address]>
;ftp://guest:PiPeSyS@ftp.pipesys.com



;|
(defun download(lien rep / cp ok tmp util)
(setq util (vla-get-Utility (vla-get-ActiveDocument 
(vlax-get-acad-object))))
(if (eq (vla-isurl util lien) :vlax-true)
(if (vl-catch-all-error-p (vl-catch-all-apply 'vla-GetRemoteFile (list util 
lien 'tmp :vlax-true)))
(princ "\nErreur lors du téléchargement.")
(progn
(setq cp (strcat rep (vl-filename-base lien) (vl-filename-extension lien)))
(if (findfile cp)
(vl-file-delete cp)
)
(if (vl-catch-all-error-p (vl-catch-all-apply 'vl-file-copy (list tmp cp)))
(progn
(princ "\nUnable to move the file \""
(strcat (vl-filename-base cp)(vl-filename-extension cp))
"\" since the directory \n\""
tmp
)
(vl-file-delete tmp)
)
(progn
(vl-file-delete tmp)
(if (zerop (vl-file-size cp))
(progn
(vl-file-delete cp)
(princ "\nUnable to download the file.")
)
(setq ok T)
)
)
)
)
)
(princ "\nThe url is not valid.")
)
ok
)

Example
(download "http://carnet-de-cablage.chez-alice.fr/Lisp/Gef.zip" "c:/test/")
If OK, return T
|;


;|

(defun c:test (/ objDOC objUTL locfile)
  (vl-load-com)
  (setq objDOC (vla-get-activedocument (vlax-get-acad-object)))
  (setq objUTL (vla-get-utility objDOC))
  (vla-getremotefile
    objUTL
    "http://www.uspconnectors.com/cad/product/hc520.dwg"
    'locfile
    :vlax-true
  )
  (alert (strcat "File downloaded here -> " locfile))
  (princ)
)

|;