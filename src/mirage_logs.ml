(* Copyright (C) 2016, Thomas Leonard <thomas.leonard@unikernel.com>
   See the README file for details. *)

let buf = Buffer.create 200
let log_fmt = Format.formatter_of_buffer buf

let string_of_level =
  let open! Logs in
  function
  | App -> "APP"
  | Error -> "ERR"
  | Warning -> "WRN"
  | Info -> "INF"
  | Debug -> "DBG"

module Make (C : Mirage_clock.PCLOCK) = struct
  let pp_tags f tags =
    let pp tag () =
      let (Logs.Tag.V (def, value)) = tag in
      Format.fprintf f " %s=%a" (Logs.Tag.name def) (Logs.Tag.printer def) value;
      ()
    in
    Logs.Tag.fold pp tags ()

  let create ?(ch = Format.err_formatter) () =
    let report src level ~over k msgf =
      let tz_offset_s = C.current_tz_offset_s () in
      let posix_time = Ptime.v @@ C.now_d_ps () in
      let lvl = string_of_level level in
      msgf @@ fun ?header ?(tags = Logs.Tag.empty) fmt ->
      let k _ =
        if not (Logs.Tag.is_empty tags) then
          Format.fprintf log_fmt ":%a" pp_tags tags;
        Format.pp_print_flush log_fmt ();
        let msg = Buffer.contents buf in
        Buffer.clear buf;
        Format.fprintf ch "%a: %s\n%!" (Ptime.pp_rfc3339 ?tz_offset_s ()) posix_time msg;
        over ();
        k ()
      in
      let src = Logs.Src.name src in
      match header with
      | None -> Format.kfprintf k log_fmt ("%s [%s] " ^^ fmt) lvl src
      | Some h -> Format.kfprintf k log_fmt ("%s [%s:%s] " ^^ fmt) lvl src h
    in
    { Logs.report }
end
