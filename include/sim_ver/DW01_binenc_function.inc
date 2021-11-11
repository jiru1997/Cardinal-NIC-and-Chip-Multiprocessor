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
// AUTHOR:    PS			Dec. 14, 1994
//
// VERSION:   Simulation Architecture
//
// DesignWare_version: b34b0ae9
// DesignWare_release: K-2015.06-DWBB_201506.5.2
//
////////////////////////////////////////////////////////////////////////////////
//----------------------------------------------------------------------------
//
// ABSTRACT:  Binary Encoder
//
// MODIFIED: 
//  Arvind:         10/14/1998
//                  Converted Module to function 07/31/97
//  Jay Zhu	
//                  STAR 59348
//
//  Rick Kelly      05/10/2000  
//                  Consistency with VHDL code for STAR 103007
//
//  RPH             07/17/2002 
//                  Rewrote to comply with the new guidelines
//
//----------------------------------------------------------------------------

function[ADDR_width-1:0] DWF_binenc;

  // synopsys map_to_operator BINENC_UNS_OP
  // synopsys return_port_name Z 
  
    input [A_width-1:0] A;
    reg [ADDR_width-1:0] temp;
    integer flag,i;
  begin
    // synopsys translate_off
    temp = -1;
    flag = 0;
    for (i=0;  (!flag) && i<=A_width-1; i=i+1) begin
      if (A[i] === 1'b1) begin
	 flag = 1;
         temp = i;
      end else begin
	if (A[i] === 1'bX) begin
	 flag = 1;
         temp = {ADDR_width{1'bX}};
	end
      end
    end
    // synopsys translate_on
    DWF_binenc = temp;
  end
endfunction


//  unified old inference name

function[ADDR_width-1:0] DW_binenc;

  // synopsys map_to_operator BINENC_UNS_OP
  // synopsys return_port_name Z 
 
  input [A_width-1:0] A;
 
  begin
    DW_binenc = DWF_binenc(A);
  end
endfunction
