(module gambit.ext jazz


(require gambit.walk)


(native new-register)
(native register-count)
(native register-ref)
(native register-set!)

(native make-domain)
(native domain-copies)
(native domain-bytes-copied)
(native domain-bytes-copied-set!)
(native copy-to)
(native update-reachable!)

(native MOVABLE0)
(native MOVABLE1)
(native MOVABLE2)
(native STILL)
(native PERM)

(native gc-hash-table?)
(native mem-allocated?)
(native mem-allocated-kind)
(native mem-allocated-size))