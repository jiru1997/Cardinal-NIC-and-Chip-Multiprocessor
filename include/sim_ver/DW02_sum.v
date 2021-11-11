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
// AUTHOR:    Anatoly Sokhatsky          July 13, 1994
//
// VERSION:   Simulation Architecture
//
// DesignWare_version: 30239535
// DesignWare_release: K-2015.06-DWBB_201506.5.2
//
////////////////////////////////////////////////////////////////////////////////

//-----------------------------------------------------------------------------------
//
// ABSTRACT:  Vector Adder
//           number of inputs = 'num_inputs'
//           wordlenght of inputs and output = 'input_width'
//
//           Sum a number of input words together to form the outpus SUM
//           Since a variable number of input ports is not supported the
//           2-D array of inputs (num_inputs X input_width) is flattened into
//           a single 1-D array of length num_inputs*input_width bits.
//
// MODIFIED:
//         GN Feb. 16th , 1996
//         changed dw02 to DW02
//         remove $generic and $end_generic
//         defined parameter num_inputs=8;
//         defined parameter input_width=8
//         fix star 33068
//  RPH 07/17/2002 Added X-processing and parameter checking
//-------------------------------------------------------------------------------
module DW02_sum (INPUT, SUM);


  parameter num_inputs=8;
  parameter input_width=8;

  // port list declaration in order
  input [ num_inputs*input_width- 1: 0] INPUT;
  output [ input_width- 1: 0] SUM;  reg [ input_width- 1: 0] SUM;

  reg [ num_inputs*input_width- 1: 0] temp_input;

  integer i;

  // synopsys translate_off 
  //-------------------------------------------------------------------------
  // Parameter legality check
  //-------------------------------------------------------------------------

  
 
  initial begin : parameter_check
    integer param_err_flg;

    param_err_flg = 0;
    
    
    if (input_width < 1) begin
      param_err_flg = 1;
      $display(
	"ERROR: %m :\n  Invalid value (%d) for parameter input_width (lower bound: 1)",
	input_width );
    end
    
    if (num_inputs < 1) begin
      param_err_flg = 1;
      $display(
	"ERROR: %m :\n  Invalid value (%d) for parameter num_inputs (lower bound: 1)",
	num_inputs );
    end 
  
    if ( param_err_flg == 1) begin
      $display(
        "%m :\n  Simulation aborted due to invalid parameter value(s)");
      $finish;
    end

  end // parameter_check 

     
     always @(INPUT)
	begin
	   if ((^(INPUT ^ INPUT) !== 1'b0)) begin
	      SUM = {input_width{1'bx}};
	   end
	   else begin
	   temp_input = INPUT;
	   SUM = temp_input [ input_width-1 : 0 ];
	   for ( i = 2; i <= num_inputs; i = i + 1)
	      begin
		 temp_input = temp_input >> input_width;
		 SUM = SUM + temp_input [ input_width-1 : 0 ];
	      end // for ( i = 2; i <= num_inputs; i = i + 1)
	   end // else: !if_Is_X(INPUT)
	end // always (INPUT)
   
  // synopsys translate_on
endmodule // DW02_sum;




