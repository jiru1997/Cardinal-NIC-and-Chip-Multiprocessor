
////////////////////////////////////////////////////////////////////////////////
//
//       This confidential and proprietary software may be used only
//     as authorized by a licensing agreement from Synopsys Inc.
//     In the event of publication, the following notice is applicable:
//
//                    (C) COPYRIGHT 2006 - 2016 SYNOPSYS INC.
//                           ALL RIGHTS RESERVED
//
//       The entire notice above must be reproduced on all authorized
//     copies.
//
// AUTHOR:    Kyung-Nam Han, Nov. 07, 2006
//
// VERSION:   Verilog Simulation Model for DW_sqrt_rem
//
// DesignWare_version: d4ffe838
// DesignWare_release: K-2015.06-DWBB_201506.5.2
//
////////////////////////////////////////////////////////////////////////////////
//-----------------------------------------------------------------------------
//
// ABSTRACT:  Combinational Square Root with a Remainder Output
// 
//              DW_sqrt_rem shares the same code with DW_sqrt, which is 
//              first created by Reto in 2000.
//              DW_sqrt_rem is an "internal" component for DW_fp_sqrt
//              It has an additional output port for the partial remainder
//
//              parameters      valid values (defined in the DW manual)
//              ==========      ============
//              width           Word length of a   (width >= 2)
//              tc_mode         Two's complementation
//                              0 - unsigned
//                              1 - signed
//
//              Input ports     Size & Description
//              ===========     ==================
//              a               (width)-bits
//                              Radicand
//              root            int([width+1]/2)-bits
//                              Square root
//              remainder       (int([width+1]/2) + 1)-bits
//                              Remainder
//
//-----------------------------------------------------------------------------

module DW_sqrt_rem (a, root, remainder);

  parameter width   = 8;
  parameter tc_mode = 0;

  input  [width-1 : 0]       a;
  output [(width+1)/2-1 : 0] root;
  output [(width+1)/2 : 0] remainder;
  
  // include modeling functions
`include "DW_sqrt_function.inc"

  wire [width - 1:0] tc_a;

  
 
  initial begin : parameter_check
    integer param_err_flg;

    param_err_flg = 0;
    
    
    if (width < 2) begin
      param_err_flg = 1;
      $display(
	"ERROR: %m :\n  Invalid value (%d) for parameter width (lower bound: 2)",
	width );
    end
    
    if ( (tc_mode < 0) || (tc_mode > 1) ) begin
      param_err_flg = 1;
      $display(
	"ERROR: %m :\n  Invalid value (%d) for parameter tc_mode (legal range: 0 to 1)",
	tc_mode );
    end
  
    if ( param_err_flg == 1) begin
      $display(
        "%m :\n  Simulation aborted due to invalid parameter value(s)");
      $finish;
    end

  end // parameter_check 



  assign root = (tc_mode == 0)? 
		  DWF_sqrt_uns (a) : DWF_sqrt_tc (a);

  assign tc_a = (tc_mode == 1 & a[width - 1] == 1) ?
           ~a + 1 : a;

  assign remainder = tc_a - root * root;

endmodule



