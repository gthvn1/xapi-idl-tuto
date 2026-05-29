# IDL Zig — Learning Project

Goal: understand how xen-api IDL works by building a minimal equivalent in Zig.
A client sends `Host.hello(hostname, version)` over a plain text socket.
The server dispatches it to a real implementation and returns a response.

## What we have so far

- `src/datamodel.zig` — the schema (pure data, no logic)
  - `Type` enum: `.string`, `.int`
  - `Param`, `Method`, `Object` structs
  - `host_object`: object "Host" with method "hello" (params: hostname string, version int, result string)
- `src/gen-api.zig` — the generator (walks datamodel, prints Zig code as text)
  - `typeToStr()`: converts `Type` enum to Zig type string (`[]const u8`, `i64`)
  - `gen_client()`: generates client functions (WIP — prints to stderr, not to file yet)
  - `gen_server()`: stub, not implemented yet

## Remaining steps

### Step 1 — add all_objects to datamodel.zig
In `datamodel.zig` add:
```zig
pub const all_objects = [_]Object{host_object};
```
Update `gen_client()` in `gen-api.zig` to loop over `datamodel.all_objects`
instead of hardcoding `host_object`. Makes the generator truly generic.

### Step 2 — write generated/client.zig to a file
Right now `gen_client()` prints to stderr. Change it to write to
`generated/client.zig` using `std.fs.cwd().createFile(...)`.
Create the `generated/` directory first.
The output should look like:
```zig
const std = @import("std");
const rpc = @import("../src/rpc.zig");

pub fn hello(conn: std.net.Stream, hostname: []const u8, version: i64) ![]const u8 {
    try rpc.send(conn, "Host.hello");
    try rpc.send(conn, "hostname={s}", hostname);
    try rpc.send(conn, "version={d}", version);
    try rpc.send(conn, "");        // empty line = end of message
    return try rpc.read(conn);
}
```

### Step 3 — write src/rpc.zig (hand-written, shared utility)
Both generated client and server need send/read helpers.
```zig
// send a line over the connection (adds \n)
pub fn send(conn: std.net.Stream, line: []const u8) !void

// read one line from the connection (strips \n)
pub fn read(conn: std.net.Stream, buf: []u8) ![]u8
```
This file is NOT generated. It is shared by client and server.

### Step 4 — implement gen_server() to write generated/server.zig
The generated server uses comptime to receive the implementation (like xen-api's functor).
The output should look like:
```zig
const std = @import("std");
const rpc = @import("../src/rpc.zig");

pub fn makeDispatcher(comptime Impl: type) type {
    return struct {
        pub fn dispatch(conn: std.net.Stream) !void {
            var buf: [1024]u8 = undefined;
            const method = try rpc.read(conn, &buf);
            if (std.mem.eql(u8, method, "Host.hello")) {
                const hostname = try rpc.read(conn, &buf);  // read hostname=...
                const version  = try rpc.read(conn, &buf);  // read version=...
                _ = try rpc.read(conn, &buf);                // read empty line
                // parse values from "key=value" lines
                // call Impl.Host.hello(hostname_val, version_val)
                const result = try Impl.Host.hello(hostname_val, version_val);
                try rpc.send(conn, result);
            }
        }
    };
}
```
This mirrors `Server.Make(Actions)` in xen-api.

### Step 5 — write src/host_impl.zig (hand-written implementation)
This is the real logic. Like `xapi_host.ml` in xen-api.
```zig
pub const Host = struct {
    pub fn hello(hostname: []const u8, version: i64) ![]const u8 {
        // return something like "Hello from <hostname> version <version>"
        // need an allocator here — think about how to pass it
    }
};
```

### Step 6 — write src/server_main.zig (hand-written)
Listens on a TCP port, accepts connections, calls the generated dispatcher.
Like `api_server.ml` in xen-api.
```zig
const Impl = @import("host_impl.zig");
const generated_server = @import("../generated/server.zig");
const Server = generated_server.makeDispatcher(Impl);

// listen on a port, accept conn, call Server.dispatch(conn)
```

### Step 7 — write src/client_main.zig (hand-written)
Connects to the server, calls the generated client function, prints result.
Like the `xe` CLI in xen-api.
```zig
const client = @import("../generated/client.zig");

// connect to server
// call client.hello(conn, "myhost", 42)
// print result
```

### Step 8 — wire it up with build.zig
You need a `build.zig` that:
1. Builds `gen-api` executable
2. Runs `gen-api` to produce `generated/client.zig` and `generated/server.zig`
3. Builds `server` executable from server_main.zig + generated/server.zig
4. Builds `client` executable from client_main.zig + generated/client.zig

### Step 9 — run it
```sh
zig build
./zig-out/bin/server &
./zig-out/bin/client
# expected output: "Hello from myhost version 42"
```

## Key insight (why this matters for understanding xen-api)

| This project       | xen-api equivalent         |
|--------------------|---------------------------|
| datamodel.zig      | datamodel_vm.ml etc.      |
| gen-api.zig        | gen_api_main.ml           |
| generated/client.zig | client.ml               |
| generated/server.zig | server.ml               |
| src/rpc.zig        | xmlrpc_client lib         |
| host_impl.zig      | xapi_host.ml              |
| server_main.zig    | api_server.ml             |
| client_main.zig    | cli_operations.ml / xe    |
| makeDispatcher(Impl) | Server.Make(Actions)    |

## Wire protocol (plain text)
```
Client sends:
  Host.hello\n
  hostname=myhost\n
  version=42\n
  \n              <- empty line signals end of message

Server replies:
  Hello from myhost version 42\n
```
