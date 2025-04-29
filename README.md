# Custom Syntax Types

Use `(define-syntax-type <identifier> <uid>)` to define a custom syntax type.  This definition expands into three syntax definitions `define-<identifier>`, `<identifier>-case`, and `with-<identifier>`, e.g., `define-frob`, `frob-case`, and `with-frob` for `(define-syntax-type frob frob-0d421de7-7291-400e-aedb-55280eef0b30)`.

The expression `(define-frob <identifier> <expression>)` evaluates `<expression>` at expand-time, which should yield a syntax object value, which becomes the `frob`-value of `identifier`. If `<identifier>` is not bound, it is bound to syntax such that it is a syntax violation to use it as a keyword. Within the scope of the `define-frob` definition, the `<identifier>` acquires the `frob` syntax type.

The expression
```
(frob-case <identifier>
  [pat <e1> ...]
  [else <e2> ...])
```
expands into a `(begin <e1> ...)` if <identifier> has the `frob` syntax type and into `(begin <e2> ...)` otherwise. In the first case, `tmpl`, which must be a `syntax-case` pattern, is matched against the `frob` value of `identifier` and its pattern variables substituted in `<e1> ...`.

The expression
```
(with-frob (<binding> ...)
  <e1> ...)
```
where `<binding>` is of one of the forms
```
[<pat> <id> <default-expression>]
[<pat> <id>]
```
works like a simultaneous `frob-case` for the identifiers `<id>`. Here, instead of selecting an `else` case, the expand-time value of the `<default-expression>` is used to provide a `frob`-value if the corresponding identifier is not of `frob` type. If `<default-expression>` is missing, that case is a syntax violation.
