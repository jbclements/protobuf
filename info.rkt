#lang info
;; This file is part of Protocol Buffers for Racket.
;; Copyright (c) 2012 by Thomas Chust <chust@web.de>
;;
;; Protocol Buffers for Racket is free software: you can redistribute
;; it and/or modify it under the terms of the GNU Lesser General
;; Public License as published by the Free Software Foundation, either
;; version 3 of the License, or (at your option) any later version.
;;
;; Protocol Buffers for Racket is distributed in the hope that it will
;; be useful, but WITHOUT ANY WARRANTY; without even the implied
;; warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR
;; PURPOSE. See the GNU Lesser General Public License for more
;; details.
;;
;; You should have received a copy of the GNU Lesser General Public
;; License along with Protocol Buffers for Racket. If not, see
;; <http://www.gnu.org/licenses/>.

(define version "1.1")
(define deps '())
(define build-deps '())
(define collection "protobuf")

(define scribblings
  '(("scribblings/main.scrbl" (multi-page) (interop))
    ("scribblings/generator.scrbl" (multi-page) (tool))))

(define racket-launcher-names
  '("protoc-gen-racket"))
(define racket-launcher-flags
  '(("-l" "protobuf/generator" "-m-")))


#;((define name
  "Protocol Buffers")
(define blurb
  '("Protocol Buffer serialization library and ProtoC code generator plugin"))
(define categories
  '(io net))

(define release-notes
  '((dl
     (dt "1.1") (dd "Destructive message merging, serialized field sorting")
     (dt "1.0") (dd "Initial release"))))

(define primary-file
  "main.rkt")



)
