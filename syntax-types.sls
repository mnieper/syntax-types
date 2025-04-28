#!r6rs
(library (syntax-types)
  (export
    define-syntax-type)
  (import
    (scheme)
    (identifiers)
    (include-syntax)
    (syntax-types shadow-names))

  (define-syntax define-syntax-type
    (lambda (stx)
      (syntax-case stx ()
        [(define-syntax-type name uid)
         (and (identifier? #'name) (identifier? #'uid))
         (with-syntax ([define-name (construct-name #'name "define-" #'name)]
                       [case-name (construct-name #'name #'name "-case")])
           #'(... (begin
                    (define-syntax define-name
                      (lambda (stx)
                        (syntax-case stx ()
                          [(_ id stx-expr)
                           (identifier? #'id)
                           (with-syntax
                               ([shadow (construct-shadow-name #'id #'uid)]
                                [definition (if (bound-identifier? #'id)
                                                #'(begin)
                                                #'(define-syntax id
                                                    (lambda (stx)
                                                      (syntax-violation #f "invalid syntax" stx))))])
                             #'(begin
                                 definition
                                 (define-syntax shadow
                                   (let ([stx-val stx-expr])
                                     (lambda (stx)
                                       (syntax-case stx ()
                                         [(_ other-id pat kt kf)
                                          (identifier? #'other-id)
                                          (if (free-identifier=? #'id #'other-id)
                                              (with-syntax [(val stx-val)]
                                                #'(include-syntax (with-syntax ([pat #'val]) #'kt)))
                                              #'kf)]))))))])))

                    (define-syntax case-name
                      (lambda (stx)
                        (syntax-case stx (else)
                          [(_ id
                             [pat e1 ...]
                             [else e2 ...])
                           (identifier? #'id)
                           (with-syntax ([shadow (construct-shadow-name #'id #'uid)])
                             (if (bound-identifier? #'shadow)
                                 #'(shadow id pat (begin e1 ...) (begin e2 ...))
                                 #'(begin e2 ...)))]))))))]))))
