////////////////////////////////////////////////////////////////////////////////
//
//       This confidential and proprietary software may be used only
//     as authorized by a licensing agreement from Synopsys Inc.
//     In the event of publication, the following notice is applicable:
//
//                    (C) COPYRIGHT 1995 - 2016 SYNOPSYS INC.
//                           ALL RIGHTS RESERVED
//
//       The entire notice above must be reproduced on all authorized
//     copies.
//
// AUTHOR:    PS/RPH  Dec. 21, 1994/Aug 21, 2002
//
// VERSION:   Simulation Architecture
//
// DesignWare_version: 9596f04a
// DesignWare_release: K-2015.06-DWBB_201506.5.2
//
////////////////////////////////////////////////////////////////////////////////
//-----------------------------------------------------------------------------------
//
// ABSTRACT:  Multiplier-Adder
//           signed or unsigned operands       
//           ie. TC = '1' => signed 
//               TC = '0' => unsigned 
//
// MODIFIED:
//      Bob Tong: 12/07/98 
//                STAR 59142
//  RPH 07/17/2002 
//      Rewrote to comply with the new guidelines
//
//  DLL 03/21/2006
//      Replaced behavioral code 'always' block with DW02_prod_sum1.h
//
//
//----------------------------------------------------------------------
module DW02_prod_sum1 (A,B,C,TC,SUM);
   
  parameter A_width = 8;
  parameter B_width = 8;
  parameter SUM_width = 16;

  input [A_width-1:0] A;
  input [B_width-1:0] B;
  input [SUM_width-1:0] C;
  input TC;
  output [SUM_width-1:0] SUM;
  
   // synopsys translate_off 
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
  

  integer i,j;
  reg [SUM_width-1:0] temp1,temp2;
  reg [SUM_width-1:0] prod2,prodsum;
  reg [A_width+B_width-1:0] prod1;
  reg [A_width-1:0] abs_a;
  reg [B_width-1:0] abs_b;

  always @(A or B or C or TC) 
   begin
     abs_a = (A[A_width-1])? (~A + 1'b1) : A;
     abs_b = (B[B_width-1])? (~B + 1'b1) : B;
 
     temp1 = abs_a * abs_b;
     temp2 = ~(temp1 - 1'b1);
 
     prod1 = (TC) ? (((A[A_width-1] ^ B[B_width-1]) && (|temp1))?
              temp2 : temp1) : A*B;
 
     if ((^(A ^ A) !== 1'b0) || (^(B ^ B) !== 1'b0) || (^(C ^ C) !== 1'b0) || (^(TC ^ TC) !== 1'b0) )
       prodsum = {SUM_width {1'bX}};
     else if (TC === 1'b0)
       prodsum = prod1+C;
     else 
      begin
        if (SUM_width >= A_width+B_width)
         begin
           j = A_width+B_width-1;
           for(i=(A_width+B_width-1); i>=0; i=i-1)
            begin
              prod2[i] = prod1[j];
              j = j-1;
            end
           if (SUM_width > A_width+B_width)
            begin
              if (prod1[A_width+B_width-1])
               begin
                 for(i=(SUM_width-1); i>=(A_width+B_width); i=i-1)
                  begin
                    prod2[i] = 1'b1;
                  end
               end
              else
               begin
                 for(i=(SUM_width-1); i>=(A_width+B_width); i=i-1)
                  begin
                    prod2[i] = 1'b0;
                  end
               end
            end
         end
        else
         begin
           for(i=(SUM_width-1);i>=0;i=i-1)
            begin
              prod2[i] = prod1[i];
            end
         end
        prodsum = prod2+C;
      end
   end
  assign SUM = prodsum;
  // synopsys translate_on 
endmodule


