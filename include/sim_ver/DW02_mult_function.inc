////////////////////////////////////////////////////////////////////////////////
//
//       This confidential and proprietary software may be used only
//     as authorized by a licensing agreement from Synopsys Inc.
//     In the event of publication, the following notice is applicable:
//
//                    (C) COPYRIGHT 1996 - 2016 SYNOPSYS INC.
//                           ALL RIGHTS RESERVED
//
//       The entire notice above must be reproduced on all authorized
//     copies.
//
// AUTHOR:    Neel Desai, Dave Greenberg		February 29, 1996
//
// VERSION:   Simulation Architecture
//
// NOTE:      This is a subentity.
//            This file is for internal use only.
//
// DesignWare_version: 9eeb38ba
// DesignWare_release: K-2015.06-DWBB_201506.5.2
//
////////////////////////////////////////////////////////////////////////////////
//-----------------------------------------------------------------------------------
//
// ABSTRACT: Function Descriptions for Verilog
//
//           Various Multiplier function descriptions
//           Used for synthesis inference of operators,
//           and for behavioral Verilog simulation.
//
//           The following functions are declared:
//
//           DWF_mult_tc(a,b)  
//           DWF_mult_uns(a,b)
//
// MODIFIED : - 
//	10/14/1998	Jay Zhu	STAR 59348
//
// MODIFIED : - 
//	03/08/2010	Rick Kelly - removed obsolete inference functions
//
//------------------------------------------------------------------------------

// mult_tc(a,b) and mult_uns(a,b) are the base signed and unsigned multiplies
// used in all the other multiply functions


function [A_width+B_width-1 : 0] DWF_mult_tc;
// Function to perform a signed (two's complement) multiplication 

// synopsys map_to_operator MULT_TC_OP 
// synopsys return_port_name Z

input [A_width-1:0] A; 
input [B_width-1:0] B; 

reg sign;

begin
  // synopsys translate_off
  sign = A[A_width-1] ^ B[B_width-1];   // generate sign bit of output

  if (A[A_width-1] == 1'b1) A = ~A + 1'b1;   // convert A to unsigned
  if (B[B_width-1] == 1'b1) B = ~B + 1'b1;   // convert B to unsigned

  DWF_mult_tc = A * B;   // perform unsigned multiply

  if (sign == 1'b1) DWF_mult_tc = ~DWF_mult_tc + 1'b1;   // if result is -ve, return  
                                                 // 2's complement 
  // synopsys translate_on 
end

endfunction


function [A_width+B_width-1 : 0] DWF_mult_uns;
// Function to perform an unsigned multiplication 

// synopsys map_to_operator MULT_UNS_OP 
// synopsys return_port_name Z

input [A_width-1:0] A; 
input [B_width-1:0] B; 

begin
  // synopsys translate_off

  DWF_mult_uns = A * B;   // perform unsigned multiply

  // synopsys translate_on 
end

endfunction


//  unified old inference names

function [A_width+B_width-1 : 0] mult_tc;
 
// synopsys map_to_operator MULT_TC_OP 
// synopsys return_port_name Z

input [A_width-1:0] A;
input [B_width-1:0] B;
 
begin
  mult_tc = DWF_mult_tc(A,B);   
end
 
endfunction

function [A_width+B_width-1 : 0] mult_uns;
 
// synopsys map_to_operator MULT_UNS_OP 
// synopsys return_port_name Z

input [A_width-1:0] A;
input [B_width-1:0] B;
 
begin
  mult_uns = DWF_mult_uns(A,B);  
end
 
endfunction

