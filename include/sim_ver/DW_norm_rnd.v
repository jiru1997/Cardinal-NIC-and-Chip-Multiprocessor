////////////////////////////////////////////////////////////////////////////////
//
//       This confidential and proprietary software may be used only
//     as authorized by a licensing agreement from Synopsys Inc.
//     In the event of publication, the following notice is applicable:
//
//                    (C) COPYRIGHT 2004 - 2016 SYNOPSYS INC.
//                           ALL RIGHTS RESERVED
//
//       The entire notice above must be reproduced on all authorized
//     copies.
//
// AUTHOR:    Alexandre Tenca
//
// VERSION:   Simulation Architecture
//
// DesignWare_version: 03d6bdb8
// DesignWare_release: K-2015.06-DWBB_201506.5.2
//
////////////////////////////////////////////////////////////////////////////////
//-------------------------------------------------------------------------------
//
// ABSTRACT:  Normalization and Rounding unit
//           This component generates a normalized and rounded value from an 
//           initial input in the form x.xxxxxxx (1 integer bit and k fractional
//           bits). The module has the following inputs:
//            * Main input (a_mag) to be normalized and rounded to n < k-1 fractional bits
//            * pos_offset: number of bit positions that the binary point in the input
//              had to be adjusted in order to be in the appropriate format.
//            * sticky_bit: 1 when some bit after the LS bit in the main input has 
//              a 1 (in the infinite precision representation of the input A).
//            * a_sign: Sign of the number being rounded (0 - positive, 1 - negative)
//            * Rnd_mode: Type of rounding to be performed. The options are:
//               - RNE - Round to the nearest even
//               - Rzero - Round toward zero
//               - Rposinf - Round toward positive infinity
//               - Rneginf - Round toward negative infinity
//               - Rup - Round to the nearest up
//               - Raway - Round away from zero.
//           The module has the following parameters:
//            * Input width (number of fractional bits) = a_width
//            * Output width (number of fractional bits) = b_width
//            * srch_wind: number of bits that the unit should look for the MS 1
//            * exp_widht: number of bits used in the pos_offset input and the pos output
//           It is imposed that b_width < a_width - srch_wind - 1 for proper 
//           rounding. It is also assumed that all the bits applied as input are
//           correct (correspond to the same bits in an infinite precision 
//           representation of the Main input (a_mag))  
//           The module outpus are:
//            * b - normalized and rounded result
//            * pos - Exponent correction value. This output accounts for the 
//                    Offset input and any changes in the value during normalization
//                    and rounding.
//            * no_detect - 1 when the normalization was not possible with the
//                    search window provided as parameter. Input is unexpected or
//                    the input represents a denormal value.
//            * pos_err - 1 when there is an overflow in the computation of the
//                    exponent adjustment value. Overflow may happen during 
//                    normalization or during rounding phase.
//
// MODIFIED:
//           10/25: depending on the new parameter exp_ctr, the output pos will
//           have the value: pos_pffset+shifted_norm-1_bit_post_round when
//           when exp_ctr=0 (previous bahavior) or will have the value:
//           pos_offset-shifted_norm-1_bit_post_round when exp_ctr=1
//           Where shifter_pos_norm corresponds to the number of bit positions
//           shifted during normalization and 1_bit_post_round corresponds
//           to the correction of 1 when post-round normalization is required
//
//-------------------------------------------------------------------------------

module DW_norm_rnd(a_mag, pos_offset, sticky_bit, a_sign, rnd_mode, pos_err, 
                   no_detect, b, pos);
  parameter a_width=16;
  parameter srch_wind=4;
  parameter exp_width=4;
  parameter b_width=10;
  parameter exp_ctr=0;

  input [a_width-1:0] a_mag;
  input [exp_width-1:0] pos_offset;
  input  sticky_bit;
  input  a_sign;
  input  [2:0] rnd_mode;
  
  output pos_err;
  output no_detect;
  output [b_width-1:0] b;
  output [exp_width-1:0] pos;

  // include modeling functions
//  `include "DW_norm_function.inc"  
 
  // synopsys translate_off
      
  //-------------------------------------------------------------------------
  // Parameter legality check
  //-------------------------------------------------------------------------

    
 
  initial begin : parameter_check
    integer param_err_flg;

    param_err_flg = 0;
    
    
    if (a_width < 2) begin
      param_err_flg = 1;
      $display(
	"ERROR: %m :\n  Invalid value (%d) for parameter a_width (lower bound: 2)",
	a_width );
    end
    
    if (srch_wind < 1) begin
      param_err_flg = 1;
      $display(
	"ERROR: %m :\n  Invalid value (%d) for parameter srch_wind (lower bound: 1)",
	srch_wind );
    end     
    
    if (exp_width < 1) begin
      param_err_flg = 1;
      $display(
	"ERROR: %m :\n  Invalid value (%d) for parameter exp_width (lower bound: 1)",
	exp_width );
    end     
    
    if (b_width < 2) begin
      param_err_flg = 1;
      $display(
	"ERROR: %m :\n  Invalid value (%d) for parameter b_width (lower bound: 2)",
	b_width );
    end     
    
    if ( param_err_flg == 1) begin
      $display(
        "%m :\n  Simulation aborted due to invalid parameter value(s)");
      $finish;
    end

  end // parameter_check 
  

