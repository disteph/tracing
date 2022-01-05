(** Command-line option for tracing will typically be of the form
      -trace "REGEXP" 3
    possibly immeditaely followed by
      -step
    where:
    REGEXP is a regular expression in Posix syntax, intended to capture a class of tracing keys,
    3 (for example) is the level of verbosity required for tracing the keys matching REGEXP,
    and -step, if presents, indicates that computation will wait for the user to hit RETURN
    before continuing.
 *)

(** We also provide a command-line option
      -filedump PREFIX
    for allowing the user to specify a path prefix where log files should be dumped. 
 *)

(** Low-level functions; can be ignored if using the Arg.specs below *)

(** Parses Foobar *)
val parse_regexp : string -> unit

(** Parses 3 *)
val parse_verbos : int -> unit

(** Parses -step *)
val parse_step   : unit -> unit

(** Parses -filedump *)
val parse_filedump   : string -> unit

(** Command-line specifications for tracing, using Arg *)
val trace_option    : Arg.spec
val step_option     : Arg.spec
val filedump_option : Arg.spec

(** Packaging all three options, using the syntax -trace / -step / -filedump *)
val options : (string * Arg.spec * string) list

(** compile () must be called just after parsing the command-line arguments *)
val compile : unit -> unit
  
(** Usage inside code *)

(** print fmt key i format_string ...
    prints on formatter fmt the string specified by format_string and the following arguments,
    provided that a command-line option of the format
      -trace "REGEXP" j
    was given by the user, where
    - the key matches REGEXP
    - and the level of verbosity j specified for that regular expression is >= i
    If the -step option was given by the user on the command line,
    computation pauses until the user hits RETURN.
    Note: If the key matches several regular expressions from the command line,
    the first one is used.
*)
val print  : Format.formatter -> string -> int -> ('a, Format.formatter, unit) format -> 'a

(** Function with the same type as print, but that does nothing (useful in an if-then-else) *)
val iprint : Format.formatter -> string -> int -> ('a, Format.formatter, unit) format -> 'a

(** Pauses computation, waiting for user to press RETURN;
    formatter is used to specify where the primpt should be *)
val pause : bool -> Format.formatter -> unit
  
(** Get the prefix for dumping files *)
val filedump : unit -> string option
