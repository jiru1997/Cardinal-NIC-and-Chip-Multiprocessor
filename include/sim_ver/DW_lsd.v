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
// AUTHOR:    Reto Zimmermann	Mar. 22, 2006
//
// VERSION:   Simulation Architecture
//
// DesignWare_version: 2a8274e3
// DesignWare_release: K-2015.06-DWBB_201506.5.2
//
////////////////////////////////////////////////////////////////////////////////
//
// ABSTRACT: Leading Signs Detector
//           - Outputs an 'encoded' value that is the number of sign bits 
//             (from the left) before the first non-sign bit is found in the 
//             input vector. 
//           - Outputs a one-hot 'decoded' value that indicates the position 
//             of the right-most sign bit in the input vector.
//
//           Note: Only for the simulation model, X's will be handled in
//                 the following manner.  If an X is in a sign or the first
//                 non-sign bit position, then the outputs enc and dec get
//                 all X's.  If an X is after the first non-sign bit position,
//                 the outputs enc and dec get the expected non-X values.
//
//           Parameters  Legal Range  Default  Description
//           ----------  -----------  -------  -----------
//           a_width     >= 1         8        word length of a, dec
//              
//           Inputs   Size                 Description
//           ------   ----                 -----------
//           a        a_width              input vector
//
//           Outputs  Size                 Description
//           -------  ----                 -----------
//           enc      ceil(log2(a_width))  encoded output (number of sign bits)
//           dec      a_width              decoded output (position of sign bit)
//
// MODIFIED: 
//
//-----------------------------------------------------------------------------

module DW_lsd (a, dec, enc);

  parameter a_width = 8;

  localparam addr_width = ((a_width>65536)?((a_width>16777216)?((a_width>268435456)?((a_width>536870912)?30:29):((a_width>67108864)?((a_width>134217728)?28:27):((a_width>33554432)?26:25))):((a_width>1048576)?((a_width>4194304)?((a_width>8388608)?24:23):((a_width>2097152)?22:21)):((a_width>262144)?((a_width>524288)?20:19):((a_width>131072)?18:17)))):((a_width>256)?((a_width>4096)?((a_width>16384)?((a_width>32768)?16:15):((a_width>8192)?14:13)):((a_width>1024)?((a_width>2048)?12:11):((a_width>512)?10:9))):((a_width>16)?((a_width>64)?((a_width>128)?8:7):((a_width>32)?6:5)):((a_width>4)?((a_width>8)?4:3):((a_width>2)?2:1)))));

  input     [a_width-1:0] a;
  output    [a_width-1:0] dec;
  output [addr_width-1:0] enc;

  // include modeling functions
  `include "DW_lsd_function.inc"

  // synopsys translate_off

  // parameter legality check
  
 
  initial begin : parameter_check
    integer param_err_flg;

    param_err_flg = 0;
    
  
    if (a_width < 1) begin
      param_err_flg = 1;
      $display(
	"ERROR: %m :\n  Invalid value (%d) for parameter a_width (lower bound: 1)",
	a_width );
    end
  
    if ( param_err_flg == 1) begin
      $display(
        "%m :\n  Simulation aborted due to invalid parameter value(s)");
      $finish;
    end

  end // parameter_check 


  // calculate outputs
  assign enc = DWF_lsd_enc (a);
  assign dec = DWF_lsd (a);

  // synopsys translate_on

endmodule
