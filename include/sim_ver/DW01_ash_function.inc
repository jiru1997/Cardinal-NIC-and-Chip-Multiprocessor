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
// AUTHOR:    PS         Dec 14, 1994
//
// VERSION:   Simulation Architecture
//
// DesignWare_version: 68b77307
// DesignWare_release: K-2015.06-DWBB_201506.5.2
//
////////////////////////////////////////////////////////////////////////////////
//----------------------------------------------------------------------------
//
// ABSTRACT:  Arithmetic Shifter
//           This component performs left and right shifting.
//           When SH_TC = '0', the shift coefficient SH is interpreted as a
//           positive unsigned number and only left shifts are performed.
//           When SH_TC = '1', the shift coefficient SH is a signed two's
//           complement number. A negative coefficient indicates
//           a right shift (division) and a positive coefficient indicates
//           a left shift (multiplication).
//           The input data A can also be interpreted as an unsigned or signed
//           number.  When DATA_TC = '0', A and B are unsigned numbers.  When
//           DATA_TC = '1', A and B are interpreted as signed two's complement
//           numbers.
//           The coding of A only affects B when right shifts are performed
//           (ie. when SH_TC = '1')  Under these circumstances, B is zero padded
//
//           on the MSBs when A and B are unsigned, and sign extended on the
//           MSBs when A and B are signed two's complement numbers.
//
// MODIFIED: Arvind:   07/31/97 
//                     Converted module to function
//
//	     Jay Zhu   10/14/1998	
//                     SAR 59348
//
//           RPH       07/17/2002 
//                     Rewrote to comply with the new guidelines
//     
//----------------------------------------------------------------------------

function[A_width-1:0] DWF_ash_uns_uns;
 
  // synopsys map_to_operator ASH_UNS_UNS_OP
  // synopsys return_port_name Z

  input [A_width-1:0] A;
  input [SH_width-1:0] SH;

  begin 
  // synopsys translate_off
     
    DWF_ash_uns_uns = ((^(SH ^ SH) !== 1'b0)) ? {A_width{1'bx}} : A << SH;
     
  // synopsys translate_on
  end
endfunction

function[A_width-1:0] DWF_ash_tc_uns;
   
   // synopsys map_to_operator ASH_TC_UNS_OP
   // synopsys return_port_name Z
   
   input [A_width-1:0] A;
   input [SH_width-1:0] SH;
   
   begin 
  // synopsys translate_off
      
      DWF_ash_tc_uns = ((^(SH ^ SH) !== 1'b0)) ? {A_width{1'bx}} : A << SH; 
    
  // synopsys translate_on
   end
endfunction

function[A_width-1:0] DWF_ash_uns_tc;
   
   // synopsys map_to_operator ASH_UNS_TC_OP
   // synopsys return_port_name Z
   
   input [A_width-1:0] A;
   input [SH_width-1:0] SH;
   
   begin
  // synopsys translate_off
      
      DWF_ash_uns_tc = ((^(SH ^ SH) !== 1'b0)) ? {A_width{1'bx}} :
		       (SH[SH_width-1] == 1'b0) ? A << SH :
		       A >> (-SH);
      
  // synopsys translate_on  

   end
endfunction

function[A_width-1:0] DWF_ash_tc_tc;
   
   // synopsys map_to_operator ASH_TC_TC_OP
   // synopsys return_port_name Z
   
   input [A_width-1:0] A;
   input [SH_width-1:0] SH;
   integer 		i;
   reg [A_width-1:0] 	data_out;
   reg [SH_width-1:0] 	sh_abs;
   reg 			data_sign;
   
   begin
  // synopsys translate_off
      
      DWF_ash_tc_tc = ((^(SH ^ SH) !== 1'b0)) ? {A_width{1'bx}} :
		      signed_shift(A, SH);
      
  // synopsys translate_on
   end
endfunction

function [A_width-1 : 0] signed_shift;
   input [A_width-1 : 0] a;
   input [SH_width-1 : 0] sh;
   
   reg [A_width-1 : 0] 	  a_out;
   reg 			  sign;
   reg [SH_width-1 : 0]   sh_abs;
   reg [A_width-1 : 0] 	  data_out;
   integer 		  i;
   
   begin
  // synopsys translate_off
      if(sh[SH_width-1] == 1'b0)           
	 data_out = a << sh;
      else begin  
	 sign = a[A_width-1];
	 sh_abs = sh[SH_width-1] ? (~sh)+1 : sh;
	 a_out = a >> sh_abs;
	 for (i = 0; i < A_width; i = i+1) begin
	    if ((i > A_width-sh_abs-1)||(sh_abs >= A_width))
	       data_out[i] = sign;
	    else
	       data_out[i] = a_out[i];
	 end // for (i = 0; i < A_width; i = i+1)
      end 
      signed_shift = data_out;
      
  // synopsys translate_on
   end
endfunction // signed_shift

//  unified old inference names

function[A_width-1:0] DW_ash_uns_uns;
 
  // synopsys map_to_operator ASH_UNS_UNS_OP
  // synopsys return_port_name Z

  input [A_width-1:0] A;
  input [SH_width-1:0] SH;
 
  begin
    DW_ash_uns_uns = DWF_ash_uns_uns(A,SH);
  end
endfunction

function[A_width-1:0] DW_ash_tc_uns;
 
  // synopsys map_to_operator ASH_TC_UNS_OP
  // synopsys return_port_name Z
 
  input [A_width-1:0] A;
  input [SH_width-1:0] SH;
 
  begin
    DW_ash_tc_uns = DWF_ash_tc_uns(A,SH);
  end
endfunction
 
function[A_width-1:0] DW_ash_uns_tc;
 
  // synopsys map_to_operator ASH_UNS_TC_OP
  // synopsys return_port_name Z
 
  input [A_width-1:0] A;
  input [SH_width-1:0] SH;
 
  begin
    DW_ash_uns_tc = DWF_ash_uns_tc(A,SH);
  end
endfunction
 
function[A_width-1:0] DW_ash_tc_tc;

  // synopsys map_to_operator ASH_TC_TC_OP
  // synopsys return_port_name Z
 
  input [A_width-1:0] A;
  input [SH_width-1:0] SH;
 
  begin
    DW_ash_tc_tc = DWF_ash_tc_tc(A,SH);   
  end
endfunction
