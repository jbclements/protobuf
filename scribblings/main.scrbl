#lang scribble/manual
@require[(for-label "../main.rkt")]

@title{Protocol Buffers: Portable Data Serialization}

@table-of-contents[]

@section{Message I/O}

@defmodule[(planet murphy/protobuf)]{

  Facilities to read and write @link["http://protobuf.googlecode.com/"]{Protocol Buffers}
  in binary format. The basic message type is re-exported from the
  reflection module.
  
}

@defproc[(deserialize [type struct-type?] [in input-port? (current-input-port)]) any/c]{

  Read an instance of @racket[type] encoded in protocol buffer format
  from the port @racket[in]. @racket[type] must represent a protocol
  buffer message type.

}

@defproc[(serialize [v struct?] [out output-port? (current-output-port)]) void?]{

  Write @racket[v] to the port @racket[out], encoding it in protocol
  buffer format. @racket[v] must be an instance of a protocol buffer
  message type.

}

@include-section{reflection.scrbl}
@include-section{syntax.scrbl}
@include-section{encoding.scrbl}
@include-section{license.scrbl}
