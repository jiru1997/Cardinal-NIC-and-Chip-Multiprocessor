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
// VERSION:   Verilog Inference Functions for DW_inc_gray
//
// DesignWare_version: 577bdac2
// DesignWare_release: K-2015.06-DWBB_201506.5.2
//
////////////////////////////////////////////////////////////////////////////////
//-----------------------------------------------------------------------------
//
// ABSTRACT:  Gray incrementer
//
// MODIFIED:
//
//-----------------------------------------------------------------------------

function [width-1:0] DWF_inc_gray;

  // synopsys map_to_operator INC_GRAY_STD_LOGIC_OP
  // synopsys return_port_name Z

  input [width-1 : 0] A;
  input               CI;

  reg [width : 0] ab_v;
  reg [width-1 : 0] zb_v;
  reg [width-1 : 0] z_v;

  integer i;

  begin

    // synopsys translate_off

     if ((^(A ^ A) !== 1'b0) || (^(CI ^ CI) !== 1'b0))
	z_v = {width{1'bx}};
     else begin
	ab_v[width] = 1'b0;
	for (i = width-1; i >= 0; i = i-1)
	   ab_v[i] = A[i] ^ ab_v[i+1];

	zb_v = ab_v[width-1 : 0] + CI;

	z_v = zb_v ^ (zb_v >> 1);
     end // else: !if((^(a ^ a) !== 1'b0))
     
    DWF_inc_gray = z_v;

    // synopsys translate_on

  end

endfunction

//-----------------------------------------------------------------------------
