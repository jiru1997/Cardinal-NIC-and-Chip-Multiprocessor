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
// AUTHOR:    Poliakov A.                July. 14, 1994 
//
// VERSION:   Simulation Architecture
//
// DesignWare_version: fb120bf5
// DesignWare_release: K-2015.06-DWBB_201506.5.2
//
////////////////////////////////////////////////////////////////////////////////
//-----------------------------------------------------------------------------------
//
// ABSTRACT:  Decrementer
//           The n-bit address A decodes to 2**n lines.
//           The selected bit in port B is active high.
//
//           eg. n=3
//           A(2:0)        B(7:0)
//           000        -> 00000001
//           001        -> 00000010
//           010        -> 00000100
//           011        -> 00001000
//           100        -> 00010000
//           101        -> 00100000
//           110        -> 01000000
//           111        -> 10000000
//
//
// MODIFIED: Arvind: Converted module to function 07/30/97
//	10/14/1998	Jay Zhu	STAR 59348
//           RPH        07/17/2002 
//                      Rewrote to comply with the new guidelines
//------------------------------------------------------------------------------


function[(1<<width)-1:0] DWF_decode;

 // synopsys map_to_operator BINDEC_UNS_OP
 // synopsys return_port_name Z

 input[width-1:0]A;
 
 //process decoding
 begin
  // synopsys translate_off
  DWF_decode = ((^(A ^ A) !== 1'b0)) ? {(1 << width){1'bx}} : (1 << A);
  // synopsys translate_on
 end
endfunction 


//  unified old inference name

function[(1<<width)-1:0] DW_decode;
 
 // synopsys map_to_operator BINDEC_UNS_OP
 // synopsys return_port_name Z

 input[width-1:0]A;
 
 begin
  // synopsys translate_off
  DW_decode = DWF_decode(A);
  // synopsys translate_on
 end
endfunction
