////////////////////////////////////////////////////////////////////////////////
//
//       This confidential and proprietary software may be used only
//     as authorized by a licensing agreement from Synopsys Inc.
//     In the event of publication, the following notice is applicable:
//
//                    (C) COPYRIGHT 2001 - 2016 SYNOPSYS INC.
//                           ALL RIGHTS RESERVED
//
//       The entire notice above must be reproduced on all authorized
//     copies.
//
// AUTHOR:    Reto Zimmermann    11/14/01
//
// VERSION:   Verilog Simulation Model for DW_inc_gray
//
// DesignWare_version: 0885e40b
// DesignWare_release: K-2015.06-DWBB_201506.5.2
//
////////////////////////////////////////////////////////////////////////////////
//-----------------------------------------------------------------------------
//
// ABSTRACT:  Gray incrementer
//
// MODIFIED:
//
//-----------------------------------------------------------------------------

module DW_inc_gray (a, ci, z);

  parameter width = 8;                  // word width

  input  [width-1 : 0] a;               // Gray input
  input  ci;                            // carry input
  output [width-1 : 0] z;               // Gray output


  // include modeling functions
`include "DW_inc_gray_function.inc"

  // synopsys translate_off


  //---------------------------------------------------------------------------
  // Parameter legality check
  //---------------------------------------------------------------------------

  
 
  initial begin : parameter_check
    integer param_err_flg;

    param_err_flg = 0;
    
    
    if (width < 1) begin
      param_err_flg = 1;
      $display(
	"ERROR: %m :\n  Invalid value (%d) for parameter width (lower bound: 1)",
	width );
    end
  
    if ( param_err_flg == 1) begin
      $display(
        "%m :\n  Simulation aborted due to invalid parameter value(s)");
      $finish;
    end

  end // parameter_check 


  //---------------------------------------------------------------------------
  // Behavioral model
  //---------------------------------------------------------------------------

  assign z = ((^(a ^ a) !== 1'b0) || (^(ci ^ ci) !== 1'b0) ) ? {width{1'bx}} : DWF_inc_gray (a, ci);

  // synopsys translate_on

endmodule

//-----------------------------------------------------------------------------
