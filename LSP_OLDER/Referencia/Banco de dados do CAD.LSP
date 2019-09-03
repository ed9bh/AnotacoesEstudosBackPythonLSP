(vlax-dump-object(setq db(vla-get-summaryinfo(vla-get-activedocument(vlax-get-acad-object))))t)


(vla-put-author db "EDG")
(vla-put-comments db "xxxx")
(vla-put-hyperlinkbase db "http://www.google.com")
(vla-put-keywords db "aaaa")
(vla-put-title db "bbb")
(vla-put-subject db "ccc")
(vla-AddCustomInfo db "xxx" "yyy")

(vlax-get db 'Author)