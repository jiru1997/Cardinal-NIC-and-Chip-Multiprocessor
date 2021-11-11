////////////////////////////////////////////////////////////////////////////////
//
//       This confidential and proprietary software may be used only
//     as authorized by a licensing agreement from Synopsys Inc.
//     In the event of publication, the following notice is applicable:
//
//                    (C) COPYRIGHT 2007 - 2016 SYNOPSYS INC.
//                           ALL RIGHTS RESERVED
//
//       The entire notice above must be reproduced on all authorized
//     copies.
//
// AUTHOR:    Alexandre Tenca	May 31, 2007
//
// VERSION:   Verilog Simulation Model - DW_FP_ALIGN
//
// DesignWare_version: 055da968
// DesignWare_release: K-2015.06-DWBB_201506.5.2
//
////////////////////////////////////////////////////////////////////////////////
//---------------------------------------------------------------------------------
//
// ABSTRACT:  Right logical shift with sticky bit computation
//            This file contains a verification model for an alignment
//            unit (used in floating-point operations) that consists 
//            in a shifter and a logic to detect non-zero bits that 
//            are shifted out of range. 
//
// MODIFIED:
//
//---------------------------------------------------------------------------------

module DW_FP_ALIGN (a, sh, b, stk);
parameter a_width=8;
parameter sh_width=3;

input [a_width-1:0] a;
input [sh_width-1:0] sh;
output [a_width-1:0] b;
output stk;

  // synopsys translate_off

  //-------------------------------------------------------------------------
  // Parameter legality check
  //-------------------------------------------------------------------------
  
 
  initial begin : parameter_check
    integer param_err_flg;

    param_err_flg = 0;
    
  
    if (a_width < 1) begin
      param_err_flg = 1;
      $display(
	"ERROR: %m :\n  Invalid value (%d) for parameter a_width (lower bound: 1)",
	a_width );
    end
  
    if (sh_width < 1) begin
      param_err_flg = 1;
      $display(
	"ERROR: %m :\n  Invalid value (%d) for parameter sh_width (lower bound: 1)",
	sh_width );
    end
  
    if ( param_err_flg == 1) begin
      $display(
        "%m :\n  Simulation aborted due to invalid parameter value(s)");
      $finish;
    end

  end // parameter_check 


reg [a_width-1:0] a_shifted;
reg stk_int;
integer i;

 always @ (a or sh)
  begin
    a_shifted = a;
    stk_int = 1'b0;
    if (sh != 0)
      begin
        for (i=0;i<sh;i=i+1) begin
          stk_int = stk_int | a_shifted[0];
          a_shifted = a_shifted >> 1;
        end
      end
  end

 assign stk = stk_int;
 assign b = a_shifted;

  // synopsys translate_on

endmodule

