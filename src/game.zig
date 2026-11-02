//! Provides functionality for aspects of game logic.

const std = @import("std");
const c = @import("c");
const interface = @import("interface.zig");

pub const Tetromino = enum(u3) {
    I,
    J,
    L,
    O,
    S,
    T,
    Z,
};

pub const Actions = enum {
    left,
    right,
    hard,
    soft,
    hold,
    rotatecw,
    rotateccw,
    quit,
};

/// All valid keys for key-binding.
pub const Keys = enum {
    
};

/// Takes input from 'getch' and processes it. Should only be called once per game loop.
pub fn handleInput(input: c_int) !void {
    switch (input) {
        
    }
}
