////////////////////////////////////////////////////////////////////////////////
//
//       This confidential and proprietary software may be used only
//     as authorized by a licensing agreement from Synopsys Inc.
//     In the event of publication, the following notice is applicable:
//
//                    (C) COPYRIGHT 1992 - 2016 SYNOPSYS INC.
//                           ALL RIGHTS RESERVED
//
//       The entire notice above must be reproduced on all authorized
//     copies.
//
// AUTHOR:    Igor Oznobikhin
//
// VERSION:   Verilog Simulation Architecture
//
// DesignWare_version: 5ba473f0
// DesignWare_release: K-2015.06-DWBB_201506.5.2
//
////////////////////////////////////////////////////////////////////////////////

//----------------------------------------------------------------------------
//
// ABSTRACT:  Barrel Shifter
//
// MODIFIED:  Sitanshu Kumar   March 12th 1997
//	      Inserted a  missing ";" at line 26
//
//            Sourabh    Dec 22, 1998
//            Added functionality for X/Z handling
//           RPH        07/17/2002 
//                      Rewrote to comply with the new guidelines
//----------------------------------------------------------------------------


module DW01_bsh (A, SH, B);

   parameter A_width = 8 ;
   parameter SH_width = 3;

   // port list declaration in order
   input [ A_width- 1: 0] A;
   input [ SH_width- 1: 0] SH;
   
   output [ A_width- 1: 0] B;
   
   // include modeling functions
   `include "DW01_bsh_function.inc"  
 
   // synopsys translate_off
      
   //-------------------------------------------------------------------------
   // Parameter legality check
   //-------------------------------------------------------------------------

   
 
  initial begin : parameter_check
    integer param_err_flg;

    param_err_flg = 0;
    
   
    if (A_width < 2) begin
      param_err_flg = 1;
      $display(
	"ERROR: %m :\n  Invalid value (%d) for parameter A_width (lower bound: 2)",
	A_width );
    end
   
    if (SH_width < 1) begin
      param_err_flg = 1;
      $display(
	"ERROR: %m :\n  Invalid value (%d) for parameter SH_width (lower bound: 1)",
	SH_width );
    end   
   
    if ( param_err_flg == 1) begin
      $display(
        "%m :\n  Simulation aborted due to invalid parameter value(s)");
      $finish;
    end

  end // parameter_check 

      
   assign B = ((^(SH ^ SH) !== 1'b0)) ? {A_width{1'bx}} : DWF_bsh(A, SH);
   
   // synopsys translate_on
   
endmodule // DW01_bsh


