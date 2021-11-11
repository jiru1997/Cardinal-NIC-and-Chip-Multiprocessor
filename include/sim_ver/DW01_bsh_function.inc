////////////////////////////////////////////////////////////////////////////////
//
//       This confidential and proprietary software may be used only
//     as authorized by a licensing agreement from Synopsys Inc.
//     In the event of publication, the following notice is applicable:
//
//                    (C) COPYRIGHT 1992 - 2016 SYNOPSYS INC.
//                           ALL RIGHTS RESERVED
//
//       The entire notice above must be reproduced on all authorized
//     copies.
//
// AUTHOR:    Igor Oznobikhin
//
// VERSION:   Verilog Simulation Architecture
//
// DesignWare_version: 6bcc669d
// DesignWare_release: K-2015.06-DWBB_201506.5.2
//
////////////////////////////////////////////////////////////////////////////////

//----------------------------------------------------------------------------
//
// ABSTRACT:  Barrel Shifter
//
// MODIFIED: Arvind: Converted module to function      July 30, 1997
//	10/14/1998	Jay Zhu	STAR 59348
//           RPH        07/17/2002 
//                      Rewrote to comply with the new guidelines   
//----------------------------------------------------------------------------

   // New Name

   function [A_width-1:0] DWF_bsh;

      // synopsys map_to_operator BSH_UNS_OP 
      // synopsys return_port_name Z
      
      // port list declaration in order
      input [ A_width- 1: 0] A;
      input [ SH_width- 1: 0] SH;
      
      reg [ A_width- 1: 0]    B;
      integer 		      j;

      begin
	 // synopsys translate_off
	 if ((^(SH ^ SH) !== 1'b0))
	    B = {A_width{1'bx}};
	 else begin  
	    B = A << (SH % A_width);
	    for ( j = 0; j < (SH % A_width) ; j = j+1 )
	       B[j] = A[ A_width - (SH % A_width) + j ];
	 end // else: !if((^(SH ^ SH) !== 1'b0))
	 
	 DWF_bsh = B;
	 // synopsys translate_on  
      end 

   endfunction


//  Backward compatibility for the  old inference name

function [A_width-1:0] DW01_bsh;
   
   // synopsys map_to_operator BSH_UNS_OP 
   // synopsys return_port_name Z
   
   input [ A_width- 1: 0] A;
   input [ SH_width- 1: 0] SH;
   
   begin
      DW01_bsh = DWF_bsh(A,SH);
   end
   
endfunction
