////////////////////////////////////////////////////////////////////////////////
//
//       This confidential and proprietary software may be used only
//     as authorized by a licensing agreement from Synopsys Inc.
//     In the event of publication, the following notice is applicable:
//
//                    (C) COPYRIGHT 1996 - 2016 SYNOPSYS INC.
//                           ALL RIGHTS RESERVED
//
//       The entire notice above must be reproduced on all authorized
//     copies.
//
// AUTHOR:    GN                 Jan. 22, 1996
//
// VERSION:   Simulation Architecture
//
// DesignWare_version: 4f36b129
// DesignWare_release: K-2015.06-DWBB_201506.5.2
//
////////////////////////////////////////////////////////////////////////////////
//-----------------------------------------------------------------------------------
//
// ABSTRACT:  
//
// MODIFIED :   Rong 	Aug. 1999
//	        Add parameter checking and x-handling
//              Reto Zimmermann  Nov 02, 1999
//              Rewrite (separating sequential and combinatorial code)
//           
//---------------------------------------------------------------------------------
//
module DW03_reg_s_pl
  (d, clk, reset_N, enable, q);

  parameter width = 8;
  parameter reset_value = 0;

  input  [width-1:0] d;
  input  clk, reset_N, enable;
  output [width-1:0] q;
  
  reg  [width-1:0] q_int, next_q_int;

  // synopsys translate_off
  

  
 
  initial begin : parameter_check
    integer param_err_flg;

    param_err_flg = 0;
    
 
    
    if (width < 1 ) begin
      param_err_flg = 1;
      $display(
	"ERROR: %m :\n  Invalid value (%d) for parameter width (lower bound: 1 )",
	width );
    end

    if (width <= 31) begin
      if ( (reset_value < 0) || (reset_value > (1<<width)-1 ) ) begin
	param_err_flg = 1;
	$display ("ERROR: %m : Invalid value (%d) for parameter, reset_value (legal range: 0 through %d )",
		  reset_value, (1<<width)-1);
      end
    end
    else if (reset_value != 0) begin
      param_err_flg = 1;
      $display ("ERROR: %m : Invalid value (%d) for parameter, reset_value (legal value for width >=32: 0)",
		reset_value);
    end
  
  
    if ( param_err_flg == 1) begin
      $display(
        "%m :\n  Simulation aborted due to invalid parameter value(s)");
      $finish;
    end

  end // parameter_check 



  always @ (enable or reset_N or d or q_int)
  begin : mk_next_q_int

    if (reset_N === 1'b0)
      next_q_int = reset_value;

    else if (reset_N === 1'b1)
      if (enable === 1'b1)
	next_q_int = d;

      else if (enable === 1'b0)
	next_q_int = q_int;

      else
	next_q_int = {width{1'bx}};

    else
      next_q_int = {width{1'bx}};

  end // mk_next_q_int
  
  
  always @ (posedge clk)
  begin : clk_register

    q_int <= next_q_int;

  end // clk_register
  

  assign q = q_int;

  
  
  always @ (clk) begin : clk_monitor 
    if ( (clk !== 1'b0) && (clk !== 1'b1) && ($time > 0) )
      $display( "WARNING: %m :\n  at time = %t, detected unknown value, %b, on clk input.",
                $time, clk );
    end // clk_monitor 

    
  // synopsys translate_on
 
 
endmodule

