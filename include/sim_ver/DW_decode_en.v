////////////////////////////////////////////////////////////////////////////////
//
//       This confidential and proprietary software may be used only
//     as authorized by a licensing agreement from Synopsys Inc.
//     In the event of publication, the following notice is applicable:
//
//                    (C) COPYRIGHT 2008 - 2016 SYNOPSYS INC.
//                           ALL RIGHTS RESERVED
//
//       The entire notice above must be reproduced on all authorized
//     copies.
//
// AUTHOR:    Alex Tenca  Feb. 05, 2008
//
// VERSION:   Verilog Simulation Model
//
// DesignWare_version: 2f496d5d
// DesignWare_release: K-2015.06-DWBB_201506.5.2
//
////////////////////////////////////////////////////////////////////////////////
//-----------------------------------------------------------
//
// ABSTRACT: Simulation model of DW_decode_en 
//
// MODIFIED:
//
//-----------------------------------------------------------

module DW_decode_en (en, a, b);
parameter width=3;

// declaration of inputs and outputs
input  en;
input  [width-1:0] a;
output [(1 << width)-1:0] b;

// synopsys translate_off
  //-------------------------------------------------------------------------
  // Parameter legality check
  //-------------------------------------------------------------------------
  
 
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


assign b = ((^(a ^ a) !== 1'b0) || (^(en ^ en) !== 1'b0)) ? {(1 << width){1'bX}} :
	   (en == 1) ? (1 << a) : 0;     


// synopsys translate_on

endmodule
