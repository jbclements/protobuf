#lang racket/base
;; Generated using protoc-gen-racket v1.0.0
(require (planet murphy/protobuf:1/syntax)
         "../../google/protobuf/descriptor.rkt")

(define-message-extension
 field-options
 (optional primitive:uint32 max-size 76884 10))

(provide (all-defined-out))