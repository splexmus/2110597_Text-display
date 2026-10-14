`default_nettype none

// Signed Q8 trigonometric lookup. One turn is 64 angle steps and +/-1.0 is
// represented by +/-256. Quadrant symmetry keeps the table small.
module sin_lut (
    input  wire [5:0] angle,
    output reg signed [9:0] value
);
  wire [3:0] offset = angle[3:0];
  wire [4:0] wave_index = angle[4] ? (5'd16 - {1'b0, offset})
                                          : {1'b0, offset};
  reg signed [9:0] magnitude;

  always @(*) begin
    case (wave_index)
      5'd0:  magnitude = 10'sd0;
      5'd1:  magnitude = 10'sd25;
      5'd2:  magnitude = 10'sd50;
      5'd3:  magnitude = 10'sd74;
      5'd4:  magnitude = 10'sd98;
      5'd5:  magnitude = 10'sd121;
      5'd6:  magnitude = 10'sd142;
      5'd7:  magnitude = 10'sd162;
      5'd8:  magnitude = 10'sd181;
      5'd9:  magnitude = 10'sd198;
      5'd10: magnitude = 10'sd213;
      5'd11: magnitude = 10'sd226;
      5'd12: magnitude = 10'sd237;
      5'd13: magnitude = 10'sd245;
      5'd14: magnitude = 10'sd251;
      5'd15: magnitude = 10'sd255;
      default: magnitude = 10'sd256;
    endcase
    value = angle[5] ? -magnitude : magnitude;
  end
endmodule

module cos_lut (
    input  wire [5:0] angle,
    output wire signed [9:0] value
);
  wire [5:0] shifted_angle = angle + 6'd16;
  sin_lut cosine_from_sine (
      .angle(shifted_angle),
      .value(value)
  );
endmodule

`default_nettype wire
