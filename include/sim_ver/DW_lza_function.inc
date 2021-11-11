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
// DesignWare_version: eef84c1d
// DesignWare_release: K-2015.06-DWBB_201506.5.2
//
////////////////////////////////////////////////////////////////////////////////
//-----------------------------------------------------------------------------------
//
// ABSTRACT:  Leading Zeroes Anticipator
//
// MODIFIED: Bruce Dean 090707
//--------------------------------------------------------------------------
function [addr_width-1:0] DWF_lza ;
// synopsys map_to_operator LZA_CNT_STD_LOGIC_OP
// synopsys return_port_name Z
input [width-1:0] A;
input [width-1:0] B;
integer pos,i;
reg lza;
begin
// synopsys translate_off
  if(A == B)  
    pos = {width{1'B1}};
  else
    for (i = width-1; i >=0; i=i-1) begin
      if(i == 0)
        lza =  (A[i]&!B[i])|(!A[i]&B[i]);      
      else
        lza = ((A[i]&!B[i])&!(!A[i-1]&B[i-1]))|((!A[i]&B[i])&!(!A[i-1]&B[i-1]));
      if (lza === 1) begin
        pos = width -i-1; 
        i   = -1;
      end else
        pos = {width{1'b1}};
    end
// synopsys translate_on
DWF_lza = pos;
end
endfunction // DWF_lza
