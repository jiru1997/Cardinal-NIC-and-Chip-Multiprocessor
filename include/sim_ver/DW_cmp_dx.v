////////////////////////////////////////////////////////////////////////////////
//
//       This confidential and proprietary software may be used only
//     as authorized by a licensing agreement from Synopsys Inc.
//     In the event of publication, the following notice is applicable:
//
//                    (C) COPYRIGHT 1998 - 2016 SYNOPSYS INC.
//                           ALL RIGHTS RESERVED
//
//       The entire notice above must be reproduced on all authorized
//     copies.
//
// AUTHOR:    Sourabh Tandon
//
// VERSION:   Simulation Architecture
//
// DesignWare_version: 46c1c9d3
// DesignWare_release: K-2015.06-DWBB_201506.5.2
//
////////////////////////////////////////////////////////////////////////////////
//-----------------------------------------------------------------------------------
//
// ABSTRACT:  Duplex Comparator
// MODIFIED :
//          RPH Aug 21, 2002    Added parameter checking
//
//-------------------------------------------------------------------------------
module DW_cmp_dx (a, b, tc, dplx, lt1, eq1, gt1, lt2, eq2, gt2);

  parameter width    = 8; 
  parameter p1_width = 4; 

  // port list declaration in order
  input [ width- 1: 0] a, b;
  input tc;
  input dplx;
   
  output lt1, eq1, gt1;
  output lt2, eq2, gt2;
  // synopsys translate_off

   wire  is_less_1, is_equal_1;
   wire  is_less_2, is_equal_2;
   reg [p1_width-1 :0] a_part_1, b_part_1;
   reg [width-p1_width-1 :0] a_part_2, b_part_2;
  
   integer 		     i;
   
   function is_less;
    input [width-1 : 0]  A, B;
    input TC; //Flag of Signed
    input [1:0] range;
    reg a_is_0, b_is_1, result ;
    integer i,sign;
    begin
        if ( range === 'b00)
           sign = width - 1;
        if ( range === 'b01)
           sign = p1_width - 1;
        if ( range === 'b10)
           sign = width - p1_width - 1;

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
   endfunction // is_less
   
   
  //---------------------------------------------------------------------------
  // Parameter legality check
  //---------------------------------------------------------------------------

  
 
  initial begin : parameter_check
    integer param_err_flg;

    param_err_flg = 0;
    
    
    if (width < 4) begin
      param_err_flg = 1;
      $display(
	"ERROR: %m :\n  Invalid value (%d) for parameter width (lower bound: 4)",
	width );
    end
    
    if ( (p1_width < 2) || (p1_width > width-2) ) begin
      param_err_flg = 1;
      $display(
	"ERROR: %m :\n  Invalid value (%d) for parameter p1_width (legal range: 2 to width-2)",
	p1_width );
    end
  
    if ( param_err_flg == 1) begin
      $display(
        "%m :\n  Simulation aborted due to invalid parameter value(s)");
      $finish;
    end

  end // parameter_check 


     always @ (a or b or tc or dplx) begin : a1000_PROC
	for ( i = 0; i < p1_width; i=i+1) begin
	   a_part_1[i] = a[i];
	   b_part_1[i] = b[i];
	end // for ( i = 0; i < width-p1_width; i=i+1)
	// 	
	for ( i = 0; i < width-p1_width; i=i+1) begin
	   a_part_2[i] = a[i+p1_width];
	   b_part_2[i] = b[i+p1_width];
	end // for ( i = 0; i < width-p1_width; i=i+1)
     end // always @ (a or b or tc or dplx)
   
	     
   assign is_less_1 = (dplx === 1'b0) ? is_less(a_part_1, b_part_1, 1'b0, 2'b01) :
			is_less(a_part_1, b_part_1, tc, 2'b01);
   assign is_equal_1 = (a_part_1 === b_part_1) ? 1'b1 : 1'b0;

   
   assign is_less_2 = (dplx === 1'b0) ? is_less(a, b, tc,2'b00) :
		      is_less(a_part_2, b_part_2, tc, 2'b10 );
   assign is_equal_2 =  (dplx === 1'b0) ? ((a === b) ? 1'b1 : 1'b0) :
			((a_part_2 === b_part_2) ? 1'b1: 1'b0);


   assign lt1 = ((^(tc ^ tc) !== 1'b0) | (^(a ^ a) !== 1'b0) | (^(b ^ b) !== 1'b0) | (^(tc ^ tc) !== 1'b0) | (^(dplx ^ dplx) !== 1'b0) ) ? 1'bx :
		(is_less_1 == 1'b1 & is_equal_1 == 1'b0) ? 1'b1 :
		1'b0;

   assign eq1 = ((^(tc ^ tc) !== 1'b0) | (^(a ^ a) !== 1'b0) | (^(b ^ b) !== 1'b0) | (^(tc ^ tc) !== 1'b0) | (^(dplx ^ dplx) !== 1'b0) ) ? 1'bx :
		(is_less_1 == 1'b0 & is_equal_1 == 1'b1) ? 1'b1 :
		1'b0;

   assign gt1 = ((^(tc ^ tc) !== 1'b0) | (^(a ^ a) !== 1'b0) | (^(b ^ b) !== 1'b0) | (^(tc ^ tc) !== 1'b0) | (^(dplx ^ dplx) !== 1'b0) ) ? 1'bx :
		(is_less_1 == 1'b0 & is_equal_1 == 1'b0) ? 1'b1 :
		1'b0;

   assign lt2 = ((^(tc ^ tc) !== 1'b0) | (^(a ^ a) !== 1'b0) | (^(b ^ b) !== 1'b0) | (^(tc ^ tc) !== 1'b0) | (^(dplx ^ dplx) !== 1'b0) ) ? 1'bx :
		(is_less_2 == 1'b1 & is_equal_2 == 1'b0) ? 1'b1 :
		1'b0;

   assign eq2 = ((^(tc ^ tc) !== 1'b0) | (^(a ^ a) !== 1'b0) | (^(b ^ b) !== 1'b0) | (^(tc ^ tc) !== 1'b0) | (^(dplx ^ dplx) !== 1'b0) ) ? 1'bx :
		(is_less_2 == 1'b0 & is_equal_2 == 1'b1) ? 1'b1 :
		1'b0;

   assign gt2 = ((^(tc ^ tc) !== 1'b0) | (^(a ^ a) !== 1'b0) | (^(b ^ b) !== 1'b0) | (^(tc ^ tc) !== 1'b0) | (^(dplx ^ dplx) !== 1'b0) ) ? 1'bx :
		(is_less_2 == 1'b0 & is_equal_2 == 1'b0) ? 1'b1 :
		1'b0;   
// synopsys translate_on
endmodule // sim;

