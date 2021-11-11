////////////////////////////////////////////////////////////////////////////////
//
//       This confidential and proprietary software may be used only
//     as authorized by a licensing agreement from Synopsys Inc.
//     In the event of publication, the following notice is applicable:
//
//                    (C) COPYRIGHT 2010 - 2016 SYNOPSYS INC.
//                           ALL RIGHTS RESERVED
//
//       The entire notice above must be reproduced on all authorized
//     copies.
//
// AUTHOR:    Alex Tenca  March 2010
//
// VERSION:   Verilog simulation model of DW02_mult with DG 
//
// DesignWare_version: 083e2dec
// DesignWare_release: K-2015.06-DWBB_201506.5.2
//
////////////////////////////////////////////////////////////////////////////////
//-----------------------------------------------------------------------------------
//
// ABSTRACT:  Multiplier with Datapath gating
//           This component is equivalent to DW02_mult when the DG_ctrl input
//           is set to '1'. When DG_ctrl is set to '0' the component output is
//	     not defined, and this simulation model generates 'x' as output.
//
//	FIXED: 
//------------------------------------------------------------------------------

module DW02_mult_DG(A,B,TC,DG_ctrl,PRODUCT);
parameter	A_width = 8;
parameter	B_width = 8;
   
input	[A_width-1:0]	A;
input	[B_width-1:0]	B;
input			TC;
input   DG_ctrl;
output	[A_width+B_width-1:0]	PRODUCT;

  // synopsys translate_off 

wire    [A_width-1:0]   A_DG;
wire    [B_width-1:0]   B_DG;
wire                    TC_DG;

  //-------------------------------------------------------------------------
  // Parameter legality check
  //-------------------------------------------------------------------------

 
  initial begin : parameter_check
    integer param_err_flg;

    param_err_flg = 0;
    
    
    if (A_width < 1) begin
      param_err_flg = 1;
      $display(
	"ERROR: %m :\n  Invalid value (%d) for parameter A_width (lower bound: 1)",
	A_width );
    end
    
    if (B_width < 1) begin
      param_err_flg = 1;
      $display(
	"ERROR: %m :\n  Invalid value (%d) for parameter B_width (lower bound: 1)",
	B_width );
    end 

    if ( param_err_flg == 1) begin
      $display(
        "%m :\n  Simulation aborted due to invalid parameter value(s)");
      $finish;
    end

  end // parameter_check 

     
assign	A_DG = (DG_ctrl)? A : {A_width{1'b0}};
assign	B_DG = (DG_ctrl)? B : {B_width{1'b0}};
assign  TC_DG = (DG_ctrl)? TC : 1'b0;

  // Instance of DW02_mult
  DW02_mult #(A_width,B_width) U1 (.A(A_DG),
       	                           .B(B_DG),
                                   .TC(TC_DG),
                                   .PRODUCT(PRODUCT));
  
   // synopsys translate_on
endmodule


