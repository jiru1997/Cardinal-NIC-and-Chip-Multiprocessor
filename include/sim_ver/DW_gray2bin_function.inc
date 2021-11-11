////////////////////////////////////////////////////////////////////////////////
//
//       This confidential and proprietary software may be used only
//     as authorized by a licensing agreement from Synopsys Inc.
//     In the event of publication, the following notice is applicable:
//
//                    (C) COPYRIGHT 2001 - 2016 SYNOPSYS INC.
//                           ALL RIGHTS RESERVED
//
//       The entire notice above must be reproduced on all authorized
//     copies.
//
// AUTHOR:    Reto Zimmermann    11/14/01
//
// VERSION:   Verilog Inference Functions for DW_gray2bin
//
// DesignWare_version: 47f14ca6
// DesignWare_release: K-2015.06-DWBB_201506.5.2
//
////////////////////////////////////////////////////////////////////////////////
//-----------------------------------------------------------------------------
//
// ABSTRACT:  Gray to Binary Converter
//
// MODIFIED:
//
//-----------------------------------------------------------------------------

function [width-1:0] DWF_gray2bin;

  // synopsys map_to_operator GRAY2BIN_STD_LOGIC_OP
  // synopsys return_port_name B

  input [width-1 : 0] G;

  reg [width : 0] b_v;

    integer i;

  begin

    // synopsys translate_off

     if ((^(G ^ G) !== 1'b0))
	b_v =  {width{1'bx}};
     else begin
	b_v[width] = 1'b0;
	for (i = width-1; i >= 0; i = i-1)
	   b_v[i] = G[i] ^ b_v[i+1];
     end // else: !if((^(G ^ G) !== 1'b0))
     
    DWF_gray2bin = b_v[width-1 : 0];

    // synopsys translate_on

  end

endfunction

//-----------------------------------------------------------------------------
