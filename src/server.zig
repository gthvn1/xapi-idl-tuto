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

    // We are expecting a list of items separated by '\n' and an empty one to ends the stream.
    var request: [1024]u8 = undefined;
    var i: usize = 0;
    while (true) {
        if (i == request.len) return error.RequestBufferTooSmall;
        // Read one byte
        const byte_read = try r.readSliceShort(request[i .. i + 1]);
        if (byte_read == 0) break;
        if (request[i] == '\n') {
            // We need to check if it is an empty line and thus the end of request.
            i += byte_read;
            if (i == request.len) return error.RequestBufferTooSmall;
            // Check if there is another '\n'
            const another_byte_read = try r.readSliceShort(request[i .. i + 1]);
            if (another_byte_read == 0) break;
            if (request[i] == '\n') {
                // We can drop the last '\n'
                i = i - 1;
                break;
            }
            i += another_byte_read;
        } else {
            i += byte_read;
        }
    }

    // request is "name\nparam1=key1\nparam2=key2\n..."
    var it = std.mem.splitScalar(u8, request[0..i], '\n');
    while (it.next()) |s| {
        std.debug.print("Found: <{s}>\n", .{s});
    }

    try w.writeAll("ok\n");
    try w.flush();

    std.debug.print("Bye\n", .{});
}
