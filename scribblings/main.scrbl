#lang scribble/manual
@require[(for-label "../main.rkt")]

@title{Protocol Buffers: Portable Data Serialization}

@table-of-contents[]

@defmodule[(planet murphy/protobuf)]{

  Facilities to read and write @link["http://protobuf.googlecode.com/"]{Protocol Buffers}
  in binary format. The basic message type is re-exported from the
  reflection module.
  
}

@include-section{license.scrbl}
