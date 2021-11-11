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
// AUTHOR:    Rick Kelly, Neel Desai             April 23, 1996
//
// VERSION:   Simulation Architecture
//
// NOTE:      This is an OBSOLETE component and is not supported in
//            future releases of the DesignWare Foundation Library.
//            This component is NOT for use in new designs
//
//            Consider using the DW_div component in place of this one.
//
// NOTE:      This is a subentity.
//            This file is for internal use only.
//
// DesignWare_version: a1015347
// DesignWare_release: K-2015.06-DWBB_201506.5.2
//
////////////////////////////////////////////////////////////////////////////////
//-----------------------------------------------------------------------------------
//
// ABSTRACT: Function Descriptions for Verilog
//
//           Various Divider function descriptions
//           Used for synthesis inference of operators,
//           and for behavioral Verilog simulation.
//
//           The following functions are declared:
//
//           DWF_divide_tc(a,b,divide_by_0)  
//           DWF_divide_uns(a,b,divide_by_0)
//
// MODIFIED : - 
//	10/14/1998	Jay Zhu	STAR 59348
//	04/04/2000      Reto Zimmermann         pre-obsoleted
// 
//------------------------------------------------------------------------------

  // pass "a_width" and "b_width" parameters to the inference functions
  parameter a_width = (A_width >= B_width) ? A_width : B_width;
  parameter b_width = B_width;

  // include modeling functions
`include "DW_div_function.inc"

  function [A_width-1 : 0] DWF_divide_uns;
    input [A_width-1 : 0] A; 
    input [B_width-1 : 0] B;
    reg [a_width-1 : 0] A_v;
    reg [a_width-1 : 0] Q_v;
    begin
      A_v = {a_width{1'b0}};
      A_v[A_width-1 : 0] = A;
      Q_v = DWF_div_uns (A_v, B);
      DWF_divide_uns = Q_v[A_width-1 : 0];
    end
  endfunction

  function [A_width-1 : 0] DWF_divide_tc;
    input [A_width-1 : 0] A; 
    input [B_width-1 : 0] B; 
    reg [a_width-1 : 0] A_v;
    reg [a_width-1 : 0] Q_v;
    begin
      A_v = {a_width{A[A_width-1]}};
      A_v[A_width-1 : 0] = A;
      Q_v = DWF_div_tc (A_v, B);
      DWF_divide_tc = {Q_v[a_width-1], Q_v[A_width-2 : 0]};
    end
  endfunction

  function [A_width-1 : 0] div_uns;
    input [A_width-1 : 0] A; 
    input [B_width-1 : 0] B; 
    reg [a_width-1 : 0] A_v;
    reg [a_width-1 : 0] Q_v;
    begin
      A_v = {a_width{1'b0}};
      A_v[A_width-1 : 0] = A;
      Q_v = DWF_div_uns (A_v, B);
      div_uns = Q_v[A_width-1 : 0];
    end
  endfunction

  function [A_width-1 : 0] div_tc;
    input [A_width-1 : 0] A; 
    input [B_width-1 : 0] B; 
    reg [a_width-1 : 0] A_v;
    reg [a_width-1 : 0] Q_v;
    begin
      A_v = {a_width{A[A_width-1]}};
      A_v[A_width-1 : 0] = A;
      Q_v = DWF_div_tc (A_v, B);
      div_tc = {Q_v[a_width-1], Q_v[A_width-2 : 0]};
    end
  endfunction
