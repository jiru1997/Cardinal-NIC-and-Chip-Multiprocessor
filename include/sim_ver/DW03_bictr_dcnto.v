////////////////////////////////////////////////////////////////////////////////
//
//       This confidential and proprietary software may be used only
//     as authorized by a licensing agreement from Synopsys Inc.
//     In the event of publication, the following notice is applicable:
//
//                    (C) COPYRIGHT 1994 - 2016 SYNOPSYS INC.
//                           ALL RIGHTS RESERVED
//
//       The entire notice above must be reproduced on all authorized
//     copies.
//
// AUTHOR:    Igor Kurilov       07/07/94 04:14am
//
// VERSION:   Simulation Architecture
//
// DesignWare_version: ab59c881
// DesignWare_release: K-2015.06-DWBB_201506.5.2
//
////////////////////////////////////////////////////////////////////////////////
//-----------------------------------------------------------------------------------
//
// ABSTRACT:  Up/Down Binary Counter w. Dynamic Flag
//           programmable wordlength (width > 0)
//           programmable count_to (count_to = 1 to 2**width-1)
//
// MODIFIED: 07/14/94 06:02am
//           GN Feb. 16th, 1996
//           changed DW03 to DW03
//           remove $generic and $end_generic
//           defined width=8
//
//
//-------------------------------------------------------------------------------

module DW03_bictr_dcnto
 (data, count_to, up_dn, load, cen, clk, reset, count, tercnt);

  parameter width = 8;

  input  [width-1 : 0] data, count_to;
  input  up_dn, load, cen, clk, reset;
  output [width-1 : 0] count;
  output tercnt;

  reg [width-1 : 0] next_state, cur_state;
  reg [width-1 : 0] en_state, next_count;
  reg tc;

  assign count  = cur_state;
  assign tercnt = tc;
   
  always @ (posedge clk or negedge reset)
    begin
      if (reset === 1'b0)
        begin
          cur_state <= {width{1'b0}};
        end
      else
        begin
          cur_state <= next_state;
        end
    end

  always
    begin
      next_state <= (load == 1'b0) ? data : en_state;
      next_count <= (up_dn == 1'b1) ? (cur_state + 1'b1) : (cur_state - 1'b1);

      en_state <= (cen == 1'b1) ? next_count : cur_state;

      @(cur_state
        or data
        or load
        or up_dn
        or cen
        or next_count
        or en_state);
    end

    always @(count_to or cur_state) tc = count_to == cur_state;

endmodule // DW03_bictr_dcnto

