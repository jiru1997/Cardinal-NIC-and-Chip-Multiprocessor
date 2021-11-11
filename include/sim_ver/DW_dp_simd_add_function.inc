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
// AUTHOR:    Reto Zimmermann    Dec. 22, 2006
//
// VERSION:   Verilog Datapath Functions for Simulation: SIMD Adder
//
// DesignWare_version: 0f19f665
// DesignWare_release: K-2015.06-DWBB_201506.5.2
//
////////////////////////////////////////////////////////////////////////////////


// parameters: width, no_confs


// ceiling(log2())
`define bit_width(n) ((n>16)?((n>64)?((n>128)?8:7):((n>32)?6:5)):((n>4)?((n>8)?4:3):((n>2)?2:1)))

// unsigned part-select
`define psel_uns(a, msb, lsb) (($unsigned(((a+1-a)<<(msb+1))-1) & a) >> lsb)


// parameter lower bound check
`define param_lower_check(func_name, param_name, param_value, lower_bound) \
  if (! (lower_bound <= param_value)) \
    $display ("\nError:  Invalid value for parameter '", param_name, \
              "' in function '", func_name, "' (= ", param_value, \
              ", lower bound is ", lower_bound, ")")

// parameter value check
`define param_value_check(func_name, param_name, param_value, condition, message, legal_value) \
  if (! condition) \
    $display ("\nError:  Invalid value for parameter '", param_name, \
              "' in function '", func_name, "' (= ", param_value, \
              ", ", message, legal_value, ")")


// ----------------------------------------------------------------------------
// DWF_dp_simd_add: SIMD add functions
// ----------------------------------------------------------------------------

// ----------------------------------------------------------------------------
// SIMD add (unsigned)
function [width-1 : 0] DWF_dp_simd_add_uns;

  input [width-1 : 0]                a, b;
  input [`bit_width(no_confs)-1 : 0] conf;

  parameter max_parts      = (1<<(no_confs-1));
  parameter min_part_width = width / max_parts;

  reg [width-1 : 0] z;
  reg [width-1 : 0] z_int;

  integer c, i, k, part_width;

  begin

// synopsys translate_off

    // parameter checks
    `param_lower_check("DWF_dp_simd_add", "width", width, 2);
    `param_value_check("DWF_dp_simd_add", "width", width, (width % max_parts) == 0, "must be divisible by ", max_parts);
    `param_lower_check("DWF_dp_simd_add", "no_confs", no_confs, 2);

    // initialize
    z = {width{1'bx}};             // sum for illegal 'conf' input is undefined
    // process all configurations
    for (c = 0; c < no_confs; c = c+1) begin
      part_width = (1<<(no_confs-c-1)) * min_part_width;
      // select configurations
      if ($unsigned(c) == conf) begin
        // add all partitions
        for (k = 0; k < (1<<c); k = k+1) begin
          // add single partition
//           z[(k+1)*part_width-1 : k*part_width] =
//             a[(k+1)*part_width-1 : k*part_width] +
//             b[(k+1)*part_width-1 : k*part_width];
          // workaround for illegal code above
          z_int = `psel_uns(a, (k+1)*part_width-1, k*part_width) +
                  `psel_uns(b, (k+1)*part_width-1, k*part_width);
          for (i = part_width-1; i >= 0; i = i-1)
            z[i+k*part_width] = z_int[i];
        end
      end
    end

    DWF_dp_simd_add_uns = z;

// synopsys translate_on

  end

endfunction


// ----------------------------------------------------------------------------
// SIMD add (signed)
function signed [width-1 : 0] DWF_dp_simd_add_tc;

  input signed [width-1 : 0]                a, b;
  input        [`bit_width(no_confs)-1 : 0] conf;

  begin

// synopsys translate_off

    // call unsigned SIMD add
    DWF_dp_simd_add_tc =
      $signed(DWF_dp_simd_add_uns ($unsigned(a), $unsigned(b), conf));

// synopsys translate_on

  end

endfunction


// ----------------------------------------------------------------------------
