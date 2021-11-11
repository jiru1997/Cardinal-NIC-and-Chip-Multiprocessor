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
// AUTHOR:    Igor Oznobikhin                 July, 14, 1994
//
// VERSION:   Simulation Architecture
//
// DesignWare_version: 4b9e2c8c
// DesignWare_release: K-2015.06-DWBB_201506.5.2
//
////////////////////////////////////////////////////////////////////////////////
//-----------------------------------------------------------------------------------
//
// ABSTRACT:  Shift Register
//           length wordlength
//           shift enable active low
//           parallel load enable active low
//
// MODIFIED:  Rong 	Aug 18,1999
//            Add X-handling
//            Reto Zimmermann  Nov 02, 1999
//            Rewrite (separating sequential and combinatorial code)
//
//-------------------------------------------------------------------------------
//
module DW03_shftreg
  (clk, s_in, p_in, shift_n, load_n, p_out);

  parameter length = 4;

  input  clk;
  input  s_in;
  input  [length-1:0] p_in;
  input  shift_n;
  input  load_n;
  output [length-1:0] p_out;  

  reg  [length-1:0] q, next_q;

  // synopsys translate_off

  
  
  initial begin : parameter_check

    
    if ( length < 1  ) begin
      $display(
	"ERROR: %m :\n  Invalid value (%d) for parameter length (lower bound: 1 )",
        length );
      $finish;
    end

  end // parameter_check


  always @ (p_in or s_in or load_n or shift_n or q)
  begin : mk_next_q

    if (load_n === 1'b0)
      next_q = p_in;

    else if (load_n === 1'b1) 
      if (shift_n === 1'b0) begin
	next_q = q << 1;
	next_q[0] = s_in;
      end

      else if (shift_n === 1'b1)
	next_q = q;

      else
	next_q = {length{1'bx}};

    else
      next_q = {length{1'bx}};
    
  end // mk_next_q


  always @ (posedge clk)
  begin : clk_register

    q <= next_q;

  end // clk_register


  assign p_out = q;

  
  
  always @ (clk) begin : clk_monitor 
    if ( (clk !== 1'b0) && (clk !== 1'b1) && ($time > 0) )
      $display( "WARNING: %m :\n  at time = %t, detected unknown value, %b, on clk input.",
                $time, clk );
    end // clk_monitor 

    
  // synopsys translate_on

endmodule
