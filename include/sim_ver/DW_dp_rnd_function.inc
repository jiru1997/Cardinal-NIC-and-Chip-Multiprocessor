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
// AUTHOR:    Reto Zimmermann    Jun. 20, 2006
//
// VERSION:   Verilog Datapath Functions for Simulation: Rounding
//
// DesignWare_version: f0e35e0e
// DesignWare_release: K-2015.06-DWBB_201506.5.2
//
////////////////////////////////////////////////////////////////////////////////


// parameters: width, lsb


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


// rounding modes
parameter DW_dp_rnd_neg_inf      = 4'b0000;
parameter DW_dp_rnd_pos_inf      = 4'b0001;
parameter DW_dp_rnd_zero         = 4'b0010;
parameter DW_dp_rnd_away         = 4'b0011;
parameter DW_dp_rnd_even         = 4'b0100;
parameter DW_dp_rnd_odd          = 4'b0101;
parameter DW_dp_rnd_near_neg_inf = 4'b1000;
parameter DW_dp_rnd_near_pos_inf = 4'b1001;
parameter DW_dp_rnd_near_zero    = 4'b1010;
parameter DW_dp_rnd_near_away    = 4'b1011;
parameter DW_dp_rnd_near_even    = 4'b1100;
parameter DW_dp_rnd_near_odd     = 4'b1101;


// ----------------------------------------------------------------------------
// DWF_dp_rnd: Rounding functions
// ----------------------------------------------------------------------------

// ----------------------------------------------------------------------------
// round (unsigned)
function [width-lsb-1 : 0] DWF_dp_rnd_uns;

  input [width-1 : 0] a;
  input [3 : 0]       mode;

  parameter msb = width-1;
  reg [lsb-1 : 0] lsb_half;

  reg [msb : lsb] a_int;
  reg [lsb-1 : 0] a_frac;
  reg             a_inc;
  reg [msb : lsb] z;

  begin

// synopsys translate_off

    // parameter range check
    `param_lower_check("DWF_dp_rnd_uns", "width", width, 1);
    `param_range_check("DWF_dp_rnd_uns", "lsb", lsb, 1, width-1);

    lsb_half        = {lsb{1'b0}};
    lsb_half[lsb-1] = 1'b1;

    a_int  = a[msb : lsb];
    a_frac = a[lsb-1 : 0];
    a_inc  = 1'b0;

    // calculate rounding increment
    case (mode)
      DW_dp_rnd_neg_inf, DW_dp_rnd_zero : ;

      DW_dp_rnd_pos_inf, DW_dp_rnd_away :
        if (a_frac > 0)
          a_inc = 1'b1;

      DW_dp_rnd_even :
        if ((a_int[lsb] == 1'b1) && (a_frac > 0))
          a_inc = 1'b1;

      DW_dp_rnd_odd :
        if ((a_int[lsb] == 1'b0) && (a_frac > 0))
          a_inc = 1'b1;

      DW_dp_rnd_near_neg_inf, DW_dp_rnd_near_zero :
        if (a_frac > lsb_half)
          a_inc = 1'b1;

      DW_dp_rnd_near_pos_inf, DW_dp_rnd_near_away :
        if (a_frac >= lsb_half)
          a_inc = 1'b1;

      DW_dp_rnd_near_even :
        if (((a_int[lsb] == 1'b0) && (a_frac >  lsb_half)) ||
            ((a_int[lsb] == 1'b1) && (a_frac >= lsb_half)))
          a_inc = 1'b1;

      DW_dp_rnd_near_odd :
        if (((a_int[lsb] == 1'b0) && (a_frac >= lsb_half)) ||
            ((a_int[lsb] == 1'b1) && (a_frac >  lsb_half)))
          a_inc = 1'b1;

      default : ;
    endcase

    // increment
    z = a_int + a_inc;

    DWF_dp_rnd_uns = z;

// synopsys translate_on

  end

endfunction


// ----------------------------------------------------------------------------
// round (signed)
function signed [width-lsb-1 : 0] DWF_dp_rnd_tc;

  input signed [width-1 : 0] a;
  input        [3 : 0]       mode;

  parameter msb = width-1;
  reg [lsb-1 : 0] lsb_half;

  reg signed [msb : lsb] a_int;
  reg        [lsb-1 : 0] a_frac;
  reg                    a_inc;
  reg signed [msb : lsb] z;

  begin

// synopsys translate_off

    // parameter range check
    `param_lower_check("DWF_dp_rnd_tc", "width", width, 1);
    `param_range_check("DWF_dp_rnd_tc", "lsb", lsb, 1, width-1);

    lsb_half        = {lsb{1'b0}};
    lsb_half[lsb-1] = 1'b1;

    a_int  = $signed(a[msb : lsb]);
    a_frac = $unsigned(a[lsb-1 : 0]);
    a_inc  = 1'b0;

    // calculate rounding increment
    case (mode)
      DW_dp_rnd_neg_inf : ;

      DW_dp_rnd_pos_inf :
        if (a_frac > 0)
          a_inc = 1'b1;

      DW_dp_rnd_zero :
        if ((a_int < 0) && (a_frac > 0))
          a_inc = 1'b1;

      DW_dp_rnd_away :
        if ((a_int >= 0) && (a_frac > 0))
          a_inc = 1'b1;

      DW_dp_rnd_even :
        if ((a_int[lsb] == 1'b1) && (a_frac > 0))
          a_inc = 1'b1;

      DW_dp_rnd_odd :
        if ((a_int[lsb] == 1'b0) && (a_frac > 0))
          a_inc = 1'b1;

      DW_dp_rnd_near_neg_inf :
        if (a_frac > lsb_half)
          a_inc = 1'b1;

      DW_dp_rnd_near_pos_inf :
        if (a_frac >= lsb_half)
          a_inc = 1'b1;

      DW_dp_rnd_near_zero :
        if (((a_int >= 0) && (a_frac >  lsb_half)) ||
            ((a_int <  0) && (a_frac >= lsb_half)))
          a_inc = 1'b1;

      DW_dp_rnd_near_away :
        if (((a_int >= 0) && (a_frac >= lsb_half)) ||
            ((a_int <  0) && (a_frac >  lsb_half)))
          a_inc = 1'b1;

      DW_dp_rnd_near_even :
        if (((a_int[lsb] == 1'b0) && (a_frac >  lsb_half)) ||
            ((a_int[lsb] == 1'b1) && (a_frac >= lsb_half)))
          a_inc = 1'b1;

      DW_dp_rnd_near_odd :
        if (((a_int[lsb] == 1'b0) && (a_frac >= lsb_half)) ||
            ((a_int[lsb] == 1'b1) && (a_frac >  lsb_half)))
          a_inc = 1'b1;

      default : ;
    endcase

    // increment
    z = a_int + $signed({1'b0, a_inc});

    DWF_dp_rnd_tc = z;

// synopsys translate_on

  end

endfunction


// ----------------------------------------------------------------------------
