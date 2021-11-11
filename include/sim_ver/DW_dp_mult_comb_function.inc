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
// AUTHOR:    Reto Zimmermann    Sep 6, 2013
//
// VERSION:   Verilog Datapath Functions for Simulation: Combined multiply
//
// DesignWare_version: 2225bd8f
// DesignWare_release: K-2015.06-DWBB_201506.5.2
//
////////////////////////////////////////////////////////////////////////////////


// parameters: a_width, b_width


// parameter lower bound check
`define param_lower_check(func_name, param_name, param_value, lower_bound) \
  if (! (lower_bound <= param_value)) \
    $display ("\nError:  Invalid value for parameter '", param_name, \
              "' in function '", func_name, "' (= ", param_value, \
              ", lower bound is ", lower_bound, ")")


// ----------------------------------------------------------------------------
// DWF_dp_mult_comb: Combined multiply functions
// ----------------------------------------------------------------------------

// ----------------------------------------------------------------------------
// combined multiply (unsigned)
function [a_width+b_width-1 : 0] DWF_dp_mult_comb;

  input [a_width-1 : 0] a;
  input                 a_tc;
  input [b_width-1 : 0] b;
  input                 b_tc;

  reg [a_width+b_width-1 : 0] p;

  reg signed [a_width+b_width-1 : 0] p_sgn;

  begin

// synopsys translate_off

    // parameter check
    `param_lower_check("DWF_dp_mult_comb", "a_width", a_width, 1);
    `param_lower_check("DWF_dp_mult_comb", "b_width", b_width, 1);

    // conditional unsigned / signed multiply
    case ({a_tc, b_tc})
      2'b00 : p = a * b;
      2'b01 : begin
                p_sgn = $signed({1'b0, a}) * $signed(b);
                p = $unsigned(p_sgn);
              end
      2'b10 : begin
                p_sgn = $signed(a) * $signed({1'b0, b});
                p = $unsigned(p_sgn);
              end
      2'b11 : begin
                p_sgn = $signed(a) * $signed(b);
                p = $unsigned(p_sgn);
              end
    endcase
    
    DWF_dp_mult_comb = p;

// synopsys translate_on

  end

endfunction


// ----------------------------------------------------------------------------
// combined multiply (signed)
function signed [a_width+b_width-1 : 0] DWF_dp_mult_comb_tc;

  input signed [a_width-1 : 0] a;
  input                        a_tc;
  input signed [b_width-1 : 0] b;
  input                        b_tc;

  reg signed [a_width+b_width-1 : 0] p;

  begin

// synopsys translate_off

    p = $signed(DWF_dp_mult_comb ($unsigned(a), a_tc, $unsigned(b), b_tc));
    
    DWF_dp_mult_comb_tc = p;
      

// synopsys translate_on

  end

endfunction
