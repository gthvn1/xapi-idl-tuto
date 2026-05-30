const std = @import("std");
const net = std.Io.net;
const datamodel_client = @import("datamodel_client_gen.zig");

pub fn main(init: std.process.Init) !void {
    const io = init.io;

    const address = try net.IpAddress.parseIp4("127.0.0.1", 8080);
    const s = try net.IpAddress.connect(
        &address,
        io,
        net.IpAddress.ConnectOptions{
            .mode = net.Socket.Mode.stream,
        },
    );

    std.debug.print("Sending hello\n", .{});
    var answer: [64]u8 = undefined;
    const bytes_read = try datamodel_client.Host.hello(io, s, &answer, "example", 1);

    std.debug.print("Received {d} bytes: {s}\n", .{ bytes_read, answer[0..bytes_read] });
    std.debug.print("Bye\n", .{});
}
