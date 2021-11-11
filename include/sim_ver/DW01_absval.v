////////////////////////////////////////////////////////////////////////////////
//
//       This confidential and proprietary software may be used only
//     as authorized by a licensing agreement from Synopsys Inc.
//     In the event of publication, the following notice is applicable:
//
//                    (C) COPYRIGHT 1994  - 2016 SYNOPSYS INC.
//                           ALL RIGHTS RESERVED
//
//       The entire notice above must be reproduced on all authorized
//     copies.
//
// AUTHOR:    Igor Kurilov
//
// VERSION:   Simulation Architecture
//
// DesignWare_version: 47070cbe
// DesignWare_release: K-2015.06-DWBB_201506.5.2
//
////////////////////////////////////////////////////////////////////////////////
//-----------------------------------------------------------------------------------
//
// ABSTRACT: Absolute Value
//           This operator assumes that the input A is coded as a two's complement
//           number.  The sign std_logic A(n-1) determines whether the input is positive
//           or negative.
//
//           A(n-1)     ABSVAL
//           -------+----------
//            '0'   |    A
//            '1'   |   -A
//
//           The value -A is computed as (A') + '1'
//
// MODIFIED: RPH        07/17/2002 
//                      Rewrote to comply with the new guidelines
//   
//-------------------------------------------------------------------------------

module DW01_absval (A, ABSVAL);

  parameter width = 8;

  input  [width-1 : 0] A;
   
  output [width-1 : 0] ABSVAL;
   
  // include modeling functions
  `include "DW01_absval_function.inc"  
 
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


  assign ABSVAL = ((^(A ^ A) !== 1'b0)) ? {width{1'bx}} : DWF_absval(A);

  // synopsys translate_on
		   
endmodule // DW01_absval
