/*
 * Copyright (c) 2026 Italia Venecia Saldana Seturino
 * SPDX-License-Identifier: Apache-2.0
 */

`default_nettype none

module tt_um_countdown_1digit (
    input  wire [7:0] ui_in,    // Dedicated inputs: ui_in[0] = enable
    output wire [7:0] uo_out,   // Dedicated outputs: uo_out[6:0] = seg_a..seg_g, uo_out[7] = done_zero
    input  wire [7:0] uio_in,   // IOs: Input path
    output wire [7:0] uio_out,  // IOs: Output path
    output wire [7:0] uio_oe,   // IOs: Enable path (active high: 0=input, 1=output)
    input  wire       ena,      // always 1 when the design is powered, so you can ignore it
    input  wire       clk,      // clock
    input  wire       rst_n     // reset_n - low to reset
);

  wire enable = ui_in[0];
  reg [3:0] count;
  reg [6:0] seg;

  // 1-digit countdown from 9 down to 0
  always @(posedge clk) begin
    if (!rst_n) begin
      count <= 4'd9;
    end else if (enable && count != 4'd0) begin
      count <= count - 4'd1;
    end
  end

  // 7-segment decoder (active high: bit 0 = seg_a ... bit 6 = seg_g)
  always @(*) begin
    case (count)
      4'd0:    seg = 7'b0111111;
      4'd1:    seg = 7'b0000110;
      4'd2:    seg = 7'b1011011;
      4'd3:    seg = 7'b1001111;
      4'd4:    seg = 7'b1100110;
      4'd5:    seg = 7'b1101101;
      4'd6:    seg = 7'b1111101;
      4'd7:    seg = 7'b0000111;
      4'd8:    seg = 7'b1111111;
      4'd9:    seg = 7'b1101111;
      default: seg = 7'b0000000;
    endcase
  end

  assign uo_out[6:0] = seg;
  assign uo_out[7]   = (count == 4'd0);

  // Unused outputs assigned to 0
  assign uio_out = 8'b00000000;
  assign uio_oe  = 8'b00000000;

  // List all unused inputs to prevent warnings
  wire _unused = &{ena, ui_in[7:1], uio_in, 1'b0};

endmodule
