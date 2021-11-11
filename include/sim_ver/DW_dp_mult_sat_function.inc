////////////////////////////////////////////////////////////////////////////////
//
//       This confidential and proprietary software may be used only
//     as authorized by a licensing agreement from Synopsys Inc.
//     In the event of publication, the following notice is applicable:
//
//                    (C) COPYRIGHT 2013 - 2016 SYNOPSYS INC.
//                           ALL RIGHTS RESERVED
//
//       The entire notice above must be reproduced on all authorized
//     copies.
//
// AUTHOR:    Reto Zimmermann    Aug 8, 2013
//
// VERSION:   Verilog Datapath Functions for Simulation: Multiply-Saturate
//
// DesignWare_version: 86e5a11f
// DesignWare_release: K-2015.06-DWBB_201506.5.2
//
////////////////////////////////////////////////////////////////////////////////


// parameters: a_width, b_width, p_width


// parameter lower bound check
`define param_lower_check(func_name, param_name, param_value, lower_bound) \
  if (! (lower_bound <= param_value)) \
    $display ("\nError:  Invalid value for parameter '", param_name, \
              "' in function '", func_name, "' (= ", param_value, \
              ", lower bound is ", lower_bound, ")")

// minimum value
`define MIN(p,q) ((p)<(q)?(p):(q))
// maximum value
`define MAX(p,q) ((p)>(q)?(p):(q))


// ----------------------------------------------------------------------------
// DWF_dp_mult_sat: Multiply-saturate functions
// ----------------------------------------------------------------------------

// ----------------------------------------------------------------------------
// multiply-saturate (unsigned)
function [p_width-1 : 0] DWF_dp_mult_sat_uns;

  input [a_width-1 : 0] a;
  input [b_width-1 : 0] b;

  reg [p_width-1 : 0] p;

  reg [a_width+b_width-1 : 0] p_int;

  begin

// synopsys translate_off

    // parameter check
    `param_lower_check("DWF_dp_mult_sat_uns", "a_width", a_width, 2);
    `param_lower_check("DWF_dp_mult_sat_uns", "b_width", b_width, 2);
    `param_lower_check("DWF_dp_mult_sat_uns", "p_width", p_width, 2);

    // multiply
    p_int = a * b;

    // saturate if overflow
    if ((a_width+b_width-1 >= p_width) &&
        ({`MAX(a_width+b_width-p_width,1){1'b0}} !=
         p_int[a_width+b_width-1 : `MIN(p_width,a_width+b_width-1)]))
      p = {p_width{1'b1}};
    // otherwise resize
    else
      p = p_int;

    DWF_dp_mult_sat_uns = p;

// synopsys translate_on

  end

endfunction


// ----------------------------------------------------------------------------
// multiply-saturate (signed)
function signed [p_width-1 : 0] DWF_dp_mult_sat_tc;

  input signed [a_width-1 : 0] a;
  input signed [b_width-1 : 0] b;

  reg signed [p_width-1 : 0] p;
  
  reg signed [a_width+b_width-1 : 0] p_int;

  begin

// synopsys translate_off

    // parameter check
    `param_lower_check("DWF_dp_mult_sat_tc", "a_width", a_width, 2);
    `param_lower_check("DWF_dp_mult_sat_tc", "b_width", b_width, 2);
    `param_lower_check("DWF_dp_mult_sat_tc", "p_width", p_width, 2);

    // multiply
    p_int = a * b;

    // saturate if overflow/underflow
    if ((a_width+b_width-1 >= p_width) &&
        ({`MAX(a_width+b_width-p_width,1){p_int[a_width+b_width-1]}} !=
         p_int[a_width+b_width-2 : `MIN(p_width,a_width+b_width-1)-1]))
      p = $signed({p_int[a_width+b_width-1], {p_width-1{~p_int[a_width+b_width-1]}}});
    // otherwise resize
    else
      p = $signed(p_int);

    DWF_dp_mult_sat_tc = p;

// synopsys translate_on

  end

endfunction
