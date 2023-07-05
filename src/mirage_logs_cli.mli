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

(** {2 Log Thresholds} *)

open Cmdliner

type threshold = [ `All | `Src of string ] * Logs.level option
(** [threshold] type is used to control logging level and source.

    The first element of the pair is a source pattern. It can be either [`All]
    (representing all the existing and new sources) or [`Src src], representing
    the specific logging source named [src].

    The second element is the logging level. A log level of [None] indicates
    that logging is disabled for this source. If the level is [Some l] then any
    message whose level is smaller or equal to [l] is reported. *)

val env : Cmd.Env.info
(** [env] is the environment variable [LOGGING_LEVELS]. *)

val levels : ?env:Cmd.Env.info -> ?docs:string -> unit -> threshold list Term.t
(** [levels ~docs ~env ()] is a term that processes command-line arguments and
    environment variables to produce a list of thresholds for logging.

    [docs] is the title of the man page section in which the argument will be
    listed. [env] defines the name of an environment variable which is looked up
    for defining the argument if it is absent from the command line (default is
    {!logging_levels_env}). See the description of [docs] and [env] in the
    {{:https://erratique.ch/software/cmdliner/doc/Cmdliner/Arg/index.html#val-info}
      Cmdliner manual} for more details.

    The option work as follow:

    - The parameters is split into groups on ','
    - each group is turned into a threshold but splitting it on ':'
    - the expected logging levels are ["app"], ["error"], ["warning"], ["info"]
      and ["debug"]. The are translated into the equivalent [Some d] value.
    - To disable a source, use ["quiet"] or ["-"] to get a [None] value.

    For instance, [--logging-level '*:info,foo:debug,bar:-'] is evaluated as
    follows.

    - ["*:info"] is [(`All, Some Logs.Info)];
    - ["foo:debug"] is [(`Src "foo", Some Logs.debug)]; and
    - ["bar:-"] is [(`Src "bar", None)]

    This means: use the default logging threshold [Logs.Info] for all sources,
    apart from the source ["foo"] that should use [Logs.Debug] and the source
    ["bar"] that should be disabled. *)

val set_levels : default:Logs.level option -> threshold list -> unit
(** [set_levels ~default l] configures the logging system to use all the log
    sources that appear in the threshold list [l]. If a log source is not
    present in [l], then the default logging level is applied.

    If the default level is [Some l] then any message sent to a source not in
    [l] and whose level is smaller or equal to [l] is reported. If the default
    level is [None] no message other than the ones in [l] are ever reported. *)

val setup : unit Term.t
(** [setup] is a term that the init the logging system using [set_levels]. It
    parses the command-line arguments with [levels] and {!Logs_cli.setup_log}.*)
