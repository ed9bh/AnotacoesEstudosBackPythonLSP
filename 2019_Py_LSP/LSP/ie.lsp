(defun c:ieTeste()

  (setq
    ie(vlax-get-or-create-object "InternetExplorer.Application")
    )
  
  (vla-put-visible ie :vlax-true)

  ;(vlax-put-property (vlax-get ie 'AddressBar) "www.google.com")

  (vlax-dump-object ie)

  )