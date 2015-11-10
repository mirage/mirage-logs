let string_of_level =
  let open Logs in function
  | Error -> "ERROR"
  | Warning -> "WARN"
  | Info -> "INFO"
  | Debug -> "DEBUG"
  | App -> "LOG"

let month = function
  | 0 -> "Jan"
  | 1 -> "Feb"
  | 2 -> "Mar"
  | 3 -> "Apr"
  | 4 -> "May"
  | 5 -> "Jun"
  | 6 -> "Jul"
  | 7 -> "Aug"
  | 8 -> "Sep"
  | 9 -> "Oct"
  | 10 -> "Nov"
  | 11 -> "Dec"
  | _ -> "XXX"

module Console(C : V1_LWT.CONSOLE)(Clock : V1.CLOCK) = struct
  let ppf, flush =
    let b = Buffer.create 255 in
    let flush () = let s = Buffer.contents b in Buffer.clear b; s in
    Format.formatter_of_buffer b, flush

  let connect c =
    let report src level k fmt msgf =
      let k _ =
        C.log c (flush ());
        k () in
      msgf (fun ?header ?tags ->
        ignore tags;
        let tm = Clock.(gmtime (time ())) in
        let header =
          match header with
          | Some h -> h
          | None -> string_of_level level in
        let open Clock in
        Format.kfprintf k ppf ("%s %d %02d:%02d:%02d %s %s: @[" ^^ fmt ^^ "@]@.")
          (month tm.tm_mon) tm.tm_mday tm.tm_hour tm.tm_min tm.tm_sec
          header (Logs.Src.name src)
      ) in
    Logs.set_reporter { Logs.report }
end
