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
// AUTHOR:    PS			Nov. 8, 1992
//
// VERSION:   Simulation Architecture
//
// DesignWare_version: f1632608
// DesignWare_release: K-2015.06-DWBB_201506.5.2
//
////////////////////////////////////////////////////////////////////////////////
//-----------------------------------------------------------------------------------
//
// ABSTRACT:  Adder-Subtractor
//           ADD_SUB= '1' : SUM <= A - B - CI
//           ADD_SUB= '0' : SUM <= A + B + CI
//           Carry-in and Carry-out is active high with both addition 
//           and subtraction.
// MODIFIED:  Sheela    May 11, 1995 
//                      Converted to verilog from vhdl
//            GN 
//                      changed dw01 to DW01 star 33068
//
//	      Bob Tong: 12/02/98  	
//                      STAR 59142
//
//	      Bob Tong: 03/03/2000	
//                      STAR 99907
//
//           RPH        07/17/2002 
//                          Rewrote to comply with the new guidelines
//     
//---------------------------------------------------------------------

module DW01_addsub (A,B,CI,ADD_SUB,SUM,CO);

  parameter width = 4;

  // port list declaration in order
  input   [width-1 : 0]     A, B;
  input                     CI, ADD_SUB;
   
  output  [width-1 : 0]     SUM;
  output                    CO;
   
  // synopsys translate_off
  wire [width : 0]      tmp_out;   
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


  assign tmp_out = ((^(A ^ A) !== 1'b0) || (^(B ^ B) !== 1'b0) || (^(ADD_SUB ^ ADD_SUB) !== 1'b0)) ? {width+1{1'bx}} 
		   : ADD_SUB ? A-B-CI : A+B+CI;
  assign CO = tmp_out[width];
  assign SUM = tmp_out[width-1 : 0];

  // synopsys translate_on
   
endmodule
