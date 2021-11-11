////////////////////////////////////////////////////////////////////////////////
//
//       This confidential and proprietary software may be used only
//     as authorized by a licensing agreement from Synopsys Inc.
//     In the event of publication, the following notice is applicable:
//
//                    (C) COPYRIGHT 2005 - 2016 SYNOPSYS INC.
//                           ALL RIGHTS RESERVED
//
//       The entire notice above must be reproduced on all authorized
//     copies.
//
// AUTHOR:    Alexandre F. Tenca
//
// VERSION:   Verilog Simulation Architecture
//
// DesignWare_version: 842f44cc
// DesignWare_release: K-2015.06-DWBB_201506.5.2
//
////////////////////////////////////////////////////////////////////////////////

//----------------------------------------------------------------------------
// ABSTRACT:  Bidirectional Barrel Shifter - Prefers Left direction
//           This component performs left and right rotation.  
//           When SH_TC = '0', the rotation coefficient SH is interpreted as a
//	     positive unsigned number and only left rotation is performed.
//           When SH_TC = '1', the rotation coefficient SH is interpreted as a 
//           signed two's complement number. A negative coefficient indicates
//           a right rotation and a positive coefficient indicates a left rotation.
//           The input data A is always considered as a simple bit vector (unsigned).
//
// MODIFIED:  
//
//----------------------------------------------------------------------------

function[A_width-1:0] DWF_rbsh_uns;
 
  // synopsys map_to_operator BSHR_UNS_OP
  // synopsys return_port_name Z

  input [A_width-1:0] A;
  input [SH_width-1:0] SH;
  reg   [SH_width-1:0] SHMIN;
  begin 
  // synopsys translate_off

    SHMIN = SH;                                          // compute minimum rotat distance
    while (SHMIN > A_width) SHMIN = SHMIN-A_width;
    DWF_rbsh_uns = ((^(SH ^ SH) !== 1'b0)) ? {A_width{1'bx}} : 
			(($unsigned(A) >> SHMIN) | ($unsigned(A) << (A_width-SHMIN)));
     
  // synopsys translate_on
  end
endfunction

function[A_width-1:0] DWF_rbsh_tc;
   
   // synopsys map_to_operator BSHR_TC_OP
   // synopsys return_port_name Z
   
   input [A_width-1:0] A;
   input [SH_width-1:0] SH;
   reg   [SH_width-1:0] SHMIN;
   reg [SH_width : 0] sh_abs;
   reg [A_width-1 : 0] 	data_out;
   
   begin 
  // synopsys translate_off
      
      sh_abs = SH[SH_width-1] ? (~{SH[SH_width-1],SH})+1 : {SH[SH_width-1],SH};
      SHMIN = sh_abs;                                     // compute minimum rotat distance
      while (SHMIN > A_width) SHMIN = SHMIN-A_width;
      if(SH[SH_width-1] == 1'b0)           
         data_out = ($unsigned(A) >> SHMIN) | ($unsigned(A) << (A_width-SHMIN));
      else  
        data_out = ($unsigned(A) << SHMIN) | ($unsigned(A) >> (A_width-SHMIN));
      
      DWF_rbsh_tc = ((^(SH ^ SH) !== 1'b0)) ? {A_width{1'bx}} : data_out; 
    
  // synopsys translate_on
   end
endfunction
