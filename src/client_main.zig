const std = @import("std");
const client = @import("generated/client.zig");

pub fn main(init: std.process.Init) !void {
    _ = init;
    std.debug.print("Hello from client\n", .{});
}
