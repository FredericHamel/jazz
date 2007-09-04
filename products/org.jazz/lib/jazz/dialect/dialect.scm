;;;==============
;;;  JazzScheme
;;;==============
;;;
;;;; Jazz Dialect
;;;
;;;  The contents of this file are subject to the Mozilla Public License Version
;;;  1.1 (the "License"); you may not use this file except in compliance with
;;;  the License. You may obtain a copy of the License at
;;;  http://www.mozilla.org/MPL/
;;;
;;;  Software distributed under the License is distributed on an "AS IS" basis,
;;;  WITHOUT WARRANTY OF ANY KIND, either express or implied. See the License
;;;  for the specific language governing rights and limitations under the
;;;  License.
;;;
;;;  The Original Code is JazzScheme.
;;;
;;;  The Initial Developer of the Original Code is Guillaume Cartier.
;;;  Portions created by the Initial Developer are Copyright (C) 1996-2006
;;;  the Initial Developer. All Rights Reserved.
;;;
;;;  Contributor(s):
;;;
;;;  Alternatively, the contents of this file may be used under the terms of
;;;  the GNU General Public License Version 2 or later (the "GPL"), in which
;;;  case the provisions of the GPL are applicable instead of those above. If
;;;  you wish to allow use of your version of this file only under the terms of
;;;  the GPL, and not to allow others to use your version of this file under the
;;;  terms of the MPL, indicate your decision by deleting the provisions above
;;;  and replace them with the notice and other provisions required by the GPL.
;;;  If you do not delete the provisions above, a recipient may use your version
;;;  of this file under the terms of any one of the MPL or the GPL.
;;;
;;;  See www.jazzscheme.org for details.


