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
    const file = try cwd.createFile(io, "src/datamodel_client_gen.zig", .{});
    defer file.close(io);

    var buf: [4096]u8 = undefined;
    var file_writer = file.writer(io, &buf);
    const writer = &file_writer.interface;

    try writer.writeAll("const std = @import(\"std\");\n");
    try writer.writeAll("const rpc = @import(\"rpc.zig\");\n\n");

    for (datamodel.all_objects) |obj| {
        try writer.print("pub const {s} = struct {{\n", .{obj.name});
        for (obj.methods) |method| {
            try writer.print("    pub fn {s}(io: std.Io, conn: std.Io.net.Stream", .{method.name});
            // always ask for a buffer. If the result is a int the caller will read it as
            // a string in buf.
            try writer.print(", buf: []u8", .{});

            for (method.params) |param| {
                try writer.print(", {s}: {s}", .{ param.name, typeToStr(param.ty) });
            }
            try writer.print(") !usize {{\n", .{});

            try writer.print("        try rpc.send(io, conn, \"{s}.{s}\", .{{}});\n", .{ obj.name, method.name });
            for (method.params) |param| {
                try writer.print("        try rpc.send(io, conn, \"{s}={s}\", .{{{s}}});\n", .{
                    param.name,
                    typeToFmt(param.ty),
                    param.name,
                });
            }

            try writer.print("        try rpc.sendEnd(io, conn);\n", .{});
            try writer.print("        return try rpc.receive(io, conn, buf);\n", .{});
            try writer.print("    }}\n", .{});
        }
        try writer.print("}};\n", .{});
    }

    try writer.flush();
    std.debug.print("Generate src/datamodel_client_gen.zig: DONE\n", .{});
}

fn genServer(io: std.Io) !void {
    const cwd = std.Io.Dir.cwd();
    const file = try cwd.createFile(io, "src/datamodel_server_gen.zig", .{});
    defer file.close(io);

    var buf: [4096]u8 = undefined;
    var file_writer = file.writer(io, &buf);
    const writer = &file_writer.interface;

    try writer.writeAll("const std = @import(\"std\");\n\n");

    try writer.writeAll("pub fn make(comptime Impl: type) type {\n");
    try writer.writeAll("    return struct {\n");
    try writer.writeAll("        pub fn dispatchCall(name: []const u8, params: []const []const u8) ![]const u8 {\n");
    try writer.writeAll("            _ = params;\n");
    try writer.writeAll("            return try if (std.mem.eql(u8, name, \"Host.hello\")) \n");
    try writer.writeAll("                Impl.Host.hello(\"fake\", 1)\n");
    try writer.writeAll("            else\n");
    try writer.writeAll("                error.Unimplemented;\n");
    try writer.writeAll("        }\n");
    try writer.writeAll("    };\n");
    try writer.writeAll("}\n");

    try writer.flush();
    std.debug.print("Generate src/datamodel_server_gen.zig: PARTIAL\n", .{});
}

pub fn main(init: std.process.Init) !void {
    const io = init.io;
    try genClient(io);
    try genServer(io);
}
