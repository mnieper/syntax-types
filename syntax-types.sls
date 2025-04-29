#!r6rs
(library (syntax-types)
  (export
    define-syntax-type)
  (import
    (rnrs)
    (identifiers)
    (include-syntax)
    (syntax-types shadow-names))

  (define-syntax define-syntax-type
    (lambda (stx)
      (syntax-case stx ()
        [(define-syntax-type name uid)
         (and (identifier? #'name) (identifier? #'uid))
         (with-syntax ([define-name (construct-name #'name "define-" #'name)]
                       [case-name (construct-name #'name #'name "-case")]
                       [with-name (construct-name #'name "with-" #'name)])
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
                           (with-syntax ([shadow (construct-shadow-name #'id #'uid)]
                                         [e1 #'(begin e1 ...)]
                                         [e2 #'(begin e2 ...)])
                             (if (bound-identifier? #'shadow)
                                 #'(shadow id pat e1 e2)
                                 #'e2))])))

                    (define-syntax with-name
                      (lambda (stx)
                        (define parse-binding
                          (lambda (binding)
                            (syntax-case binding ()
                              [(pat id default-expr)
                               (identifier? #'id)
                               #'(pat id default-expr #t)]
                              [(pat id)
                               #'(pat id #f #f)]
                              [_ (syntax-violation #f "invalid binding clause" stx binding)])))
                        (syntax-case stx ()
                          [(_ (binding ...) e1 ...)
                           (with-syntax ([((pat id default-expr has-default?) ...) (map parse-binding #'(binding ...))])
                             (with-syntax ([(pat-id ...) (generate-temporaries #'(pat ...))]
                                           [(default ...) (generate-temporaries #'(default-expr ...))]
                                           [stx-expr stx])
                               #'(letrec-syntax
                                     ([m (lambda (stx)
                                           (syntax-case stx ()
                                             [(_ () e) #'e]
                                             [(_ ([pat-id1 id1 default1 has-default1?] [pat-id2 id2 default2 has-default2?] (... ...)) e)
                                              (with-syntax ([stx-syntax #'((... ...) stx-expr)])
                                                (with-syntax ([else-expr (if (syntax->datum #'has-default1?)
                                                                             #'(include-syntax
                                                                                 (with-syntax ([pat-id1 default1])
                                                                                   #'(m ([pat-id2 id2] (... ...))  ((... ...) ((... ...) e)))))
                                                                             #'(include-syntax
                                                                                 (syntax-violation #f "identifier of invalid syntax type" #'((... ...) ((... ...) stx-syntax)) #'id1)))])
                                                  #'(case-name id1
                                                      [pat-id1 (m ([pat-id2 id2 default2 has-default2?] (... ...)) ((... ...) ((... ...) e)))]
                                                      [else else-expr])))]))])
                                   (include-syntax
                                     (with-syntax ([default #'default-expr] ...)
                                       #'((... ...)
                                          (m ([pat-id id default has-default?] ...)
                                            (include-syntax
                                              (with-syntax ([pat #'pat-id] ...) #'(begin e1 ...))))))))))]))))))]))))
