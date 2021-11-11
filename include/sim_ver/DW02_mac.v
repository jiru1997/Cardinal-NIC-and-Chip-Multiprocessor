////////////////////////////////////////////////////////////////////////////////
//
//       This confidential and proprietary software may be used only
//     as authorized by a licensing agreement from Synopsys Inc.
//     In the event of publication, the following notice is applicable:
//
//                    (C) COPYRIGHT 1994 - 2016 SYNOPSYS INC.
//                           ALL RIGHTS RESERVED
//
//       The entire notice above must be reproduced on all authorized
//     copies.
//
// AUTHOR:    Anatoly Sokhatsky            July 13, 1994
//
// VERSION:   Simulation Architecture
//
// DesignWare_version: b19238c4
// DesignWare_release: K-2015.06-DWBB_201506.5.2
//
////////////////////////////////////////////////////////////////////////////////
//-----------------------------------------------------------------------------------
//
// ABSTRACT:  Multiplier-Accumulator
//           (A_width Bits * B_width Bits) + (A_width+B_width Bits)
//             => A_width+B_width Bits
//           signed or unsigned operands
//           ie. TC = '1' => signed
//	         TC = '0' => unsigned
//
//      
// MODIFIED :
//  GN                     
//      changed dw02 to DW02 (star 33068) remove $generic and 
//      $end_generic  define parameter a_width=8 define parameter 
//      b_width=8
//
//  RPH 07/17/2002 
//      Rewrote to comply with the new guidelines
//
   
//-------------------------------------------------------------------------------

module DW02_mac
  (A, B, C, TC, MAC);

  parameter A_width=8;
  parameter B_width=8;

  // port list declaration in order
  input [ A_width- 1: 0] A;
  input [ B_width- 1: 0] B;
  input [ A_width+B_width- 1: 0] C;
  input TC;
   
  output [ A_width+B_width- 1: 0] MAC;

  `include "DW02_mac_function.inc"

  // synopsys translate_off 
  //-------------------------------------------------------------------------
  // Parameter legality check
  //-------------------------------------------------------------------------

  
 
  initial begin : parameter_check
    integer param_err_flg;

    param_err_flg = 0;
    
    
    if (A_width < 1) begin
      param_err_flg = 1;
      $display(
	"ERROR: %m :\n  Invalid value (%d) for parameter A_width (lower bound: 1)",
	A_width );
    end
    
    if (B_width < 1) begin
      param_err_flg = 1;
      $display(
	"ERROR: %m :\n  Invalid value (%d) for parameter B_width (lower bound: 1)",
	B_width );
    end 
  
    if ( param_err_flg == 1) begin
      $display(
        "%m :\n  Simulation aborted due to invalid parameter value(s)");
      $finish;
    end

  end // parameter_check 


   assign MAC = ((^(A ^ A) !== 1'b0) || (^(B ^ B) !== 1'b0) || (^(C ^ C) !== 1'b0) || (^(TC ^ TC) !== 1'b0)) ? {A_width+B_width{1'bx}} :
		( TC === 1'b0 ) ? DWF_mac_uns(A, B, C) :
		DWF_mac_tc(A, B, C);

   // synopsys translate_on
endmodule // DW02_mac;
