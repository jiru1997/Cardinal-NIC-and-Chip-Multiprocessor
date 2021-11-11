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
// AUTHOR:    Igor Kurilov       07/09/94 04:03am
//
// VERSION:   Simulation Architecture
//
// DesignWare_version: cc0c3fd4
// DesignWare_release: K-2015.06-DWBB_201506.5.2
//
////////////////////////////////////////////////////////////////////////////////
//-----------------------------------------------------------------------------------
//
// ABSTRACT:  Up/Down Binary Counter w. Static  Flag
//           programmable wordlength (width > 0)
//           programmable count_to ( count_to = 1 to 2**width-1)
//
// MODIFIED: 07/14/94 05:53am
//           GN Feb. 16th,1996
//           changed dw03 to DW03
//
//-------------------------------------------------------------------------------

module DW03_bictr_scnto
 (data, up_dn, load, cen, clk, reset, count, tercnt);

  parameter width = 4;
  parameter count_to  = 2;

  input  [width-1 : 0] data;
  input  up_dn, load, cen, clk, reset;
  output [width-1 : 0] count;
  output tercnt;

  reg [width-1 : 0] next_state, cur_state;
  reg [width-1 : 0] en_state, next_count;
  reg tc;

  assign count  = cur_state;
  assign tercnt = tc;

  always @(posedge clk or negedge reset) 
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

    always @(cur_state) tc = count_to == cur_state;

endmodule // DW03_bictr_scnto

