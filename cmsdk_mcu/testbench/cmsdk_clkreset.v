//--------------------------------------------------------------
// Abstract : Simple clock and power on reset generator
//-----------------------------------------------------------------------------
`timescale 1ns/1ps

module cmsdk_clkreset(
  output wire CLK,
  output wire NRST);

  reg clock_q   = 1'b0;
  reg reset_n_q = 1'b0;

  initial
    begin
      #10 clock_q <= 1'b1;
      #100 reset_n_q <= 1'b1;
    end


  always @(clock_q)
      #10 clock_q <= ~clock_q;

  assign CLK = clock_q;
  assign NRST = reset_n_q;

endmodule



