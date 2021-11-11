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
// AUTHOR:    PS
//
// VERSION:   Simulation Architecture
//
// DesignWare_version: e8538605
// DesignWare_release: K-2015.06-DWBB_201506.5.2
//
////////////////////////////////////////////////////////////////////////////////
//-----------------------------------------------------------------------------------
//
// ABSTRACT:  Priority Encoder
//
// MODIFIED: RPH Added X-handling and fixed STAR 60092 
//           RPH        07/17/2002 
//                      Rewrote to comply with the new guidelines
//           DLL        02/07/2005
//                      Changed INDEX_width param_lower_bound_check to
//                      param_general_check.
//--------------------------------------------------------------------------

module DW01_prienc (A, INDEX);
 
  parameter A_width = 8;
  parameter INDEX_width = 3;

  // port list declaration in order 
  input [A_width-1:0] A;
   
  output [INDEX_width-1:0] INDEX;
  // include modeling functions
  `include "DW01_prienc_function.inc"  
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
    
    if ( (A_width > (1 << INDEX_width)) ) begin
      param_err_flg = 1;
      $display(
	"ERROR: %m : INDEX_width must be at least ceil(log2[A_width])" );
    end
    
    if ( param_err_flg == 1) begin
      $display(
        "%m :\n  Simulation aborted due to invalid parameter value(s)");
      $finish;
    end

  end // parameter_check 

       
   assign INDEX = DWF_prienc(A);

   // synopsys translate_on 
endmodule


