`default_nettype none

module logic_ball (
    input  wire [9:0] x,
    input  wire [9:0] y,
    input  wire [5:0] angle, // 2^6 = 64
    output reg  [2:0] character
);
  reg [9:0] center_x = 319;
  reg [9:0] center_y = 239;
  reg [32:0] radius = 8100;
  reg [32:0] radius_A = 8100;
  reg [32:0] radius_B = 8100;

  always @(*) begin
    if(angle <= 18 ) begin
      center_y <= angle*angle;
      radius_A <= radius;
      radius_B <= radius;
    end else if (angle <= 31) begin
      center_y <= angle + 9'd324;
      radius_A <= radius + 220*angle;
      radius_B <= radius - 220*angle;
    end else if (angle <= 45) begin
      center_y <= 9'd64 - angle + 9'd324;
      radius_A <= radius + 220*(9'd64 - angle);
      radius_B <= radius - 220*(9'd64 - angle);
    end else begin
      center_y <= (9'd64-angle)*(9'd64-angle);
      radius_A <= radius;
      radius_B <= radius;
    end
  end

  wire circle = radius_B*(x-center_x) * (x-center_x) + radius_A*(y-center_y) * (y-center_y) <= radius_A*radius_B;

  // The fixed-point assignments intentionally discard high fractional/sign
  // extension bits after each stage.
  /* verilator lint_off WIDTH */
  always @(*) begin
    character = 3'd0;
    if(y>320) character = 3'd1;
    // Only the nearer face from each opposite pair can be visible. The
    // character IDs preserve the face symbols used in ref/cube.c.
    if(circle) begin
      if (angle > 56) begin
        character <= 3'd2;
      end else if (angle > 48) begin
        character <= 3'd2;
      end else if (angle > 40) begin
        character <= 3'd3;
      end else if (angle > 32) begin
        character <= 3'd4;
      end else if (angle > 24) begin
        character <= 3'd4;
      end else if (angle > 16) begin
        character <= 3'd5;
      end else if (angle > 8) begin
        character <= 3'd6;
      end else begin
        character <= 3'd6;
      end
    end
  end
  /* verilator lint_on WIDTH */
endmodule

`default_nettype wire
