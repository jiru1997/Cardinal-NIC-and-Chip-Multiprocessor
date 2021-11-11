////////////////////////////////////////////////////////////////////////////////
//
//       This confidential and proprietary software may be used only
//     as authorized by a licensing agreement from Synopsys Inc.
//     In the event of publication, the following notice is applicable:
//
//                    (C) COPYRIGHT 1998 - 2016 SYNOPSYS INC.
//                           ALL RIGHTS RESERVED
//
//       The entire notice above must be reproduced on all authorized
//     copies.
//
// AUTHOR:    Bob Tong                   March 1, 1998
//
// VERSION:   Simulation Architecture
//
// DesignWare_version: cef31b31
// DesignWare_release: K-2015.06-DWBB_201506.5.2
//
////////////////////////////////////////////////////////////////////////////////
//-----------------------------------------------------------------------------------
//
// ABSTRACT:  Boundary Scan Cell Type BC_3
//
//
//
//
//  Input Ports:    Size    Description
//  ===========     ====    ===========
//  capture_clk     1 bit   Clocks data into the capture stage
//  capture_en      1 bit   Enable for data clocked into the capture
//  shift_dr        1 bit   Enables the boundary scan chain to shift data
//                          one stage toward its serial output (tdo)
//  mode            1 bit   Determines whether data_out is controlled by the
//                          boundary scan cell or by the data_in signal
//  si              1 bit   Serial path from the previous boundary scan cell
//  data_in         1 bit   Input data
//
//  Output Ports    Size    Description
//  ============    ====    ===========
//  data_out        1 bit   Output data
//  so              1 bit   Serial path to the next boundary scan cell
//
//
//
// MODIFIED:
//
//  Liming SU   02/25/2016  Simplified codes by using continuous assignments
//
//  Liming SU   02/04/2016  Eiminated use of non-blocking assignments in
//                          always blocks that doesn't use posedge or
//                          negedge conditioning
//
//------------------------------------------------------------------------------

module DW_bc_3 (
  capture_clk,
  capture_en,
  shift_dr,
  mode,
  si,
  data_in,
  data_out,
  so
);

  input  capture_clk;
  input  capture_en;
  input  shift_dr;
  input  mode;
  input  si;
  input  data_in;
  output data_out;
  output so;

  wire next_so;
  reg  so;

// synopsys translate_off
  assign next_so = (capture_en===1'b1) ? so :
                     ((shift_dr===1'b1) ? si : data_in);

  always @(posedge capture_clk) begin : so_proc_PROC
    so <= next_so;
  end

  assign data_out = (mode===1'b1) ? so : data_in;

//synopsys translate_on

endmodule
