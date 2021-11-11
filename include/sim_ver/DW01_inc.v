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
// AUTHOR:    PS
//
// VERSION:   Simulation Architecture
//
// DesignWare_version: 5ab46097
// DesignWare_release: K-2015.06-DWBB_201506.5.2
//
////////////////////////////////////////////////////////////////////////////////
//-----------------------------------------------------------------------------------
//
// ABSTRACT:  Incrementer
//
// MODIFIED: 
//
//       Sheela      May 12,1995
//                   Converted from vhdl to verilog
//
//       GN          Feb. 15, 1996 
//                   changed dw01 to DW01 star 33068
//
//        RPH        07/17/2002 
//                   Rewrote to comply with the new guidelines    
//--------------------------------------------------------------------------

module DW01_inc ( A, SUM );
   
    parameter width=4;

    // port list declaration in order
    input    [ width-1 : 0]  A;
 
    output   [ width-1 : 0]  SUM;  

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


   assign SUM = ((^(A ^ A) !== 1'b0) ) ? {width{1'bx}} : A-{width{1'b1}};
   
   // synopsys translate_on
endmodule // DW01_inc;
