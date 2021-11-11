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
// DesignWare_version: 1ecfa9e2
// DesignWare_release: K-2015.06-DWBB_201506.5.2
//
////////////////////////////////////////////////////////////////////////////////
//-------------------------------------------------------------------------------
//
// ABSTRACT: Inverse square-root B=(A)^{-1/2}
//           Computes the reciprocal of the square-root of A using a
//           digit recurrence algorithm. The recurrence equation is
//           W[j+1]=2W[j]-(2P[j]+A2^{-j-1})q_{j+1}
//           where P[j+1]=P[j]+Aq_{j+1}2^{-j-1}, and q_j is a bit.
//           The output is composed by the q_j bits as:
//                B=1.q_1q_2q_3....q_n
//           Input A must be in the range 1/4 < A < 1
//           Output B is in the range 1 < B < 2,  and t is the sticky bit
//           The prec_control parameter defines the number of bits that must
//           be discarded from the extra_bits used internally
//
// MODIFIED:
//           7/23/2015: Streamlined model
//           1/30/2007: Modified upper bound of prec_control and fixed problems
//                      when prec_control is not zero.
//           5/2010: allowed the use of negative prec_control and adjusted the 
//                   value of internal precision for some a_width values
//
//-------------------------------------------------------------------------------

module DW_inv_sqrt (a, b, t);
  parameter a_width=8;
  parameter prec_control=0;

  input [a_width-1:0] a;
   
  output [a_width-1:0] b;
  output t;

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
    
    if ( (prec_control > (a_width-2)/2) ) begin
      param_err_flg = 1;
      $display(
	"ERROR: %m : Invalid value for parameter prec_control (upper bound: (a_width-2)/2)" );
    end
    
    if ( param_err_flg == 1) begin
      $display(
        "%m :\n  Simulation aborted due to invalid parameter value(s)");
      $finish;
    end

  end // parameter_check 
  

`define extra_bits (a_width/2 + ((a_width==7)?1+((prec_control<0)?-prec_control:0):((a_width > 21 && a_width < 36)?3+((prec_control<0)?-prec_control:0):((a_width >= 36)?a_width/4+((prec_control<0)?-prec_control:0):((prec_control<0)?-prec_control:0)))))

reg [a_width-1:0] b_var;
reg               t_var;

localparam [a_width-1+`extra_bits:0] zero_vector = 0;
localparam [`extra_bits-1:0] zero_extra_vector = 0;
 
  
  always @ (a) begin : mk_inv_sqrt_PROC
    reg [a_width+1+`extra_bits:0] w_array  [a_width:0];
    reg [a_width+1+`extra_bits:0] p_array  [a_width:0];
    reg [a_width+1+`extra_bits:0] p_array1 [a_width:0];
    reg [a_width+1+`extra_bits:0] p_array2 [a_width:0];
    reg [a_width+1+`extra_bits:0] x_array  [a_width:0];
    reg [a_width+2+`extra_bits:0] wtemp;
    integer index;
    integer lsbits_deleted;

    w_array[0] = ({2'b01,zero_vector} - {2'b00,a,zero_extra_vector});
    p_array[0] = {2'b00,a,zero_extra_vector};
    x_array[0] = {2'b00,a,zero_extra_vector};
    b_var[a_width-1] = 1'b1;

    if (prec_control > 0)
      lsbits_deleted = prec_control;
    else
      lsbits_deleted = 0;
    
    for (index = 0; index < a_width-1; index=index+1)
      begin
	x_array[index+1] =  ( x_array[index] >> (1+lsbits_deleted) ) << lsbits_deleted;
	p_array1[index] = (((p_array[index] << 1) + x_array[index+1])>>lsbits_deleted) << lsbits_deleted;
	p_array2[index] = ((p_array[index] + x_array[index+1]) >> lsbits_deleted) << lsbits_deleted;
	wtemp = {w_array[index],1'b0} - {1'b0,p_array1[index]};
	b_var[a_width-index-2] = ~(wtemp[a_width+2+`extra_bits]);  
	if (wtemp[a_width+2+`extra_bits] == 1'b0)
	 begin
	  w_array[index+1] = wtemp;
	  p_array[index+1] = p_array2[index];
	 end
	else
	 begin
	  w_array[index+1] = w_array[index] << 1;
	  p_array[index+1] = p_array[index];
	 end
      end

    t_var = |w_array[a_width-1];
  end

// assign values to the output
assign b = ((^(a ^ a) !== 1'b0)) ? {a_width{1'bx}} : b_var;
assign t = ((^(a ^ a) !== 1'b0)) ? 1'bx : t_var;

 // synopsys translate_on

endmodule

