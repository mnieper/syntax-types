#!r6rs
(import
  (rnrs)
  (include-syntax))

(assert
  (eqv? 3
    (include-syntax #'(+ 1 2))))

(assert
  (eqv? 4
    (include-syntax
      (with-syntax ([(foo ...) #'(+ 1 3)])
        #'(foo ...)))))

(assert
  (eqv? 5
    (let-syntax ([m (lambda (stx)
                      (syntax-case stx ()
                        [(m x)
                         #'(include-syntax x)]))])
      (m #'(+ 1 4)))))

(assert
  (eqv? 6
    (let-syntax ([m (lambda (stx)
                      (syntax-case stx ()
                        [(m x)
                         #'(include-syntax x)]))])
      (m
        (with-syntax ([(bar ...) #'(+ 1 5)])
          #'(bar ...))))))
