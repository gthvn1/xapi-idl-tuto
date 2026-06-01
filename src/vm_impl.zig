const std = @import("std");

pub fn createImpl(name: []const u8, memory: i64) ![]const u8 {
    std.debug.print("name is {s}\n", .{name});
    std.debug.print("memory set to {d}\n", .{memory});
    return "VM.create: Not implemented";
}

pub fn destroyImpl(name: []const u8) ![]const u8 {
    std.debug.print("name is {s}\n", .{name});
    return "VM.destroy: Not implemented";
}
