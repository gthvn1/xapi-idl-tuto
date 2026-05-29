const std = @import("std");
const datamodel = @import("datamodel.zig");

fn typeToStr(ty: datamodel.Type) []const u8 {
    return switch (ty) {
        .string => "[]const u8",
        .int => "i64",
    };
}

fn typeToFmt(ty: datamodel.Type) []const u8 {
    return switch (ty) {
        .string => "{s}",
        .int => "{d}",
    };
}

fn genClient(io: std.Io) !void {
    const cwd = std.Io.Dir.cwd();
    const file = try cwd.createFile(io, "generated/client.zig", .{});
    defer file.close(io);

    var buf: [4096]u8 = undefined;
    var file_writer = file.writer(io, &buf);
    const writer = &file_writer.interface;

    try writer.writeAll("const std = @import(\"std\");\n");
    try writer.writeAll("const rpc = @import(\"../src/rpc.zig\");\n\n");

    for (datamodel.all_objects) |obj| {
        try writer.print("pub const {s} = struct {{\n", .{obj.name});
        for (obj.methods) |method| {
            try writer.print("    pub fn {s}(conn: std.net.Stream", .{method.name});
            // always ask for a buffer. If the result is a int the caller will read it as
            // a string in buf.
            try writer.print(", buf: []u8", .{});

            for (method.params) |param| {
                try writer.print(", {s}: {s}", .{ param.name, typeToStr(param.ty) });
            }
            try writer.print(") !usize {{\n", .{});

            try writer.print("        rpc.send(conn, \"{s}.{s}\", .{{}});\n", .{ obj.name, method.name });
            for (method.params) |param| {
                try writer.print("        rpc.send(conn, \"{s}={s}\", .{{ {s} }});\n", .{
                    param.name,
                    typeToFmt(param.ty),
                    param.name,
                });
            }

            try writer.print("        rpc.sendEnd(conn);\n", .{});
            try writer.print("        return rpc.receive(conn, buf);\n", .{});
            try writer.print("    }}\n", .{});
        }
        try writer.print("}};\n", .{});
    }

    try writer.flush();
}

fn genServer() !void {
    std.debug.print("server.zig: wip\n", .{});
}

pub fn main(init: std.process.Init) !void {
    const io = init.io;
    const cwd = std.Io.Dir.cwd();
    cwd.createDir(io, "generated", .default_dir) catch |err| {
        if (err != std.Io.Dir.CreateDirError.PathAlreadyExists) return err;
    };
    try genClient(io);
    try genServer();
}
