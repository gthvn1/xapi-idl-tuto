const std = @import("std");
const net = std.Io.net;

pub fn main(init: std.process.Init) !void {
    const io = init.io;

    const address = try net.IpAddress.parseIp4("127.0.0.1", 8080);
    var server = try net.IpAddress.listen(
        &address,
        io,
        net.IpAddress.ListenOptions{ .mode = net.Socket.Mode.stream },
    );

    // Accept one connection, read the string until reading EOL
    // and returns "ok\n"
    std.debug.print("Waiting for client ... ", .{});
    const stream = try server.accept(io);
    std.debug.print("connected\n", .{});

    var buffer_writer: [64]u8 = undefined;
    var stream_writer = stream.writer(io, &buffer_writer);
    const w = &stream_writer.interface;

    var buffer_reader: [64]u8 = undefined;
    var stream_reader = stream.reader(io, &buffer_reader);
    const r = &stream_reader.interface;

    var request: [64]u8 = undefined;
    var i: usize = 0;
    while (i < request.len) {
        const byte_read = try r.readSliceShort(request[i .. i + 1]);
        if ((byte_read == 0) or (request[i] == '\n')) break;
        i += byte_read;
    }
    std.debug.print("Received {d} bytes: {s}\n", .{ i, request[0..i] });

    try w.writeAll("ok\n");
    try w.flush();

    std.debug.print("Bye\n", .{});
}
