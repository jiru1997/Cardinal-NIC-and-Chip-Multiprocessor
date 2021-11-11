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
// AUTHOR:    PS/RPH  Dec. 21, 1994/Aug 21, 2002
//
// VERSION:   Simulation Architecture
//
// DesignWare_version: 37a473b4
// DesignWare_release: K-2015.06-DWBB_201506.5.2
//
////////////////////////////////////////////////////////////////////////////////
//-----------------------------------------------------------------------------------
//
// ABSTRACT:  Generalized Sum of Products
//           signed or unsigned operands       
//           ie. TC = '1' => signed 
//               TC = '0' => unsigned 
//
// MODIFIED:
//      Bob Tong: 12/07/98 
//                STAR 59142
//
//  RPH 07/17/2002 
//      Rewrote to comply with the new guidelines
//-------------------------------------------------------------------------

module DW02_prod_sum (A,B,TC,SUM);

  parameter A_width = 4;
  parameter B_width = 5;
  parameter num_inputs = 4;
  parameter SUM_width = 12;

  input [num_inputs * A_width-1:0] A;
  input [num_inputs * B_width-1:0] B;
  input TC;
  output [SUM_width-1:0] SUM;
   
   // synopsys translate_off 
  wire [SUM_width-1:0] SUM;

  integer i, j, k;
  reg [SUM_width-1 : 0] SUM_int;
  reg [SUM_width-1 : 0] PROD[num_inputs-1 :0];
  reg [A_width-1:0] A_int;
  reg [B_width-1:0] B_int;
  reg a_sign, b_sign;
  //---------------------------------------------------------------------------
  // Parameter legality check
  //---------------------------------------------------------------------------

  
 
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
      
    if (num_inputs < 1) begin
      param_err_flg = 1;
      $display(
	"ERROR: %m :\n  Invalid value (%d) for parameter num_inputs (lower bound: 1)",
	num_inputs );
    end
      
    if (SUM_width < 1) begin
      param_err_flg = 1;
      $display(
	"ERROR: %m :\n  Invalid value (%d) for parameter SUM_width (lower bound: 1)",
	SUM_width );
    end
  
    if ( param_err_flg == 1) begin
      $display(
        "%m :\n  Simulation aborted due to invalid parameter value(s)");
      $finish;
    end

  end // parameter_check 
  
  

  always @(A or B or TC) 
   begin
     if ((^(A ^ A) !== 1'b0) || (^(B ^ B) !== 1'b0) || (^(TC ^ TC) !== 1'b0) ) 
      begin
        SUM_int = {SUM_width {1'bX}};
      end
     else 
      begin 
        for(i=0; i <= num_inputs-1; i=i+1) 
         begin 
           a_sign = A[(i+1)*A_width-1];
           b_sign = B[(i+1)*B_width-1];
           for(j=i*A_width;j <= (i+1) * A_width-1;j=j+1) 
             A_int[j -i*A_width] = A[j]; 
           for(k=i*B_width;k <= (i+1) * B_width-1;k=k+1) 
             B_int[k -i*B_width] = B[k];
	    
           if (a_sign && TC) 
	      A_int = ~A_int + 1'b1;
           if (b_sign && TC) 
	      B_int = ~B_int + 1'b1;
	    
           PROD[i] = A_int * B_int;
           if ( (a_sign ^ b_sign) && TC) 
             PROD[i] = ~(PROD[i] -1'b1);
         end
        SUM_int = {SUM_width{1'b0}};
        for(i=0; i <= num_inputs-1; i=i+1) 
         begin 
           SUM_int = SUM_int + PROD[i];
         end
     end
   end
  assign SUM = SUM_int;
  // synopsys translate_on

endmodule
