const std = @import("std");
const net = std.Io.net;

pub fn send(io: std.Io, conn: net.Stream, comptime fmt: []const u8, args: anytype) !void {
    var buffer: [1024]u8 = undefined;
    var sw: std.Io.net.Stream.Writer = conn.writer(io, &buffer);
    const w: *std.Io.Writer = &sw.interface;
    try w.print(fmt, args);
    try w.writeByte('\n');
    try w.flush();
}

pub fn sendEnd(io: std.Io, conn: net.Stream) !void {
    try send(io, conn, "", .{});
}

pub fn receive(io: std.Io, conn: net.Stream, buf: []u8) !usize {
    var buffer: [1024]u8 = undefined;
    var sr: std.Io.net.Stream.Reader = conn.reader(io, &buffer);
    const r: *std.Io.Reader = &sr.interface;
    return try r.readSliceShort(buf);
}
