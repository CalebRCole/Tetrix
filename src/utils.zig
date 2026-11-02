//! Provide functions that don't quite fit the other modules.

const std = @import("std");

/// Takes the values specified in "config.ini" in the binary directory.
/// If a path is added as an argument, it is used for locating "config.ini".
/// If 'path' is not specified or valid and config.ini does not exist, it is created.
/// Caller must free returned file.
pub fn readConfig(allocator: std.mem.Allocator, io: std.Io, path: ?[]const u8) ![]const u8 {
    const config_path = path orelse blk: {
        std.log.info("Configuration file path not specified. Using default configuration file \"config.ini\".\n", .{});
        break :blk "config.ini";
    };
    const file = std.Io.Dir.readFileAlloc(.cwd(), io, config_path, allocator, .unlimited) catch |err| switch (err) {
        error.FileNotFound => blk: {
            const exe_dir_path = try std.process.executableDirPathAlloc(io, allocator);
            defer allocator.free(exe_dir_path);

            const exe_dir = try std.Io.Dir.openDirAbsolute(io, exe_dir_path, .{});
            defer exe_dir.close(io);

            // Path to input config missing, falling back to the default config.
            if (path != null) fallback: {
                std.log.warn("Specified configuration path is not found. Using default configuration file \"config.ini\".\n", .{});
                const default_config = std.Io.Dir.readFileAlloc(exe_dir, io, "config.ini", allocator, .unlimited) catch {
                    break :fallback;
                };
                break :blk default_config;
            }
            // If either config not specified/invalid and the default config is missing,
            // We generate the config and write it to the smae directory as the binary.
            std.log.info("Default config.ini not found, generating...\n", .{});
            const config = generateConfig(allocator, io) catch |e| return e;
            break :blk config;
        },
        else => return err,
    };
    return file;
}

/// Writes the default configuration to the same directory as the executable.
fn generateConfig(allocator: std.mem.Allocator, io: std.Io) ![]const u8 {
    const generated_config = @embedFile("config.ini");
    const exe_dir_path = try std.process.executableDirPathAlloc(io, allocator);
    defer allocator.free(exe_dir_path);

    const buf = try allocator.alloc(u8, exe_dir_path.len + 11);
    defer allocator.free(buf);

    const config_path = try std.mem.print(buf, "{s}/config.ini", .{exe_dir_path});
    const config = try std.Io.Dir.createFileAbsolute(io, config_path, .{});
    defer config.close(io);

    try std.Io.File.writeStreamingAll(config, io, generated_config);
    return generated_config;
}
