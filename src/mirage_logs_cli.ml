(*
 * Copyright (c) 2014 David Sheets <sheets@alum.mit.edu>
 * Copyright (c) 2023 Thomas Gazagnaire <thomas@gazagnaire.org>
 *
 * Permission to use, copy, modify, and distribute this software for any
 * purpose with or without fee is hereby granted, provided that the above
 * copyright notice and this permission notice appear in all copies.
 *
 * THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES
 * WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF
 * MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR
 * ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
 * WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN
 * ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF
 * OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.
 *)

open Cmdliner

type threshold = [ `All | `Src of string ] * Logs.level option

let err str = Error (`Msg ("Can't parse log threshold: " ^ str))

module Conv = struct
  let threshold =
    let parser str =
      let source = function "*" -> `All | s -> `Src s in
      let level src s =
        match Logs.level_of_string s with
        | Ok s -> Ok (src, s)
        | Error _ as e -> e
      in
      match String.split_on_char ':' str with
      | [ src; "-" ] -> Ok (source src, None)
      | [ src; lvl ] -> level (source src) lvl
      | _ -> err str
    in
    let serialize ppf = function
      | `All, l -> Format.pp_print_string ppf (Logs.level_to_string l)
      | `Src s, l -> Format.fprintf ppf "%s:%s" s (Logs.level_to_string l)
    in
    Arg.conv (parser, serialize)
end

let set_levels ~default l =
  let srcs = Logs.Src.list () in
  let default =
    try snd @@ List.find (function `All, _ -> true | _ -> false) l
    with Not_found -> default
  in
  Logs.set_level default;
  List.iter
    (function
      | `All, _ -> ()
      | `Src src, level -> (
          try
            let s = List.find (fun s -> Logs.Src.name s = src) srcs in
            Logs.Src.set_level s level
          with Not_found ->
            Format.printf "WARNING: %s is not a valid log source.\n%!" src))
    l

let env = Cmd.Env.info "LOGGING_LEVELS"

let levels ?(env = env) ?docs () =
  let logs = Arg.list Conv.threshold in
  let doc =
    "Be more or less verbose. $(docv) must be of the form \
     $(b,'*:info,foo:debug') means that that the log threshold is set to \
     $(b,'info') for every log sources but the $(b,'foo') which is set to \
     $(b,'debug'). Use $(b,'quiet') or $(b,'-') to disable a souce. And \
     $(b,'*') to consider all sources. For instance $(b, '*-,foo:debug') \
     disable all sources but $(b,foo) which is set to $(b, debug).'"
  in
  let doc = Arg.info ~env ~docv:"LEVEL" ~doc ?docs [ "l"; "logging-levels" ] in
  Arg.(value & opt logs [] doc)

let docs = "DISPLAY OPTIONS"

let setup =
  Term.(
    const (fun default levels -> set_levels ~default levels)
    $ Logs_cli.level ~docs () $ levels ~docs ())
