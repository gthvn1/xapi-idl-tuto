const std = @import("std");

pub fn enableImpl(name: []const u8) ![]const u8 {
    std.debug.print("name is {s}\n", .{name});
    return "Host.enable: Not implemented";
}

pub fn disableImpl(name: []const u8) ![]const u8 {
    std.debug.print("name is {s}\n", .{name});
    return "Host.disable: Not implemented";
}
