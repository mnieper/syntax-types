#!r6rs
(library (identifiers)
  (export
    bound-identifier?
    construct-name)
  (import
    (rnrs)
    (identifiers nowhere))

  (define bound-identifier?
    (lambda (id)
      (unless (identifier? id)
        (assertion-violation 'bound-identifier? "invalid identifier argument" id))
      (not (free-identifier=? id (datum->syntax nowhere (syntax->datum id))))))

  (define construct-name
    (lambda (k . arg*)
      (unless (identifier? k)
        (assertion-violation 'construct-name "invalid template identifier argument" k))
      (datum->syntax k
        (string->symbol
	  (apply string-append
	    (map (lambda (x)
		   (cond
                     [(string? x) x]
                     [(identifier? x)
		      (symbol->string (syntax->datum x))]
                     [else
                       (assertion-violation 'construct-name "invalid argument" x)]))
		 arg*)))))))
