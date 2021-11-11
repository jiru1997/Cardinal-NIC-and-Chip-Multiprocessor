////////////////////////////////////////////////////////////////////////////////
//
//       This confidential and proprietary software may be used only
//     as authorized by a licensing agreement from Synopsys Inc.
//     In the event of publication, the following notice is applicable:
//
//                    (C) COPYRIGHT 1998 - 2016 SYNOPSYS INC.
//                           ALL RIGHTS RESERVED
//
//       The entire notice above must be reproduced on all authorized
//     copies.
//
// AUTHOR:    Sourabh Tandon                        Dec. 8, 1998
//
// VERSION:   Simulation Architecture
//
// NOTE:      This is a subentity.
//            This file is for internal use only.
//
// DesignWare_version: d85d9a1f
// DesignWare_release: K-2015.06-DWBB_201506.5.2
//
////////////////////////////////////////////////////////////////////////////////
//-----------------------------------------------------------------------------------
//
// ABSTRACT: Generic Control/Force test point - Simulation Model
//
// MODIFIED: 
//           Reto Zimmermann            Nov 05, 1999
//           Changed blocking to non-blocking assignment
//
//----------------------------------------------------------------------------

module DW_observ_dgen (OBIN, CLK, TDGO);

input  OBIN;
input  CLK;
output TDGO;
reg    TDGO;

always@(posedge CLK)
    begin
       TDGO <= OBIN;
    end

endmodule
