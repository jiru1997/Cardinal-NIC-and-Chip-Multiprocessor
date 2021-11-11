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
// DesignWare_version: 7663ee49
// DesignWare_release: K-2015.06-DWBB_201506.5.2
//
////////////////////////////////////////////////////////////////////////////////
//-----------------------------------------------------------------------------------
//
// ABSTRACT:  6-Function Comparator
//           GT: A > B
//           LT: A < B
//           EQ: A = B
//           LE: A =< B
//           GE: A >= B
//           NE: A /= B
//           When TC  = 0   Unsigned numbers
//           When TC  = 1   Two's - complement numbers
// MODIFIED: Sourabh    Dec 22, 1998
//           Added functionality for X/Z handling
//           RPH        07/17/2002 
//                      Rewrote to comply with the new guidelines
//
//           dougl      12/15/04
//                      Fixed decoding of x's from "-1" to "3".
//-------------------------------------------------------------------------------
module DW01_cmp6
  (A, B, TC, LT, GT, EQ, LE, GE, NE);

  parameter width = 8;

  // port list declaration in order
  input [ width- 1: 0] A, B;
  input TC; // 1 => 2's complement numbers
   
  output LT; 
  output GT;
  output EQ;
  output LE;
  output GE;
  output NE;
  
   // synopsys translate_off

   wire[1:0] result;
   
    function is_less;
    parameter sign = width - 1;
    input [width-1 : 0]  A, B;
    input TC; //Flag of Signed
    reg	a_is_0, b_is_1, result ;
    integer i;
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
	  end else begin
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
    endfunction // ;

   function [1:0] eq_lt_gt;
      input [width-1 : 0] A, B;
      input 		  TC; //Flag of Signed
      reg[1:0]		  result;
      begin
	 if ((TC === 1'bx) | (^A) === 1'bx | (^B) === 1'bx)
	    result = 3;
	 else if (A === B)
	    result = 0;
	 else if (is_less(A,B,TC) === 1)
	    result = 1;
	 else
	    result = 2;
	 eq_lt_gt = result;
      end
   endfunction // eq_lt_gt
 
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

       
   assign result = eq_lt_gt(A,B,TC);
   
   assign GT =  (result === 3)  ? 1'bx :
		(result === 0 | result === 1) ? 1'b0 : 1'b1;
   assign LT =  (result === 3)  ? 1'bx :
		(result === 0 | result === 2) ? 1'b0 : 1'b1;
   assign EQ =  (result === 3)  ? 1'bx :
		(result === 1 | result === 2) ? 1'b0 : 1'b1;
   assign LE =  (result === 3)  ? 1'bx :
		(result === 0 | result === 1) ? 1'b1 : 1'b0;
   assign GE =  (result === 3)  ? 1'bx :
		(result === 0 | result === 2) ? 1'b1 : 1'b0;
   assign NE =  (result === 3)  ? 1'bx :
		(result === 1 | result === 2) ? 1'b1 : 1'b0;
 // synopsys translate_on
   
endmodule // sim;

