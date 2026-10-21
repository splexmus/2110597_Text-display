# ASCII Bouncing Ball VGA

A Tiny Tapeout Verilog design that generates a 640x480 VGA animation of an
ASCII-patterned ball bouncing and squashing above a textured floor. The image
is rendered directly from the current pixel coordinates, so the design does
not use a framebuffer or pre-rendered animation frames.

## What it does

- Generates standard 640x480 VGA timing at a 25.175 MHz pixel clock.
- Advances a 64-step animation once every four frames (about one cycle every
  4.3 seconds at 59.94 Hz).
- Draws the scene on an 8x8 character grid using the glyphs `@`, `$`, `~`,
  `#`, `;`, and `+`.
- Changes the ball's vertical position, shape, glyph, and color as the
  animation progresses.
- Exposes VGA through the Tiny VGA Pmod pin layout with two bits per color.

The Gamepad Pmod receiver is included and connected to `ui_in[6:4]`, but its
button signals are currently reserved for future interaction. The animation
runs autonomously.

## Hardware interface

The top-level module is `tt_um_vga_example`.

| Signal | Direction | Purpose |
| --- | --- | --- |
| `clk` | Input | 25.175 MHz pixel clock |
| `rst_n` | Input | Active-low reset |
| `ui_in[6]` | Input | Gamepad serial data (currently unused by the animation) |
| `ui_in[5]` | Input | Gamepad serial clock |
| `ui_in[4]` | Input | Gamepad latch |
| `uo_out[7]` | Output | VGA horizontal sync |
| `uo_out[6:4]` | Output | VGA blue, green, and red low bits |
| `uo_out[3]` | Output | VGA vertical sync |
| `uo_out[2:0]` | Output | VGA blue, green, and red high bits |

All bidirectional pins are configured as inputs and are otherwise unused.

## Design structure

| File | Role |
| --- | --- |
| `src/project.v` | Tiny Tapeout top level, frame timing, palette, and module integration |
| `src/hvsync_generator.v` | 640x480 VGA timing generator |
| `src/logic_ball.v` | Ball position, deformation, and character selection |
| `src/ascii_mem.v` | Combinational 8x8 glyph ROM |
| `src/gamepad_pmod.v` | Single- and dual-controller Gamepad Pmod receivers |
| `test/test.py` | Cocotb frame capture and reference-image comparison |

Only the source files listed in `info.yaml` are included in the Tiny Tapeout
build.

## Local validation

Install Icarus Verilog, then run a syntax/elaboration check from the project
root:

```sh
iverilog -g2012 \
  -s tt_um_vga_example \
  -o /tmp/tt_um_vga_example_sim \
  src/project.v \
  src/gamepad_pmod.v \
  src/hvsync_generator.v \
  src/logic_ball.v \
  src/ascii_mem.v
```

The Cocotb test captures three frames into `output/` and compares them with
PNG files under `reference/`. To run that regression, add the usual Cocotb
simulator Makefile and matching `reference/frame0.png` through
`reference/frame2.png`, then install its Python dependencies:

```sh
python3 -m venv .venv
. .venv/bin/activate
python3 -m pip install -r test/requirements.txt
```

## Vga playground simulation

You can open this simulation on this [this_link](https://vga-playground.com/?repo=https://github.com/splexmus/2110597_Text-display)

## Tiny Tapeout configuration

Project metadata, source membership, tile size, clock frequency, and the
physical pinout are defined in `info.yaml`. Fill in the blank title, author,
Discord, and description fields there before submitting the design.
