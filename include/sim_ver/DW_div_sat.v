////////////////////////////////////////////////////////////////////////////////
//
//       This confidential and proprietary software may be used only
//     as authorized by a licensing agreement from Synopsys Inc.
//     In the event of publication, the following notice is applicable:
//
//                    (C) COPYRIGHT 2013 - 2016 SYNOPSYS INC.
//                           ALL RIGHTS RESERVED
//
//       The entire notice above must be reproduced on all authorized
//     copies.
//
// AUTHOR:    Reto Zimmermann		Sep 25, 2013
//
// VERSION:   Verilog Simulation Architecture
//
// DesignWare_version: dd3dd17a
// DesignWare_release: K-2015.06-DWBB_201506.5.2
//
////////////////////////////////////////////////////////////////////////////////
//
// ABSTRACT:  Verilog Simulation Models for Combinational Divider with Saturation
//            - Uses modeling functions from DW_div_sat_function.inc.
//
//-----------------------------------------------------------------------------

module DW_div_sat (a, b, quotient, divide_by_0);

  parameter a_width  = 8;
  parameter b_width  = 8;
  parameter q_width  = 8;
  parameter tc_mode  = 0;

  input  [a_width-1 : 0] a;
  input  [b_width-1 : 0] b;
  output [q_width-1 : 0] quotient;
  output 		 divide_by_0;
  
  wire [a_width-1 : 0] a;
  wire [b_width-1 : 0] b;
  reg  [q_width-1 : 0] quotient;
  reg		       divide_by_0;
  reg 		       b_x;
  reg  [q_width-1 : 0] q_int;

  // include modeling functions
`include "DW_div_sat_function.inc"

  
 
  initial begin : parameter_check
    integer param_err_flg;

    param_err_flg = 0;
    
    
    if (a_width < 2) begin
      param_err_flg = 1;
      $display(
	"ERROR: %m :\n  Invalid value (%d) for parameter a_width (lower bound: 2)",
	a_width );
    end
    
    if (b_width < 2) begin
      param_err_flg = 1;
      $display(
	"ERROR: %m :\n  Invalid value (%d) for parameter b_width (lower bound: 2)",
	b_width );
    end
    
    if ( (q_width < 2) || (q_width > a_width) ) begin
      param_err_flg = 1;
      $display(
	"ERROR: %m :\n  Invalid value (%d) for parameter q_width (legal range: 2 to a_width)",
	q_width );
    end
    
    if ( (tc_mode < 0) || (tc_mode > 1) ) begin
      param_err_flg = 1;
      $display(
	"ERROR: %m :\n  Invalid value (%d) for parameter tc_mode (legal range: 0 to 1)",
	tc_mode );
    end
  
    if ( param_err_flg == 1) begin
      $display(
        "%m :\n  Simulation aborted due to invalid parameter value(s)");
      $finish;
    end

  end // parameter_check 



  always @(a or b)
  begin
    if (tc_mode == 0) begin
      quotient = DWF_div_sat_uns (a, b);
    end
    else begin
      quotient = DWF_div_sat_tc (a, b);
    end
    b_x = ^b;
    if (b_x === 1'bx)
      divide_by_0 = 1'bx;
    else if (b == {b_width{1'b0}})
      divide_by_0 = 1'b1;
    else
      divide_by_0 = 1'b0;
  end 

endmodule

//-----------------------------------------------------------------------------

