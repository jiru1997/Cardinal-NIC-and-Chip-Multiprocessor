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
// AUTHOR:    Anatoly Sokhatsky
//
// VERSION:   Simulation Architecture
//
// DesignWare_version: c35d00d4
// DesignWare_release: K-2015.06-DWBB_201506.5.2
//
////////////////////////////////////////////////////////////////////////////////
//-----------------------------------------------------------------------------------
//
// ABSTRACT:  2-Function Comparator
//           When LEQ = 1   LT_LE: A =< B
//                          GE_GT: A > B
//           When LEQ = 0   LT_LE: A < B
//                          GE_GT: A >= B
//           When TC  = 0   Unsigned numbers
//           When TC  = 1   Two's - complement numbers
//
// MODIFIED: 
//           Sourabh        Dec. '98. 
//                          Added functionality for X/Z handling.
//   
//           RPH            07/17/2002 
//                          Rewrote to comply with the new guidelines   
//-------------------------------------------------------------------------------
module DW01_cmp2
  (A, B, LEQ, TC, LT_LE, GE_GT);

  parameter width = 8; 

  // port list declaration in order
  input [ width- 1: 0] A, B;
  input LEQ; // 1 => LEQ/GT 0=> LT/GEQ
  input TC; // 1 => 2's complement numbers
   
  output LT_LE;
  output GE_GT;

   // synopsys translate_off
    function is_less;
      parameter sign = width - 1;
      input [width-1 : 0] A, B;
      input 		  TC; //Flag of Signed
      reg 		  a_is_0, b_is_1, result ;
      integer 		  i;
      begin
	 if ( TC === 1'b0 ) begin  // unsigned numbers
	    result = 0;
	    for (i = 0; i <= sign; i = i + 1) begin
	       a_is_0 = A[i] === 1'b0;
	       b_is_1 = B[i] === 1'b1;
	       result = (a_is_0 & b_is_1) |
			(a_is_0 & result) |
			(b_is_1 & result);
	    end // loop
	 end else begin  // signed numbers
	    if ( A[sign] !== B[sign] ) begin
	       result = A[sign] === 1'b1;
	    end 
	    else begin
	       result = 0;
	       for (i = 0; i <= sign-1; i = i + 1) begin
		  a_is_0 = A[i] === 1'b0;
		  b_is_1 = B[i] === 1'b1;
		  result = (a_is_0 & b_is_1) |
			   (a_is_0 & result) |
			   (b_is_1 & result);
	       end // loop
	    end // if
	 end // if
	 is_less = result;
      end
   endfunction //
   
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



  assign GE_GT = ( TC === 1'bx || LEQ === 1'bx || ((^A)^(^B)) === 1'bx ) ? 1'bx :
		 ( LEQ === 1'b1 ) ? (( is_less(A,B,TC) || A === B ) ? 1'b0 : 1'b1) :
		 (( is_less(B,A,TC) || A === B ) ? 1'b1 : 1'b0);
   
  assign LT_LE = ( TC === 1'bx || LEQ === 1'bx || ((^A)^(^B)) === 1'bx ) ? 1'bx :
		 ( LEQ === 1'b1 ) ? (( is_less(A,B,TC) || A === B ) ? 1'b1 : 1'b0) :
		 (( is_less(B,A,TC) || A === B ) ? 1'b0 : 1'b1); 
//synopsys translate_on
   
endmodule // sim;
