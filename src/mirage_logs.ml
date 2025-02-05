(* Copyright (C) 2016, Thomas Leonard <thomas.leonard@unikernel.com>
   See the README file for details. *)

let pp_tags f tags =
  let pp tag () =
    let (Logs.Tag.V (def, value)) = tag in
    Format.fprintf f " %s=%a" (Logs.Tag.name def) (Logs.Tag.printer def) value;
    ()
  in
  Logs.Tag.fold pp tags ()

let create ?(ch = Format.err_formatter) () =
  let report src level ~over k msgf =
    let tz_offset_s = Mirage_ptime.current_tz_offset_s () in
    let posix_time = Mirage_ptime.now () in
    let src = Logs.Src.name src in
    msgf @@ fun ?header ?tags fmt ->
    let k _ =
      over ();
      k ()
    in
    Format.kfprintf k ch
      ("%a:%a %a [%s] @[" ^^ fmt ^^ "@]@.")
      (Ptime.pp_rfc3339 ?tz_offset_s ())
      posix_time
      Fmt.(option ~none:(any "") pp_tags)
      tags Logs_fmt.pp_header (level, header) src
  in
  { Logs.report }
