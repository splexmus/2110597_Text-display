/*
 * Copyright (c) 2025 Uri Shaked
 * SPDX-License-Identifier: Apache-2.0
 */

`default_nettype none

module tt_um_vga_example (
    input  wire [7:0] ui_in,    // Dedicated inputs
    output wire [7:0] uo_out,   // Dedicated outputs
    input  wire [7:0] uio_in,   // IOs: Input path
    output wire [7:0] uio_out,  // IOs: Output path
    output wire [7:0] uio_oe,   // IOs: Enable path (active high: 0=input, 1=output)
    input  wire       ena,      // always 1 when the design is powered, so you can ignore it
    input  wire       clk,      // clock
    input  wire       rst_n     // reset_n - low to reset
);

  // Unused outputs assigned to 0.
  assign uio_out = 0;
  assign uio_oe  = 0;

  // Suppress unused signals warning
  wire _unused_ok = &{ena, ui_in[7], ui_in[4:0], uio_in};

  // VGA signals
  wire hsync;
  wire vsync;
  reg [1:0] R;
  reg [1:0] G;
  reg [1:0] B;
  wire video_active;
  wire [9:0] pix_x;
  wire [9:0] pix_y;

  // Tiny VGA Pmod
  assign uo_out = {hsync, B[0], G[0], R[0], vsync, B[1], G[1], R[1]};

  hvsync_generator vga_sync_gen (
      .clk(clk),
      .reset(~rst_n),
      .hsync(hsync),
      .vsync(vsync),
      .display_on(video_active),
      .hpos(pix_x),
      .vpos(pix_y)
  );

  // Gamepad Pmod
  wire inp_b, inp_y, inp_select, inp_start, inp_up, inp_down, inp_left, inp_right, inp_a, inp_x, inp_l, inp_r;
  wire inp_present;

  gamepad_pmod_single driver (
      // Inputs:
      .rst_n(rst_n),
      .clk(clk),
      .pmod_data(ui_in[6]),
      .pmod_clk(ui_in[5]),
      .pmod_latch(ui_in[4]),
      // Outputs:
      .b(inp_b),
      .y(inp_y),
      .select(inp_select),
      .start(inp_start),
      .up(inp_up),
      .down(inp_down),
      .left(inp_left),
      .right(inp_right),
      .a(inp_a),
      .x(inp_x),
      .l(inp_l),
      .r(inp_r),
      .is_present(inp_present)
  );

  // Buttons are available for future interaction but do not affect this
  // autonomous animation.
  wire _unused_gamepad = &{inp_b, inp_y, inp_select, inp_start, inp_up,
                            inp_down, inp_left, inp_right, inp_a, inp_x,
                            inp_l, inp_r, inp_present};

  // Colors
  localparam [5:0] BLACK = {2'b00, 2'b00, 2'b00};

  // Advance the angle once every four display frames. With 64 angular steps,
  // one complete rotation takes a little over four seconds at 60 Hz.
  reg [1:0] frame_hold;
  reg [5:0] cube_angle;
  always @(posedge clk) begin
    if (~rst_n) begin
      frame_hold <= 0;
      cube_angle <= 0;
    end else if ((pix_x == 0) && (pix_y == 0)) begin
      if (frame_hold == 3) begin
        frame_hold <= 0;
        cube_angle <= cube_angle + 1'b1;
      end else begin
        frame_hold <= frame_hold + 1'b1;
      end
    end
  end

  wire [2:0] cube_character;
  wire [7:0] glyph_pixels;
  wire cube_pixel = glyph_pixels[3'd7 - pix_x[2:0]];

  logic_ball animation_renderer (
      .x({pix_x[9:3],3'b0}),
      .y({pix_y[9:3],3'b0}),
      .angle(cube_angle),
      .character(cube_character)
  );

  ascii_mem glyph_rom (
      .character(cube_character),
      .glyph_row(pix_y[2:0]),
      .text_pix(glyph_pixels)
  );

  // RGB output logic
  always @(posedge clk) begin
    if (~rst_n) begin
      R <= 0;
      G <= 0;
      B <= 0;
    end else begin
      if (video_active) begin
        if (cube_pixel) begin
          // Give each visible cube face its own shade/color.
          case (cube_character)
            3'd1: {R, G, B} <= 6'b11_11_11;
            3'd2: {R, G, B} <= 6'b11_01_01;
            3'd3: {R, G, B} <= 6'b01_11_11;
            3'd4: {R, G, B} <= 6'b01_10_11;
            3'd5: {R, G, B} <= 6'b11_10_00;
            3'd6: {R, G, B} <= 6'b10_11_01;
            default: {R, G, B} <= BLACK;
          endcase
        end else begin
          {R, G, B} <= BLACK;
        end
      end else begin
        {R, G, B} <= 0;
      end
    end
  end

endmodule