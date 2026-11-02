//! Provides utilities for interacting with the terminal.
//! Primarily handles interfaces and ncurses.

const std = @import("std");
const c = @import("c");

pub const ns_per_frame = 1666667;

pub const playfield_width = 10;
pub const playfield_height = 40;
pub const playfield_area = playfield_width * playfield_height;

pub const separator = 6;

pub const preview_width = 6;
pub const preview_height = 6;

pub const full_width = playfield_width + preview_width;
pub const full_height = playfield_height;

pub const NcursesError = error{
    InitscrFailed,
    NoechoFailed,
    Curs_setFailed,
    CbreakFailed,
    NodelayFailed,
    KeypadFailed,
    FlushinpFailed,
    RefreshFailed,
    EndwinFailed,
    MvprintwFailed,
    StartColorFailed,
};

/// Ncurses wrapper function to scale terminal cells 1:1 rather than 2:1 default.
/// Pass in the standard coordinates to get what you'd expect from printing.
/// Also handles NcursesErrors and provides a more native interface.
pub fn mvprintw(y: u32, x: u32, msg: []const u8) NcursesError!void {
    if (c.mvprintw(@intCast(y), @intCast(x * 2), msg.ptr) == c.ERR) return NcursesError.MvprintwFailed;
}

/// Prints the user interface to the terminal. Call once before the main loop.
pub fn createBorders() NcursesError!void {
    for (0..full_width + 2) |x| {
        for (0..playfield_height + 2) |y| {
            const is_valid_border: bool = (x == 0 or x == full_width + 1 or y == 0 or y == playfield_height + 1);
            const is_valid_playfield: bool = (x == playfield_width + 1);
            const is_valid_preview: bool = (y == separator and x > playfield_width);

            if (is_valid_border or is_valid_playfield or is_valid_preview) {
                try mvprintw(@intCast(y), @intCast(x), "[]");
            }
        }
    }
}

/// Performs terminal configurations and returns a window pointer.
pub fn ncursesSetUp() !*c.WINDOW {
    const stdscr: *c.WINDOW = c.initscr() orelse return NcursesError.InitscrFailed;

    const start_colors: c_int = if (c.has_colors()) c.start_color() else c.ERR;
    if (start_colors == c.ERR) return NcursesError.StartColorFailed;
    if (c.noecho() == c.ERR) return NcursesError.NoechoFailed;
    if (c.curs_set(0) == c.ERR) return NcursesError.Curs_setFailed;
    if (c.cbreak() == c.ERR) return NcursesError.CbreakFailed;
    if (c.nodelay(stdscr, true) == c.ERR) return NcursesError.NodelayFailed;
    if (c.keypad(stdscr, true) == c.ERR) return NcursesError.KeypadFailed;
    return stdscr;
}
