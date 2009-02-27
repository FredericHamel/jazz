;;;==============
;;;  JazzScheme
;;;==============
;;;
;;;; Jazz Kernel
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
;;;  Portions created by the Initial Developer are Copyright (C) 1996-2008
;;;  the Initial Developer. All Rights Reserved.
;;;
;;;  Contributor(s):
;;;    Stephane Le Cornec
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


(library jazz.dialect.kernel scheme


;;;
;;;; Autoload
;;;


(native jazz.get-autoload)
(native jazz.autoload)
(native jazz.autoreload)


;;;
;;;; Boolean
;;;


(native jazz.boolean)


;;;
;;;; Box
;;;


(native box?)
(native box)
(native unbox)
(native set-box!)


;;;
;;;; Build
;;;


(native jazz.build-module)
(native jazz.build-executable)
(native jazz.compile-module)
(native jazz.for-each-submodule)


;;;
;;;; Category
;;;


(native jazz.get-category-name)
(native jazz.get-category-descendants)
(native jazz.get-class-ascendant)


;;;
;;;; Char
;;;


(native jazz.symbolic-char)
(native jazz.char-symbol)


;;;
;;;; Collector
;;;


(native jazz.gc)


;;;
;;;; Continuation
;;;


(native jazz.continuation?)
(native jazz.continuation-capture)
(native jazz.continuation-graft)
(native jazz.continuation-return)


;;;
;;;; Debug
;;;


(native jazz.run-loop?)
(native jazz.terminal)
(native jazz.terminal-string)
(native jazz.terminal-port)
(native jazz.error)
(native jazz.unimplemented)
(native jazz.dump-stack)
(native jazz.log-object)
(native jazz.log-string)
(native jazz.log-newline)
(native jazz.close-log)
(native generate-proper-tail-calls)


;;;
;;;; Development
;;;


;; These globals should really be some readtime mecanism like Gambit's #
;; Need to discuss with Marc Feeley about how to do that cleanly


(native ?) (native get-?) (native set-?)
(native %) (native get-%) (native set-%)


(native ?a) (native get-?a) (native set-?a)
(native ?b) (native get-?b) (native set-?b)
(native ?c) (native get-?c) (native set-?c)
(native ?d) (native get-?d) (native set-?d)
(native ?e) (native get-?e) (native set-?e)
(native ?f) (native get-?f) (native set-?f)
(native ?g) (native get-?g) (native set-?g)
(native ?h) (native get-?h) (native set-?h)
(native ?i) (native get-?i) (native set-?i)
(native ?j) (native get-?j) (native set-?j)
(native ?k) (native get-?k) (native set-?k)
(native ?l) (native get-?l) (native set-?l)
(native ?m) (native get-?m) (native set-?m)
(native ?n) (native get-?n) (native set-?n)
(native ?o) (native get-?o) (native set-?o)
(native ?p) (native get-?p) (native set-?p)
(native ?q) (native get-?q) (native set-?q)
(native ?r) (native get-?r) (native set-?r)
(native ?s) (native get-?s) (native set-?s)
(native ?t) (native get-?t) (native set-?t)
(native ?u) (native get-?u) (native set-?u)
(native ?v) (native get-?v) (native set-?v)
(native ?w) (native get-?w) (native set-?w)
(native ?x) (native get-?x) (native set-?x)
(native ?y) (native get-?y) (native set-?y)
(native ?z) (native get-?z) (native set-?z)


(native %a) (native get-%a) (native set-%a)
(native %b) (native get-%b) (native set-%b)
(native %c) (native get-%c) (native set-%c)
(native %d) (native get-%d) (native set-%d)
(native %e) (native get-%e) (native set-%e)
(native %f) (native get-%f) (native set-%f)
(native %g) (native get-%g) (native set-%g)
(native %h) (native get-%h) (native set-%h)
(native %i) (native get-%i) (native set-%i)
(native %j) (native get-%j) (native set-%j)
(native %k) (native get-%k) (native set-%k)
(native %l) (native get-%l) (native set-%l)
(native %m) (native get-%m) (native set-%m)
(native %n) (native get-%n) (native set-%n)
(native %o) (native get-%o) (native set-%o)
(native %p) (native get-%p) (native set-%p)
(native %q) (native get-%q) (native set-%q)
(native %r) (native get-%r) (native set-%r)
(native %s) (native get-%s) (native set-%s)
(native %t) (native get-%t) (native set-%t)
(native %u) (native get-%u) (native set-%u)
(native %v) (native get-%v) (native set-%v)
(native %w) (native get-%w) (native set-%w)
(native %x) (native get-%x) (native set-%x)
(native %y) (native get-%y) (native set-%y)
(native %z) (native get-%z) (native set-%z)


;;;
;;;; Digest
;;;


(native open-digest)
(native close-digest)
(native digest-update-subu8vector)
(native digest-string)
(native digest-substring)
(native digest-u8vector)
(native digest-subu8vector)
(native digest-file)


;;;
;;;; Enumerator
;;;


(native jazz.enumerator?)
(native jazz.enumerator->symbol)


;;;
;;;; Exception
;;;


(native jazz.exception-reason)
(native jazz.exception-detail)
(native jazz.display-exception)
(native jazz.display-continuation-backtrace)
(native jazz.get-exception-hook)
(native jazz.set-exception-hook)
(native jazz.invoke-exception-hook)
(native jazz.system-exception-hook)
(native jazz.current-exception-handler)
(native jazz.with-exception-handler)
(native jazz.with-exception-catcher)
(native jazz.with-exception-filter)
(native jazz.with-exception-propagater)
(native jazz.dump-exception)
(native jazz.raise)
(native jazz.present-exception)
(native jazz.get-detail)


;;;
;;;; Field
;;;


(native jazz.field? <object:bool>)
(native jazz.field-name)
(native jazz.find-field)


;;;
;;;; Fixnum
;;;


(native fixnum? <object:bool>)
(native flonum? <object:bool>)
(native jazz.fixnum->flonum <fx:fl>)
(native jazz.flonum->fixnum <fl:fx>)
(native fx+ <fx^fx:fx>)
(native fx- <fx^fx:fx>)
(native fx* <fx^fx:fx>)
(native jazz.+infinity)
(native jazz.-infinity)


;;;
;;;; Flonum
;;;


;; until proper call site casting of native calls

(native ##fl+ <fl^fl:fl>)
(native ##fl- <fl^fl:fl>)
(native ##fl* <fl^fl:fl>)
(native ##fl/ <fl^fl:fl>)


;;;
;;;; Foreign
;;;


(native jazz.foreign?)
(native jazz.foreign-address)
(native jazz.foreign-release!)
(native jazz.foreign-released?)
(native jazz.foreign-tags)
;;(native jazz.still-obj-refcount)
(native jazz.still-obj-refcount-dec!)
(native jazz.still-obj-refcount-inc!)


;;;
;;;; Gambit
;;;


(native compile-file)


;;;
;;;; Host
;;;


(native command-line)
(native user-name)


;;;
;;;; Identifier
;;;


(native jazz.composite-name?)
(native jazz.compose-name)
(native jazz.identifier-module <symbol>)
(native jazz.identifier-name <symbol>)
(native jazz.split-identifier)


;;;
;;;; Instance
;;;


;;(native jazz.current-instance)


;;;
;;;; Integer
;;;


(native bitwise-not <int:int>)
(native bitwise-and <int*:int>)
(native bitwise-ior <int*:int>)
(native bitwise-xor <int*:int>)
(native arithmetic-shift <int:int>)
(native bit-set? <int^int:bool>)
(native extract-bit-field <int^int^int:int>)


;;;
;;;; Kernel
;;;


(native jazz.build-feedback)
(native jazz.boot-directory)
(native jazz.kernel-system)
(native jazz.kernel-platform)
(native jazz.kernel-windowing)
(native jazz.kernel-safety)
(native jazz.kernel-optimize?)
(native jazz.kernel-debug-environments?)
(native jazz.kernel-debug-location?)
(native jazz.kernel-debug-source?)
(native jazz.kernel-destination)
(native jazz.kernel-built)
(native jazz.kernel-install)
(native jazz.kernel-source)
(native jazz.kernel-version)
(native jazz.get-source-version-number)
(native jazz.jazz-product)
(native jazz.jazz-profile)
(native jazz.use-debugger?)
(native jazz.get-repositories)
(native jazz.install-repository)
(native jazz.uninstall-repository)
(native jazz.find-repository)
(native jazz.repository?)
(native jazz.repository-name)
(native jazz.repository-directory)
(native jazz.repository-packages)
(native jazz.repository-find-package)
(native jazz.repository-install-packages)
(native jazz.repository-add-package)
(native jazz.repository-remove-package)
(native jazz.package?)
(native jazz.package-repository)
(native jazz.package-name)
(native jazz.package-project)
(native jazz.split-version)
(native jazz.present-version)
(native jazz.load-package)
(native jazz.register-product)
(native jazz.get-registered-product)
(native jazz.current-process-name)
(native jazz.current-process-name-set!)
(native jazz.current-process-title)
(native jazz.current-process-title-set!)
(native jazz.current-process-icon)
(native jazz.current-process-icon-set!)
(native jazz.current-process-version)
(native jazz.current-process-version-set!)
(native jazz.current-process-present)
(native jazz.destination-directory)
(native jazz.executable-extension)
(native jazz.run-product)
(native jazz.update-product)
(native jazz.build-product)
(native jazz.find-pathname-module)
(native jazz.find-module-src)
(native jazz.gather-profiles)
(native jazz.make-profile)
(native jazz.profile-name)
(native jazz.profile-title)
(native jazz.profile-module)
(native jazz.module-autoload)
(native jazz.get-environment)
(native jazz.get-environment-module)
(native jazz.load-module)
(native jazz.reload-module)
(native jazz.load-all)
(native jazz.get-load-mutex)
(native jazz.walk-for)
(native main)


;;;
;;;; Keyword
;;;


(native jazz.keyword?)
(native jazz.string->keyword)
(native jazz.keyword->string)


;;;
;;;; List
;;;


(native jazz.not-null?)
(native jazz.listify)
(native jazz.list-copy)
(native jazz.last-pair)
(native jazz.proper-list)


;;;
;;;; Network
;;;


(native jazz.open-tcp-client)
(native jazz.open-tcp-server)
(native jazz.tcp-server-socket-info)
(native jazz.call-with-tcp-client)


;;;
;;;; Object
;;;


(native jazz.new)
(native jazz.class-of)
(native jazz.object?)
(native jazz.type?)
(native jazz.category?)
(native jazz.interface?)
(native jazz.method?)
(native jazz.is?)
(native jazz.subtype?)
(native jazz.subcategory?)
(native jazz.subclass?)


;;;
;;;; Parameters
;;;


(native make-parameter)


;;;
;;;; Pathname
;;;


(native jazz.pathname-type)
(native jazz.pathname-expand)
(native jazz.pathname-normalize)
(native jazz.file-exists?)
(native jazz.file-delete)
(native jazz.file-copy)
(native jazz.file-modification-time)
(native jazz.file-rename)
(native jazz.current-directory)
(native jazz.current-directory-set!)
(native jazz.with-current-directory)
(native jazz.directory-create)
(native jazz.directory-content)
(native jazz.directory-delete)


;;;
;;;; Pipe
;;;


(native open-string-pipe)


;;;
;;;; Port
;;;


(native port?)
(native jazz.close-port)
(native jazz.input-port-timeout-set!)
(native jazz.output-port-timeout-set!)
(native open-event-queue)
(native jazz.eof-object)
(native open-input-string)
(native open-output-string)
(native get-output-string)
(native call-with-input-string)
(native with-input-from-string)
(native call-with-output-string)
(native read-substring)
(native open-vector)
(native call-with-input-u8vector)
(native open-output-u8vector)
(native get-output-u8vector)
(native jazz.read-u8)
(native jazz.write-u8)
(native jazz.read-subu8vector)
(native jazz.write-subu8vector)
(native jazz.read-line)
(native jazz.read-proper-line)
(native jazz.read-all)
(native jazz.print)
(native jazz.pretty-print)
(native jazz.read-source-all)
(native jazz.read-source-first)
(native force-output)
(native current-error-port)
(native with-output-to-port)
(native write-u8)


;;;
;;;; Property
;;;


(native jazz.property-getter)
(native jazz.property-setter)


;;;
;;;; Queue
;;;


(native jazz.new-queue)
(native jazz.enqueue)
(native jazz.enqueue-list)
(native jazz.queue-list)
(native jazz.reset-queue)


;;;
;;;; Random
;;;


(native jazz.random-integer)
(native jazz.random-real)
(native jazz.random-source-randomize!)
(native jazz.random-source-pseudo-randomize!)
(native jazz.default-random-source)


;;;
;;;; Readtable
;;;


(native jazz.with-readtable)
(native jazz.scheme-readtable)
(native jazz.jazz-readtable)
(native jazz.with-jazz-readtable)
(native jazz.install-jazz-literals)


;;;
;;;; Repl
;;;


(native jazz.current-repl-context)
(native jazz.repl-context-level)
(native jazz.repl-context-depth)
(native jazz.repl-context-cont)
(native jazz.repl-context-initial-cont)
(native jazz.repl-context-prev-level)
(native jazz.repl-context-prev-depth)
(native jazz.with-repl-context)
(native jazz.inspect-repl-context)
(native jazz.repl)
(native jazz.eval-within-no-winding)
(native jazz.repl-result-history-add)
(native repl-result-history-ref)


;;;
;;;; Resource
;;;


(native jazz.resource-pathname)


;;;
;;;; Runtime
;;;


(native jazz.get-catalog)
(native jazz.get-catalog-entry)
(native jazz.locate-library-declaration)
(native jazz.get-object-slot)
(native jazz.set-object-slot)
(native jazz.dispatch)
(native jazz.find-dispatch)
(native jazz.call-into-abstract)


;;;
;;;; Serial
;;;


(native jazz.object->serial)
(native jazz.serial->object)

;; the -number versions are necessary to support the expansion of the # reader construct
(native object->serial-number)
(native serial-number->object)


;;;
;;;; Shell
;;;


(native shell-command)


;;;
;;;; Slot
;;;


(native jazz.slot? <object:bool>)
(native jazz.slot-value)
(native jazz.set-slot-value)


;;;
;;;; Socket
;;;


(native jazz.socket-info-address)
(native jazz.socket-info-port-number)


;;;
;;;; Stack
;;;


(native jazz.get-procedure-name)
(native jazz.get-continuation-stack)
(native jazz.get-continuation-name)
(native jazz.get-continuation-dynamic-environment)
(native jazz.get-continuation-lexical-environment)
(native jazz.get-continuation-location)


;;;
;;;; Statprof
;;;


(native jazz.active-profile)
(native jazz.profile-total)
(native jazz.profile-unknown)
(native jazz.profile-calls)
(native jazz.reset-profile)
(native jazz.start-profile)
(native jazz.stop-profile)
(native jazz.profile-running?)


;;;
;;;; String
;;;


(native jazz.join-strings)


;;;
;;;; Symbol
;;;


(native jazz.generate-symbol)
(native jazz.with-uniqueness)


;;;
;;;; Syntax
;;;


(native jazz.source?)
(native jazz.source-code)
(native jazz.source-locat)
(native jazz.desourcify)
(native jazz.desourcify-list)
(native jazz.sourcify)
(native jazz.sourcify-if)
(native jazz.present-source)
(native jazz.locat-container)
(native jazz.locat-position)
(native jazz.locat->file/line/col)
(native jazz.container->path)
(native jazz.position->filepos)
(native jazz.filepos-line)
(native jazz.filepos-col)


;;;
;;;; System
;;;


(native jazz.switch?)
(native jazz.switch-name)
(native jazz.command-argument)
(native jazz.open-process)
(native jazz.process-status)
(native jazz.exit)


;;;
;;;; Table
;;;


(native table?)
(native make-table)
(native table-ref)
(native table-set!)
(native table->list)
(native list->table)
(native jazz.table-clear)
(native jazz.table-length)
(native jazz.iterate-table)
(native jazz.map-table)
(native jazz.table-entries)
(native jazz.eq-hash)
(native jazz.eqv-hash)
(native jazz.equal-hash)


;;;
;;;; Terminal
;;;


(native jazz.set-terminal-title)
(native jazz.bring-terminal-to-front)
(native jazz.clear-terminal)


;;;
;;;; Thread
;;;


(native jazz.current-thread)
(native jazz.thread?)
(native jazz.make-thread)
(native jazz.make-root-thread)
(native jazz.thread-name)
(native jazz.thread-specific)
(native jazz.thread-specific-set!)
(native jazz.thread-base-priority)
(native jazz.thread-base-priority-set!)
(native jazz.thread-priority-boost)
(native jazz.thread-priority-boost-set!)
(native jazz.thread-start!)
(native jazz.thread-yield!)
(native jazz.thread-sleep!)
(native jazz.thread-terminate!)
(native jazz.thread-join!)
(native jazz.thread-send)
(native jazz.thread-receive)
(native jazz.thread-interrupt!)
(native jazz.thread-thread-group)
(native jazz.thread-group->thread-group-list)
(native jazz.thread-group->thread-group-vector)
(native jazz.thread-group->thread-list)
(native jazz.thread-group->thread-vector)
(native jazz.thread-state)
(native jazz.thread-state-abnormally-terminated-reason)
(native jazz.thread-state-abnormally-terminated?)
(native jazz.thread-state-active-timeout)
(native jazz.thread-state-active-waiting-for)
(native jazz.thread-state-active?)
(native jazz.thread-state-initialized?)
(native jazz.thread-state-normally-terminated-result)
(native jazz.thread-state-normally-terminated?)
(native jazz.thread-state-uninitialized?)
(native jazz.pristine-thread-continuation)
(native jazz.mutex?)
(native jazz.make-mutex)
(native jazz.mutex-name)
(native jazz.mutex-specific)
(native jazz.mutex-specific-set!)
(native jazz.mutex-state)
(native jazz.mutex-lock!)
(native jazz.mutex-unlock!)
(native jazz.mutex-wait)
(native jazz.mutex-owner)
(native jazz.condition?)
(native jazz.make-condition)
(native jazz.condition-name)
(native jazz.condition-specific)
(native jazz.condition-specific-set!)
(native jazz.condition-signal!)
(native jazz.condition-broadcast!)


;;;
;;;; Time
;;;


(native jazz.current-systime)
(native jazz.systime?)
(native jazz.systime->seconds)
(native jazz.seconds->systime)
(native jazz.process-times)
(native jazz.cpu-time)
(native jazz.real-time)


;;;
;;;; Unspecified
;;;


(native jazz.unspecified)
(native jazz.unspecified?)
(native jazz.specified?)


;;;
;;;; Vector
;;;


(native jazz.vector-copy)
(native u8vector)
(native make-u8vector)
(native u8vector-length)
(native u8vector-ref)
(native u8vector-set!)
(native u8vector?)
(native u8vector->list)
(native list->u8vector)
(native u16vector)
(native make-u16vector)
(native u16vector-length)
(native u16vector-ref)
(native u16vector-set!)
(native u16vector?)
(native u32vector)
(native make-u32vector)
(native u32vector-length)
(native u32vector-ref)
(native u32vector-set!)
(native u32vector?)
(native f32vector)
(native make-f32vector)
(native f32vector-length)
(native f32vector-ref)
(native f32vector-set!)
(native f32vector?)
(native f64vector)
(native make-f64vector)
(native f64vector-length)
(native f64vector-ref)
(native f64vector-set!)
(native f64vector?)


;;;
;;;; Walker
;;;


(native jazz.new-walk-context)
(native jazz.register-literal-constructor)
(native jazz.specifier?)
(native jazz.binding-specifier)
(native jazz.parse-specifier)
(native jazz.requested-module-name)
(native jazz.requested-module-resource))
