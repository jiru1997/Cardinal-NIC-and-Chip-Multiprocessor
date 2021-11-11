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
// DesignWare_version: def453cb
// DesignWare_release: K-2015.06-DWBB_201506.5.2
//
////////////////////////////////////////////////////////////////////////////////
//-----------------------------------------------------------------------------------
//
// ABSTRACT:  Priority Encoder
//
// MODIFIED: Arvind: Converted module to function 07/31/97
//	10/14/1998	Jay Zhu	STAR 59348
//           RPH        07/17/2002 
//                      Rewrote to comply with the new guidelines
//--------------------------------------------------------------------------

function[INDEX_width-1:0] DWF_prienc;

  // synopsys map_to_operator PRIENC_UNS_OP
  // synopsys return_port_name Z 

  input [A_width-1:0] A;
  reg [INDEX_width-1:0] temp;
  reg flag;
  integer i;

  begin
    // synopsys translate_off
    temp = 0;
    flag = 0;
    for (i=A_width-1; flag == 0 && i>=0; i=i-1) begin
      if (A[i] === 1'b1) begin
        flag = 1;
        temp = i+1;
      end else begin
	if (A[i] === 1'bX) begin
          flag = 1;
	  temp = {INDEX_width{1'bX}};
	end
      end
    end
    // synopsys translate_on
    DWF_prienc = temp;
  end
endfunction


//  unified old inference name

function[INDEX_width-1:0] DW_prienc;
 
  // synopsys map_to_operator PRIENC_UNS_OP
  // synopsys return_port_name Z 

  input [A_width-1:0] A;
 
  begin
    DW_prienc = DWF_prienc(A);
  end
endfunction
