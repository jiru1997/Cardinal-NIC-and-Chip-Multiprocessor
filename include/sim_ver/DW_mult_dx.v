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
// AUTHOR:    Jay Zhu     February 20, 1999
//
// VERSION:   Simulation Architecture
//
// DesignWare_version: 6d4f0fb6
// DesignWare_release: K-2015.06-DWBB_201506.5.2
//
////////////////////////////////////////////////////////////////////////////////
//-----------------------------------------------------------------------------------
//
// ABSTRACT:  Duplex Multiplier
//
//	Parameters		Valid Values
//	==========		============
//	width			>= 4
//	p1_width		2 to (width-2)
//
//	Input Ports	Size	Description
//	===========	====	===========
//	a		width	Input data
//	b		width	Input data
//	tc		1 bit	Two's complement select (active high)
//	dplx		1 bit	Duplex mode select (active high)
//
//	Output Ports	Size	Description
//	===========	====	===========
//	product		2*width	Output data
//
// MODIFIED:
//      RPH      Aug 21, 2002       
//              Added parameter checking and cleaned up 
//----------------------------------------------------------------------


module DW_mult_dx (a, b, tc, dplx, product );

   parameter width = 16;
   parameter p1_width = 8;

   `define DW_p2_width (width-p1_width)

   input [width-1 : 0] a;
   input [width-1 : 0] b;
   input 	       tc;
   input 	       dplx;
   output [2*width-1 : 0] product;

   wire [width-1 : 0] 	  a;
   wire [width-1 : 0] 	  b;
   wire 		  tc;
   wire 		  dplx;
   wire [2*width-1 : 0]   product;
   wire [2*width-1 : 0]   duplex_prod;
   wire [2*width-1 : 0]   simplex_prod;

// synopsys translate_off
  
 
  initial begin : parameter_check
    integer param_err_flg;

    param_err_flg = 0;
    
    
    if (width < 4) begin
      param_err_flg = 1;
      $display(
	"ERROR: %m :\n  Invalid value (%d) for parameter width (lower bound: 4)",
	width );
    end
    
    if ( (p1_width < 2) || (p1_width > width-2) ) begin
      param_err_flg = 1;
      $display(
	"ERROR: %m :\n  Invalid value (%d) for parameter p1_width (legal range: 2 to width-2)",
	p1_width );
    end
  
    if ( param_err_flg == 1) begin
      $display(
        "%m :\n  Simulation aborted due to invalid parameter value(s)");
      $finish;
    end

  end // parameter_check 

     
     DW02_mult 	#(width, width)
	U1 (
	    .A(a),
	    .B(b),
	    .TC(tc),
	    .PRODUCT(simplex_prod)
	    );

   DW02_mult #(p1_width, p1_width)
      U2_1 (
	    .A(a[p1_width-1 : 0]),
	    .B(b[p1_width-1 : 0]),
	    .TC(tc),
	    .PRODUCT(duplex_prod[2*p1_width-1 : 0])
	    );

   DW02_mult #(`DW_p2_width, `DW_p2_width)
      U2_2 (
	    .A(a[width-1 : p1_width]),
	    .B(b[width-1 : p1_width]),
	    .TC(tc),
	    .PRODUCT(duplex_prod[2*width-1 : 2*p1_width])
	    );

   assign  product =  dplx == 1'b0 ? simplex_prod : 
		      dplx == 1'b1 ? duplex_prod : 
		      {2*width{1'bx}};

// synopsys translate_on

`undef DW_p2_width

endmodule
