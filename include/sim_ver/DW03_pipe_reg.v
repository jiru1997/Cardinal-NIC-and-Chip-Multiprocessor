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
// AUTHOR:    Poliakov A.        July 12, 1994
//
// VERSION:   Simulation Architecture
//
// DesignWare_version: bf6a5a59
// DesignWare_release: K-2015.06-DWBB_201506.5.2
//
////////////////////////////////////////////////////////////////////////////////
//-----------------------------------------------------------------------------------
//
// ABSTRACT:  Pipeline Register
//
// MODIFIED: by POLYAKOV A. at jul. 5. 1994.
//           VHDL - model of entity DW03_pip_reg
//           by converted to his VERILOG equivalent
//           GN Feb. 16th, 1996
//           changed DW03 to DW03
//           remove $generic
//           define parameter depth = 4
//           define parameter width = 8;
// 
//	     by Sitanshu Kumar 7th oct 96
//	     The model was completely wrong, instead of pipeline it was simulating 
//	     a delay element.
//
//	     SS April 16, `97
//	     Changed to non-blocking assignments
//	   
//	     Rong	Aug. 1999
//	     Add x-handling
//
//		RJK	May 17, 2000
//		Updated to latest coding style to avoid blocking vs.
//		nonblocking assignment problems (STAR 103980)
//-------------------------------------------------------------------------------


module DW03_pipe_reg (
		    A,		// input data bus
		    clk,	// clock input
		    B		// output data bus
		    );

parameter depth = 4;
parameter width = 8;

// port list declaration in order
input  [width-1 : 0]	A;
input			clk;
output [width-1 : 0]	B; 

// synopsys translate_off

reg    [width-1 : 0]	B_int; 
reg    [width-1 : 0]	reg_array[1:depth-1];
integer i;


    assign B = B_int;


    always @(A) begin : P_degenerate_case_out_PROC
	if (depth == 0)
	    B_int = A ;
    end // P_degenerate_case_out


    always @(posedge clk) begin : P_clk_registers_PROC
	
	if (depth > 0) begin

	    for (i=depth-1 ; i > 1 ; i=i-1) begin

		reg_array[i-1] <= reg_array[i];
	    end // for

	    if (depth == 1) begin
		B_int <= A | {width{1'b0}};
	    end else begin
		reg_array[depth-1] <= A | {width{1'b0}};
		B_int <= reg_array[1];
	    end // if-else
	end // if
    
    end // P_clk_registers


    
 
  initial begin : parameter_check
    integer param_err_flg;

    param_err_flg = 0;
    
	
    if (width < 1 ) begin
      param_err_flg = 1;
      $display(
	"ERROR: %m :\n  Invalid value (%d) for parameter width (lower bound: 1 )",
	width );
    end
	
    if (depth < 0 ) begin
      param_err_flg = 1;
      $display(
	"ERROR: %m :\n  Invalid value (%d) for parameter depth (lower bound: 0 )",
	depth );
    end
    
    if ( param_err_flg == 1) begin
      $display(
        "%m :\n  Simulation aborted due to invalid parameter value(s)");
      $finish;
    end

  end // parameter_check 



    
  always @ (clk) begin : P_monitor_clk 
    if ( (clk !== 1'b0) && (clk !== 1'b1) && ($time > 0) )
      $display( "WARNING: %m :\n  at time = %t, detected unknown value, %b, on clk input.",
                $time, clk );
    end // P_monitor_clk 

// synopsys translate_on

endmodule // DW03_pipe_reg
