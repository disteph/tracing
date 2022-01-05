open Arg

type t = {
    regexp : string Tyre.t;
    verb   : int ref;
    step   : bool ref
  }

let routes = ref []

let make s = {
    regexp = s |> Re.Posix.re |> Tyre.regex;
    verb   = ref 0;
    step   = ref false
  }

let current = ref (make "")

let parse_regexp s = current := make s
let parse_verbos i =
  (!current).verb := i;
  routes := !current::!routes
let parse_step () = (!current).step := true

(* type routes = (int*bool) Tyre.re *)
let re = ref (Tyre.route [])

let compile() =
  re :=
    !routes
    |> List.rev_map(fun x -> Tyre.(x.regexp --> (fun _ -> !(x.verb), !(x.step))))
    |> Tyre.route

let filedump : string option ref = ref None

let parse_filedump s = filedump := Some s
let filedump () = !filedump
  
let trace_option = Tuple [
                       String parse_regexp;
                       Int parse_verbos
                     ]
let step_option = Unit parse_step
let filedump_option = String parse_filedump
  
let options = [
    ("-trace", trace_option , "trace pattern with verbosity level (default is: don't trace anything)");
    ("-step",  step_option, "step through last trace (default is false)");
    ("-filedump", filedump_option, "Dump file in case of error: if so, give path prefix (default is no file dump)");
  ];;

let pause step fmt =
  if step then let _ =  Format.fprintf fmt "@]%!@[<v>"; read_line () in () else ()

let print fmt trace i fs =
  match !routes with
  | [] -> Format.ifprintf fmt fs
  | _ ->
     match Tyre.exec (!re) trace with
     | Ok(verbosity, step) when verbosity >= i ->
        Format.(kfprintf (pause step) fmt) fs
     | _ -> Format.ifprintf fmt fs

let iprint fmt _trace _i fs = Format.ifprintf fmt fs

