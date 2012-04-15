#lang scribble/manual
@require[(for-label "../generator.rkt")]

@title{@tt{protoc-gen-racket}: Generate Racket Code for Protocol Buffers}

@table-of-contents[]

@defmodule[(planet murphy/protobuf/generator)]{

  Provides functions to convert Protocol Buffer descriptors into Racket
  code. The module also provides a plug-in executable for ProtoC to
  facilitate the conversion between Protocol Buffer description files
  and Racket modules.
  
  To use the @tt{protoc-gen-racket} code converter, make sure the
  executable is in your path as well as the @tt{protoc} compiler, then
  simply invoke @tt{protoc} with the @tt{--racket_out} option.

}

@include-section{license.scrbl}
