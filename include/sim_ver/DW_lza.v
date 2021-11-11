////////////////////////////////////////////////////////////////////////////////
//
//       This confidential and proprietary software may be used only
//     as authorized by a licensing agreement from Synopsys Inc.
//     In the event of publication, the following notice is applicable:
//
//                    (C) COPYRIGHT 2007 - 2016 SYNOPSYS INC.
//                           ALL RIGHTS RESERVED
//
//       The entire notice above must be reproduced on all authorized
//     copies.
//
// AUTHOR:    Bruce Dean Aug 15 2007     
//
// VERSION:   
//
// DesignWare_version: 10dbe915
// DesignWare_release: K-2015.06-DWBB_201506.5.2
//
////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
//
//
//  ABSTRACT: Leading zero anticipator (LZA) for addition
//           The LZA - leading zero anticipation module works under
//           some basic conditions:
//           1. B is subtracted from A, and the result is expected to have 2
//              or more zeros. The case when only 1 zero happens, will require 
//              normalization.
//           2. The output is maximum when the vector should have all its bit 
//              positions shifted to the left during normalization. No 1-bit
//              is detected by the anticipator in the bit-vector
//           3. The estimation is not exact, and may have a value that is 1
//              less than the exact value. From the original algorithm, the
//              result may be 2 less than the exact, but a filtering process
//              was put in place to correct the error to only 1.
//              because Alex is so damn smart.  
//
//             Parameters:     Valid Values
//             ==========      ============
//             width           2-256 
//             addr_width      ceiling log 2 of width 1-8 
//
//             Input Ports:    Size      Description
//             ===========     ====      ===========
//             a               width-1:0 a input
//             b               width-1:0 b input
//
//             Output Ports    Size                Description
//             ============    ====                ===========
//             count           ceil(log2(width))   number of leading zero's
//
//
//
//
//  MODIFIED:
//           JBD 9/07 Original simulation model
//           JBD 7/2009 Fixed incorrect `define in function
//
////////////////////////////////////////////////////////////////////////////////
module DW_lza (a,b,count);
parameter width = 7;
localparam addr_width = ((width>256)?((width>4096)?((width>16384)?((width>32768)?16:15):((width>8192)?14:13)):((width>1024)?((width>2048)?12:11):((width>512)?10:9))):((width>16)?((width>64)?((width>128)?8:7):((width>32)?6:5)):((width>4)?((width>8)?4:3):((width>2)?2:1))));
input [width-1:0] a;
input [width-1:0] b;
output [addr_width-1:0] count;
// synopsys translate_off
// include modeling functions
`include "DW_lza_function.inc"

 
  initial begin : parameter_check
    integer param_err_flg;

    param_err_flg = 0;
    

    if ( (width < 2) || (width > 256) ) begin
      param_err_flg = 1;
      $display(
	"ERROR: %m :\n  Invalid value (%d) for parameter width (legal range: 2 to 256)",
	width );
    end

    if ( (addr_width < 1) || (addr_width > 8) ) begin
      param_err_flg = 1;
      $display(
	"ERROR: %m :\n  Invalid value (%d) for parameter addr_width (legal range: 1 to 8)",
	addr_width );
    end

    if ( param_err_flg == 1) begin
      $display(
        "%m :\n  Simulation aborted due to invalid parameter value(s)");
      $finish;
    end

  end // parameter_check 

assign count = DWF_lza(a,b);
// synopsys translate_on
endmodule
