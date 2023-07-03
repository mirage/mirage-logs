(* Copyright (C) 2016, Thomas Leonard <thomas.leonard@unikernel.com>
   See the README file for details. *)

(** MirageOS support for the Logs library.

    This is the default log reporter used by MirageOS. *)

module Make (Clock : Mirage_clock.PCLOCK) : sig
  val create : ?ch:Format.formatter -> unit -> Logs.reporter
  (** [create ~ch ()] is a Logs reporter that logs to [ch] (defaults to
      [Format.err_formatter]), with time-stamps provided by [Clock].

      If logs are written faster than the backend can consume them, the whole
      unikernel will block until there is space (so log messages will not be
      lost, but unikernels generating a lot of log output may run slowly). *)
end
