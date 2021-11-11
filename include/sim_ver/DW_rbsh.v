////////////////////////////////////////////////////////////////////////////////
//
//       This confidential and proprietary software may be used only
//     as authorized by a licensing agreement from Synopsys Inc.
//     In the event of publication, the following notice is applicable:
//
//                    (C) COPYRIGHT 2005 - 2016 SYNOPSYS INC.
//                           ALL RIGHTS RESERVED
//
//       The entire notice above must be reproduced on all authorized
//     copies.
//
// AUTHOR:    Alexandre F. Tenca
//
// VERSION:   Verilog Simulation Architecture
//
// DesignWare_version: e98a1e70
// DesignWare_release: K-2015.06-DWBB_201506.5.2
//
////////////////////////////////////////////////////////////////////////////////

//----------------------------------------------------------------------------
// ABSTRACT:  Bidirectional Barrel Shifter - Prefers Left direction
//           This component performs left and right rotation.  
//           When SH_TC = '0', the rotation coefficient SH is interpreted as a
//	     positive unsigned number and only left rotation is performed.
//           When SH_TC = '1', the rotation coefficient SH is interpreted as a 
//           signed two's complement number. A negative coefficient indicates
//           a right rotation and a positive coefficient indicates a left rotation.
//           The input data A is always considered as a simple bit vector (unsigned).
//
// MODIFIED:  
//
//----------------------------------------------------------------------------


module DW_rbsh (A, SH, SH_TC, B);

   parameter A_width = 8 ;
   parameter SH_width = 3;

   // port list declaration in order
   input [ A_width- 1: 0] A;
   input [ SH_width- 1: 0] SH;
   input SH_TC;
   
   output [ A_width- 1: 0] B;
   
   // include modeling functions
   `include "DW_rbsh_function.inc"  
 
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

      
   assign B = ((SH_TC === 1'bx) | ((^(SH ^ SH) !== 1'b0))) ? {A_width{1'bx}} : 
              ((SH_TC === 1'b0) | (SH[SH_width-1] === 1'b0)) ? DWF_rbsh_uns(A, SH) :
              DWF_rbsh_tc(A,SH);
   
   // synopsys translate_on
   
endmodule // DW_rbsh


