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
// DesignWare_version: 6fbd4506
// DesignWare_release: K-2015.06-DWBB_201506.5.2
//
////////////////////////////////////////////////////////////////////////////////
//-----------------------------------------------------------------------------------
//
// ABSTRACT:  Boundary Scan Cell Type BC_2
//
//           
//
//              
//  Input Ports:        Size    Description
//  ===========         ====    ===========
//  capture_clk         1 bit   Clocks data into the capture stage
//  update_clk          1 bit   Clocks data into the update stage 
//  capture_en          1 bit   Enable for data clocked into the capture 
//  update_en           1 bit   Enable for data clocked into the update stage 
//  shift_dr            1 bit   Enables the boundary scan chain to shift data
//                              one stage toward its serial output (tdo) 
//  mode                1 bit   Determines whether data_out is controlled by the
//                              boundary scan cell or by the data_in signal
//  si                  1 bit   Serial path from the previous boundary scan cell
//  data_in             1 bit   Input data
//
//  Output Ports        Size    Description
//  ============        ====    ===========
//  data_out            1 bit   Output data
//  so                  1 bit   Serial path to the next boundary scan cell
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

module DW_bc_2 (
  capture_clk,
  update_clk,
  capture_en,
  update_en,
  shift_dr,
  mode,
  si,
  data_in,
  data_out,
  so
);

  input   capture_clk;
  input   update_clk;
  input   capture_en;
  input   update_en;
  input   shift_dr;
  input   mode;
  input   si;
  input   data_in;
  output  data_out;
  output  so;

  wire next_so;
  reg  so;
  wire next_update_out;
  reg  update_out;

// synopsys translate_off

  assign next_so = (capture_en===1'b1) ? so :
                     ((shift_dr===1'b1) ? si : data_out);

  always @(posedge capture_clk) begin : so_proc_PROC
    so <= next_so;
  end

  assign next_update_out = (update_en===1'b1) ? so : update_out;

  always @(posedge update_clk) begin : upd_proc_PROC
    update_out <= next_update_out;
  end

  assign data_out = (mode===1'b1) ? update_out : data_in;

//synopsys translate_on

endmodule
