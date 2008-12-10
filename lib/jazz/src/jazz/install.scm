;;;==============
;;;  JazzScheme
;;;==============
;;;
;;;; Jazz Install
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


(module jazz.install


(define jazz.install-jazz-literals
  (let ((readtable #f))
    (lambda ()
      (define (register-literal name module constructor-name)
        ((jazz.global-value 'jazz.register-literal-constructor)
         name
         (let ((constructor #f))
           (lambda rest
             (if (not constructor)
                 (set! constructor (jazz.module-autoload module constructor-name)))
             (apply constructor rest)))))
      
      (define (install-literals)
        (jazz.load-module 'core.library)
        (jazz.load-module 'jazz.dialect)
        
        (register-literal 'Point                     'jazz.literals 'construct-point)
        (register-literal 'Dimension                 'jazz.literals 'construct-dimension)
        (register-literal 'Cell                      'jazz.literals 'construct-cell)
        (register-literal 'Rect                      'jazz.literals 'construct-rect)
        (register-literal 'Range                     'jazz.literals 'construct-range)
        (register-literal 'Exception-Detail          'jazz.literals 'construct-exception-detail)
        (register-literal 'Walk-Location             'jazz.literals 'construct-walk-location)
        (register-literal 'Box                       'jazz.literals 'construct-box)
        (register-literal 'Action                    'jazz.literals 'construct-action)
        (register-literal 'Shortcut                  'jazz.literals 'construct-shortcut)
        (register-literal 'Locales                   'jazz.literals 'construct-locales)
        (register-literal 'Color                     'jazz.literals 'construct-color)
        (register-literal 'Font                      'jazz.literals 'construct-font)
        (register-literal 'Pen                       'jazz.literals 'construct-pen)
        (register-literal 'File                      'jazz.literals 'construct-file)
        (register-literal 'Directory                 'jazz.literals 'construct-directory)
        (register-literal 'Directory-Group           'jazz.literals 'construct-directory-group)
        (register-literal 'Host                      'jazz.literals 'construct-host)
        (register-literal 'Datatype                  'jazz.literals 'construct-datatype)
        (register-literal 'Systype                   'jazz.literals 'construct-systype)
        (register-literal 'IOR                       'jazz.literals 'construct-ior)
        (register-literal 'Format                    'jazz.literals 'construct-format)
        (register-literal 'Text-Style                'jazz.literals 'construct-text-style)
        (register-literal 'Hyperlink-Style           'jazz.literals 'construct-hyperlink-style)
        (register-literal 'Text                      'jazz.literals 'construct-text)
        (register-literal 'Formatted-Text            'jazz.literals 'construct-formatted-text)
        (register-literal 'Bitmap-Resource           'jazz.literals 'construct-bitmap-resource)
        (register-literal 'Icon-Resource             'jazz.literals 'construct-icon-resource)
        (register-literal 'Cursor-Resource           'jazz.literals 'construct-cursor-resource)
        (register-literal 'Event                     'jazz.literals 'construct-event)
        (register-literal 'Event-Handler             'jazz.literals 'construct-event-handler)
        (register-literal 'Selection-Handler         'jazz.literals 'construct-selection-handler)
        (register-literal 'Version                   'jazz.literals 'construct-version)
        (register-literal 'C-File-Entry              'jazz.literals 'construct-c-file-entry)
        (register-literal 'C-Category-Entry          'jazz.literals 'construct-c-category-entry)
        (register-literal 'C-Define-Entry            'jazz.literals 'construct-c-define-entry)
        (register-literal 'C-Include-Entry           'jazz.literals 'construct-c-include-entry)
        (register-literal 'C-Export-Entry            'jazz.literals 'construct-c-export-entry)
        (register-literal 'CSS-File-Entry            'jazz.literals 'construct-css-file-entry)
        (register-literal 'CSS-Entry                 'jazz.literals 'construct-css-entry)
        (register-literal 'Java-File-Entry           'jazz.literals 'construct-java-file-entry)
        (register-literal 'JavaScript-File-Entry     'jazz.literals 'construct-javascript-file-entry)
        (register-literal 'JavaScript-Variable-Entry 'jazz.literals 'construct-javascript-variable-entry)
        (register-literal 'JavaScript-Function-Entry 'jazz.literals 'construct-javascript-function-entry)
        (register-literal 'Lua-File-Entry            'jazz.literals 'construct-lua-file-entry)
        (register-literal 'Lua-Function-Entry        'jazz.literals 'construct-lua-function-entry)
        (register-literal 'Properties-File-Entry     'jazz.literals 'construct-properties-file-entry)
        (register-literal 'Properties-Entry          'jazz.literals 'construct-properties-entry)
        (register-literal 'Python-File-Entry         'jazz.literals 'construct-python-file-entry)
        (register-literal 'Python-Class-Entry        'jazz.literals 'construct-python-class-entry)
        (register-literal 'Python-Def-Entry          'jazz.literals 'construct-python-def-entry)
        (register-literal 'Lisp-File-Entry           'jazz.literals 'construct-lisp-file-entry)
        (register-literal 'Lisp-Entry                'jazz.literals 'construct-lisp-entry)
        
        (jazz.global-value 'jazz.jazz-readtable))
        
      (if (not readtable)
          (set! readtable (install-literals)))
      
      readtable)))


(jazz.register-reader-extension "jazz" jazz.install-jazz-literals))
