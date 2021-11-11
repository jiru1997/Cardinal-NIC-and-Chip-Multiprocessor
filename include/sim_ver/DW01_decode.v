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
// AUTHOR:    Poliakov
//
// VERSION:   Simulation Architecture
//
// DesignWare_version: a892be04
// DesignWare_release: K-2015.06-DWBB_201506.5.2
//
////////////////////////////////////////////////////////////////////////////////
//-----------------------------------------------------------------------------------
//
// ABSTRACT:  Decrementer
//           The n-bit address A decodes to 2**n lines.
//           The selected bit in port B is active high.
//
//           eg. n=3
//           A(2:0)        B(7:0)
//           000        -> 00000001
//           001        -> 00000010
//           010        -> 00000100
//           011        -> 00001000
//           100        -> 00010000
//           101        -> 00100000
//           110        -> 01000000
//           111        -> 10000000
//
//
// MODIFIED:
//
//        RPH        07/17/2002 
//                   Rewrote to comply with the new guidelines   
//-------------------------------------------------------------------------------


module DW01_decode(A,B);

   parameter width = 3;
   
   // port list declaration in order
   input [width-1:0] A;
   
   output [(1 << width)-1:0] B;

  // include modeling functions
  `include "DW01_decode_function.inc"     
   
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


      assign B = ((^(A ^ A) !== 1'b0) ) ? {(1 <<width){1'bx}} : DWF_decode(A);

   // synopsys translate_on
   
endmodule //dw01_decode

