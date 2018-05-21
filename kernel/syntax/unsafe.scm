;;;==============
;;;  JazzScheme
;;;==============
;;;
;;;; Unsafe Calls
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
;;;  Portions created by the Initial Developer are Copyright (C) 1996-2018
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


(define jazz:debug-core?
  (eq? jazz:kernel-safety 'core))

(define jazz:debug-user?
  (not (eq? jazz:kernel-safety 'sealed)))

(define jazz:debug-flonum?
  (if (memq 'finite jazz:kernel-features)
      #f
    jazz:debug-core?))


(jazz:define-macro (%%danger name expr)
  #;
  `(begin
     (pp '(***DANGER ,name))
     ,expr)
  expr)


(jazz:define-macro (jazz:unsafe expr)
  (let ((oper (car expr))
        (args (cdr expr)))
    `(let ()
       (declare (not safe))
       (,oper ,@(map (lambda (arg)
                       (if jazz:debug-user?
                           `(let ()
                              (declare (safe))
                              ,arg)
                         arg))
                     args)))))


(jazz:define-macro (jazz:define-unsafe name)
  (let ((str (symbol->string name)))
    (let ((suffix (substring str 2 (string-length str))))
      (let ((lowlevel (string->symbol (string-append "##" suffix))))
        `(jazz:define-macro (,name . rest)
           `(jazz:unsafe (,',lowlevel ,@rest)))))))


;;;
;;;; Unsafe
;;;


(jazz:define-unsafe ^#*)
(jazz:define-unsafe ^#+)
(jazz:define-unsafe ^#-)
(jazz:define-unsafe ^#/)
(jazz:define-unsafe ^#=)
(jazz:define-unsafe ^#actlog-stop)
(jazz:define-unsafe ^#add-gc-interrupt-job!)
(jazz:define-unsafe ^#append)
(jazz:define-unsafe ^#apply)
(jazz:define-unsafe ^#assoc)
(jazz:define-unsafe ^#assq)
(jazz:define-unsafe ^#assv)
(jazz:define-unsafe ^#boolean?)
(jazz:define-unsafe ^#box)
(jazz:define-unsafe ^#box?)
(jazz:define-unsafe ^#build-list)
(jazz:define-unsafe ^#caar)
(jazz:define-unsafe ^#cadr)
(jazz:define-unsafe ^#car)
(jazz:define-unsafe ^#cdar)
(jazz:define-unsafe ^#cddr)
(jazz:define-unsafe ^#cdr)
(jazz:define-unsafe ^#char<=?)
(jazz:define-unsafe ^#char=?)
(jazz:define-unsafe ^#char?)
(jazz:define-unsafe ^#clear-gc-interrupt-jobs!)
(jazz:define-unsafe ^#closure-code)
(jazz:define-unsafe ^#closure-length)
(jazz:define-unsafe ^#closure-ref)
(jazz:define-unsafe ^#closure?)
(jazz:define-unsafe ^#complex?)
(jazz:define-unsafe ^#cond-expand-features)
(jazz:define-unsafe ^#cons)
(jazz:define-unsafe ^#container->id-hook-set!)
(jazz:define-unsafe ^#container->path)
(jazz:define-unsafe ^#container->path-hook-set!)
(jazz:define-unsafe ^#continuation-capture)
(jazz:define-unsafe ^#continuation-creator)
(jazz:define-unsafe ^#continuation-first-frame)
(jazz:define-unsafe ^#continuation-graft)
(jazz:define-unsafe ^#continuation-graft-no-winding)
(jazz:define-unsafe ^#continuation-locals)
(jazz:define-unsafe ^#continuation-locat)
(jazz:define-unsafe ^#continuation-next)
(jazz:define-unsafe ^#continuation-next-frame)
(jazz:define-unsafe ^#continuation-parent)
(jazz:define-unsafe ^#continuation-return)
(jazz:define-unsafe ^#continuation-return-no-winding)
(jazz:define-unsafe ^#continuation?)
(jazz:define-unsafe ^#current-readtable)
(jazz:define-unsafe ^#current-thread)
(jazz:define-unsafe ^#default-wr)
(jazz:define-unsafe ^#desourcify)
(jazz:define-unsafe ^#disable-interrupts!)
(jazz:define-unsafe ^#display-exception-hook-set!)
(jazz:define-unsafe ^#enable-interrupts!)
(jazz:define-unsafe ^#eof-object?)
(jazz:define-unsafe ^#eq?)
(jazz:define-unsafe ^#equal?)
(jazz:define-unsafe ^#eqv?)
(jazz:define-unsafe ^#exception->locat)
(jazz:define-unsafe ^#f32vector)
(jazz:define-unsafe ^#f32vector-length)
(jazz:define-unsafe ^#f32vector-ref)
(jazz:define-unsafe ^#f32vector-set!)
(jazz:define-unsafe ^#f32vector?)
(jazz:define-unsafe ^#f64vector)
(jazz:define-unsafe ^#f64vector-length)
(jazz:define-unsafe ^#f64vector-ref)
(jazz:define-unsafe ^#f64vector-set!)
(jazz:define-unsafe ^#f64vector?)
(jazz:define-unsafe ^#filepos->position)
(jazz:define-unsafe ^#filepos-col)
(jazz:define-unsafe ^#filepos-line)
(jazz:define-unsafe ^#fixnum->flonum)
(jazz:define-unsafe ^#fixnum?)
(jazz:define-unsafe ^#fl*)
(jazz:define-unsafe ^#fl+)
(jazz:define-unsafe ^#fl-)
(jazz:define-unsafe ^#fl/)
(jazz:define-unsafe ^#fl<)
(jazz:define-unsafe ^#fl<=)
(jazz:define-unsafe ^#fl=)
(jazz:define-unsafe ^#fl>)
(jazz:define-unsafe ^#fl>=)
(jazz:define-unsafe ^#flabs)
(jazz:define-unsafe ^#flacos)
(jazz:define-unsafe ^#flasin)
(jazz:define-unsafe ^#flatan)
(jazz:define-unsafe ^#flceiling)
(jazz:define-unsafe ^#flcos)
(jazz:define-unsafe ^#flexpt)
(jazz:define-unsafe ^#flfloor)
(jazz:define-unsafe ^#flmax)
(jazz:define-unsafe ^#flmin)
(jazz:define-unsafe ^#flnan?)
(jazz:define-unsafe ^#flonum->exact-int)
(jazz:define-unsafe ^#flonum->fixnum)
(jazz:define-unsafe ^#flonum?)
(jazz:define-unsafe ^#flround)
(jazz:define-unsafe ^#flsin)
(jazz:define-unsafe ^#flsqrt)
(jazz:define-unsafe ^#flsquare)
(jazz:define-unsafe ^#fltan)
(jazz:define-unsafe ^#fltruncate)
(jazz:define-unsafe ^#foreign?)
(jazz:define-unsafe ^#fx*)
(jazz:define-unsafe ^#fx+)
(jazz:define-unsafe ^#fx-)
(jazz:define-unsafe ^#fx<)
(jazz:define-unsafe ^#fx<=)
(jazz:define-unsafe ^#fx=)
(jazz:define-unsafe ^#fx>)
(jazz:define-unsafe ^#fx>=)
(jazz:define-unsafe ^#fxabs)
(jazz:define-unsafe ^#fxand)
(jazz:define-unsafe ^#fxarithmetic-shift)
(jazz:define-unsafe ^#fxarithmetic-shift-left)
(jazz:define-unsafe ^#fxarithmetic-shift-right)
(jazz:define-unsafe ^#fxeven?)
(jazz:define-unsafe ^#fxior)
(jazz:define-unsafe ^#fxmax)
(jazz:define-unsafe ^#fxmin)
(jazz:define-unsafe ^#fxmodulo)
(jazz:define-unsafe ^#fxnot)
(jazz:define-unsafe ^#fxodd?)
(jazz:define-unsafe ^#fxquotient)
(jazz:define-unsafe ^#fxxor)
(jazz:define-unsafe ^#gc)
(jazz:define-unsafe ^#gc-hash-table?)
(jazz:define-unsafe ^#get-bytes-allocated!)
(jazz:define-unsafe ^#get-current-time!)
(jazz:define-unsafe ^#get-heartbeat-interval!)
(jazz:define-unsafe ^#get-live-percent)
(jazz:define-unsafe ^#get-max-heap)
(jazz:define-unsafe ^#get-min-heap)
(jazz:define-unsafe ^#get-monotonic-time!)
(jazz:define-unsafe ^#global-var-ref)
(jazz:define-unsafe ^#global-var-set!)
(jazz:define-unsafe ^#global-var?)
(jazz:define-unsafe ^#inexact->exact)
(jazz:define-unsafe ^#input-port-column-set!)
(jazz:define-unsafe ^#input-port-line-set!)
(jazz:define-unsafe ^#integer?)
(jazz:define-unsafe ^#interp-continuation?)
(jazz:define-unsafe ^#interp-procedure?)
(jazz:define-unsafe ^#interrupt-handler)
(jazz:define-unsafe ^#interrupt-vector-set!)
(jazz:define-unsafe ^#jazz?)
(jazz:define-unsafe ^#jazzstruct?)
(jazz:define-unsafe ^#keyword->string)
(jazz:define-unsafe ^#keyword-table)
(jazz:define-unsafe ^#keyword?)
(jazz:define-unsafe ^#length)
(jazz:define-unsafe ^#list)
(jazz:define-unsafe ^#list->vector)
(jazz:define-unsafe ^#load)
(jazz:define-unsafe ^#locat-container)
(jazz:define-unsafe ^#locat-position)
(jazz:define-unsafe ^#locat?)
(jazz:define-unsafe ^#make-f32vector)
(jazz:define-unsafe ^#make-f64vector)
(jazz:define-unsafe ^#make-locat)
(jazz:define-unsafe ^#make-s16vector)
(jazz:define-unsafe ^#make-s32vector)
(jazz:define-unsafe ^#make-s64vector)
(jazz:define-unsafe ^#make-s8vector)
(jazz:define-unsafe ^#make-source)
(jazz:define-unsafe ^#make-standard-readtable)
(jazz:define-unsafe ^#make-u16vector)
(jazz:define-unsafe ^#make-u32vector)
(jazz:define-unsafe ^#make-u64vector)
(jazz:define-unsafe ^#make-u8vector)
(jazz:define-unsafe ^#make-vector)
(jazz:define-unsafe ^#member)
(jazz:define-unsafe ^#memq)
(jazz:define-unsafe ^#newline)
(jazz:define-unsafe ^#not)
(jazz:define-unsafe ^#null?)
(jazz:define-unsafe ^#number->string)
(jazz:define-unsafe ^#number?)
(jazz:define-unsafe ^#object->string)
(jazz:define-unsafe ^#pair?)
(jazz:define-unsafe ^#path->container-hook-set!)
(jazz:define-unsafe ^#path-expand)
(jazz:define-unsafe ^#port-name)
(jazz:define-unsafe ^#port-name->container)
(jazz:define-unsafe ^#port?)
(jazz:define-unsafe ^#position->filepos)
(jazz:define-unsafe ^#procedure-locat)
(jazz:define-unsafe ^#procedure-name)
(jazz:define-unsafe ^#procedure?)
(jazz:define-unsafe ^#process-statistics)
(jazz:define-unsafe ^#raise-heap-overflow-exception)
(jazz:define-unsafe ^#rational?)
(jazz:define-unsafe ^#ratnum->flonum)
(jazz:define-unsafe ^#ratnum?)
(jazz:define-unsafe ^#read-all-as-a-begin-expr-from-port)
(jazz:define-unsafe ^#read-datum-or-label-or-none-or-dot)
(jazz:define-unsafe ^#readenv-current-filepos)
(jazz:define-unsafe ^#readtable-char-class-set!)
(jazz:define-unsafe ^#readtable-char-delimiter?)
(jazz:define-unsafe ^#readtable-char-delimiter?-set!)
(jazz:define-unsafe ^#readtable-char-handler)
(jazz:define-unsafe ^#readtable-char-handler-set!)
(jazz:define-unsafe ^#readtable-char-sharp-handler)
(jazz:define-unsafe ^#readtable-char-sharp-handler-set!)
(jazz:define-unsafe ^#readtable-copy)
(jazz:define-unsafe ^#readtable?)
(jazz:define-unsafe ^#real?)
(jazz:define-unsafe ^#remove)
(jazz:define-unsafe ^#repl)
(jazz:define-unsafe ^#repl-channel-result-history-add)
(jazz:define-unsafe ^#repl-debug)
(jazz:define-unsafe ^#reverse)
(jazz:define-unsafe ^#s16vector)
(jazz:define-unsafe ^#s16vector-length)
(jazz:define-unsafe ^#s16vector-ref)
(jazz:define-unsafe ^#s16vector-set!)
(jazz:define-unsafe ^#s16vector?)
(jazz:define-unsafe ^#s32vector)
(jazz:define-unsafe ^#s32vector-length)
(jazz:define-unsafe ^#s32vector-ref)
(jazz:define-unsafe ^#s32vector-set!)
(jazz:define-unsafe ^#s32vector?)
(jazz:define-unsafe ^#s64vector)
(jazz:define-unsafe ^#s64vector-length)
(jazz:define-unsafe ^#s64vector-ref)
(jazz:define-unsafe ^#s64vector-set!)
(jazz:define-unsafe ^#s64vector?)
(jazz:define-unsafe ^#s8vector)
(jazz:define-unsafe ^#s8vector-length)
(jazz:define-unsafe ^#s8vector-ref)
(jazz:define-unsafe ^#s8vector-set!)
(jazz:define-unsafe ^#s8vector?)
(jazz:define-unsafe ^#set-car!)
(jazz:define-unsafe ^#set-cdr!)
(jazz:define-unsafe ^#set-heartbeat-interval!)
(jazz:define-unsafe ^#set-max-heap!)
(jazz:define-unsafe ^#set-min-heap!)
(jazz:define-unsafe ^#six-types-set!)
(jazz:define-unsafe ^#source-code)
(jazz:define-unsafe ^#source-locat)
(jazz:define-unsafe ^#source?)
(jazz:define-unsafe ^#sourcify)
(jazz:define-unsafe ^#sourcify-deep)
(jazz:define-unsafe ^#still-copy)
(jazz:define-unsafe ^#still-obj-refcount-dec!)
(jazz:define-unsafe ^#still-obj-refcount-inc!)
(jazz:define-unsafe ^#string->keyword)
(jazz:define-unsafe ^#string->number)
(jazz:define-unsafe ^#string->symbol)
(jazz:define-unsafe ^#string-append)
(jazz:define-unsafe ^#string-ci=?)
(jazz:define-unsafe ^#string-length)
(jazz:define-unsafe ^#string-ref)
(jazz:define-unsafe ^#string-set!)
(jazz:define-unsafe ^#string-shrink!)
(jazz:define-unsafe ^#string<?)
(jazz:define-unsafe ^#string=?)
(jazz:define-unsafe ^#string?)
(jazz:define-unsafe ^#structure-ref)
(jazz:define-unsafe ^#structure-set!)
(jazz:define-unsafe ^#structure-type)
(jazz:define-unsafe ^#structure?)
(jazz:define-unsafe ^#substring)
(jazz:define-unsafe ^#subtype-set!)
(jazz:define-unsafe ^#symbol->string)
(jazz:define-unsafe ^#symbol-table)
(jazz:define-unsafe ^#symbol?)
(jazz:define-unsafe ^#table-merge!)
(jazz:define-unsafe ^#table-ref)
(jazz:define-unsafe ^#table-set!)
(jazz:define-unsafe ^#thread-repl-channel-get!)
(jazz:define-unsafe ^#thread-repl-context-get!)
(jazz:define-unsafe ^#type-all-fields)
(jazz:define-unsafe ^#type-field-count)
(jazz:define-unsafe ^#type-flags)
(jazz:define-unsafe ^#type-id)
(jazz:define-unsafe ^#type-name)
(jazz:define-unsafe ^#type-super)
(jazz:define-unsafe ^#type?)
(jazz:define-unsafe ^#u16vector)
(jazz:define-unsafe ^#u16vector-length)
(jazz:define-unsafe ^#u16vector-ref)
(jazz:define-unsafe ^#u16vector-set!)
(jazz:define-unsafe ^#u16vector?)
(jazz:define-unsafe ^#u32vector)
(jazz:define-unsafe ^#u32vector-length)
(jazz:define-unsafe ^#u32vector-ref)
(jazz:define-unsafe ^#u32vector-set!)
(jazz:define-unsafe ^#u32vector?)
(jazz:define-unsafe ^#u64vector)
(jazz:define-unsafe ^#u64vector-length)
(jazz:define-unsafe ^#u64vector-ref)
(jazz:define-unsafe ^#u64vector-set!)
(jazz:define-unsafe ^#u64vector?)
(jazz:define-unsafe ^#u8vector)
(jazz:define-unsafe ^#u8vector-length)
(jazz:define-unsafe ^#u8vector-ref)
(jazz:define-unsafe ^#u8vector-set!)
(jazz:define-unsafe ^#u8vector?)
(jazz:define-unsafe ^#unbound?)
(jazz:define-unsafe ^#unbox)
(jazz:define-unsafe ^#values?)
(jazz:define-unsafe ^#vector)
(jazz:define-unsafe ^#vector->list)
(jazz:define-unsafe ^#vector-copy)
(jazz:define-unsafe ^#vector-length)
(jazz:define-unsafe ^#vector-ref)
(jazz:define-unsafe ^#vector-set!)
(jazz:define-unsafe ^#vector?)
(jazz:define-unsafe ^#wr-set!)
(jazz:define-unsafe ^#write)
(jazz:define-unsafe ^#write-string)