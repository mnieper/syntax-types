#!r6rs
(library (include-syntax)
  (export
    include-syntax)
  (import
    (rnrs))
  (define-syntax include-syntax
    (lambda (stx)
      (syntax-case stx ()
        [(_ expr)
         #'(let-syntax ([m (lambda (stx) expr)])
             m)]))))
