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
// AUTHOR:    SS
//
// VERSION:   Simulation Architecture
//
// DesignWare_version: edd7e841
// DesignWare_release: K-2015.06-DWBB_201506.5.2
//
////////////////////////////////////////////////////////////////////////////////
//-----------------------------------------------------------------------------------
//
// ABSTRACT:  Carry Save Adder
//
// MODIFIED: 
//           RPH        07/17/2002 
//                      Rewrote to comply with the new guidelines
//
//           RJK        09/19/2007 
//                      Added special case for width = 1 (STAR 9000190460)
//---------------------------------------------------------------------------

module DW01_csa (a,b,c,ci,carry,sum,co);

  parameter width=4;

  // port decalrations

  input  [width-1 : 0]   a,b,c;
  input                  ci;
   
  output [width-1 : 0]   carry,sum;
  output                 co;

  // synopsys translate_off 
  reg [width-1 : 0]   carry,sum;
  reg                 co;
   
   task DWF_csa;
      input [width-1 : 0] a,b,c;
      input 		  ci;
      output [width-1 : 0] carry,sum;
      output 		   co;
      reg [width-1 : 0] carry,sum;
      reg 		   co;       
      integer 		   i;
      begin	 
	 carry[0] = c[0];
	 carry[1] = (a[0]&b[0])|((a[0]^b[0])&ci);
	 sum[0]   = a[0]^b[0]^ci;
	 for (i = 1; i <= width-2; i = i + 1) begin 
	    carry[i+1] = (a[i]&b[i])|((a[i]^b[i])&c[i]);
	    sum[i]     = a[i]^b[i]^c[i];
	 end // loop
	 sum[width-1] = a[width-1]^b[width-1]^c[width-1];
	 co           = (a[width-1]&b[width-1])|((a[width-1]^b[width-1])&c[width-1]);
      end
    endtask  
  //-------------------------------------------------------------------------
  // Parameter legality check
  //-------------------------------------------------------------------------

  
 
  initial begin : parameter_check
    integer param_err_flg;

    param_err_flg = 0;
    
  
    if (width < 1) begin
      param_err_flg = 1;
      $display(
	"ERROR: %m :\n  Invalid value (%d) for parameter width (lower bound: 1)",
	width );
    end 
  
    if ( param_err_flg == 1) begin
      $display(
        "%m :\n  Simulation aborted due to invalid parameter value(s)");
      $finish;
    end

  end // parameter_check 

      
always @(a or b or c or ci)
   begin
	 if ((^(a ^ a) !== 1'b0) || (^(b ^ b) !== 1'b0) || (^(c ^ c) !== 1'b0) || (^(ci ^ ci) !== 1'b0) ) begin
	    sum = {width{1'bx}};
	    carry = {width{1'bx}};
	    co = 1'bx;
	 end
	 else begin
	    if (width > 1)
	      DWF_csa(a, b, c, ci, carry, sum, co);
	    else begin
	      sum[0] = a[0]^b[0]^ci;
	      carry[0] = c[0];
	      co = (a[0]&b[0])|((a[0]^b[0])&ci);
	    end
	 end // else: !if((^(a ^ a) !== 1'b0) || (^(b ^ b) !== 1'b0) || (^(c ^ c) !== 1'b0) || (^(ci ^ ci) !== 1'b0) )
   end // always @ (a or b or c or ci)
   
  // synopsys translate_on
 
endmodule  // DW01_csa;
