////////////////////////////////////////////////////////////////////////////////
//
//       This confidential and proprietary software may be used only
//     as authorized by a licensing agreement from Synopsys Inc.
//     In the event of publication, the following notice is applicable:
//
//                    (C) COPYRIGHT 2012 - 2016 SYNOPSYS INC.
//                           ALL RIGHTS RESERVED
//
//       The entire notice above must be reproduced on all authorized
//     copies.
//
// AUTHOR:    Reto Zimmermann    Aug. 15, 2012
//
// VERSION:   Verilog Datapath Functions for Simulation: Subtract + Absolute Value
//
// DesignWare_version: a4877f4e
// DesignWare_release: K-2015.06-DWBB_201506.5.2
//
////////////////////////////////////////////////////////////////////////////////


// parameters: width


// parameter lower bound check
`define param_lower_check(func_name, param_name, param_value, lower_bound) \
  if (! (lower_bound <= param_value)) \
    $display ("\nError:  Invalid value for parameter '", param_name, \
              "' in function '", func_name, "' (= ", param_value, \
              ", lower bound is ", lower_bound, ")")


// ----------------------------------------------------------------------------
// DWF_dp_sub_abs: Subtract + absolute value functions
// ----------------------------------------------------------------------------

// ----------------------------------------------------------------------------
// subtract + absolute value (unsigned)
function [width-1 : 0] DWF_dp_sub_abs_uns;

  input [width-1 : 0] a, b;

  reg [width-1 : 0] z;

  begin

// synopsys translate_off

    // parameter range check
    `param_lower_check("DWF_dp_sub_abs_uns", "width", width, 1);

    // subtract and complement if negative
    if (a >= b)
      z = a - b;
    else
      z = b - a;

    DWF_dp_sub_abs_uns = z;

// synopsys translate_on

  end

endfunction


// ----------------------------------------------------------------------------
// subtract + absolute value (signed)
function signed [width-1 : 0] DWF_dp_sub_abs_tc;

  input signed [width-1 : 0] a, b;

  reg signed [width-1 : 0] z;

  begin

// synopsys translate_off

    // parameter range check
    `param_lower_check("DWF_dp_sub_abs_tc", "width", width, 1);

    // subtract and complement if negative
    if (a >= b)
      z = a - b;
    else
      z = b - a;

    DWF_dp_sub_abs_tc = z;

// synopsys translate_on

  end

endfunction


// ----------------------------------------------------------------------------
