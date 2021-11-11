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
// VERSION:   Verilog Datapath Functions for Simulation: Saturation
//
// DesignWare_version: e098084f
// DesignWare_release: K-2015.06-DWBB_201506.5.2
//
////////////////////////////////////////////////////////////////////////////////


// parameters: width, size


// parameter lower bound check
`define param_lower_check(func_name, param_name, param_value, lower_bound) \
  if (! (lower_bound <= param_value)) \
    $display ("\nError:  Invalid value for parameter '", param_name, \
              "' in function '", func_name, "' (= ", param_value, \
              ", lower bound is ", lower_bound, ")")

// parameter range check
`define param_range_check(func_name, param_name, param_value, lower_bound, upper_bound) \
  if (! ((lower_bound <= param_value) && (param_value <= upper_bound))) \
    $display ("\nError:  Invalid value for parameter '", param_name, \
              "' in function '", func_name, "' (= ", param_value, \
              ", valid range is ", lower_bound, " to ", upper_bound, ")")


// ----------------------------------------------------------------------------
// DWF_dp_sat: Saturation functions
// ----------------------------------------------------------------------------

// ----------------------------------------------------------------------------
// saturation (unsigned)
function [size-1 : 0] DWF_dp_sat_uns;

  input [width-1 : 0] a;

  reg [size-1 : 0] z;

  begin

// synopsys translate_off

    // parameter range check
    `param_lower_check("DWF_dp_sat_uns", "width", width, 1);
    `param_range_check("DWF_dp_sat_uns", "size", size, 2, width-1);

    // saturate if overflow
    if ((| a[width-1 : size]) == 1'b1)
      z = {size{1'b1}};
    else
      z = a[size-1 : 0];

    DWF_dp_sat_uns = z;

// synopsys translate_on

  end

endfunction


// ----------------------------------------------------------------------------
// saturation (signed)
function signed [size-1 : 0] DWF_dp_sat_tc;

  input signed [width-1 : 0] a;

  reg signed [size-1 : 0] z;

  begin

// synopsys translate_off

    // parameter range check
    `param_lower_check("DWF_dp_sat_tc", "width", width, 1);
    `param_range_check("DWF_dp_sat_tc", "size", size, 2, width-1);

    // saturate if overflow/underflow
    if ((a[width-1] == 1'b0) && ((| a[width-2 : size-1]) == 1'b1))
      z = $signed({1'b0, {size-1{1'b1}}});
    else if ((a[width-1] == 1'b1) && ((& a[width-2 : size-1]) == 1'b0))
      z = $signed({1'b1, {size-1{1'b0}}});
    else
      z = $signed(a[size-1 : 0]);

    DWF_dp_sat_tc = z;

// synopsys translate_on

  end

endfunction


// ----------------------------------------------------------------------------
// saturation, inverted output (unsigned)
function [size-1 : 0] DWF_dp_sati_uns;

  input [width-1 : 0] a;

  reg [size-1 : 0] z;

  begin

// synopsys translate_off

    // parameter range check
    `param_lower_check("DWF_dp_sati_uns", "width", width, 1);
    `param_range_check("DWF_dp_sati_uns", "size", size, 2, width-1);

    // saturate if overflow
    if ((| a[width-1 : size]) == 1'b1)
      z = ~ {size{1'b1}};
    else
      z = ~ a[size-1 : 0];

    DWF_dp_sati_uns = z;

// synopsys translate_on

  end

endfunction


// ----------------------------------------------------------------------------
// saturation, inverted output (signed)
function signed [size-1 : 0] DWF_dp_sati_tc;

  input signed [width-1 : 0] a;

  reg signed [size-1 : 0] z;

  begin

// synopsys translate_off

    // parameter range check
    `param_lower_check("DWF_dp_sati_tc", "width", width, 1);
    `param_range_check("DWF_dp_sati_tc", "size", size, 2, width-1);

    // saturate if overflow/underflow
    if ((a[width-1] == 1'b0) && ((| a[width-2 : size-1]) == 1'b1))
      z = ~ $signed({1'b0, {size-1{1'b1}}});
    else if ((a[width-1] == 1'b1) && ((& a[width-2 : size-1]) == 1'b0))
      z = ~ $signed({1'b1, {size-1{1'b0}}});
    else
      z = ~ $signed(a[size-1 : 0]);

    DWF_dp_sati_tc = z;

// synopsys translate_on

  end

endfunction


// ----------------------------------------------------------------------------
