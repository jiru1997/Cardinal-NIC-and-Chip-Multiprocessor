
////////////////////////////////////////////////////////////////////////////////
//
//       This confidential and proprietary software may be used only
//     as authorized by a licensing agreement from Synopsys Inc.
//     In the event of publication, the following notice is applicable:
//
//                    (C) COPYRIGHT 2009 - 2016 SYNOPSYS INC.
//                           ALL RIGHTS RESERVED
//
//       The entire notice above must be reproduced on all authorized
//     copies.
//
// AUTHOR:    Kyung-Nam Han   Nov. 23, 2009
//
// VERSION:   Simulation Model for DW_lp_multifunc
//
// DesignWare_version: f428ecc1
// DesignWare_release: K-2015.06-DWBB_201506.5.2
//
////////////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////////////
//-----------------------------------------------------------------------------
//
// ABSTRACT: Fixed-point Multi-function Unit
//
//              DW_lp_multifunc calculates transcendental functions 
//              with polynomial approximation method. Functions that are 
//              implemented include reciprocal, square root, inverse 
//              square root, trigonometric functions, logarithm and 
//              exponential function. All can be implemented in one unit,
//              but user can choose some of them or just one function for
//              the implementation. The results keeps 1 ulp or 2 ulp error
//              range by the user's choice. 
//
//              parameters      valid values (defined in the DW manual)
//              ==========      ============
//              op_width        operand width,  3 to 24 bits
//              func_select     Select functions to be implemented
//                              16-bit binary parameter
//                              func_select[0]: reciprocal, 1/x
//                              func_select[1]: square root, sqrt(x)
//                              func_select[2]: inv. square root, 1/sqrt(x)
//                              func_select[3]: sine function, sin(pi*x)
//                              func_select[4]: cosine function, cos(pi*x)
//                              func_select[5]: base-2 log function, log2(x)
//                              func_select[6]: base-2 power function, 2^x
//                              func_select[7:15]: reserved
//
//              Input ports     Size & Description
//              ===========     ==================
//              A               (op_width + 1) bits
//                              Fixed-point Number Input
//              FUNC            16-bit Function selection port
//                              Output function is determined by FUNC
//
//              Output ports    Size & Description
//              ===========     ==================
//              Z               (op_width + 2) bits
//                              Fixed-point number output
//              status          1 bit
//
//-----------------------------------------------------------------------------
////////////////////////////////////////////////////////////////////////////////
`ifdef VCS
`include "vcs/DW_lp_multifunc.v"
`else

module DW_lp_multifunc (
                   a,
                   func,
                   z,
                   status);


  parameter op_width = 24;        // RANGE 3 to 24
  parameter func_select = 127;    // RANGE 1 to 127

  localparam opt1 = 1;             // RANGE 0 to 1


  input [op_width:0] a;
  input [15:0] func;
  output [op_width + 1:0] z;
  output status;

// synopsys translate_off

  initial begin : PROC_invald_simulator_msg
    
    $display( "\
ERROR: %m:\
  ******************************************************\
  *                                                    *\
  *  The DesignWare minPower Library Component,        *\
  *  DW_lp_multifunc, is only supported for Synopsys   *\
  *  VCS and VCS-MX simulators.                        *\
  *                                                    *\
  *  support@synopsys.com                              *\
  *                                                    *\
  ******************************************************\
  ");
    $finish;


  end

// synopsys translate_on
endmodule
`endif
