- We are using `zig 0.16.0`
- format: `zig fmt src`
- build: `zig build`
  - It will generate `src/datamodel_client_gen.zig` and `src/datamodel_server_gen.zig`

# Goal

The goal is to understand how XAPI is generating code from its datamodel. All objects
in XAPI are described in [ocaml/idl](https://github.com/xapi-project/xen-api/tree/master/ocaml/idl).
There is a generator written in OCaml that creates several files. Two of them are the client and the
server. It ensures consistency between the two. To really understand how it works, we try to
reimplement the logic in Zig.

# Dev

- Testing: simulate server using `socat TCP-LISTEN:8080,reuseaddr SYSTEM:'cat'`
- Now we have a server so we can start the server: `zig-out/bin/server` and then `zig-out/bin/client`
  - The client writes a string, the server reads it and responds ok, the client gets the answer
- next step -> Use generated files
