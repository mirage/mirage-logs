## v2.1.0 (2023-10-17)

- use Logs.pp_level instead of a custom string_of_level (#23 @hannesm)
- avoid global buffer, reuse Logs_fmt.pp_header for color (#25 @hannesm,
  fixes #24)

## v2.0.0 (2023-07-06)

- Bump to Dune3 (#19, @samoht)
- Remove `create` optional `ring_size` `console_threshold` parameters
  (#21, @hannesm)
- use Ptime.pp_rfc3339 for nicer output (esp. if time zone offset is
  None) (#21, @hannesm)
- Remove custom types (`type t` / `set_reporter` / `unset_reporter` /
  `reporter`) (#21, @hannesm)
- Add mirage-logs.cli to define Cmdliner terms (#20, @samoht)

## v1.3.0 (2023-03-12)

- Remove the mirage-profile dependency (#18 @hannesm)

## v1.2.0 (2019-11-01)

- Adapt to mirage-clock 3.0.0 interface changes (#17 @hannesm)

## v1.1.0 (2019-07-12)

- Emit log with a header value if present (#14 @talex5)

## v1.0.0 (2019-04-14)

- Port to dune (#13 @TheLortex @avsm)
- Upgrade opam metadata to 2.0 format (#13 @TheLortex @avsm)
- Test on OCaml 4.07 so that 4.04-4.07 is the supported matrix (@avsm).

## 0.3.0 (2017-01-19)

- Build against MirageOS 3, and drop support for earlier versions.
- Port to topkg.

## 0.2.0 (2016-04-28)

- Add a `set_reporter` function (#1, @samoht)

## 0.1 (2016-02-18)

- Initial release (@talex5)
