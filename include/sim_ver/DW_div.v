////////////////////////////////////////////////////////////////////////////////
//
//       This confidential and proprietary software may be used only
//     as authorized by a licensing agreement from Synopsys Inc.
//     In the event of publication, the following notice is applicable:
//
//                    (C) COPYRIGHT 2000 - 2016 SYNOPSYS INC.
//                           ALL RIGHTS RESERVED
//
//       The entire notice above must be reproduced on all authorized
//     copies.
//
// AUTHOR:    Reto Zimmermann		April 12, 2000
//
// VERSION:   Verilog Simulation Architecture
//
// DesignWare_version: 7434024d
// DesignWare_release: K-2015.06-DWBB_201506.5.2
//
////////////////////////////////////////////////////////////////////////////////
//
// ABSTRACT:  Verilog Simulation Models for Combinational Divider
//            - Uses modeling functions from DW_div_function.inc.
//
// MODIFIED:
//           05/14/15  RJK
//           Updated to eliminate === comparison to 1'bx for better
//           compatibility with verification tools and 2-state simulation.
//
//           08/03/05  Doug Lee
//           Modified the parameter checking for a_width and b_width
//
//-----------------------------------------------------------------------------

module DW_div (a, b, quotient, remainder, divide_by_0);

  parameter a_width  = 8;
  parameter b_width  = 8;
  parameter tc_mode  = 0;
  parameter rem_mode = 1;

  input  [a_width-1 : 0] a;
  input  [b_width-1 : 0] b;
  output [a_width-1 : 0] quotient;
  output [b_width-1 : 0] remainder;
  output 		 divide_by_0;
  
  wire [a_width-1 : 0] a;
  wire [b_width-1 : 0] b;
  reg  [a_width-1 : 0] quotient;
  reg  [b_width-1 : 0] remainder;
  reg		       divide_by_0;
  reg 		       b_x;

  // include modeling functions
`include "./include/sim_ver/DW_div_function.inc"

  
 
  initial begin : parameter_check
    integer param_err_flg;

    param_err_flg = 0;
    
    
    if (a_width < 1) begin
      param_err_flg = 1;
      $display(
	"ERROR: %m :\n  Invalid value (%d) for parameter a_width (lower bound: 1)",
	a_width );
    end
    
    if (b_width < 1) begin
      param_err_flg = 1;
      $display(
	"ERROR: %m :\n  Invalid value (%d) for parameter b_width (lower bound: 1)",
	b_width );
    end
    
    if ( (tc_mode < 0) || (tc_mode > 1) ) begin
      param_err_flg = 1;
      $display(
	"ERROR: %m :\n  Invalid value (%d) for parameter tc_mode (legal range: 0 to 1)",
	tc_mode );
    end
    
    if ( (rem_mode < 0) || (rem_mode > 1) ) begin
      param_err_flg = 1;
      $display(
	"ERROR: %m :\n  Invalid value (%d) for parameter rem_mode (legal range: 0 to 1)",
	rem_mode );
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
      quotient = DWF_div_uns (a, b);
      if (rem_mode == 1)
	remainder = DWF_rem_uns (a, b);
      else
	remainder = DWF_mod_uns (a, b);
    end
    else begin
      quotient = DWF_div_tc (a, b);
      if (rem_mode == 1)
	remainder = DWF_rem_tc (a, b);
      else
	remainder = DWF_mod_tc (a, b);
    end
    if (b == {b_width{1'b0}})
      divide_by_0 = 1'b1;
    else
      divide_by_0 = 1'b0;
  end 

endmodule

//-----------------------------------------------------------------------------

