#lang scribble/manual
@require[(for-label "../main.rkt")]

@title{Protocol Buffers: Portable Data Serialization}

@table-of-contents[]

@defmodule[(planet murphy/protobuf)]{

  Facilities to read and write @link["http://protobuf.googlecode.com/"]{Protocol Buffers}
  in binary format and to access some reflective information about the
  message definitions.
  
  The main module reexports all bindings from the interface module.

}

@include-section{license.scrbl}
