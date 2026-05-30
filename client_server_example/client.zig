const std = @import("std");
const net = std.Io.net;

pub fn main(init: std.process.Init) !void {
    const io = init.io;
    var bufreader: [1024]u8 = undefined;
    var bufwriter: [1024]u8 = undefined;

    const address = try net.IpAddress.parseIp4("127.0.0.1", 8080);
    const s = try net.IpAddress.connect(
        &address,
        io,
        net.IpAddress.ConnectOptions{
            .mode = net.Socket.Mode.stream,
        },
    );

    var stream_reader = net.Stream.reader(s, io, &bufreader);
    const r = &stream_reader.interface;

    var stream_writer = net.Stream.writer(s, io, &bufwriter);
    const w = &stream_writer.interface;

    std.debug.print("Sending hello\n", .{});
    try w.writeAll("Hello from client\n");
    try w.flush();

    var answer: [64]u8 = undefined;
    var i: usize = 0;
    while (i < answer.len) {
        const byte_read = try r.readSliceShort(answer[i .. i + 1]);
        if ((byte_read == 0) or (answer[i] == '\n')) break;
        i += byte_read;
    }

    std.debug.print("Received {d} bytes: {s}\n", .{ i, answer[0..i] });
    std.debug.print("Bye\n", .{});
}
