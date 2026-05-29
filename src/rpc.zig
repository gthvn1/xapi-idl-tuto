const std = @import("std");

pub fn send(conn: std.net.Stream, comptime fmt: []const u8, args: anytype) !void {
    _ = conn;
    _ = fmt;
    _ = args;
}

pub fn sendEnd(conn: std.net.Stream) !void {
    send(conn, "", .{});
}

pub fn receive(conn: std.net.Stream, buf: []u8) !usize {
    _ = conn;
    _ = buf;
    return 0;
}
