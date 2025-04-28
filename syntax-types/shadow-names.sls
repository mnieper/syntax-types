#!r6rs
(library (syntax-types shadow-names)
  (export
    construct-shadow-name)
  (import
    (rnrs)
    (identifiers))

  (define construct-shadow-name
    (lambda (id uid)
      (construct-name id uid ":" id "-d5a7cd08-d0cb-4de6-b79e-da1a62af27e4"))))
