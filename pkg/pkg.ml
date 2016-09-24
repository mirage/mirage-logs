#!/usr/bin/env ocaml
#use "topfind"
#require "topkg"
open Topkg

let () =
  Pkg.describe "mirage-logs" @@ fun c ->
  Ok [ Pkg.mllib "src/mirage-logs.mllib";
       Pkg.test "test/test"; ]
