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
// AUTHOR:    Reto Zimmermann    Feb. 2, 2006
//
// VERSION:   Verilog Datapath Functions for Simulation: Absolute Value
//
// DesignWare_version: 48dfadee
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
// DWF_dp_absval: Absolute value functions
// ----------------------------------------------------------------------------

// ----------------------------------------------------------------------------
// absolute value (signed)
function signed [width-1 : 0] DWF_dp_absval;

  input signed [width-1 : 0] a;

  reg signed [width-1 : 0] z;

  begin

// synopsys translate_off

    // parameter range check
    `param_lower_check("DWF_dp_absval", "width", width, 1);

    // complement if negative
    if (a >= 0)
      z = a;
    else
      z = -a;

    DWF_dp_absval = z;

// synopsys translate_on

  end

endfunction


// ----------------------------------------------------------------------------
