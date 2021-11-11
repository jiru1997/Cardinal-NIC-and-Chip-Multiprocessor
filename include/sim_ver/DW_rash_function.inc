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
// AUTHOR:    Alexandre Tenca       February 11, 2005
//
// VERSION:   Simulation Architecture
//
// DesignWare_version: 7de4e8ec
// DesignWare_release: K-2015.06-DWBB_201506.5.2
//
////////////////////////////////////////////////////////////////////////////////
//----------------------------------------------------------------------------
//
// ABSTRACT: Arithmetic Shifter with preferred right direction - DW_rash
//           This component performs left and right shifting.  
//           When SH_TC = '0', the shift coefficient SH is interpreted as a
//	     positive unsigned number and only right shifts are performed.
//           When SH_TC = '1', the shift coefficient SH is a signed two's 
//           complement number. A negative coefficient indicates
//           a left shift (multiplication) and a positive coefficient indicates
//           a right shift (division).
//           The input data A can also be interpreted as an unsigned or signed
//           number.  When DATA_TC = '0', a logical shift operation is performed on A.  
//           When DATA_TC = '1', a arithmetic shift operation is performed on A.
//           The logical or arithmetic shift is performed on A independent of its 
//           data type (signed or unsigned).
//
// MODIFIED: 
//           3/8/2007: Fix signdness of left operator for selectop used in 
//                     DWF_rash_tc_uns. The most recent VCS simulator is 
//                     generating an output as a logical shifter was applied.
//                     According to VCS team, when one of the inputs of the
//                     selectop is unsigned (that is the case), the output 
//                     of the operation is unsigned, and the arithmetic 
//                     shift is treated as a logical shift.
//
//----------------------------------------------------------------------------

function[A_width-1:0] DWF_rash_uns_uns;
 
  // synopsys map_to_operator ASHR_UNS_UNS_OP
  // synopsys return_port_name Z

  input [A_width-1:0] A;
  input [SH_width-1:0] SH;

  begin 
  // synopsys translate_off
     
    DWF_rash_uns_uns = ((^(SH ^ SH) !== 1'b0)) ? {A_width{1'bx}} : A >> SH;
     
  // synopsys translate_on
  end
endfunction

function[A_width-1:0] DWF_rash_tc_uns;
   
   // synopsys map_to_operator ASHR_TC_UNS_OP
   // synopsys return_port_name Z
   
   input [A_width-1:0] A;
   input [SH_width-1:0] SH;
   
   begin 
  // synopsys translate_off
      
      DWF_rash_tc_uns = ((^(SH ^ SH) !== 1'b0)) ? 
                        $signed({A_width{1'bx}}) : $signed(A) >>> SH; 
    
  // synopsys translate_on
   end
endfunction

function[A_width-1:0] DWF_rash_uns_tc;
   
   // synopsys map_to_operator ASHR_UNS_TC_OP
   // synopsys return_port_name Z
   
   input [A_width-1:0] A;
   input [SH_width-1:0] SH;
   
   begin
  // synopsys translate_off
      
      DWF_rash_uns_tc = ((^(SH ^ SH) !== 1'b0)) ? {A_width{1'bx}} :
		       (SH[SH_width-1] == 1'b0) ? A >> SH :
		       A << (-SH);
      
  // synopsys translate_on  

   end
endfunction

function[A_width-1:0] DWF_rash_tc_tc;
   
   // synopsys map_to_operator ASHR_TC_TC_OP
   // synopsys return_port_name Z
   
   input [A_width-1:0] A;
   input [SH_width-1:0] SH;
   integer 		i;
   reg [A_width-1:0] 	data_out;
   reg [SH_width-1:0] 	sh_abs;
   reg 			data_sign;
   
   begin
  // synopsys translate_off
      
      DWF_rash_tc_tc = ((^(SH ^ SH) !== 1'b0)) ? {A_width{1'bx}} :
		      signed_shift(A, SH);
      
  // synopsys translate_on
   end
endfunction

function [A_width-1 : 0] signed_shift;
   input [A_width-1 : 0] a;
   input [SH_width-1 : 0] sh;
   
   reg 			  sign;
   reg [SH_width-1 : 0]   sh_abs;
   reg [A_width-1 : 0] 	  data_out;
   
   begin
  // synopsys translate_off
      if(sh[SH_width-1] == 1'b0)           
	 data_out = $signed(a) >>> sh;
      else begin  
	 sign = a[A_width-1];
	 sh_abs = sh[SH_width-1] ? (~sh)+1 : sh;
	 data_out = a << sh_abs;
      end 
      signed_shift = data_out;
      
  // synopsys translate_on
   end
endfunction // signed_shift

