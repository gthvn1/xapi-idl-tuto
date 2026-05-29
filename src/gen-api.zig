const std = @import("std");
const datamodel = @import("datamodel.zig");

fn typeToStr(ty: datamodel.Type) []const u8 {
    return switch (ty) {
        .string => "[]const u8",
        .int => "i64",
    };
}

fn genClient(io: std.Io) !void {
    const cwd = std.Io.Dir.cwd();
    const file = try cwd.createFile(io, "generated/client.ml", .{});
    defer file.close(io);

    var buf: [4096]u8 = undefined;
    var file_writer = file.writer(io, &buf);
    const writer = &file_writer.interface;

    try writer.writeAll("Generate client.ml on stderr for now\n");
    try writer.flush();

    for (datamodel.all_objects) |obj| {
        for (obj.methods) |method| {
            std.debug.print("pub fn {s}(conn: std.net.Stream", .{method.name});
            for (method.params) |param| {
                std.debug.print(",{s}: {s}", .{ param.name, typeToStr(param.ty) });
            }
            std.debug.print(") !{s} {{\n", .{typeToStr(method.result)});

            std.debug.print("  var response: []u8;\n", .{});
            std.debug.print("  send(\"{s}.{s}\");\n", .{ datamodel.host_object.name, method.name });
            for (method.params) |param| {
                std.debug.print("  send(\"{s}={{s}}\", .{{ {s} }});\n", .{ param.name, param.name });
            }

            std.debug.print("  send(\"\");\n", .{});
            std.debug.print("  read(response);\n", .{});
            std.debug.print("  return response;\n", .{});
            std.debug.print("}}\n", .{});
        }
    }
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
