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
// VERSION:   Verilog Datapath Functions for Simulation: Combined multiply with overflow detection
//
// DesignWare_version: 5eaa3947
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
// DWF_dp_mult_comb_ovfldet: Combined multiply with overflow detection functions
// ----------------------------------------------------------------------------

// ----------------------------------------------------------------------------
// combined multiply with overflow detection (unsigned)
task DWF_dp_mult_comb_ovfldet;

  input  [a_width-1 : 0] a;
  input                  a_tc;
  input  [b_width-1 : 0] b;
  input                  b_tc;
  output [p_width-1 : 0] p;
  output                 ovfl;

  reg signed [a_width+b_width-1 : 0] p_sgn;
  reg        [a_width+b_width-1 : 0] p_int;

  begin

// synopsys translate_off

    // parameter check
    `param_lower_check("DWF_dp_mult_comb_ovfldet", "a_width", a_width, 2);
    `param_lower_check("DWF_dp_mult_comb_ovfldet", "b_width", b_width, 2);
    `param_lower_check("DWF_dp_mult_comb_ovfldet", "p_width", p_width, 2);

    // conditional unsigned / signed multiply
    case ({a_tc, b_tc})
      2'b00 : p_int = a * b;
      2'b01 : begin
                p_sgn = $signed({1'b0, a}) * $signed(b);
                p_int = $unsigned(p_sgn);
              end
      2'b10 : begin
                p_sgn = $signed(a) * $signed({1'b0, b});
                p_int = $unsigned(p_sgn);
              end
      2'b11 : begin
                p_sgn = $signed(a) * $signed(b);
                p_int = $unsigned(p_sgn);
              end
    endcase
    
    // detect unsigned overflow/underflow
    if (((a_tc == 1'b0) && (b_tc == 1'b0)) &&
        (a_width+b_width-1 >= p_width) &&
        ({`MAX(a_width+b_width-p_width,1){1'b0}} !=
         p_int[a_width+b_width-1 : `MIN(p_width,a_width+b_width-1)]))
      ovfl = 1'b1;
    // detect signed overflow/underflow
    else if (((a_tc == 1'b1) || (b_tc == 1'b1)) &&
             (a_width+b_width-1 >= p_width) &&
             ({`MAX(a_width+b_width-p_width,1){p_int[a_width+b_width-1]}} !=
              p_int[a_width+b_width-2 : `MIN(p_width,a_width+b_width-1)-1]))
      ovfl = 1'b1;
    // no overflow
    else
      ovfl = 1'b0;

    // resize unsigned product
    if ((a_tc == 1'b0) && (b_tc == 1'b0))
      p = p_int;
    // size down signed product
    else if (a_width+b_width >= p_width)
      p = {p_int[a_width+b_width-1], p_int[p_width-2:0]};
    // sign-extend signed product
    else
      p = {{`MAX(p_width-a_width-b_width,1){p_int[a_width+b_width-1]}}, 
           p_int[a_width+b_width-1:0]};

// synopsys translate_on

  end

endtask


// ----------------------------------------------------------------------------
// combined multiply with overflow detection (signed)
task DWF_dp_mult_comb_ovfldet_tc;

  input  signed [a_width-1 : 0] a;
  input                         a_tc;
  input  signed [b_width-1 : 0] b;
  input                         b_tc;
  output signed [p_width-1 : 0] p;
  output                        ovfl;

  reg [p_width-1 : 0] p_int;

  begin

// synopsys translate_off

    DWF_dp_mult_comb_ovfldet ($unsigned(a), a_tc, $unsigned(b), b_tc, 
                              p_int, ovfl);

    p = $signed(p_int);

// synopsys translate_on

  end

endtask
