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
// AUTHOR:    KB WSFDB		June 30, 1994
//
// VERSION:   Simulation Architecture
//
// DesignWare_version: acbf175f
// DesignWare_release: K-2015.06-DWBB_201506.5.2
//
////////////////////////////////////////////////////////////////////////////////
//-----------------------------------------------------------------------------------
//
// ABSTRACT:  Multiplier
//           A_width-Bits * B_width-Bits => A_width+B_width Bits
//           Operands A and B can be either both signed (two's complement) or 
//	     both unsigned numbers. TC determines the coding of the input operands.
//           ie. TC = '1' => signed multiplication
//	         TC = '0' => unsigned multiplication
//
//	FIXED: by replacement with A tested working version
//		that not only doesn't multiplies right it does it
//		two times faster!
//  RPH 07/17/2002 
//      Rewrote to comply with the new guidelines
//------------------------------------------------------------------------------

module DW02_mult(A,B,TC,PRODUCT);
parameter	A_width = 8;
parameter	B_width = 8;
   
input	[A_width-1:0]	A;
input	[B_width-1:0]	B;
input			TC;
output	[A_width+B_width-1:0]	PRODUCT;

wire	[A_width+B_width-1:0]	PRODUCT;

wire	[A_width-1:0]	temp_a;
wire	[B_width-1:0]	temp_b;
wire	[A_width+B_width-2:0]	long_temp1,long_temp2;

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
    
    if (B_width < 1) begin
      param_err_flg = 1;
      $display(
	"ERROR: %m :\n  Invalid value (%d) for parameter B_width (lower bound: 1)",
	B_width );
    end 
  
    if ( param_err_flg == 1) begin
      $display(
        "%m :\n  Simulation aborted due to invalid parameter value(s)");
      $finish;
    end

  end // parameter_check 

     
assign	temp_a = (A[A_width-1])? (~A + 1'b1) : A;
assign	temp_b = (B[B_width-1])? (~B + 1'b1) : B;

assign	long_temp1 = temp_a * temp_b;
assign	long_temp2 = ~(long_temp1 - 1'b1);

assign	PRODUCT = ((^(A ^ A) !== 1'b0) || (^(B ^ B) !== 1'b0) || (^(TC ^ TC) !== 1'b0) ) ? {A_width+B_width{1'bX}} :
		  (TC)? (((A[A_width-1] ^ B[B_width-1]) && (|long_temp1))?
			 {1'b1,long_temp2} : {1'b0,long_temp1})
		     : A * B;
   // synopsys translate_on
endmodule


