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
// VERSION:   Verilog Datapath Functions for Simulation: Sign Selection
//
// DesignWare_version: cf3d1503
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
// DWF_dp_sign_select: Sign selection functions
// ----------------------------------------------------------------------------

// ----------------------------------------------------------------------------
// sign_select (unsigned)
function [width-1 : 0] DWF_dp_sign_select_uns;

  input [width-1 : 0] a;
  input               s;

  reg [width-1 : 0] z;

  begin

// synopsys translate_off

    // parameter range check
    `param_lower_check("DWF_dp_sign_select_uns", "width", width, 1);

    // conditionally complement
    if (s == 1'b0)
      z = a;
    else
      z = -a;

    DWF_dp_sign_select_uns = z;

// synopsys translate_on

  end

endfunction


// ----------------------------------------------------------------------------
// sign_select (signed)
function signed [width-1 : 0] DWF_dp_sign_select_tc;

  input signed [width-1 : 0] a;
  input                      s;

  reg signed [width-1 : 0] z;

  begin

// synopsys translate_off

    // parameter range check
    `param_lower_check("DWF_dp_sign_select_tc", "width", width, 1);

    // conditionally complement
    if (s == 1'b0)
      z = a;
    else
      z = -a;

    DWF_dp_sign_select_tc = z;

// synopsys translate_on

  end

endfunction


// ----------------------------------------------------------------------------
