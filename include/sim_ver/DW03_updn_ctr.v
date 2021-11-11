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
// AUTHOR:    Anatoly Sokhatsky		July 10, 1994
//
// VERSION:   Simulation Architecture
//
// DesignWare_version: c0cc6b1d
// DesignWare_release: K-2015.06-DWBB_201506.5.2
//
////////////////////////////////////////////////////////////////////////////////
//-----------------------------------------------------------------------------------
//
// ABSTRACT:  Up/Down Counter
//           parameterizable wordlength (width > 0)
//	     clk	- positive edge-triggering clock
//           reset	- asynchronous reset (active low)
//           data	- data load input
//	     cen	- counter enable
//	     count	- counter state
//
// MODIFIED : GN Feb. 16th, 1996
//            changed dw03 to DW03
//            remove $generic
//            defined paramter = 8
//
//		RJK		June 19, 1997
//		Corrected faulty tercnt detection mechanism
//          
//            Rong 	Sep. 1999
// 	      Add x-handling
//
//		RJK		May 17, 2000
//		Updated to latest coding style to avoid blocking vs.
//		nonblocking assignment problems (STAR 103980)
//-------------------------------------------------------------------------------

module DW03_updn_ctr (
		    // input ports
		    data,	// data used for load operation
		    up_dn,	// up/down control input (0=down, 1-up)
		    load,	// load operation control input (active low)
		    cen,	// count enable control input (active high enable)
		    clk,	// clock input
		    reset,	// asynchronous reset input (active low)

		    // output ports
		    count,	// count value output
		    tercnt	// terminal count output flag (active high)
		    );

parameter width = 8; 

// port list declaration in order
input  [width-1 : 0]	data;
input 			up_dn, load, cen, clk, reset;
output [width-1 : 0]	count;  
output 		 	tercnt;

// synopsys translate_off

reg  [width-1 : 0]	cur_state;
wire [width-1 : 0]	next_state;
   
    assign  count  =  cur_state;

   
    always @ (posedge clk or negedge reset) begin : P_clk_registers_PROC

	if (reset === 1'b0)
	    cur_state <= {width{1'b0}};
	
	else begin

	    if (reset === 1'b1)
		cur_state <= next_state;
	    
	    else
		cur_state <= {width{reset ^ reset}};

	end
    end // P_clk_registers


    assign next_state = (load == 1'b0)? data | {width{1'b0}} :
			    ( (cen == 1'b0)? cur_state :
				( (up_dn == 1'b0)? cur_state + {width{1'b1}} :
						    cur_state - {width{1'b1}} ) );


    assign tercnt = (up_dn == 1'b0)? ( (cur_state == {width{1'b0}})? 1'b1 : 1'b0 ) :
				     ( (cur_state == {width{1'b1}})? 1'b1 : 1'b0 );


    
  initial begin : parameter_check

    
    if ( width < 1  ) begin
      $display(
	"ERROR: %m :\n  Invalid value (%d) for parameter width (lower bound: 1 )",
        width );
      $finish;
    end

  end // parameter_check

    
  always @ (clk) begin : P_monitor_clk 
    if ( (clk !== 1'b0) && (clk !== 1'b1) && ($time > 0) )
      $display( "WARNING: %m :\n  at time = %t, detected unknown value, %b, on clk input.",
                $time, clk );
    end // P_monitor_clk 

// synopsys translate_on

endmodule // DW03_updn_ctr
