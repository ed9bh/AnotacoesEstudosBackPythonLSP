(vla-put-textstring(setq xxx(nth 0(vlax-safearray->list(vlax-variant-value(vla-getattributes(vlax-ename->vla-object(entlast)))))))"3")
(vla-update xxx)

(setq blk(vlax-ename->vla-object(ssname(ssget"x"'((0 . "insert")(2 . "CARIMBO MANABI")))0)))
(vla-get-textstring(nth 0(vlax-safearray->list(vlax-variant-value(vla-getattributes blk)))))
(vla-get-tagstring(nth 0(vlax-safearray->list(vlax-variant-value(vla-getattributes blk)))))

(vla-get-promptstring(nth 0(vlax-safearray->list(vlax-variant-value(vla-getattributes blk)))))
(vlax-get(nth 0(vlax-safearray->list(vlax-variant-value(vla-getattributes blk))))'promptstring)
(vlax-for x(setq blkdef(vla-item(vla-get-blocks(vla-get-activedocument(vlax-get-acad-object)))(vlax-get blk 'Name)))
  (setq lst(cons(vlax-get x 'PromptString)lst))
  )