// function that detects the MS 1 bit in the window given by srch_wind
// returns the number of bits that are zeros on the MS bit positions
// The exp_width must be at least log2(srch_wind)+1 to avoid overflow
function[a_width-1:0] num_MS_zeros;

 input  [a_width-1:0] A;

 begin // search for the MS 1 in the search window...
   num_MS_zeros = 0;
   while (A[a_width-1-num_MS_zeros] == 1'b0 && 
	  num_MS_zeros < a_width-1 && 
          num_MS_zeros < srch_wind-1) 
   begin
      num_MS_zeros = num_MS_zeros + 1;
   end  // while
 end
 
endfunction

wire [a_width-1:0] Index;
wire [exp_width-1:0] adjusted_offset;
wire [a_width-1:0] A_norm;
wire overflow_norm;
wire overflow_rounding;
wire overflow_expo_corrected;
wire [exp_width-1:0] Exp_adjustment;
wire [exp_width:0] corrected_expo;
wire [exp_width:0] zero_vector_e;
wire [exp_width:0] one_vector_e;
wire [b_width:0] zero_vector_b;
wire [b_width:0] one_vector_b;
wire rnd; // value added to the normalized input - based on rounding mode
wire R; // bits used in the rounding procedure
wire L;
wire T; 
wire [b_width:0] A_rounded;
wire ovfl_int;

  assign Index = num_MS_zeros (a_mag);
  assign adjusted_offset = (exp_ctr==1)?(pos_offset - Index) : (pos_offset + Index);
  assign Exp_adjustment = ((^(a_mag ^ a_mag) !== 1'b0) || (^(a_sign ^ a_sign) !== 1'b0) || (^(pos_offset ^ pos_offset) !== 1'b0)) ? {exp_width+1{1'bx}} : adjusted_offset; 
  assign A_norm =  ((^(a_mag ^ a_mag) !== 1'b0) || (^(a_sign ^ a_sign) !== 1'b0) || (^(pos_offset ^ pos_offset) !== 1'b0)) ? {exp_width+1{1'bx}} : a_mag << Index;
  assign no_detect = ((^(a_mag ^ a_mag) !== 1'b0) || (^(a_sign ^ a_sign) !== 1'b0) || (^(pos_offset ^ pos_offset) !== 1'b0) ) ? 1'bx :
	    	        (a_mag[a_width-1-Index] == 1'b0) ? 1'b1 : 1'b0;
  assign ovfl_int = (exp_ctr==1) ? ((adjusted_offset > pos_offset) ? 1'b1 : 1'b0) :
	            (((adjusted_offset<pos_offset)&&(adjusted_offset<Index))? 1'b1 : 1'b0);
  assign overflow_norm =  ((^(a_mag ^ a_mag) !== 1'b0) || (^(a_sign ^ a_sign) !== 1'b0) || (^(pos_offset ^ pos_offset) !== 1'b0)) ? 
				{exp_width+1{1'bx}} : ovfl_int;

// include the rouding logic
  assign zero_vector_e = {exp_width+1{1'b0}};
  assign zero_vector_b = {b_width+1{1'b0}};
  assign one_vector_e =  {{exp_width{1'b0}},1'b1};
  assign one_vector_b =  {{b_width{1'b0}},1'b1};
  assign corrected_expo =  (exp_ctr==1)?
			   {1'b0,Exp_adjustment} + {{exp_width{1'b0}},overflow_rounding}:
			   {1'b0,Exp_adjustment} - {{exp_width{1'b0}},overflow_rounding};
  assign pos = ((^(a_mag ^ a_mag) !== 1'b0) || (^(a_sign ^ a_sign) !== 1'b0) || (^(pos_offset ^ pos_offset) !== 1'b0) ) ? {exp_width{1'bx}} : corrected_expo[exp_width-1:0];
  assign overflow_expo_corrected =  corrected_expo[exp_width];
  assign pos_err = overflow_norm ^ overflow_expo_corrected;
// if any other bits are left in the LS bit positions after normalization, combine then with the
// Sticky bit.
  assign T = (a_width > b_width+1) ? sticky_bit || |(A_norm[a_width-b_width-2:0]) : sticky_bit;
  assign R = (a_width > b_width) ? A_norm[a_width-b_width-1]:1'b0; 
  assign L = (a_width > b_width-1) ? A_norm[a_width-b_width]:1'b0;
  assign rnd = ((^(a_mag ^ a_mag) !== 1'b0) || (^(pos_offset ^ pos_offset) !== 1'b0) || (^(sticky_bit ^ sticky_bit) !== 1'b0) || (^(a_sign ^ a_sign) !== 1'b0)) ? 1'bx : 
               (rnd_mode == 3'd0) ? R && (L || T) :   
               (rnd_mode == 3'd1) ? 1'b0 :    
               (rnd_mode == 3'd2) ? !a_sign && (R || T) :
               (rnd_mode == 3'd3) ? a_sign && (R || T) :
               (rnd_mode == 3'd4) ? R :
               (rnd_mode == 3'd5) ? R || T : 1'bx;
  assign A_rounded = {1'b0, A_norm[a_width-1:a_width-b_width]} + {{b_width{1'b0}},rnd};
  assign b = ((^(a_mag ^ a_mag) !== 1'b0) || (^(pos_offset ^ pos_offset) !== 1'b0) || (^(sticky_bit ^ sticky_bit) !== 1'b0) || (^(a_sign ^ a_sign) !== 1'b0)) ? {b_width{1'bx}} :  
             (overflow_rounding == 1'b0) ? A_rounded[b_width-1:0] :
             {1'b1, {b_width-1{1'b0}}}; // detects the special case of post-normalization 
  assign overflow_rounding = A_rounded[b_width];

 // synopsys translate_on

endmodule

