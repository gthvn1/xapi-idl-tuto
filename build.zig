const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const gen_api_exe = b.addExecutable(.{
        .name = "gen-api",
        .root_module = b.createModule(.{
            .root_source_file = b.path("src/gen_api.zig"),
            .target = target,
            .optimize = optimize,
        }),
    });

    // Install it so we can run it manually but it is not strictly required.
    b.installArtifact(gen_api_exe);

    const run_gen = b.addRunArtifact(gen_api_exe);

    const client_exe = b.addExecutable(.{
        .name = "client",
        .root_module = b.createModule(.{
            .root_source_file = b.path("src/client.zig"),
            .target = target,
            .optimize = optimize,
        }),
    });

    client_exe.step.dependOn(&run_gen.step);
    b.installArtifact(client_exe);

    const server_exe = b.addExecutable(.{
        .name = "server",
        .root_module = b.createModule(.{
            .root_source_file = b.path("src/server.zig"),
            .target = target,
            .optimize = optimize,
        }),
    });
    server_exe.step.dependOn(&run_gen.step);
    b.installArtifact(server_exe);

    b.getInstallStep().dependOn(&client_exe.step);
    b.getInstallStep().dependOn(&server_exe.step);
}
