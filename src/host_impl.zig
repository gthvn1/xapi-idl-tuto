const std = @import("std");

pub fn helloImpl(name: []const u8, version: i64) ![]const u8 {
    std.debug.print("name is {s}\n", .{name});
    std.debug.print("version is {d}\n", .{version});
    return "you reach hello implementation";
}
