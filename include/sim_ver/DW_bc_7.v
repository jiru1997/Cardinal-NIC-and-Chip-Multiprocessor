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
// DesignWare_version: 9833a499
// DesignWare_release: K-2015.06-DWBB_201506.5.2
//
////////////////////////////////////////////////////////////////////////////////
//-----------------------------------------------------------------------------------
//
// ABSTRACT:  Boundary Scan Cell Type BC_7
//
//           
//
//              
//  Input Ports:        Size    Description
//  === =========         === ==    === =========
//  capture_clk         1 bit   Clocks data into the capture stage.
//  update_clk          1 bit   Clocks data into the update stage. 
//  capture_en          1 bit   Enable for data clocked into the capture. 
//  update_en           1 bit   Enable for data clocked into the update 
//                              stage. 
//  shift_dr            1 bit   Enables the boundary scan chain to shift 
//                              data one stage toward its serial output 
//                              (tdo). 
//  mode1               1 bit   Determines whether data_out is controlled 
//                              by the boundary scan cell or by the 
//                              output_data signal.
//  mode2               1 bit   Determines whether ic_input is controlled 
//                              by the boundary scan cell or by the 
//                              pin_input signal.
//  si                  1 bit   Serial path from the previous boundary 
//                              scan cell.
//  pin_input           1 bit   IC system input pin.
//  control_out         1 bit   Control signal for the output enable.
//  output_data         1 bit   IC output logic signal.
//
//  Output Ports        Size    Description
//  === ==========        === ==    === =========
//  ic_input            1 bit   Ic input logic signal.
//  data_out            1 bit   Output data
//  so                  1 bit   Serial path to the next boundary scan cell.
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
//-------------------------------------------------------------------------
module DW_bc_7 (
capture_clk,
  update_clk,
  capture_en,
  update_en,
  shift_dr,
  mode1,
  mode2,
  si,
  pin_input,
  control_out,
  output_data,
  ic_input,
  data_out,
  so
);
 
  input  capture_clk;
  input  update_clk;
  input  capture_en;
  input  update_en;
  input  shift_dr;
  input  mode1;
  input  mode2;
  input  si;
  input  pin_input;
  input  control_out;
  input  output_data;
  output ic_input;
  output data_out;
  output so;

  wire m1_sel;
  wire next_so;
  reg  so;
  wire next_update_out;
  reg  update_out;
  wire ic_input;

// synopsys translate_off

  assign  m1_sel  = ((~mode1 ) & control_out );

  assign next_so = (capture_en===1'b1) ? so :
                     ((shift_dr===1'b1) ? si :
                       ((m1_sel===1'b1) ? output_data : ic_input));

  always @(posedge capture_clk) begin : so_proc_PROC
    so <= next_so;
  end

  assign next_update_out = (update_en===1'b1) ? so : update_out;

  always @(posedge update_clk) begin : upd_proc_PROC
    update_out <= next_update_out;
  end

  assign data_out = (mode1===1'b1) ? update_out : output_data;

  assign ic_input = (mode2===1'b1) ? update_out : pin_input;

// synopsys translate_on

endmodule
