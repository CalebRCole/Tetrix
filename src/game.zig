//! Provides functionality for aspects of game logic.

const std = @import("std");
const c = @import("c");
const interface = @import("interface.zig");

const GameErrors = error{
    ConfigurationError,
};

pub const Tetromino = enum(u3) {
    I,
    J,
    L,
    O,
    S,
    T,
    Z,
};

pub const Action = enum {
    left,
    right,
    hard,
    soft,
    hold,
    rotatecw,
    rotateccw,
    quit,
};

pub const KeyMapper = struct {
    map: std.hash_map.AutoHashMap(c_int, Action),

    pub fn init(allocator: std.mem.Allocator) KeyMapper {
        return .{
            .map = .init(allocator),
        };
    }

    pub fn deinit(self: *KeyMapper) void {
        self.map.deinit();
    }

    pub fn addBinding(
        self: *KeyMapper,
        action_str: []const u8,
        key_str: []const u8,
    ) (GameErrors || std.mem.Allocator.Error)!void {
        const action = std.meta.stringToEnum(Action, action_str) orelse {
            std.log.err("Invalid action name in configuration: {s}", .{action_str});
            return error.ConfigurationError;
        };
        const key = interface.parseKey(key_str) orelse {
            std.log.err("Invalid key in configuration: {s}", .{key_str});
            return error.ConfigurationError;
        };
        try self.map.put(key, action);
    }

    pub fn parseConfig(
        self: *KeyMapper,
        config: []const u8,
    ) (GameErrors || std.mem.Allocator.Error)!void {
        var line_iter = std.mem.splitScalar(u8, config, '\n');
        while (line_iter.next()) |line| {
            var word_iter = std.mem.splitScalar(u8, line, '=');
            const action: []const u8 = word_iter.next() orelse return;
            const key: []const u8 = word_iter.next() orelse return;

            try self.addBinding(
                std.mem.trim(u8, action, " \t\r\n"),
                std.mem.trim(u8, key, " \t\r\n"),
            );
        }
    }
};
