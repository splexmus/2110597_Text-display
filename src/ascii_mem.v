`default_nettype none
module ascii_mem (
    input wire [2:0] character,
    input wire [2:0] glyph_row,
    output reg [7:0] text_pix
);
  // Character IDs: blank, @, $, ~, #, ;, +.  These are the six face
  // characters used by the reference C cube renderer.
  always @(*) begin
    case ({character, glyph_row})
      // @
      6'b001_000: text_pix = 8'b00111100;
      6'b001_001: text_pix = 8'b01100110;
      6'b001_010: text_pix = 8'b01101110;
      6'b001_011: text_pix = 8'b01101010;
      6'b001_100: text_pix = 8'b01101110;
      6'b001_101: text_pix = 8'b01100000;
      6'b001_110: text_pix = 8'b00111100;
      // $
      6'b010_000: text_pix = 8'b00011000;
      6'b010_001: text_pix = 8'b00111110;
      6'b010_010: text_pix = 8'b01100000;
      6'b010_011: text_pix = 8'b00111100;
      6'b010_100: text_pix = 8'b00000110;
      6'b010_101: text_pix = 8'b01111100;
      6'b010_110: text_pix = 8'b00011000;
      // ~
      6'b011_010: text_pix = 8'b00110010;
      6'b011_011: text_pix = 8'b01001100;
      // #
      6'b100_001: text_pix = 8'b00100100;
      6'b100_010: text_pix = 8'b01111110;
      6'b100_011: text_pix = 8'b00100100;
      6'b100_100: text_pix = 8'b01111110;
      6'b100_101: text_pix = 8'b00100100;
      // ;
      6'b101_001: text_pix = 8'b00011000;
      6'b101_010: text_pix = 8'b00011000;
      6'b101_100: text_pix = 8'b00011000;
      6'b101_101: text_pix = 8'b00010000;
      6'b101_110: text_pix = 8'b00100000;
      // +
      6'b110_001: text_pix = 8'b00011000;
      6'b110_010: text_pix = 8'b00011000;
      6'b110_011: text_pix = 8'b01111110;
      6'b110_100: text_pix = 8'b00011000;
      6'b110_101: text_pix = 8'b00011000;
      default: text_pix = 8'b00000000;
    endcase
  end
endmodule
`default_nettype wire
