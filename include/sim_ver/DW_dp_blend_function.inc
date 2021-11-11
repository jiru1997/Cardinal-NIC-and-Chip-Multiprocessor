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
// VERSION:   Verilog Datapath Functions for Simulation: Graphics Alpha Blend
//
// DesignWare_version: 660bd26e
// DesignWare_release: K-2015.06-DWBB_201506.5.2
//
////////////////////////////////////////////////////////////////////////////////


// parameters: width, alpha_width


// parameter lower bound check
`define param_lower_check(func_name, param_name, param_value, lower_bound) \
  if (! (lower_bound <= param_value)) \
    $display ("\nError:  Invalid value for parameter '", param_name, \
              "' in function '", func_name, "' (= ", param_value, \
              ", lower bound is ", lower_bound, ")")


// ----------------------------------------------------------------------------
// DWF_dp_blend: Graphics alpha blend functions
// ----------------------------------------------------------------------------

// ----------------------------------------------------------------------------
// basic blend
function [width-1 : 0] DWF_dp_blend;

  input [width-1 : 0]       x, y;
  input [alpha_width-1 : 0] alpha;

  reg [alpha_width-1 : 0]       alpha_neg;
  reg [width+alpha_width-1 : 0] z_int;
  reg [width-1 : 0]             z;

  begin

// synopsys translate_off

    // parameter range check
    `param_lower_check("DWF_dp_blend", "width", width, 2);
    `param_lower_check("DWF_dp_blend", "alpha_width", alpha_width, 2);

    // calculate blend and round
    alpha_neg = ~alpha;
    z_int = x * alpha + y * alpha_neg + {1'b1, {alpha_width-1{1'b0}}};

    // truncate
    z = z_int >> alpha_width;

    DWF_dp_blend = z;

// synopsys translate_on

  end

endfunction


// ----------------------------------------------------------------------------
// basic blend (no rounding/truncation)
function [width+alpha_width-1 : 0] DWF_dp_blend2;

  input [width-1 : 0]       x, y;
  input [alpha_width-1 : 0] alpha;

  reg [alpha_width-1 : 0]       alpha_neg;
  reg [width+alpha_width-1 : 0] z;

  begin

// synopsys translate_off

    // parameter range check
    `param_lower_check("DWF_dp_blend2", "width", width, 2);
    `param_lower_check("DWF_dp_blend2", "alpha_width", alpha_width, 2);

    // calculate blend
    alpha_neg = ~alpha;
    z = x * alpha + y * alpha_neg;

    DWF_dp_blend2 = z;

// synopsys translate_on

  end

endfunction


// ----------------------------------------------------------------------------
// exact blend
function [width-1 : 0] DWF_dp_blend_exact;

  input [width-1 : 0]       x, y;
  input [alpha_width-1 : 0] alpha;

  reg [alpha_width-1 : 0]       alpha_neg;
  reg [width+alpha_width-1 : 0] z_int;
  reg [width-1 : 0]             z;

  begin

// synopsys translate_off

    // parameter range check
    `param_lower_check("DWF_dp_blend_exact", "width", width, 2);
    `param_lower_check("DWF_dp_blend_exact", "alpha_width", alpha_width, 2);

    // calculate exact blend
    alpha_neg = ~alpha;
    z_int = x * alpha + y * alpha_neg + {alpha_width-1{1'b1}};
    z = z_int / {alpha_width{1'b1}};

    DWF_dp_blend_exact = z;

// synopsys translate_on

  end

endfunction


// ----------------------------------------------------------------------------
// exact blend with alpha1
function [width-1 : 0] DWF_dp_blend_exact2;

  input [width-1 : 0]       x, y;
  input [alpha_width-1 : 0] alpha;
  input                     alpha1;

  reg [alpha_width-1 : 0]       alpha_neg;
  reg [width+alpha_width-1 : 0] z_int;
  reg [width-1 : 0]             z;

  begin

// synopsys translate_off

    // parameter range check
    `param_lower_check("DWF_dp_blend_exact2", "width", width, 2);
    `param_lower_check("DWF_dp_blend_exact2", "alpha_width", alpha_width, 2);

    // calculate blend and round
    alpha_neg = ~alpha;
    z_int = x * alpha + y * alpha_neg + ((alpha1 == 1'b1) ? x : y) +
            {1'b1, {alpha_width-1{1'b0}}};

    // truncate
    z = z_int >> alpha_width;

    DWF_dp_blend_exact2 = z;

// synopsys translate_on

  end

endfunction


// ----------------------------------------------------------------------------
// exact blend with alpha1
function [width+alpha_width-1 : 0] DWF_dp_blend2_exact2;

  input [width-1 : 0]       x, y;
  input [alpha_width-1 : 0] alpha;
  input                     alpha1;

  reg [alpha_width-1 : 0]       alpha_neg;
  reg [width+alpha_width-1 : 0] z;

  begin

// synopsys translate_off

    // parameter range check
    `param_lower_check("DWF_dp_blend2_exact2", "width", width, 2);
    `param_lower_check("DWF_dp_blend2_exact2", "alpha_width", alpha_width, 2);

    // calculate blend
    alpha_neg = ~alpha;
    z = x * alpha + y * alpha_neg + ((alpha1 == 1'b1) ? x : y);

    DWF_dp_blend2_exact2 = z;

// synopsys translate_on

  end

endfunction


// ----------------------------------------------------------------------------
