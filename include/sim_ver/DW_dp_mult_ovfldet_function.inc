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
// VERSION:   Verilog Datapath Functions for Simulation: Multiply with overflow detection
//
// DesignWare_version: cf23adc9
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
// DWF_dp_mult_ovfldet: Multiply with overflow detection functions
// ----------------------------------------------------------------------------

// ----------------------------------------------------------------------------
// multiply with overflow detection (unsigned)
task DWF_dp_mult_ovfldet_uns;

  input  [a_width-1 : 0] a;
  input  [b_width-1 : 0] b;
  output [p_width-1 : 0] p;
  output                 ovfl;

  reg [a_width+b_width-1 : 0] p_int;

  begin

// synopsys translate_off

    // parameter check
    `param_lower_check("DWF_dp_mult_ovfldet_uns", "a_width", a_width, 2);
    `param_lower_check("DWF_dp_mult_ovfldet_uns", "b_width", b_width, 2);
    `param_lower_check("DWF_dp_mult_ovfldet_uns", "p_width", p_width, 2);

    // multiply
    p_int = a * b;

    // detect overflow
    if ((a_width+b_width-1 >= p_width) &&
        ({`MAX(a_width+b_width-p_width,1){1'b0}} !=
         p_int[a_width+b_width-1 : `MIN(p_width,a_width+b_width-1)]))
      ovfl = 1'b1;
    else
      ovfl = 1'b0;

    // resize product
    p = p_int;

// synopsys translate_on

  end

endtask


// ----------------------------------------------------------------------------
// multiply with overflow detection (signed)
task DWF_dp_mult_ovfldet_tc;

  input  signed [a_width-1 : 0] a;
  input  signed [b_width-1 : 0] b;
  output signed [p_width-1 : 0] p;
  output                        ovfl;

  reg signed [a_width+b_width-1 : 0] p_int;

  begin

// synopsys translate_off

    // parameter check
    `param_lower_check("DWF_dp_mult_ovfldet_tc", "a_width", a_width, 2);
    `param_lower_check("DWF_dp_mult_ovfldet_tc", "b_width", b_width, 2);
    `param_lower_check("DWF_dp_mult_ovfldet_tc", "p_width", p_width, 2);

    // multiply
    p_int = a * b;

    // detect overflow/underflow
    if ((a_width+b_width-1 >= p_width) &&
        ({`MAX(a_width+b_width-p_width,1){p_int[a_width+b_width-1]}} !=
         p_int[a_width+b_width-2 : `MIN(p_width,a_width+b_width-1)-1]))
      ovfl = 1'b1;
    else
      ovfl = 1'b0;

    // resize product
    if (a_width+b_width >= p_width)
      p = $signed({p_int[a_width+b_width-1], $signed(p_int[p_width-2:0])});
    else
      p = p_int;

// synopsys translate_on

  end

endtask
