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
// AUTHOR:    Reto Zimmermann    Jan. 10, 2006
//
// VERSION:   Verilog Datapath Functions for Simulation: SIMD Adder with Carries
//
// DesignWare_version: 12cb2161
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
// DWF_dp_simd_addc: SIMD add with carries functions
// ----------------------------------------------------------------------------

// ----------------------------------------------------------------------------
// SIMD add with carries (unsigned)
task DWF_dp_simd_addc_uns;

  input  [width-1 : 0]                a, b;
  input  [(1<<(no_confs-1))-1 : 0]    cin;
  input  [`bit_width(no_confs)-1 : 0] conf;
  output [width-1 : 0]                s;
  output [(1<<(no_confs-1))-1 : 0]    cout;

  parameter max_parts      = (1<<(no_confs-1));
  parameter min_part_width = width / max_parts;

  reg [width : 0] s_int;

  integer c, i, k, part_width;

  begin

// synopsys translate_off

    // parameter checks
    `param_lower_check("DWF_dp_simd_addc", "width", width, 2);
    `param_value_check("DWF_dp_simd_addc", "width", width, (width % max_parts) == 0, "must be divisible by ", max_parts);
    `param_lower_check("DWF_dp_simd_addc", "no_confs", no_confs, 2);

    // initialize
    s    = {width{1'bx}};          // sum for illegal 'conf' input is undefined
    cout = {(1<<(no_confs-1)){1'bx}};  // unused carries are undefined
    // process all configurations
    for (c = 0; c < no_confs; c = c+1) begin
      part_width = (1<<(no_confs-c-1)) * min_part_width;
      // select configurations
      if ($unsigned(c) == conf) begin
        // add all partitions
        for (k = 0; k < (1<<c); k = k+1) begin
          // add single partition
//           { cout[(k+1)*(1<<(no_confs-c-1))-1],
//             s[(k+1)*part_width-1 : k*part_width] } =
//             a[(k+1)*part_width-1 : k*part_width] +
//             b[(k+1)*part_width-1 : k*part_width] +
//             cin[k*(1<<(no_confs-c-1))];
          // workaround for illegalcode above
          s_int = `psel_uns(a, (k+1)*part_width-1, k*part_width) +
                  `psel_uns(b, (k+1)*part_width-1, k*part_width) +
                  cin[k*(1<<(no_confs-c-1))];
          for (i = part_width-1; i >= 0; i = i-1)
            s[i+k*part_width] = s_int[i];
          cout[(k+1)*(1<<(no_confs-c-1))-1] = s_int[part_width];
        end
      end
    end

// synopsys translate_on

  end

endtask


// ----------------------------------------------------------------------------
// SIMD add with carries (signed)
task DWF_dp_simd_addc_tc;

  input  signed [width-1 : 0]                a, b;
  input         [(1<<(no_confs-1))-1 : 0]    cin;
  input         [`bit_width(no_confs)-1 : 0] conf;
  output signed [width-1 : 0]                s;
  output        [(1<<(no_confs-1))-1 : 0]    cout;

  begin

// synopsys translate_off

    // call unsigned SIMD add with carries
    DWF_dp_simd_addc_uns (
      $unsigned(a), $unsigned(b), cin, conf, s, cout);

// synopsys translate_on

  end

endtask


// ----------------------------------------------------------------------------
