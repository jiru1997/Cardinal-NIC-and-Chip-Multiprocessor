////////////////////////////////////////////////////////////////////////////////
//
//       This confidential and proprietary software may be used only
//     as authorized by a licensing agreement from Synopsys Inc.
//     In the event of publication, the following notice is applicable:
//
//                    (C) COPYRIGHT 2005 - 2016 SYNOPSYS INC.
//                           ALL RIGHTS RESERVED
//
//       The entire notice above must be reproduced on all authorized
//     copies.
//
// AUTHOR:    Doug Lee    7/8/05
//
// VERSION:   Simulation Architecture
//
// DesignWare_version: 3b508326
// DesignWare_release: K-2015.06-DWBB_201506.5.2
//
////////////////////////////////////////////////////////////////////////////////
//-----------------------------------------------------------------------------------
//
// ABSTRACT: Leading Ones Detector 
//           Outputs an 'encoded' value that is the number of 1s (from the 
//           left) before the first "0" is found in the input vector as
//           well as a 'decoded' value that is a one-hot result of the 
//           input vector.
//
//           Note: Only for the simulation model, x's will be handled in
//                 the following manner.  If an "x" is the first non-zero
//                 bit value found, then the output num_index gets all x's.
//                 If an "x", is in the "a" input, but a "1" is encountered
//                 at a higher bit position, then the output num_index gets
//                 the a non-x value.
//
//           Parameters:     Valid Values
//           ==========      ============
//           a_width         [ 1 to 1073741824 ]  // up to 30 bits
//              
//           Input Ports:    Size    Description
//           ===========     ====    ===========
//           a               N bits  Input vector width of "a_width"
//
//           Output Ports    Size    Description
//           ============    ====    ===========
//           dec             N bits  Decoded version of 'a' (all don't bits zeroed)
//           enc             M bits  Number of leading 1s found before first 0
//
//           Notes: the value of N is a_width
//                  the value of M is equal to: ceil(log2(a_width))+1
//              
//
//
// MODIFIED: 
//
//-------------------------------------------------------------------------------
//
module DW_lod (
    a,
    dec,
    enc
);

  parameter a_width  = 8;

  localparam addr_width = ((a_width>65536)?((a_width>16777216)?((a_width>268435456)?((a_width>536870912)?30:29):((a_width>67108864)?((a_width>134217728)?28:27):((a_width>33554432)?26:25))):((a_width>1048576)?((a_width>4194304)?((a_width>8388608)?24:23):((a_width>2097152)?22:21)):((a_width>262144)?((a_width>524288)?20:19):((a_width>131072)?18:17)))):((a_width>256)?((a_width>4096)?((a_width>16384)?((a_width>32768)?16:15):((a_width>8192)?14:13)):((a_width>1024)?((a_width>2048)?12:11):((a_width>512)?10:9))):((a_width>16)?((a_width>64)?((a_width>128)?8:7):((a_width>32)?6:5)):((a_width>4)?((a_width>8)?4:3):((a_width>2)?2:1)))));

  input  [a_width-1:0]    a;
  output [a_width-1:0]    dec;
  output [addr_width:0]   enc;

  // include modeling functions
  `include "DW_lod_function.inc"
    // synopsys translate_off

  //-------------------------------------------------------------------------
  // Parameter legality check
  //-------------------------------------------------------------------------
  
 
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


  assign dec = DWF_lod(a);
  assign enc = DWF_lod_enc(a);

   // synopsys translate_on
endmodule
