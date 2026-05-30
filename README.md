- We are using `zig 0.16.0`
- format: `zig fmt src`
- build: `zig build`
  - It will generate `src/client_gen.zig`

---

- Testing: simulate server using `socat TCP-LISTEN:8080,reuseaddr SYSTEM:'cat'`
