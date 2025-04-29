#!r6rs
(import
  (rnrs)
  (syntax-types))

(define-syntax-type frob frob-0d421de7-7291-400e-aedb-55280eef0b30)

(define-frob foo #'(1 2 3))

(define-syntax frob?
  (lambda (stx)
    (syntax-case stx ()
      [(_ id)
       (identifier? #'id)
       #'(frob-case id
           [ignore #t]
           [else #f])])))

(assert (frob? foo))
(assert (not (frob? bar)))

(let ((foo #t))
  (assert (not (frob? foo))))

(define x 10)

(define-frob x #'(1 2 3))

(assert (frob? x))
(assert (eqv? x 10))

(frob-case x
  [(e ...) (assert (equal? (list e ...) '(1 2 3)))]
  [else (assert #f)])

(with-syntax ([(a ...) #'(6 7 8)])
  (frob-case x
    [(e ...) (assert (equal? (length #'(a (... ...))) 3))]
    [else (assert #f)]))

(with-frob ([(x ...) foo #'(#f)] [(y ...) bar #'(#f)])
  (assert (equal? (list (list x ...) (list y ...)) '((1 2 3) (#f)))))
