#lang racket/base
(require
 srfi/26
 racket/contract
 racket/match
 racket/port
 racket/promise
 racket/set
 syntax/readerr
 "encoding.rkt")

(struct type-info
  (name)
  #:transparent)

(struct primitive-info type-info
  (type reader writer))

(struct enum-info type-info
  (integer->enum enum->integer))

(define-values (prop:protobuf protobuf? protobuf-ref)
  (make-struct-type-property 'protobuf 'can-impersonate))

(struct message-info type-info
  (constructor
   [fields #:mutable] [required #:mutable]))

(struct field-info
  (type
   repeated? packed?
   accessor mutator))

(provide
 (struct-out type-info)
 (struct-out primitive-info)
 (struct-out enum-info)
 prop:protobuf protobuf? protobuf-ref
 (struct-out message-info)
 (struct-out field-info))

(struct message
  (extensions
   [unknown #:auto])
  #:transparent
  #:mutable
  #:auto-value #"")

(define ((appender accessor mutator) msg v)
  (mutator msg (append (accessor msg null) (if (list? v) v (list v)))))

(define (deserialize type [port (current-input-port)])
  (let ([info (force (protobuf-ref type))])
    (letrec ([msg ((message-info-constructor info))]
             [fields (message-info-fields info)]
             [required (message-info-required info)]
             [unknown (open-output-bytes)])
      (let loop ()
        (let*-values ([(line col pos) (port-next-location port)]
                      [(tag type) (read-tag/type port)])
          (unless (or (eof-object? tag) (eof-object? type))
            (set! required (set-remove required tag))
            (cond
              [(hash-ref fields tag #f)
               => (match-lambda
                    [(field-info (primitive-info _ ptype read _) repeated? _
                                 accessor mutator)
                     ((if repeated? (appender accessor mutator) mutator)
                      msg
                      (cond
                        [(eq? type ptype)
                         (read port)]
                        [(and repeated? (eq? type 'sized) (not (eq? ptype 'sized)))
                         (read-sized (cut port->list read <>) port)]
                        [else
                         (let-values ([(line1 col1 pos1) (port-next-location port)])
                           (raise-read-error
                            (format "~s: wire type does not match declared type: ~e"
                                    'deserialize type)
                            (object-name port)
                            line col pos (and pos pos1 (- pos1 pos))))]))]
                    [(field-info (enum-info _ integer->enum _) repeated? _
                                 accessor mutator)
                     ((if repeated? (appender accessor mutator) mutator)
                      msg
                      (cond
                        [(eq? type 'int*)
                         (integer->enum (read-int* port))]
                        [(and repeated? (eq? type 'sized))
                         (map integer->enum
                              (read-sized (cut port->list read-int* <>) port))]
                        [else
                         (let-values ([(line1 col1 pos1) (port-next-location port)])
                           (raise-read-error
                            (format "~s: wire type does not match declared type: ~e"
                                    'deserialize type)
                            (object-name port)
                            line col pos (and pos pos1 (- pos1 pos))))]))]
                    [(field-info (? struct-type? stype) repeated? _
                                 accessor mutator)
                     ((if repeated? (appender accessor mutator) mutator)
                      msg
                      (cond
                        [(eq? type 'sized)
                         (read-sized (cut deserialize stype <>) port)]
                        [else
                         (let-values ([(line1 col1 pos1) (port-next-location port)])
                           (raise-read-error
                            (format "~s: wire type does not match declared type: ~e"
                                    'deserialize type)
                            (object-name port)
                            line col pos (and pos pos1 (- pos1 pos))))]))])]
              [else
               (write-tag/type tag type unknown)
               (case type
                 [(int*)
                  (write-uint* (read-uint* port) unknown)]
                 [(64bit)
                  (copy-port (make-limited-input-port port 8 #f) unknown)]
                 [(32bit)
                  (copy-port (make-limited-input-port port 4 #f) unknown)]
                 [(sized)
                  (let ([size (read-uint* port)])
                    (write-uint* size unknown)
                    (copy-port (make-limited-input-port port size #f) unknown))])])
            (loop))))
      (set-message-unknown! msg (get-output-bytes unknown))
      (unless (set-empty? required)
        (error 'deserialize "missing required fields: ~e" required))
      msg)))

(define (serialize msg [port (current-output-port)])
  (let ([info (force (protobuf-ref msg))])
    (let ([fields (message-info-fields info)]
          [required (message-info-required info)])
      (for ([(tag field) (in-hash fields)]
            #:when #t
            [vs (in-value ((field-info-accessor field) msg))]
            #:when (not (void? vs))
            [repeated? (in-value (field-info-repeated? field))]
            [packed? (in-value (field-info-packed? field))]
            #:when #t
            [v ((if (and repeated? (not packed?)) in-list in-value) vs)])
        (set! required (set-remove required tag))
        (match (field-info-type field)
          [(primitive-info _ ptype _ write)
           (cond
             [(and repeated? packed?)
              (when (eq? ptype 'sized)
                (error 'serialize "cannot apply packed encoding to sized type"))
              (write-tag/type tag 'sized port)
              (write-sized
               (cut for-each write-int* <> <>) vs port)]
             [else
              (write-tag/type tag ptype port)
              (write v port)])]
          [(enum-info _ _ enum->integer)
           (cond
             [(and repeated? packed?)
              (write-tag/type tag 'sized port)
              (write-sized
               (cut for-each write-int* <> <>) (map enum->integer vs) port)]
             [else
              (write-tag/type tag 'int* port)
              (write-int* (enum->integer v) port)])]
          [_
           (write-tag/type tag 'sized port)
           (write-sized serialize v port)]))
      (write-bytes (message-unknown msg) port)
      (unless (set-empty? required)
        (error 'serialize "missing required fields: ~e" required)))))

(provide
 (struct-out message))
(provide/contract
 [deserialize
  (->* (struct-type?)
       (input-port?)
       any)]
 [serialize
  (->* (struct?)
       (output-port?)
       any)])
