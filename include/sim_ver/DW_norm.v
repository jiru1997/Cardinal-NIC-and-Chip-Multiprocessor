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
// VERSION:   Simulation Architecture for DW_norm
//
// DesignWare_version: 5f92c0a4
// DesignWare_release: K-2015.06-DWBB_201506.5.2
//
////////////////////////////////////////////////////////////////////////////////
//-------------------------------------------------------------------------------
//
// ABSTRACT:  Normalization unit
//           This component shifts the input bit vector to the left till
//           the resulting vector has a 1 in the MS bit position. Parameters
//	     control the size of the input and output and the search limit
//           for the MS 1 bit. The input and output must be of the same   
//           size. 
//
// MODIFIED:  1/09/2006 - AFT - index stays at the maximum value when there is no value
//                         1 in the search window.
//            9/30/2008 - AFT - Modified to have the number of shifted bit positions during 
//                         normalization added (exp_ctr=0) or subtracted (exp_ctr=1) 
//                         to become the value of exp_adj
//            6/19/2012 - RJK - dded parameter checking for exp_width as it relates
//                         to srch_wind (STAR 9000541092)
//            8/10/2012 - AFT - fixed lint errors
//
//-------------------------------------------------------------------------------

module DW_norm(a, exp_offset, no_detect, ovfl, b, exp_adj);
  parameter a_width=8;
  parameter srch_wind=8;
  parameter exp_width=4;
  parameter exp_ctr=0;

  input [a_width-1:0] a;
  input [exp_width-1:0] exp_offset;
   
  output no_detect;
  output ovfl;
  output [a_width-1:0] b;
  output [exp_width-1:0] exp_adj;

  // synopsys translate_off

// include modeling functions
//  `include "DW_norm_function.inc"  
 
      
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
    
    if (exp_ctr < 0) begin
      param_err_flg = 1;
      $display(
	"ERROR: %m :\n  Invalid value (%d) for parameter exp_ctr (lower bound: 0)",
	exp_ctr );
    end     
    
    if ( (1 << exp_width) < srch_wind ) begin
      param_err_flg = 1;
      $display(
	"ERROR: %m : Invalid combination of srch_wind and exp_width values.  The srch_wind value cannot exeed 2**exp_width value." );
    end
    
    if ( param_err_flg == 1) begin
      $display(
        "%m :\n  Simulation aborted due to invalid parameter value(s)");
      $finish;
    end

  end // parameter_check 
  

// function that detects the MS 1 bit in the window given by srch_wind
// returns the number of bits that are zeros on the MS bit positions
// The exp_width must be at least log2(srch_wind)+1
function[a_width-1:0] ms_one_index;

 input  [a_width-1:0] a;

 begin // search for the MS 1 in the search window...
   ms_one_index = 0;
   while (a[a_width-1-ms_one_index] == 1'b0 && 
	  ms_one_index < a_width-1 && 
          ms_one_index < srch_wind-1) 
   begin
      ms_one_index = ms_one_index + 1;
   end  // while
 end

endfunction

wire [a_width-1:0] Index;
wire [a_width+exp_width-1:0] Index_ext;
wire [a_width+exp_width-1:0] exp_offset_ext;
wire [exp_width-1:0] adjusted_offset;
wire [a_width+exp_width-1:0] adjusted_offset_ext;
wire ovfl_int;

  assign Index = ms_one_index(a);
  assign Index_ext = Index;
  assign exp_offset_ext = exp_offset;
  assign adjusted_offset_ext = (exp_ctr==1)?(exp_offset_ext - Index_ext) : (exp_offset_ext + Index_ext);
  assign adjusted_offset = adjusted_offset_ext[exp_width-1:0];
  assign exp_adj =  ((^(a ^ a) !== 1'b0) || (^(exp_offset ^ exp_offset) !== 1'b0)) ? {exp_width{1'bx}} : adjusted_offset;
  assign b = ((^(a ^ a) !== 1'b0) || (^(exp_offset ^ exp_offset) !== 1'b0)) ? {exp_width+1{1'bx}} : a << Index;
  assign no_detect = ((^(a ^ a) !== 1'b0) || (^(exp_offset ^ exp_offset) !== 1'b0)) ? 1'bx : 
	    	        (a[a_width-1-Index]==1'b0) ? 1'b1: 1'b0;
  assign ovfl_int = (exp_ctr==1) ? ((adjusted_offset > exp_offset) ? 1'b1 : 1'b0) :
	            (((adjusted_offset<exp_offset)&&(adjusted_offset<Index))? 1'b1 : 1'b0);

  assign ovfl = ((^(a ^ a) !== 1'b0) || (^(exp_offset ^ exp_offset) !== 1'b0)) ? 1'bx : ovfl_int;

 // synopsys translate_on

endmodule

