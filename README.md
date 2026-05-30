- We are using `zig 0.16.0`
- format: `zig fmt src`
- build: `zig build`
  - It will generate `src/client_gen.zig` and `src/server_gen.zig`

---

- Testing: simulate server using `socat TCP-LISTEN:8080,reuseaddr SYSTEM:'cat'`
- Now we have a server so we can start the server: `zig-out/bin/server` and then `zig-out/bin/client`
  - The client write a string, the server read it and responds ok, the client get the answer
- next step -> Use generated file
