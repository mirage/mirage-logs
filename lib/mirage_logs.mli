(* Copyright (C) 2016, Thomas Leonard <thomas.leonard@unikernel.com>
   See the README file for details. *)

(** Mirage support for Logs library.

    To use this reporter, add a call to [run] at the start of your program:

{[
module Logs_reporter = Mirage_logs.Make(Clock)

let start () =
  Logs.(set_level (Some Info));
  Logs_reporter.(create () |> run) @@ fun () ->
  ...
]}

    If you'd like to log only important messages to the console by default, but
    still get detailed logs on error:

{[
module Logs_reporter = Mirage_logs.Make(Clock)

let console_threshold src =
  match Logs.Src.name src with
  | "noisy.library" -> Logs.Warning
  | _ -> Logs.Info

let start () =
  Logs.(set_level (Some Debug));
  Logs_reporter.(create ~ring_size:20 ~console_threshold () |> run) @@ fun () ->
  ...
]}
*)

type threshold_config = Logs.src -> Logs.level
(** A function that gives a threshold level for a given log source.
    Only messages at or above the returned level will be processed. *)

module Make (Clock : V1.CLOCK) : sig
  type t
  type ring

  val run : t -> (unit -> 'a Lwt.t) -> 'a Lwt.t
  (** [run t fn] installs the reporter [t] as the current [Logs] reporter and
      runs [fn ()].

      If [t] has a ring buffer and [fn] returns an error then the contents of
      the ring are dumped to provide extra context (and [Lwt.async_exception_hook]
      is also wrapped, to dump the ring for asynchronous exceptions). *)

  val create :
    ?ch:out_channel ->
    ?ring_size:int ->
    ?console_threshold:threshold_config ->
    unit -> t
  (** [create ~ch ()] is a Logs reporter that logs to [ch], with time-stamps
      provided by [Clock].

      If [ring_size] is provided then each message that reaches the reporter
      is also written to a ring buffer (with the given size).

      If tracing is enabled then each log message that reaches the reporter
      is also written to the trace buffer.

      If [console_threshold] is provided then any message at or above the
      returned threshold is also written to the console. If not provided,
      all messages reaching the reporter are printed.

      If logs are written faster than the backend can consume them,
      the whole unikernel will block until there is space (so log messages
      will not be lost, but unikernels generating a lot of log output
      may run slowly). *)

  val reporter : t -> Logs.reporter

  val dump_ring : t -> out_channel -> unit
  (** Write all entries in the ring buffer to [out_channel] and clear the ring.
      If [t] has no ring buffer, this function does nothing. *)
end