(module jazz.dialect.dialect


;;;
;;;; Definition
;;;


(jazz.define-class-runtime jazz.Definition-Declaration jazz.Declaration (name access compatibility attributes toplevel parent children) jazz.Object-Class
  (signature))


(define (jazz.new-definition-declaration name access compatibility attributes parent parameters)
  (let ((new-declaration (jazz.allocate-definition-declaration jazz.Definition-Declaration name access compatibility attributes #f parent '() (and parameters (jazz.new-walk-signature parameters)))))
    (jazz.setup-declaration-toplevel new-declaration)
    new-declaration))


;; mega patch to support final methods expanding into definitions
(define (jazz.is-method-definition? declaration)
  (let ((signature (%%get-definition-declaration-signature declaration)))
    (if (not signature)
        #f
      (let ((parameters (%%get-walk-signature-parameters signature)))
        (and (pair? parameters) (eq? (car parameters) 'self))))))


(jazz.define-specific (jazz.walk-binding-walk-reference (jazz.Definition-Declaration declaration) walker resume source-declaration environment)
  (let ((path (jazz.get-locator declaration))
        (self (jazz.lookup-self walker environment)))
    (if (and self (jazz.is-method-definition? declaration) (jazz.is? (%%get-declaration-parent declaration) jazz.Unit-Declaration))
        `(lambda rest (apply ,path self rest))
      path)))


(jazz.define-specific (jazz.walk-binding-walk-assignment (jazz.Definition-Declaration declaration) walker resume source-declaration environment value)
  (let ((locator (jazz.get-locator declaration))
        (walk (jazz.walk walker resume source-declaration environment value)))
    `(set! ,locator ,walk)))


(jazz.define-specific (jazz.walk-binding-validate-call (jazz.Definition-Declaration declaration) walker resume source-declaration call arguments)
  (let ((signature (%%get-definition-declaration-signature declaration)))
    (if signature
        (jazz.validate-arguments walker resume source-declaration declaration signature arguments))))


(jazz.define-specific (jazz.walk-binding-walk-call (jazz.Definition-Declaration declaration) walker resume source-declaration environment call arguments)
  (let ((self (jazz.lookup-self walker environment)))
    (if (and self (jazz.is-method-definition? declaration) (jazz.is? (%%get-declaration-parent declaration) jazz.Unit-Declaration))
        `(,(jazz.get-locator declaration)
          self
          ,@(jazz.walk-list walker resume source-declaration environment arguments))
      (nextmethod declaration walker resume source-declaration environment call arguments))))


;;;
;;;; Generic
;;;


(jazz.define-class-runtime jazz.Generic-Declaration jazz.Declaration (name access compatibility attributes toplevel parent children) jazz.Object-Class
  (signature))


(define (jazz.new-generic-declaration name access compatibility attributes parent parameters)
  (let ((new-declaration (jazz.allocate-generic-declaration jazz.Generic-Declaration name access compatibility attributes #f parent '() (jazz.new-walk-signature parameters))))
    (jazz.setup-declaration-toplevel new-declaration)
    new-declaration))


(jazz.define-specific (jazz.walk-binding-walk-reference (jazz.Generic-Declaration declaration) walker resume source-declaration environment)
  (let ((path (jazz.get-locator declaration))
        (self (jazz.lookup-self walker environment)))
    (if (and self (jazz.is? (%%get-declaration-parent declaration) jazz.Unit-Declaration))
        `(lambda rest (apply ,path self rest))
      path)))


(jazz.define-specific (jazz.walk-binding-walk-call (jazz.Generic-Declaration declaration) walker resume source-declaration environment call arguments)
  (let ((self (jazz.lookup-self walker environment)))
    (if (and self (jazz.is? (%%get-declaration-parent declaration) jazz.Unit-Declaration))
        `(,(jazz.get-locator declaration)
          self
          ,@(jazz.walk-list walker resume source-declaration environment arguments))
      (nextmethod declaration walker resume source-declaration environment call arguments))))


(jazz.define-specific (jazz.walk-binding-walk-assignment (jazz.Generic-Declaration declaration) walker resume source-declaration environment value)
  (jazz.walk-error walker resume source-declaration "Illegal assignment to a generic: {s}" (jazz.get-locator declaration)))


(jazz.define-specific (jazz.walk-binding-validate-call (jazz.Generic-Declaration declaration) walker resume source-declaration call arguments)
  (jazz.validate-arguments walker resume source-declaration declaration (%%get-generic-declaration-signature declaration) arguments))


;;;
;;;; Unit
;;;


(jazz.define-class-runtime jazz.Unit-Declaration jazz.Namespace-Declaration (name access compatibility attributes toplevel parent children lookup) jazz.Object-Class
  (metaclass))


(jazz.define-specific (jazz.walk-binding-walk-reference (jazz.Unit-Declaration declaration) walker resume source-declaration environment)
  (jazz.get-locator declaration))


(jazz.define-specific (jazz.walk-binding-walk-assignment (jazz.Unit-Declaration declaration) walker resume source-declaration environment value)
  (jazz.walk-error walker resume source-declaration "Illegal assignment to a unit: {s}" (jazz.get-locator declaration)))


;;;
;;;; Class
;;;


(jazz.define-class-runtime jazz.Class-Declaration jazz.Unit-Declaration (name access compatibility attributes toplevel parent children lookup metaclass) jazz.Object-Class
  (ascendant
   interfaces))


(define (jazz.new-class-declaration name access compatibility attributes parent metaclass ascendant interfaces)
  (let ((new-declaration (jazz.allocate-class-declaration jazz.Class-Declaration name access compatibility attributes #f parent '() (%%new-hashtable ':eq?) metaclass ascendant interfaces)))
    (jazz.setup-declaration-toplevel new-declaration)
    new-declaration))


(jazz.define-specific (jazz.lookup-declaration (jazz.Class-Declaration declaration) symbol external?)
  (or (jazz.find-declaration declaration symbol)
      (jazz.lookup-class-ascendant declaration symbol)
      (jazz.lookup-class-interfaces declaration symbol)))


(define (jazz.lookup-class-ascendant declaration symbol)
  (let ((ascendant-declaration (%%get-class-declaration-ascendant declaration)))
    (if (%%not ascendant-declaration)
        #f
      (jazz.lookup-declaration ascendant-declaration symbol #t))))


(define (jazz.lookup-class-interfaces declaration symbol)
  (jazz.find-in (lambda (interface-declaration)
                  (jazz.lookup-declaration interface-declaration symbol #t))
                (%%get-class-declaration-interfaces declaration)))


;;;
;;;; Validate
;;;


(define (jazz.validate-core-class/class core-class declaration)
  (jazz.validate-core-class/unit core-class declaration)
  (jazz.validate-core-class/slots core-class declaration))


(define (jazz.validate-core-class/slots core-class declaration)
  (let ((core-class-slot-names (map (lambda (name/slot) (if (%%symbol? name/slot) name/slot (%%get-field-name name/slot))) (%%get-class-slots core-class)))
        (declaration-slot-names (map jazz.get-declaration-name (jazz.collect-type jazz.Slot-Declaration (%%get-declaration-children declaration)))))
    (%%when (%%not (%%equal? core-class-slot-names declaration-slot-names))
      (jazz.error "Inconsistant core-class/class slots for {s}: {s} / {s}" (jazz.get-declaration-name declaration) core-class-slot-names declaration-slot-names))))


(define (jazz.validate-core-class/unit core-class declaration)
  (jazz.validate-core-class/ascendant core-class declaration)
  (jazz.validate-core-class/interfaces core-class declaration))


(define (jazz.validate-core-class/ascendant core-class declaration)
  (let* ((core-class-ascendant (%%get-class-ascendant core-class))
         (core-class-ascendant-name (if (%%not core-class-ascendant) '() (jazz.identifier-name (%%get-unit-name core-class-ascendant))))
         (declaration-ascendant (%%get-class-declaration-ascendant declaration))
         (declaration-ascendant-name (if (%%not declaration-ascendant) '() (jazz.identifier-name (jazz.get-locator declaration-ascendant)))))
    (%%when (%%not (%%eq? core-class-ascendant-name declaration-ascendant-name))
      (jazz.error "Inconsistant core-class/class ascendant for {s}: {s} / {s}" (jazz.get-declaration-name declaration) core-class-ascendant-name declaration-ascendant-name))))


(define (jazz.validate-core-class/interfaces core-class declaration)
  (let ((declaration-interfaces (%%get-class-declaration-interfaces declaration)))
    (%%when (%%not (%%null? declaration-interfaces))
      (jazz.error "Interfaces are not supported in open classes: {s}" (jazz.get-declaration-name declaration)))))


;;;
;;;; Interface
;;;


(jazz.define-class-runtime jazz.Interface-Declaration jazz.Unit-Declaration (name access compatibility attributes toplevel parent children lookup metaclass) jazz.Object-Class
  (ascendants))


(define (jazz.new-interface-declaration name access compatibility attributes parent metaclass ascendants)
  (let ((new-declaration (jazz.allocate-interface-declaration jazz.Interface-Declaration name access compatibility attributes #f parent '() (%%new-hashtable ':eq?) metaclass ascendants)))
    (jazz.setup-declaration-toplevel new-declaration)
    new-declaration))


(jazz.define-specific (jazz.lookup-declaration (jazz.Interface-Declaration declaration) symbol external?)
  (or (jazz.find-declaration declaration symbol)
      (jazz.lookup-interface-ascendants declaration symbol)))


(define (jazz.lookup-interface-ascendants declaration symbol)
  (jazz.find-in (lambda (ascendant-declaration)
                  (jazz.lookup-declaration ascendant-declaration symbol #t))
                (%%get-interface-declaration-ascendants declaration)))


;;;
;;;; Field
;;;


(jazz.define-class-runtime jazz.Field-Declaration jazz.Declaration (name access compatibility attributes toplevel parent children) jazz.Object-Class
  ())


;;;
;;;; Slot
;;;


(jazz.define-class-runtime jazz.Slot-Declaration jazz.Field-Declaration (name access compatibility attributes toplevel parent children) jazz.Object-Class
  (initialize
   getter-name
   setter-name))


(define (jazz.new-slot-declaration name access compatibility attributes parent initialize getter-name setter-name)
  (let ((new-declaration (jazz.allocate-slot-declaration jazz.Slot-Declaration name access compatibility attributes #f parent '() initialize getter-name setter-name)))
    (jazz.setup-declaration-toplevel new-declaration)
    new-declaration))


(jazz.define-specific (jazz.walk-binding-walk-reference (jazz.Slot-Declaration declaration) walker resume source-declaration environment)
  (let ((self (jazz.lookup-self walker environment)))
    (if self
        (jazz.walk walker resume source-declaration environment `(slot-value self ',(jazz.get-declaration-name declaration)))
      (jazz.walk-error walker resume source-declaration "Illegal reference to a slot: {s}" (jazz.get-locator declaration)))))


(jazz.define-specific (jazz.walk-binding-walk-assignment (jazz.Slot-Declaration declaration) walker resume source-declaration environment value)
  (let ((self (jazz.lookup-self walker environment)))
    (if self
        (jazz.walk walker resume source-declaration environment `(set-slot-value self ',(jazz.get-declaration-name declaration) ,value))
      (jazz.walk-error walker resume source-declaration "Illegal assignment to a slot: {s}" (jazz.get-locator declaration)))))


(jazz.define-specific (jazz.walk-binding-validate-call (jazz.Slot-Declaration declaration) walker resume source-declaration call arguments)
  #f)


;;;
;;;; Method
;;;


(jazz.define-class-runtime jazz.Method-Declaration jazz.Field-Declaration (name access compatibility attributes toplevel parent children) jazz.Object-Class
  (propagation
   implementation
   expansion
   parameters))


(define (jazz.new-method-declaration name access compatibility attributes propagation implementation expansion parent parameters)
  (let ((new-declaration (jazz.allocate-method-declaration jazz.Method-Declaration name access compatibility attributes #f parent '() propagation implementation expansion parameters)))
    (jazz.setup-declaration-toplevel new-declaration)
    new-declaration))


;;;
;;;; Dialect
;;;


(jazz.define-class jazz.Jazz-Dialect jazz.Dialect () jazz.Object-Class jazz.allocate-jazz-dialect
  ())


(jazz.define-class-runtime jazz.Jazz-Dialect jazz.Dialect () jazz.Object-Class
  ())


(define (jazz.new-jazz-dialect)
  (jazz.allocate-jazz-dialect jazz.Jazz-Dialect))


(jazz.define-specific (jazz.dialect-walker (jazz.Jazz-Dialect dialect))
  (jazz.new-jazz-walker))


;;;
;;;; Walker
;;;


(jazz.define-class jazz.Jazz-Walker jazz.Scheme-Walker (warnings errors literals c-references direct-dependencies autoload-declarations) jazz.Object-Class jazz.allocate-jazz-walker
  ())


(jazz.define-class-runtime jazz.Jazz-Walker jazz.Scheme-Walker (warnings errors literals c-references direct-dependencies autoload-declarations) jazz.Object-Class
  ())


(define (jazz.new-jazz-walker)
  (jazz.allocate-jazz-walker jazz.Jazz-Walker '() '() '() '() '() '()))


;;;
;;;; Environment
;;;


(define (jazz.jazz-bindings)
  (%%list
    (jazz.new-macro-form 'definition      jazz.expand-definition)   (jazz.new-special-form '%definition   jazz.walk-%definition)
    (jazz.new-macro-form 'generic         jazz.expand-generic)      (jazz.new-special-form '%generic      jazz.walk-%generic)
    (jazz.new-macro-form 'specific        jazz.expand-specific)     (jazz.new-special-form '%specific     jazz.walk-%specific)
    (jazz.new-macro-form 'c-type          jazz.expand-c-type)       (jazz.new-special-form '%c-type       jazz.walk-%c-type)
    (jazz.new-macro-form 'c-definition    jazz.expand-c-definition) (jazz.new-special-form '%c-definition jazz.walk-%c-definition)
    (jazz.new-macro-form 'class           jazz.expand-class)        (jazz.new-special-form '%class        jazz.walk-%class)
    (jazz.new-macro-form 'interface       jazz.expand-interface)    (jazz.new-special-form '%interface    jazz.walk-%interface)
    (jazz.new-macro-form 'slot            jazz.expand-slot)         (jazz.new-special-form '%slot         jazz.walk-%slot)
    (jazz.new-macro-form 'property        jazz.expand-property)     (jazz.new-special-form '%property     jazz.walk-%slot)
    
    (jazz.new-macro-form 'optimize        jazz.expand-optimize)
    (jazz.new-macro-form 'method          jazz.expand-method)
    (jazz.new-macro-form 'remote-proxy    jazz.expand-remote-proxy)
    (jazz.new-macro-form 'coclass         jazz.expand-coclass)
    (jazz.new-macro-form 'cointerface     jazz.expand-cointerface)
    (jazz.new-macro-form 'assert          jazz.expand-assert)
    (jazz.new-macro-form 'validate        jazz.expand-validate)
    
    (jazz.new-special-form 'atomic-region jazz.walk-atomic-region)
    (jazz.new-special-form 'c-include     jazz.walk-c-include)
    (jazz.new-special-form 'c-function    jazz.walk-c-function)
    (jazz.new-special-form 'function      jazz.walk-function)
    (jazz.new-special-form 'not-void?     jazz.walk-not-void?)
    (jazz.new-special-form 'parameterize  jazz.walk-parameterize)
    (jazz.new-special-form 'void?         jazz.walk-void?)
    (jazz.new-special-form 'with-slots    jazz.walk-with-slots)
    (jazz.new-special-form 'with-self     jazz.walk-with-self)
    (jazz.new-special-form 'form          jazz.walk-form-special)))


(define jazz.jazz-environment
  #f)


(jazz.define-specific (jazz.walker-environment (jazz.Jazz-Walker walker))
  (or jazz.jazz-environment
      (begin
        (set! jazz.jazz-environment (%%list (jazz.new-walk-frame (append (jazz.core-bindings) (jazz.scheme-bindings) (jazz.jazz-bindings)))))
        jazz.jazz-environment)))


;;;
;;;; Declaration
;;;


(jazz.define-specific (jazz.walk-declaration (jazz.Jazz-Walker walker) resume declaration environment form)
  (if (%%pair? form)
      (let ((first (%%car form)))
        (case first
          ((%definition)     (jazz.walk-%definition-declaration     walker resume declaration environment form))
          ((%generic)        (jazz.walk-%generic-declaration        walker resume declaration environment form))
          ((c-include)       #f)
          ((%c-type)         (jazz.walk-%c-type-declaration         walker resume declaration environment form))
          ((%c-definition)   (jazz.walk-%c-definition-declaration   walker resume declaration environment form))
          ((%class)          (jazz.walk-%class-declaration          walker resume declaration environment form))
          ((%interface)      (jazz.walk-%interface-declaration      walker resume declaration environment form))
          ((%slot %property) (jazz.walk-%slot-declaration           walker resume declaration environment form))
          ((%specific)       #f)
          ((%initialize)     #f)
          (else              (nextmethod walker resume declaration environment form))))
    #f))


;;;
;;;; Parse
;;;


(define (jazz.parse-modifiers walker resume declaration infos rest)
  (let ((partitions (map (lambda (info) (%%cons info '())) infos))
        (done? #f))
    (%%while (and (%%not-null? rest) (%%not done?))
      (let ((target (%%car rest))
            (found? #f))
        (for-each (lambda (partition)
                    (let ((allowed (%%caar partition))
                          (default (%%cdar partition)))
                      (if (%%memq target allowed)
                          (begin
                            (set! found? #t)
                            (%%set-cdr! partition (%%cons target (%%cdr partition)))))))
                  partitions)
        (if (%%not found?)
            (set! done? #t)
          (set! rest (%%cdr rest)))))
    (%%apply values (%%append (map (lambda (partition)
                                     (let ((modifiers (%%cdr partition)))
                                       (cond ((%%null? modifiers) (%%cdar partition))
                                         ((%%null? (%%cdr modifiers)) (%%car modifiers))
                                         (else (jazz.walk-error walker resume declaration "Ambiguous modifiers: {s}" modifiers)))))
                                   partitions)
                              (%%list rest)))))


(define (jazz.parse-keywords keywords rest)
  (let ((table (%%new-hashtable ':eq?))
        (done? #f))
    (%%while (%%not done?)
      (if (or (%%null? rest) (%%not (%%memq (%%car rest) keywords)))
          (set! done? #t)
        (begin
          (%%hashtable-set! table (%%car rest) (%%cadr rest))
          (set! rest (%%cddr rest)))))
    (%%apply values (%%append (map (lambda (keyword)
                                     (%%hashtable-ref table keyword jazz.unspecified))
                                   keywords)
                              (%%list rest)))))


;;;
;;;; True/False
;;;


(jazz.define-specific (jazz.walk-true (jazz.Jazz-Walker walker) form)
  `(true? ,form))


(jazz.define-specific (jazz.walk-false (jazz.Jazz-Walker walker) form)
  `(false? ,form))


;;;
;;;; Lambda
;;;


(jazz.define-specific (jazz.walk-parameters (jazz.Jazz-Walker walker) parameters)
  (jazz.remove-specifiers-quicky parameters))


;;;
;;;; Let
;;;


(jazz.define-specific (jazz.default-let-value (jazz.Jazz-Walker walker) resume declaration form)
  '(void))


;;;
;;;; Form
;;;


(jazz.define-specific (jazz.walk-form (jazz.Jazz-Walker walker) resume declaration environment form)
  (let ((procedure-expr (%%car form)))
    (if (jazz.dispatch? procedure-expr)
        (jazz.walk-dispatch walker resume declaration environment form)
      (nextmethod walker resume declaration environment form))))


;;;
;;;; Dispatch
;;;


(define (jazz.walk-dispatch walker resume declaration environment form)
  (let ((name (jazz.dispatch->symbol (%%car form)))
        (object (jazz.generate-symbol "object")))
    `(let ((,object ,(jazz.walk walker resume declaration environment (%%cadr form))))
       ((jazz.need-dispatch-implementation-by-name ',name ,object)
        ,object
        ,@(jazz.walk-list walker resume declaration environment (%%cddr form))))))


;;;
;;;; Definition
;;;


(define jazz.definition-modifiers
  '(((private package protected public) . package)
    ((deprecated uptodate) . uptodate)
    ((inline onsite) . onsite)))


(define (jazz.parse-definition walker resume declaration rest)
  (receive (access compatibility expansion rest) (jazz.parse-modifiers walker resume declaration jazz.definition-modifiers rest)
    (if (%%symbol? (%%car rest))
        (values (%%car rest) access compatibility expansion (%%cadr rest) #f)
      (let* ((name (%%caar rest))
             (parameters (jazz.remove-specifiers-quicky (%%cdar rest)))
             (body (%%cdr rest))
             (effective-body (if (%%null? body) (%%list (%%list 'void)) body)))
        ;; quick patch to return value specifier
        (let ((body-quicky (if (jazz.specifier? (%%car effective-body)) (%%cdr effective-body) effective-body)))
          (values name access compatibility expansion `(lambda ,parameters ,@body-quicky) parameters))))))


(define (jazz.expand-definition walker resume declaration environment . rest)
  (jazz.expand-definition-form walker resume declaration (%%cons 'definition rest)))


(define (jazz.expand-definition-form walker resume declaration form)
  (receive (name access compatibility expansion value parameters) (jazz.parse-definition walker resume declaration (%%cdr form))
    `(%definition ,name ,access ,compatibility ,expansion ,value ,parameters)))


(define (jazz.walk-%definition-declaration walker resume declaration environment form)
  (jazz.bind (name access compatibility expansion value parameters) (%%cdr form)
    (let ((new-declaration (jazz.new-definition-declaration name access compatibility '() declaration parameters)))
      (jazz.add-declaration-child walker resume declaration new-declaration)
      new-declaration)))


(define (jazz.walk-%definition walker resume declaration environment form)
  (jazz.bind (name access compatibility expansion value parameters) (%%cdr form)
    (let* ((new-declaration (jazz.find-form-declaration declaration form))
           (locator (jazz.get-locator new-declaration))
           (new-environment (%%cons new-declaration environment)))
      `(define ,locator
         ,(jazz.walk walker resume new-declaration new-environment value)))))


;;;
;;;; Generic
;;;


;; Only works for 1 generic parameter for now until the underlying generics are generalized...


(define jazz.generic-modifiers
  '(((private package protected public) . private)
    ((deprecated uptodate) . uptodate)))


(define (jazz.parse-generic walker resume declaration rest)
  (receive (access compatibility rest) (jazz.parse-modifiers walker resume declaration jazz.generic-modifiers rest)
    (let ((signature (%%car rest)))
      (%%assert (%%null? (%%cdr rest))
        (let ((name (%%car signature))
              (parameters (%%cdr signature)))
          (values name access compatibility parameters))))))


(define (jazz.expand-generic walker resume declaration environment . rest)
  (jazz.expand-generic-form walker resume declaration (%%cons 'generic rest)))


(define (jazz.expand-generic-form walker resume declaration form)
  (receive (name access compatibility parameters) (jazz.parse-generic walker resume declaration (%%cdr form))
    `(%generic ,name ,access ,compatibility ,parameters)))


(define (jazz.walk-%generic-declaration walker resume declaration environment form)
  (jazz.bind (name access compatibility parameters) (%%cdr form)
    (let ((new-declaration (jazz.new-generic-declaration name access compatibility '() declaration parameters)))
      (jazz.add-declaration-child walker resume declaration new-declaration)
      new-declaration)))


(define (jazz.walk-%generic walker resume declaration environment form)
  (jazz.bind (name access compatibility parameters) (%%cdr form)
    (let* ((new-declaration (jazz.find-form-declaration declaration form))
           (generic-locator (jazz.get-locator new-declaration))
           (dispatch-specifier (%%car parameters))
           (dispatch-type-name (%%car dispatch-specifier))
           (dispatch-type-declaration (jazz.lookup-reference walker resume declaration environment dispatch-type-name))
           (dispatch-type-access (jazz.walk-binding-walk-reference dispatch-type-declaration walker resume new-declaration environment))
           (dispatch-parameter (%%cadr dispatch-specifier))
           (other-parameters (%%cdr parameters))
           (generic-parameters (%%cons (%%list dispatch-type-access dispatch-parameter) other-parameters)))
      `(jazz.define-generic ,(%%cons generic-locator generic-parameters)))))


;;;
;;;; Specific
;;;


(define jazz.specific-modifiers
  '())


(define (jazz.parse-specific walker resume declaration rest)
  (receive (rest) (jazz.parse-modifiers walker resume declaration jazz.specific-modifiers rest)
    (let* ((signature (%%car rest))
           (body (%%cdr rest))
           (effective-body (if (%%null? body) (%%list (%%list 'void)) body))
           (name (%%car signature))
           (parameters (%%cdr signature)))
      (values name parameters effective-body))))


(define (jazz.expand-specific walker resume declaration environment . rest)
  (jazz.expand-specific-form walker resume declaration (%%cons 'specific rest)))


(define (jazz.expand-specific-form walker resume declaration form)
  (receive (name parameters body) (jazz.parse-specific walker resume declaration (%%cdr form))
    `(%specific ,name ,parameters #f ,@body)))


(define (jazz.walk-%specific walker resume declaration environment form)
  (jazz.bind (name parameters install? . body) (%%cdr form)
    (let* ((generic-declaration (jazz.lookup-declaration declaration name #f))
           (generic-locator (jazz.get-locator generic-declaration))
           (generic-object-locator (jazz.generic-object-locator generic-locator))
           (dispatch-specifier (%%car parameters))
           (dispatch-type-name (%%car dispatch-specifier))
           (dispatch-type-declaration (jazz.lookup-reference walker resume declaration environment dispatch-type-name))
           (dispatch-type-access (jazz.walk-binding-walk-reference dispatch-type-declaration walker resume declaration environment))
           (dispatch-parameter (%%cadr dispatch-specifier))
           (other-parameters (%%cdr parameters))
           (generic-parameters (%%cons (%%list dispatch-type-access dispatch-parameter) other-parameters))
           (specific-expansion
             `(jazz.define-specific ,(%%cons generic-locator generic-parameters)
                ,@(let* ((new-variables (%%cons (jazz.new-nextmethodvariable 'nextmethod) (jazz.parameters->variables (%%cons dispatch-parameter (%%cdr parameters)))))
                         (new-environment (%%append new-variables environment)))
                    (jazz.walk-body walker resume declaration new-environment body)))))
      (if (%%not install?)
          specific-expansion
        `(begin
           ,specific-expansion
           (jazz.update-generic ,generic-object-locator))))))


;;;
;;;; C Type
;;;


(define jazz.c-type-modifiers
  '(((private package protected public) . public)
    ((deprecated uptodate) . uptodate)))


(define (jazz.parse-c-type walker resume declaration rest)
  (receive (access compatibility rest) (jazz.parse-modifiers walker resume declaration jazz.c-type-modifiers rest)
    (let ((name (%%car rest))
          (type (%%cadr rest)))
      (values name access compatibility type))))


(define (jazz.expand-c-type walker resume declaration environment . rest)
  (jazz.expand-c-type-form walker resume declaration (%%cons 'c-type rest)))


(define (jazz.expand-c-type-form walker resume declaration form)
  (receive (name access compatibility type) (jazz.parse-c-type walker resume declaration (%%cdr form))
    (if (%%is? declaration jazz.Unit-Declaration)
        (jazz.walk-error walker resume declaration "C types can only be defined inside libraries: {s}" name)
      `(%c-type ,name ,access ,compatibility ,type))))


(define (jazz.walk-%c-type-declaration walker resume declaration environment form)
  (jazz.bind (name access compatibility type) (%%cdr form)
    (receive (expansion references) (jazz.resolve-c-type walker resume declaration environment type)
      (let ((new-declaration (jazz.new-c-type-declaration name access compatibility '() declaration expansion references)))
        (jazz.add-declaration-child walker resume declaration new-declaration)
        new-declaration))))


(define (jazz.walk-%c-type walker resume declaration environment form)
  `(begin))


(define (jazz.resolve-c-type walker resume declaration environment type)
  (let ((queue (jazz.new-queue)))
    (letrec ((resolve
              (lambda (type)
                (cond ((%%symbol? type)
                       (let ((c-type-declaration (jazz.resolve-c-type-reference walker resume declaration environment type)))
                         (jazz.enqueue queue c-type-declaration)
                         (jazz.get-locator c-type-declaration)))
                      ((%%string? type)
                       type)
                      ((%%pair? type)
                       (case (%%car type)
                         ((native)
                          (%%cadr type))
                         ((type)
                          (jazz.bind (c-string tag) (%%cdr type)
                           `(type ,c-string ,tag)))
                         ((pointer)
                          (let ((base-type (%%cadr type))
                                (tag (if (%%null? (%%cddr type)) #f (%%car (%%cddr type)))))
                            (if (%%not tag)
                                `(pointer ,(resolve base-type))
                              `(pointer ,(resolve base-type) ,tag))))
                         ((function)
                          (jazz.bind (parameter-types result-type) (%%cdr type)
                           `(function ,(map resolve parameter-types) ,(resolve result-type))))
                         ((struct)
                          (jazz.bind (c-string) (%%cdr type)
                           `(struct ,c-string)))))
                      (else
                       (jazz.error "Ill-formed c-type: {s}" type))))))
      (let ((expansion (resolve type)))
        (values expansion (jazz.queue-list queue))))))


(define (jazz.resolve-c-type-reference walker resume declaration environment symbol)
  (let ((c-type-declaration (jazz.lookup-reference walker resume declaration environment symbol)))
    (if (%%is? c-type-declaration jazz.C-Type-Declaration)
        c-type-declaration
      (jazz.walk-error walker resume declaration "{s} did not resolve to a c-type: {s}" symbol (jazz.get-locator c-type-declaration)))))


(define (jazz.expand-c-type-access walker resume declaration environment type)
  (receive (expansion references) (jazz.resolve-c-type walker resume declaration environment type)
    (%%set-walker-c-references walker (%%append (%%get-walker-c-references walker) references))
    expansion))


;;;
;;;; C Definition
;;;


(define jazz.c-definition-modifiers
  '(((private package protected public) . public)
    ((deprecated uptodate) . uptodate)))


(define (jazz.parse-c-definition walker resume declaration rest)
  (receive (access compatibility rest) (jazz.parse-modifiers walker resume declaration jazz.c-definition-modifiers rest)
    (jazz.bind (signature parameter-types result-type c-name scope . body) rest
      (let ((name (%%car signature))
            (parameters (%%cdr signature)))
        (values name access compatibility parameters parameter-types result-type c-name scope body)))))


(define (jazz.expand-c-definition walker resume declaration environment . rest)
  (jazz.expand-c-definition-form walker resume declaration (%%cons 'c-definition rest)))


(define (jazz.expand-c-definition-form walker resume declaration form)
  (receive (name access compatibility parameters parameter-types result-type c-name scope body) (jazz.parse-c-definition walker resume declaration (%%cdr form))
    `(%c-definition ,name ,access ,compatibility ,parameters ,parameter-types ,result-type ,c-name ,scope ,body)))


(define (jazz.walk-%c-definition-declaration walker resume declaration environment form)
  (jazz.bind (name access compatibility parameters parameter-types result-type c-name scope body) (%%cdr form)
    (let ((new-declaration (jazz.new-c-definition-declaration name access compatibility '() declaration parameters)))
      (jazz.add-declaration-child walker resume declaration new-declaration)
      new-declaration)))


(define (jazz.walk-%c-definition walker resume declaration environment form)
  (jazz.bind (name access compatibility parameters parameter-types result-type c-name scope body) (%%cdr form)
    (let* ((new-declaration (jazz.find-form-declaration declaration form))
           (locator (jazz.get-locator new-declaration))
           (new-variables (jazz.parameters->variables parameters))
           (new-environment (%%append new-variables environment))
           (resolve-access (lambda (type) (jazz.expand-c-type-access walker resume declaration environment type))))
      `(c-define ,(%%cons locator parameters) ,(map resolve-access parameter-types) ,(resolve-access result-type) ,c-name ,scope
         ,@(jazz.walk-body walker resume new-declaration new-environment body)))))


;;;
;;;; Class
;;;


(define jazz.class-modifiers
  '(((private package protected public) . public)
    ((abstract concrete) . concrete)
    ((deprecated uptodate) . uptodate)))

(define jazz.class-keywords
  '(metaclass extends implements attributes))


(define (jazz.parse-class walker resume declaration rest)
  (receive (access implementation compatibility rest) (jazz.parse-modifiers walker resume declaration jazz.class-modifiers rest)
    (let ((name (%%car rest))
          (rest (%%cdr rest)))
      (receive (metaclass-name ascendant-name interface-names attributes body) (jazz.parse-keywords jazz.class-keywords rest)
        (values name access implementation compatibility metaclass-name ascendant-name interface-names attributes body)))))


(define (jazz.expand-class walker resume declaration environment . rest)
  (receive (name access implementation compatibility metaclass-name ascendant-name interface-names attributes body) (jazz.parse-class walker resume declaration rest)
    (if (%%is? declaration jazz.Library-Declaration)
        `(%class ,name ,access ,implementation ,compatibility ,metaclass-name ,ascendant-name ,interface-names ,attributes ,body)
      (jazz.walk-error walker resume declaration "Classes can only be defined at the library level: {s}" name))))


(define (jazz.walk-%class-declaration walker resume declaration environment form)
  (jazz.bind (name access implementation compatibility metaclass-name ascendant-name interface-names attributes body) (%%cdr form)
    ;; explicit test on Object-Class is to break circularity 
    (let ((metaclass (if (or (jazz.unspecified? metaclass-name) (%%eq? metaclass-name 'Object-Class)) #f (jazz.lookup-reference walker resume declaration environment metaclass-name)))
          (ascendant (if (jazz.unspecified? ascendant-name) #f (jazz.lookup-reference walker resume declaration environment ascendant-name)))
          (interfaces (if (jazz.unspecified? interface-names) '() (map (lambda (interface-name) (jazz.lookup-reference walker resume declaration environment interface-name)) (jazz.listify interface-names)))))
      (let ((new-declaration (jazz.new-class-declaration name access compatibility attributes declaration metaclass ascendant interfaces)))
        (jazz.add-declaration-child walker resume declaration new-declaration)
        (let ((new-environment (%%cons new-declaration environment)))
          (jazz.walk-declarations walker resume new-declaration new-environment body)
          new-declaration)))))


(define (jazz.walk-%class walker resume declaration environment form)
  (jazz.bind (name access implementation compatibility metaclass-name ascendant-name interface-names attributes body) (%%cdr form)
    (let* ((locator (jazz.compose-name (jazz.get-locator declaration) name))
           (core-class? (jazz.core-class? name))
           (new-declaration (jazz.find-form-declaration declaration form))
           (new-environment (%%cons new-declaration environment))
           (external? (%%neq? access 'private))
           (ascendant-declaration (%%get-class-declaration-ascendant new-declaration))
           (interface-declarations (%%get-class-declaration-interfaces new-declaration)))
      (if (and (%%not ascendant-declaration) (%%neq? name 'Object))
          (jazz.error "Class {s} does not specify an ascendant" name))
      `(begin
         ,@(if core-class?
               (let ((core-class (jazz.get-core-class name)))
                 (jazz.validate-core-class/class core-class new-declaration)
                 ;(jazz.register-direct-dependencies walker new-declaration)
                 ;(jazz.register-direct-dependencies walker ascendant-declaration)
                 (let ((ascendant-access (if (%%not ascendant-declaration) #f (jazz.walk-binding-walk-reference ascendant-declaration walker resume new-declaration environment))))
                   `((define ,locator ,(%%get-unit-name core-class))
                     (begin
                       ,@(if ascendant-access (%%list ascendant-access) '())
                       (jazz.remove-slots ,locator)))))
             (let ((metaclass-declaration (%%get-unit-declaration-metaclass new-declaration)))
               ;(jazz.register-direct-dependencies walker new-declaration)
               ;(jazz.register-direct-dependencies walker ascendant-declaration)
               ;(jazz.register-direct-dependencies walker interface-declarations)
               (let ((metaclass-access (if (%%not metaclass-declaration) 'jazz.Object-Class (jazz.walk-binding-walk-reference metaclass-declaration walker resume new-declaration environment)))
                     (ascendant-access (if (%%not ascendant-declaration) #f (jazz.walk-binding-walk-reference ascendant-declaration walker resume new-declaration environment)))
                     (interface-accesses (map (lambda (declaration) (jazz.walk-binding-walk-reference declaration walker resume new-declaration environment)) interface-declarations)))
                 `((define ,locator
                     ;; this is a quicky that needs to be well tought out
                     (if (jazz.global-variable? ',locator)
                         (jazz.global-value ',locator)
                       (jazz.new-class ,metaclass-access ',locator ,ascendant-access (%%list ,@interface-accesses))))))))
         ,@(jazz.walk-list walker resume new-declaration new-environment body)))))


;;;
;;;; Interface
;;;


(define jazz.interface-modifiers
  '(((private package protected public) . public)
    ((deprecated uptodate) . uptodate)))

(define jazz.interface-keywords
  '(metaclass extends attributes))


(define (jazz.parse-interface walker resume declaration rest)
  (receive (access compatibility rest) (jazz.parse-modifiers walker resume declaration jazz.interface-modifiers rest)
    (let ((name (%%car rest))
          (rest (%%cdr rest)))
      (receive (metaclass-name ascendant-names attributes body) (jazz.parse-keywords jazz.interface-keywords rest)
        (values name access compatibility metaclass-name ascendant-names attributes body)))))


(define (jazz.expand-interface walker resume declaration environment . rest)
  (jazz.expand-interface-form walker resume declaration (%%cons 'interface rest)))


(define (jazz.expand-interface-form walker resume declaration form)
  (receive (name access compatibility metaclass-name ascendant-names attributes body) (jazz.parse-interface walker resume declaration (%%cdr form))
    (if (%%is? declaration jazz.Library-Declaration)
        `(%interface ,name ,access ,compatibility ,metaclass-name ,ascendant-names ,attributes ,body)
      (jazz.walk-error walker resume declaration "Interfaces can only be defined at the library level: {s}" name))))


(define (jazz.walk-%interface-declaration walker resume declaration environment form)
  (jazz.bind (name access compatibility metaclass-name ascendant-names attributes body) (%%cdr form)
    (let ((metaclass (if (or (jazz.unspecified? metaclass-name) (%%eq? metaclass-name 'Interface)) #f (jazz.lookup-reference walker resume declaration environment metaclass-name)))
          (ascendants (if (jazz.unspecified? ascendant-names) '() (map (lambda (ascendant-name) (jazz.lookup-reference walker resume declaration environment ascendant-name)) (jazz.listify ascendant-names)))))
      (let ((new-declaration (jazz.new-interface-declaration name access compatibility attributes declaration metaclass ascendants)))
        (jazz.add-declaration-child walker resume declaration new-declaration)
        (let ((new-environment (%%cons new-declaration environment)))
          (jazz.walk-declarations walker resume new-declaration new-environment body)
          new-declaration)))))


(define (jazz.walk-%interface walker resume declaration environment form)
  (jazz.bind (name access compatibility metaclass-name ascendant-names attributes body) (%%cdr form)
    (let* ((new-declaration (jazz.find-form-declaration declaration form))
           (new-environment (%%cons new-declaration environment))
           (locator (jazz.get-locator new-declaration))
           (external? (%%neq? access 'private))
           (ascendant-declarations (%%get-interface-declaration-ascendants new-declaration))
           (metaclass-declaration (%%get-unit-declaration-metaclass new-declaration))
           (metaclass-access (if (%%not metaclass-declaration) 'jazz.Interface (jazz.walk-binding-walk-reference metaclass-declaration walker resume new-declaration environment)))
           (ascendant-accesses (map (lambda (declaration) (jazz.walk-binding-walk-reference declaration walker resume new-declaration environment)) ascendant-declarations)))
      ;(jazz.register-direct-dependencies walker new-declaration)
      ;(jazz.register-direct-dependencies walker ascendant-declarations)
      `(begin
         (define ,locator
           (jazz.new-interface ,metaclass-access ',locator (%%list ,@ascendant-accesses)))
         ,@(jazz.walk-list walker resume new-declaration new-environment body)))))


;;;
;;;; Slot
;;;


(define jazz.slot-modifiers
  '(((private package protected public) . protected)
    ((deprecated uptodate) . uptodate)))

(define jazz.slot-keywords
  '(initialize accessors getter setter))


(define jazz.slot-accessors-modifiers
  '(((private package protected public) . public)
    ((virtual chained inherited) . inherited)
    ((abstract concrete) . concrete)
    ((inline onsite) . inline)
    ((generate handcode) . handcode)))


(define jazz.slot-accessor-modifiers
  '(((private package protected public) . #f)
    ((virtual chained inherited) . #f)
    ((abstract concrete) . #f)
    ((inline onsite) . #f)
    ((generate handcode) . #f)))


(define (jazz.parse-slot walker resume declaration form)
  (receive (access compatibility rest) (jazz.parse-modifiers walker resume declaration jazz.slot-modifiers (jazz.remove-specifiers-quicky form))
    (let ((name (%%car rest))
          (rest (%%cdr rest)))
      (receive (initialize accessors getter setter rest) (jazz.parse-keywords jazz.slot-keywords rest)
        (if (%%not-null? rest)
            (jazz.walk-error walker resume declaration "Invalid slot definition: {s}" form)
          (values name access compatibility initialize accessors getter setter))))))


(define (jazz.expand-slot walker resume declaration environment . rest)
  (jazz.expand-slot-form walker resume declaration (%%cons 'slot rest)))


(define (jazz.parse-slot-accessors walker resume declaration form)
  (receive (access propagation implementation expansion generation rest) (jazz.parse-modifiers walker resume declaration jazz.slot-accessors-modifiers form)
    (if (%%not-null? rest)
        (jazz.walk-error walker resume declaration "Invalid slot accessors definition: {s}" form)
      (values access propagation implementation expansion generation))))


(define (jazz.parse-slot-accessor walker resume declaration slot-name default-access default-propagation default-implementation default-expansion default-generation form prefix)
  (receive (access propagation implementation expansion generation rest) (jazz.parse-modifiers walker resume declaration jazz.slot-accessor-modifiers form)
    (let ((generation (or generation default-generation)))
      (let ((name (cond ((%%null? rest)
                         (and (%%eq? generation 'generate)
                              (%%string->symbol (%%string-append prefix (%%symbol->string slot-name)))))
                        ((%%null? (%%cdr rest))
                         (%%car rest))
                        (else
                         (jazz.walk-error walker resume declaration "Invalid slot accessor definition: {s}" form)))))
        (values (or access default-access)
                (or propagation default-propagation)
                (or implementation default-implementation)
                (or expansion default-expansion)
                generation
                name)))))


(define (jazz.expand-slot-form walker resume declaration form)
  (receive (name access compatibility initialize accessors getter setter) (jazz.parse-slot walker resume declaration (%%cdr form))
    (let ((standardize
           (lambda (info)
             (cond ((jazz.unspecified? info)
                    '())
                   ((%%symbol? info)
                    (%%list info))
                   (else
                    info)))))
      (let ((accessors (standardize accessors))
            (getter (standardize getter))
            (setter (standardize setter)))
        (receive (default-access default-propagation default-implementation default-expansion default-generation) (jazz.parse-slot-accessors walker resume declaration accessors)
          (receive (getter-access getter-propagation getter-implementation getter-expansion getter-generation getter-name) (jazz.parse-slot-accessor walker resume declaration name default-access default-propagation default-implementation default-expansion default-generation getter "get-")
            (receive (setter-access setter-propagation setter-implementation setter-expansion setter-generation setter-name) (jazz.parse-slot-accessor walker resume declaration name default-access default-propagation default-implementation default-expansion default-generation setter "set-")
              (let* ((value (jazz.generate-symbol "value"))
                     (generate-getter? (%%eq? getter-generation 'generate))
                     (generate-setter? (%%eq? setter-generation 'generate)))
                `(begin
                   (,(if (eq? (car form) 'property) '%property '%slot) ,name ,access ,compatibility ,(if (eq? initialize jazz.unspecified) initialize `(with-self ,initialize)) ,getter-name ,setter-name)
                   ,@(if generate-getter?
                         `((method ,getter-access ,getter-propagation ,getter-implementation ,getter-expansion (,getter-name)
                             (slot-value self ',name)))
                       '())
                   ,@(if generate-setter?
                         `((method ,setter-access ,setter-propagation ,setter-implementation ,setter-expansion (,setter-name ,value)
                             (set-slot-value self ',name ,value)))
                       '()))))))))))


(define (jazz.walk-%slot-declaration walker resume declaration environment form)
  (jazz.bind (name access compatibility initialize getter-name setter-name) (%%cdr form)
    (let ((initialize (if (jazz.unspecified? initialize) (%%list 'quote '()) initialize)))
      (let ((new-declaration (jazz.new-slot-declaration name access compatibility '() declaration initialize getter-name setter-name)))
        (jazz.add-declaration-child walker resume declaration new-declaration)
        new-declaration))))


(define (jazz.walk-%slot walker resume declaration environment form)
  (jazz.bind (name access compatibility initialize getter-name setter-name) (%%cdr form)
    (let* ((new-declaration (jazz.find-form-declaration declaration form))
           (new-environment (%%cons new-declaration environment))
           (name (jazz.get-declaration-name new-declaration))
           (locator (jazz.get-locator new-declaration))
           (class-declaration (%%get-declaration-parent new-declaration))
           (class-locator (jazz.get-locator class-declaration))
           (initialize (%%get-slot-declaration-initialize new-declaration))
           (initialize-locator (jazz.compose-helper locator 'initialize)))
      `(begin
         (define (,initialize-locator self)
           ,(jazz.walk walker resume declaration environment initialize))
         ,(if (eq? (car form) '%property)
              `(jazz.add-property ,class-locator ',name ,initialize-locator
                 ,(jazz.walk walker resume declaration environment
                   `(lambda (self)
                      (with-self
                        ,(if getter-name
                             `(,getter-name)
                           name))))
                 ,(let ((value (jazz.generate-symbol "val")))
                   (jazz.walk walker resume declaration environment
                     `(lambda (self ,value)
                        (with-self
                          ,(if setter-name
                               `(,setter-name ,value)
                             `(set! ,name ,value)))))))
            `(jazz.add-slot ,class-locator ',name ,initialize-locator))))))


(define (jazz.get-slot-declaration-getter-locator declaration)
  (jazz.compose-slot-declaration-accessor-locator declaration (%%get-slot-declaration-getter-name declaration)))


(define (jazz.get-slot-declaration-setter-locator declaration)
  (jazz.compose-slot-declaration-accessor-locator declaration (%%get-slot-declaration-setter-name declaration)))


(define (jazz.compose-slot-declaration-accessor-locator declaration accessor-name)
  (let* ((class-declaration (%%get-declaration-parent declaration))
         (class-locator (jazz.get-locator class-declaration))
         (accessor-locator (jazz.compose-name class-locator accessor-name)))
    accessor-locator))


;;;
;;;; Property
;;;


(define (jazz.expand-property walker resume declaration environment . rest)
  (jazz.expand-slot-form walker resume declaration (%%cons 'property rest)))


;;;
;;;; Initialize
;;;


;;;
;;;; Method
;;;


(define jazz.method-modifiers
  '(((private package protected public) . protected)
    ((deprecated uptodate) . uptodate)
    ((virtual chained inherited) . inherited)
    ((abstract concrete) . concrete)
    ((inline onsite) . onsite)
    ;; quicky
    ((remote notremote) . notremote)
    ((synchronized notsynchronized) . notsynchronized)))


(define (jazz.parse-method walker resume declaration rest)
  (receive (access compatibility propagation implementation expansion remote synchronized rest) (jazz.parse-modifiers walker resume declaration jazz.method-modifiers rest)
    (%%assertion (and (%%pair? rest) (%%pair? (car rest))) (jazz.format "Ill-formed method in {a}: {s}" (jazz.get-declaration-name (%%get-declaration-toplevel declaration)) (cons 'method rest))
      (let* ((signature (%%car rest))
             (body (%%cdr rest))
             (effective-body (if (%%null? body) (%%list (%%list 'void)) body))
             (body-quicky (if (jazz.specifier? (%%car effective-body)) (%%cdr effective-body) effective-body))
             (name (%%car signature))
             (parameters (jazz.remove-specifiers-quicky (%%cdr signature))))
        (values name access compatibility propagation implementation expansion parameters body-quicky)))))


(define (jazz.expand-method walker resume declaration environment . rest)
  (receive (name access compatibility propagation implementation expansion parameters body) (jazz.parse-method walker resume declaration rest)
    (if (%%is? declaration jazz.Unit-Declaration)
        (let* ((found-declaration (jazz.lookup-declaration declaration name #f))
               (unit-declaration declaration)
               (unit-name (jazz.get-declaration-name unit-declaration))
               (generic-parameters (%%cons (%%list unit-name 'self) parameters)))
          (case propagation
            ((inherited)
             (if (and found-declaration (%%is? found-declaration jazz.Generic-Declaration))
                 `(%specific ,name ,generic-parameters #t (with-self ,@body))
               (jazz.expand-final-method unit-name access name parameters body)))
            (else
             (if (%%eq? implementation 'abstract)
                 `(generic ,access ,(%%cons name generic-parameters))
               `(begin
                  (generic ,access ,(%%cons name generic-parameters))
                  (%specific ,name ,generic-parameters #t (with-self ,@body)))))))
      (jazz.walk-error walker resume declaration "Methods can only be defined inside units: {s}" name))))


(define (jazz.expand-final-method unit-name access method-name parameters body)
  `(begin
     (definition ,access ,(%%cons method-name (%%cons 'self parameters))
       (with-self
         ,@body))
     (update-dispatch-table ,unit-name ',method-name ,method-name)))


;;;
;;;; With Self
;;;


(define (jazz.walk-with-self walker resume declaration environment form)
  (let ((new-environment (%%cons (jazz.new-self-binding) environment)))
    (jazz.simplify-begin
      `(begin
         ,@(jazz.walk-list walker resume declaration new-environment (%%cdr form))))))


;;;
;;;; Call
;;;


;; temp
(jazz.define-specific (jazz.validate-arguments (jazz.Jazz-Walker walker) resume source-declaration declaration signature arguments)
  (jazz.void))


;;;
;;;; Remote Proxy
;;;


(define jazz.remote-proxy-modifiers
  '(((private package protected public) . public)))

(define jazz.remote-proxy-keywords
  '(extends on))


(define (jazz.parse-remote-proxy walker resume declaration rest)
  (receive (access rest) (jazz.parse-modifiers walker resume declaration jazz.remote-proxy-modifiers rest)
    (let ((name (%%car rest))
          (rest (%%cdr rest)))
      (receive (ascendant-name on-name body) (jazz.parse-keywords jazz.remote-proxy-keywords rest)
        (values name access ascendant-name on-name body)))))


(define jazz.method-proxy-modifiers
  '(((private package protected public) . private)
    ((send post) . send)))


(define (jazz.parse-method-proxy walker resume declaration rest)
  (receive (access invocation rest) (jazz.parse-modifiers walker resume declaration jazz.method-proxy-modifiers rest)
    (let* ((signature (%%car rest))
           (name (%%car signature))
           (parameters (%%cdr signature)))
      (values name access invocation parameters))))


(define (jazz.expand-remote-proxy walker resume declaration environment . rest)
  (receive (name access ascendant-name on-name body) (jazz.parse-remote-proxy walker resume declaration rest)
    (let ((interface-class (%%string->symbol (%%string-append (%%symbol->string name) "-Interface")))
          (remote-class (%%string->symbol (%%string-append (%%symbol->string name) "-Remote")))
          (dispatcher-class (%%string->symbol (%%string-append (%%symbol->string name) "-Dispatcher")))
          (dispatcher-variable (jazz.generate-symbol "dispatcher"))
          (method-name-variable (jazz.generate-symbol "method-name"))
          (local-object-variable (jazz.generate-symbol "local-object"))
          (arguments-variable (jazz.generate-symbol "arguments"))
          (proxies (jazz.new-queue))
          (remotes (jazz.new-queue))
          (dispatchs (jazz.new-queue)))
      (for-each (lambda (method-form)
                  (%%assert (%%eq? (%%car method-form) 'method)
                    (receive (name access invocation parameters) (jazz.parse-method-proxy walker resume declaration (%%cdr method-form))
                      (let ((invoker (case invocation ((send) 'jazz.rmi.send-rmi) ((post) 'jazz.rmi.post-rmi)))
                            (proxy-parameter (%%car parameters))
                            (other-parameters (%%cdr parameters))
                            (implementation-name (jazz.compose-name on-name name)))
                        (jazz.enqueue proxies `(method ,access virtual abstract (,name ,@parameters)))
                        (jazz.enqueue remotes `(method (,name ,@parameters)
                                                       (,invoker ',name ,proxy-parameter ,@other-parameters)))
                        (jazz.enqueue dispatchs `((,name) (apply ,implementation-name ,local-object-variable ,arguments-variable)))))))
                body)
      `(begin
         (class private ,interface-class extends jazz.rmi.Proxy-Interface
           (method (remote-class interface)
             ,remote-class)
           (method (dispatcher-class interface)
             ,dispatcher-class))
         (interface ,access ,name extends jazz.rmi.Proxy metaclass ,interface-class ,@(if (jazz.specified? ascendant-name) (%%list ascendant-name) '())
           (method (proxy-interface proxy)
             ,name)
           ,@(jazz.queue-list proxies))
         (class private ,remote-class extends jazz.rmi.Remote-Proxy implements ,name
           ,@(jazz.queue-list remotes))
         (class private ,dispatcher-class extends jazz.rmi.Method-Dispatcher
           (method (dispatch ,dispatcher-variable ,method-name-variable ,local-object-variable ,arguments-variable)
             (case ,method-name-variable
               ,@(jazz.queue-list dispatchs)
               (else (nextmethod ,dispatcher-variable ,method-name-variable ,local-object-variable ,arguments-variable)))))))))


;;;
;;;; Coclass
;;;


(define (jazz.expand-coclass walker resume declaration environment . rest)
  `(begin)
  #; ;; waiting
  (apply jazz.expand-class walker resume declaration environment rest))


;;;
;;;; Cointerface
;;;


(define jazz.cointerface-modifiers
  '(((private package protected public) . public)))

(define jazz.cointerface-keywords
  '(extends on))


(define (jazz.parse-cointerface walker resume declaration rest)
  (receive (access rest) (jazz.parse-modifiers walker resume declaration jazz.cointerface-modifiers rest)
    (let ((name (%%car rest))
          (rest (%%cdr rest)))
      (receive (ascendant-name on-name body) (jazz.parse-keywords jazz.cointerface-keywords rest)
        (values name access ascendant-name on-name body)))))


(define (jazz.expand-cointerface walker resume declaration environment . rest)
  `(begin)
  #; ;; waiting
  (receive (name access ascendant-name on-name body) (jazz.parse-cointerface walker resume declaration rest)
    (let ((interface-class (%%string->symbol (%%string-append (%%symbol->string name) "-Interface")))
          (remote-class (%%string->symbol (%%string-append (%%symbol->string name) "-Remote")))
          (dispatcher-class (%%string->symbol (%%string-append (%%symbol->string name) "-Dispatcher")))
          (dispatcher-variable (jazz.generate-symbol "dispatcher"))
          (method-name-variable (jazz.generate-symbol "method-name"))
          (local-object-variable (jazz.generate-symbol "local-object"))
          (arguments-variable (jazz.generate-symbol "arguments"))
          (proxies (jazz.new-queue))
          (remotes (jazz.new-queue))
          (dispatchs (jazz.new-queue)))
      (for-each (lambda (method-form)
                  (%%assert (%%eq? (%%car method-form) 'method)
                    (receive (name access invocation parameters) (jazz.parse-method-proxy walker resume declaration (%%cdr method-form))
                      (let ((invoker (case invocation ((send) 'jazz.rmi.send-rmi) ((post) 'jazz.rmi.post-rmi)))
                            (proxy-parameter (%%car parameters))
                            (other-parameters (%%cdr parameters))
                            (implementation-name (jazz.compose-name on-name name)))
                        (jazz.enqueue proxies `(method ,access virtual abstract (,name ,@parameters)))
                        (jazz.enqueue remotes `(method (,name ,@parameters)
                                                       (,invoker ',name ,proxy-parameter ,@other-parameters)))
                        (jazz.enqueue dispatchs `((,name) (apply ,implementation-name ,local-object-variable ,arguments-variable)))))))
                body)
      `(begin
         (class private ,interface-class extends jazz.rmi.Proxy-Interface
           (method (remote-class interface)
             ,remote-class)
           (method (dispatcher-class interface)
             ,dispatcher-class))
         (interface ,access ,name extends jazz.rmi.Proxy metaclass ,interface-class ,@(if (jazz.specified? ascendant-name) (%%list ascendant-name) '())
           (method (proxy-interface proxy)
             ,name)
           ,@(jazz.queue-list proxies))
         (class private ,remote-class extends jazz.rmi.Remote-Proxy implements ,name
           ,@(jazz.queue-list remotes))
         (class private ,dispatcher-class extends jazz.rmi.Method-Dispatcher
           (method (dispatch ,dispatcher-variable ,method-name-variable ,local-object-variable ,arguments-variable)
             (case ,method-name-variable
               ,@(jazz.queue-list dispatchs)
               (else (nextmethod ,dispatcher-variable ,method-name-variable ,local-object-variable ,arguments-variable)))))))))


;;;
;;;; Symbol
;;;


(jazz.define-specific (jazz.validate-access (jazz.Jazz-Walker walker) resume declaration referenced-declaration)
  (let ((referenced-access (%%get-declaration-access referenced-declaration)))
    (case referenced-access
      ((public)    (jazz.void))
      ((private)   (jazz.validate-private-access walker resume declaration referenced-declaration))
      ((package)   (jazz.validate-package-access walker resume declaration referenced-declaration))
      ((protected) (jazz.validate-protected-access walker resume declaration referenced-declaration)))))


(define (jazz.validate-private-access walker resume declaration referenced-declaration)
  (if (%%neq? (%%get-declaration-toplevel declaration)
              (%%get-declaration-toplevel referenced-declaration))
      (jazz.illegal-access walker resume declaration referenced-declaration)))


(define (jazz.validate-package-access walker resume declaration referenced-declaration)
  ;; todo
  (jazz.void))


(define (jazz.validate-protected-access walker resume declaration referenced-declaration)
  ;; todo
  (jazz.void))


(define (jazz.illegal-access walker resume declaration referenced-declaration)
  (let ((referenced-access (%%get-declaration-access referenced-declaration))
        (referenced-locator (jazz.get-locator referenced-declaration)))
    (jazz.walk-error walker resume declaration "Illegal {a} access to {s}" referenced-access referenced-locator)))


;;;
;;;; Assert
;;;


(define (jazz.expand-assert walker resume declaration environment assertion . body)
  `(begin)
  #; ;; wait
  (if (jazz.debug?)
      (let ((message (let ((port (open-output-string)))
                       (display "Assertion " port)
                       (write assertion port)
                       (display " failed" port)
                       (get-output-string port))))
        `(if (not ,assertion)
             (error "{a}" ,message)
           ,(jazz.simplify-begin
              `(begin
                 ,@body))))
    (jazz.simplify-begin `(begin ,@body))))


;;;
;;;; Atomic Region
;;;


(define (jazz.walk-atomic-region walker resume declaration environment form)
  (let ((body (%%cdr form)))
    `(let ()
       (declare (not interrupts-enabled))
       ,@(jazz.walk-body walker resume declaration environment body))))


;;;
;;;; Optimize
;;;


(define (jazz.expand-optimize walker resume declaration environment parameters . body)
  `(begin
     ,@body))


;;;
;;;; C Include
;;;


(define (jazz.walk-c-include walker resume declaration environment form)
  (jazz.bind (name) (%%cdr form)
    `(c-declare ,(%%string-append "#include " name))))


;;;
;;;; C Function
;;;


(define (jazz.walk-c-function walker resume declaration environment form)
  (jazz.bind (types result-type c-name-or-code) (%%cdr form)
    (let ((resolve-access (lambda (type) (jazz.expand-c-type-access walker resume declaration environment type))))
      `(c-lambda ,(map resolve-access types) ,(resolve-access result-type) ,c-name-or-code))))


;;;
;;;; Function
;;;


(define jazz.function-modifiers
  '(((dynamic indefinite) . indefinite)))


(define (jazz.parse-function walker resume declaration form)
  (receive (extent rest) (jazz.parse-modifiers walker resume declaration jazz.function-modifiers (%%cdr form))
    (let* ((parameters (jazz.remove-specifiers-quicky (%%car rest)))
           (body (%%cdr rest))
           (effective-body (if (%%null? body) (%%list (%%list 'void)) body)))
      (values extent parameters effective-body))))


(define (jazz.walk-function walker resume declaration environment form)
  (receive (extent parameters body) (jazz.parse-function walker resume declaration form)
    (jazz.walk-lambda walker resume declaration environment
     `(lambda ,parameters
        ,@body))))



;;;
;;;; Parameterize
;;;


(define (jazz.walk-parameterize walker resume declaration environment form)
  (let ((bindings (%%cadr form))
        (body (%%cddr form)))
    `(parameterize ,(map (lambda (binding)
                           (let ((name (%%car binding))
                                 (value (%%cadr binding)))
                             `(,(jazz.walk walker resume declaration environment name)
                               ,(jazz.walk walker resume declaration environment value))))
                         bindings)
       ,@(jazz.walk-body walker resume declaration environment body))))


;;;
;;;; Void
;;;


(define (jazz.walk-void? walker resume declaration environment form)
  (let ((value (%%cadr form)))
    `(%%eq? ,(jazz.walk walker resume declaration environment value) jazz.Void)))


(define (jazz.walk-not-void? walker resume declaration environment form)
  (let ((value (%%cadr form)))
    `(%%neq? ,(jazz.walk walker resume declaration environment value) jazz.Void)))


;;;
;;;; With Slots
;;;


(define (jazz.walk-with-slots walker resume declaration environment form)
  (jazz.bind (slot-names object . body) (%%cdr form)
    (let ((object-symbol (jazz.generate-symbol "object")))
      (jazz.walk walker resume declaration environment
       `(let ((,object-symbol ,object))
          (let-symbol ,(map (lambda (slot-name)
                              (let* ((slot-declaration (jazz.lookup-reference walker resume declaration environment slot-name))
                                     (getter-name (%%get-slot-declaration-getter-name slot-declaration))
                                     (setter-name (%%get-slot-declaration-setter-name slot-declaration)))
                                (%%list slot-name `(lambda () (%%list ',getter-name ',object-symbol)) `(lambda (value) (%%list ',setter-name ',object-symbol value)))))
                            slot-names)
            ,@body))))))


;;;
;;;; Form
;;;


(define (jazz.walk-form-special walker resume declaration environment form)
  (let ((form (%%cadr form)))
    (let* ((class-declaration declaration)
           (class-locator (jazz.get-locator class-declaration)))
      (jazz.walk walker resume declaration environment
        `(method (get-class-forms)
           (cons (jml->form>> ',form ,class-locator) (nextmethod)))))))


;;;
;;;; Register
;;;


(let ((dialect (jazz.new-jazz-dialect)))
  (jazz.register-dialect 'jazz dialect)
  (jazz.register-dialect 'jazz.dialect dialect)))
