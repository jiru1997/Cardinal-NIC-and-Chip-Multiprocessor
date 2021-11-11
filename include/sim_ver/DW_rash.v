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
// AUTHOR:    Alexandre Tenca
//
// VERSION:   Simulation Architecture
//
// DesignWare_version: 0ef04971
// DesignWare_release: K-2015.06-DWBB_201506.5.2
//
////////////////////////////////////////////////////////////////////////////////
//----------------------------------------------------------------------------
//
// ABSTRACT: Arithmetic Shifter with preferred right direction - DW_rash
//           This component performs left and right shifting.  
//           When SH_TC = '0', the shift coefficient SH is interpreted as a
//	     positive unsigned number and only right shifts are performed.
//           When SH_TC = '1', the shift coefficient SH is a signed two's 
//           complement number. A negative coefficient indicates
//           a left shift (multiplication) and a positive coefficient indicates
//           a right shift (division).
//           The input data A can also be interpreted as an unsigned or signed
//           number.  When DATA_TC = '0', a logical shift operation is performed on A.  
//           When DATA_TC = '1', a arithmetic shift operation is performed on A.
//           The logical or arithmetic shift is performed on A independent of its 
//           data type (signed or unsigned).
//
// MODIFIED: 
//
//
//----------------------------------------------------------------------------
module DW_rash(A, DATA_TC, SH, SH_TC, B);
  parameter A_width=4;
  parameter SH_width=2;

  input [A_width-1:0] A;
  input [SH_width-1:0] SH;
  input DATA_TC, SH_TC;
   
  output [A_width-1:0] B;

  // include modeling functions
  `include "DW_rash_function.inc"  
 
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


   assign B = ((SH_TC === 1'bx) |
                ((DATA_TC === 1'bx) & (SH[SH_width-1] === 1'b1)) |
                ((^SH) === 1'bx) ) ? {A_width{1'bx}} :
              ((DATA_TC == 1'b0) & ((SH_TC === 1'b0) | (SH[SH_width-1] === 1'b0)) ) ? DWF_rash_uns_uns(A, SH) :
              ((DATA_TC == 1'b1) & ((SH_TC === 1'b0) | (SH[SH_width-1] === 1'b0)) ) ? DWF_rash_tc_uns(A,SH) :
              ((DATA_TC == 1'b0) & (SH_TC === 1'b1)) ? DWF_rash_uns_tc(A,SH) :
              DWF_rash_tc_tc(A,SH);
  // synopsys translate_on

endmodule

