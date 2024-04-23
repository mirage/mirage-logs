(* Copyright (C) 2016, Thomas Leonard <thomas.leonard@unikernel.com>
   See the README file for details. *)

let src = Logs.Src.create "test" ~doc:"mirage-logs test code"

module Log = (val Logs.src_log src : Logs.LOG)

let noisy_src = Logs.Src.create "noisy" ~doc:"mirage-logs test noisy library"

module Noisy = (val Logs.src_log noisy_src : Logs.LOG)

let src_tag = Logs.Tag.def "src" ~doc:"Source address" Format.pp_print_string
let port_tag = Logs.Tag.def "port" ~doc:"Port number" Format.pp_print_int
let tags ~src ~port = Logs.Tag.(empty |> add src_tag src |> add port_tag port)

let with_pipe fn =
  let r, w = Unix.pipe () in
  let r = Unix.in_channel_of_descr r in
  let w = Unix.out_channel_of_descr w in
  fn ~r ~w;
  close_out w;
  try
    Alcotest.fail (Printf.sprintf "Unexpected data in pipe: %S" (input_line r))
  with End_of_file -> close_in r

let get_line_without_timestamp r =
  let line = input_line r in
  String.concat " " (List.tl (String.split_on_char ' ' line))

let test_console r =
  Log.info (fun f -> f "Simple test");
  Alcotest.(check string)
    "Simple" "[INFO] [test] Simple test" (get_line_without_timestamp r);
  Log.warn (fun f ->
      f ~tags:(tags ~src:"localhost" ~port:7000) "Packet rejected");
  Alcotest.(check string)
    "Tags"
    "src=localhost port=7000 [WARNING] [test] Packet rejected"
    (get_line_without_timestamp r);
  Log.debug (fun f -> f "Not shown")

let test () =
  with_pipe @@ fun ~r ~w ->
  Lwt_main.run
    (Logs.(set_level (Some Info));
     let reporter =
       Mirage_logs.create ~ch:(Format.formatter_of_out_channel w) ()
     in
     Logs.set_reporter reporter;
     test_console r;
     Lwt.return ())

let () = Alcotest.run "mirage-logs" [ ("Tests", [ ("Logging", `Quick, test) ]) ]
