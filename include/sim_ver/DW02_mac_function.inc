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
// AUTHOR:    Anatoly Sokhatsky               July 13, 1994
//
// VERSION:   Simulation Architecture
//
// DesignWare_version: cbe594bf
// DesignWare_release: K-2015.06-DWBB_201506.5.2
//
////////////////////////////////////////////////////////////////////////////////
//-----------------------------------------------------------------------------------
//
// ABSTRACT: Multiplier-Accumulator. Behavior model.
//           (A_width Bits * B_width Bits) + (A_width+B_width Bits)
//             => A_width+B_width Bits
//           signed or unsigned operands
//           ie. TC = '1' => signed
//	         TC = '0' => unsigned
//      
// MODIFIED: 
// Arvind:  07/31/97
//          Converted module to function
//   
// Jay Zhu  10/14/1998		
//          STAR 59348
//   
//  RPH     07/17/2002 
//          Rewrote to comply with the new guidelines
//
//------------------------------------------------------------------------------

function[A_width+B_width- 1: 0] DWF_mac_uns;

  // synopsys map_to_operator MAC_UNS_OP
  // synopsys return_port_name Z

  // port list declaration in order
  input [ A_width- 1: 0] A;
  input [ B_width- 1: 0] B;
  input [ A_width+B_width- 1: 0] C;

   begin
    // synopsys translate_off  
    DWF_mac_uns = ((^(A ^ A) !== 1'b0) || (^(B ^ B) !== 1'b0) || (^(C ^ C) !== 1'b0)) ? {A_width+B_width{1'bx}}
		  : A*B+C;
   // synopsys translate_on   
  end
endfunction

function[A_width+B_width- 1: 0] DWF_mac_tc;

  // synopsys map_to_operator MAC_TC_OP
  // synopsys return_port_name Z
 
  // port list declaration in order
  input [ A_width- 1: 0] A;
  input [ B_width- 1: 0] B;
  input [ A_width+B_width- 1: 0] C;
  reg sign;

   begin
      // synopsys translate_off
      if ((^(A ^ A) !== 1'b0) || (^(B ^ B) !== 1'b0) || (^(C ^ C) !== 1'b0)) begin
	 DWF_mac_tc = {A_width+B_width{1'bx}};
      end // if ((^(A ^ A) !== 1'b0) || (^(B ^ B) !== 1'b0) || (^(C ^ C) !== 1'b0))
      else begin
	 sign = A[A_width-1] ^ B[B_width-1];   // generate sign bit of output
	 if (A[A_width-1] == 1'b1) A = -A;     // convert A to unsigned
	 if (B[B_width-1] == 1'b1) B = -B;     // convert B to unsigned

	 DWF_mac_tc = A * B;   // perform unsigned multiply
	 if (sign == 1'b1) DWF_mac_tc = -DWF_mac_tc;  // if result is -ve, return
                                                // 2's complement
	 DWF_mac_tc = DWF_mac_tc+C;
      end // else: !if((^(A ^ A) !== 1'b0) || (^(B ^ B) !== 1'b0) || (^(C ^ C) !== 1'b0))
     // synopsys translate_on 
   end
endfunction


//  unified old inference name

function[A_width+B_width- 1: 0] DW_mac_uns;
 
  // synopsys map_to_operator MAC_UNS_OP
  // synopsys return_port_name Z

  input [ A_width- 1: 0] A;
  input [ B_width- 1: 0] B;
  input [ A_width+B_width- 1: 0] C;
 
  begin
    DW_mac_uns = DWF_mac_uns(A,B,C);
  end
endfunction
 
function[A_width+B_width- 1: 0] DW_mac_tc;
 
  // synopsys map_to_operator MAC_TC_OP
  // synopsys return_port_name Z
 
  input [ A_width- 1: 0] A;
  input [ B_width- 1: 0] B;
  input [ A_width+B_width- 1: 0] C;
 
  begin
    DW_mac_tc = DWF_mac_tc(A,B,C);
  end
endfunction

