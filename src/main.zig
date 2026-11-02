const std = @import("std");
const c = @import("c");

const utils = @import("utils.zig");
const interface = @import("interface.zig");
const game = @import("game.zig");

const NcursesError = interface.NcursesError;

pub fn main(init: std.process.Init) !void {
    const arena = init.arena.allocator();
    const io = init.io;
    const args = init.minimal.args;

    var args_iter = try args.iterateAllocator(arena);
    if (!args_iter.skip()) unreachable;

    const path = args_iter.next();
    const config = try utils.readConfig(arena, io, path);

    var key_map: game.KeyMapper = .init(arena);
    try key_map.parseConfig(config);

    const seed = std.Io.Timestamp.now(io, .real).toMicroseconds();
    var prng = std.Random.DefaultPrng.init(@intCast(seed));
    const rand = prng.random();

    const stdscr = try interface.ncursesSetUp();

    const width: usize = @intCast(@divFloor(c.getmaxx(stdscr), 2));
    const height: usize = @intCast(c.getmaxy(stdscr));

    if (width < interface.full_width + 1 or height < interface.full_height + 1) {
        if (c.endwin() == c.ERR) return NcursesError.EndwinFailed;
        std.process.fatal(
            \\Terminal size is too small to play!
            \\The Terminal must be at least {d} cells wide and {d} cells tall!
        , .{ interface.full_width + 1, interface.playfield_height + 1 });
    }

    try interface.createBorders();

    var playfield: [40]u10 = @splat(0);

    const current_piece = rand.enumValue(game.Tetromino);
    //var preview_piece = rand.enumValue(Tetromino);
    //var hold_piece: ?Tetromino = null;
    _ = current_piece;

    var tick = std.Io.Timestamp.now(io, .cpu_process);
    var delta_tick: i96 = 0;
    while (true) {
        const input = c.getch();
        if (input == 'q' or input == 'Q') break;
        if (c.flushinp() == c.ERR) return NcursesError.FlushinpFailed;

        delta_tick = tick.nanoseconds - std.Io.Timestamp.now(io, .cpu_process).nanoseconds;
        if (delta_tick >= interface.ns_per_frame) {
            delta_tick = 0;
            tick = std.Io.Timestamp.now(io, .cpu_process);

            const action = key_map.map.get(input) orelse return;
            switch (action) {
                .quit => break,
                else => {},
            }
        }

        var lines_cleared: usize = 0;
        for (playfield, 0..) |row_value, row| {
            if (row_value == 0b11_1111_1111) {
                lines_cleared += 1;
                std.mem.copyForwards(u10, playfield[row..], playfield[row + 1 ..]);
                playfield[playfield.len - 1] = 0;
            }
        }

        if (c.refresh() == c.ERR) return NcursesError.RefreshFailed;
        try std.Io.sleep(io, .fromNanoseconds(interface.ns_per_frame), .awake);
    }

    if (c.endwin() == c.ERR) return NcursesError.EndwinFailed;
    std.debug.print("Finished\n", .{});
    std.process.cleanExit(io);
}
