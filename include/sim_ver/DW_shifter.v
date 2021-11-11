////////////////////////////////////////////////////////////////////////////////
//
//       This confidential and proprietary software may be used only
//     as authorized by a licensing agreement from Synopsys Inc.
//     In the event of publication, the following notice is applicable:
//
//                    (C) COPYRIGHT 1999 - 2016 SYNOPSYS INC.
//                           ALL RIGHTS RESERVED
//
//       The entire notice above must be reproduced on all authorized
//     copies.
//
// AUTHOR:    Nitin Mhamunkar    August 1999
//
// VERSION:   Simulation Architecture
//
// DesignWare_version: fa03c5f5
// DesignWare_release: K-2015.06-DWBB_201506.5.2
//
////////////////////////////////////////////////////////////////////////////////

//----------------------------------------------------------------------------
// ABSTRACT: Combo Shifter 
//
// MODIFIED:
//           RPH        07/17/2002 
//                      Rewrote to comply with the new guidelines
//----------------------------------------------------------------------------

module DW_shifter(data_in, data_tc, sh, sh_tc, sh_mode, data_out); 

 
 parameter data_width = 8;
 parameter sh_width = 3;
 parameter inv_mode = 0;
 
 input  [data_width-1:0] data_in;
 input  [sh_width-1:0] sh;
 input data_tc, sh_tc, sh_mode; 
 
 output [data_width-1:0] data_out;
  
 wire [sh_width-1:0] sh_int;
 wire data_tc_int, sh_tc_int;
 wire padded_value; 

      
  // include modeling functions
  `include "DW_shifter_function.inc"
     
  // synopsys translate_off
  //-------------------------------------------------------------------------
  // Parameter legality check
  //-------------------------------------------------------------------------

  
 
  initial begin : parameter_check
    integer param_err_flg;

    param_err_flg = 0;
    
    
    if (data_width < 2) begin
      param_err_flg = 1;
      $display(
	"ERROR: %m :\n  Invalid value (%d) for parameter data_width (lower bound: 2)",
	data_width );
    end
    
    if (sh_width < 1) begin
      param_err_flg = 1;
      $display(
	"ERROR: %m :\n  Invalid value (%d) for parameter sh_width (lower bound: 1)",
	sh_width );
    end
    
    if ( (inv_mode < 0) || (inv_mode > 3) ) begin
      param_err_flg = 1;
      $display(
	"ERROR: %m :\n  Invalid value (%d) for parameter inv_mode (legal range: 0 to 3)",
	inv_mode );
    end   
  
    if ( param_err_flg == 1) begin
      $display(
        "%m :\n  Simulation aborted due to invalid parameter value(s)");
      $finish;
    end

  end // parameter_check 

 
   assign padded_value =  (inv_mode == 0 || inv_mode == 2) ? 1'b0 : 1'b1;
   assign data_tc_int = (inv_mode == 0 || inv_mode == 1) ? data_tc : ~data_tc;
   assign sh_tc_int = (inv_mode == 0 || inv_mode == 1) ? sh_tc : ~sh_tc;
   assign sh_int = (inv_mode == 0 || inv_mode == 1) ? sh : ~sh;
   
   assign data_out = ((^(sh_tc ^ sh_tc) !== 1'b0) |
                ((^(data_tc ^ data_tc) !== 1'b0) & (^(sh[sh_width-1] ^ sh[sh_width-1]) !== 1'b0)) |
                ((^(sh ^ sh) !== 1'b0) )) ? {data_width{1'bx}} :
              ((sh_tc_int === 1'b0) & (data_tc_int === 1'b0)  ) ? shift_uns_uns(data_in, sh_int, sh_mode, padded_value) :
	      ((sh_tc_int === 1'b0) & (data_tc_int === 1'b1) ) ? shift_uns_tc(data_in, sh_int, sh_mode, padded_value) :	     
              ((sh_tc_int === 1'b1) & (data_tc_int === 1'b0) ) ? shift_tc_uns(data_in, sh_int, sh_mode, padded_value) :
              shift_tc_tc(data_in, sh_int, sh_mode,padded_value);
 
// synopsys translate_on 
endmodule  
