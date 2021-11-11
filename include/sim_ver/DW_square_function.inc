////////////////////////////////////////////////////////////////////////////////
//
//       This confidential and proprietary software may be used only
//     as authorized by a licensing agreement from Synopsys Inc.
//     In the event of publication, the following notice is applicable:
//
//                    (C) COPYRIGHT 1999 - 2016 SYNOPSYS INC.
//                           ALL RIGHTS RESERVED
//
//       The entire notice above must be reproduced on all authorized
//     copies.
//
// AUTHOR:    Rick Kelly		February 4, 1999
//
// VERSION:   Simulation Architecture
//
// NOTE:      This is a subentity.
//            This file is for internal use only.
//
// DesignWare_version: ed94cc17
// DesignWare_release: K-2015.06-DWBB_201506.5.2
//
////////////////////////////////////////////////////////////////////////////////
//-----------------------------------------------------------------------------------
//
// ABSTRACT: Verilog inference functions for DW_square
//

function [width*2-1 : 0] DWF_square_tc;
// Function to perform a signed (two's complement) square 

// synopsys map_to_operator SQR_TC_OP 
// synopsys return_port_name SQUARE

input [width-1:0] A; 

begin
  // synopsys translate_off

  if (A[width-1] == 1'b1) A = ~A + 1'b1;   // convert to unsigned

  DWF_square_tc = A * A;   // perform unsigned multiply

  // synopsys translate_on 
end

endfunction


function [width*2-1 : 0] DWF_square_uns;
// Function to perform an unsigned square 

// synopsys map_to_operator SQR_UNS_OP 
// synopsys return_port_name SQUARE

input [width-1:0] A; 

begin
  // synopsys translate_off

  DWF_square_uns = A * A;   // perform unsigned multiply

  // synopsys translate_on 
end

endfunction

