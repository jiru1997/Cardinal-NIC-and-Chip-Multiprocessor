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
// AUTHOR:    Kurt Baty (WSFDB)          Sep. 24th, 1995
//
// VERSION:   Simulation Architecture
//
// DesignWare_version: 3caaefa4
// DesignWare_release: K-2015.06-DWBB_201506.5.2
//
////////////////////////////////////////////////////////////////////////////////
//-----------------------------------------------------------------------------------
//
// ABSTRACT:  Shadow and Multibit Register
//
// MODIFIED: Rick Kelly                 May 2nd, 1996
//           Changed Port and Parameter
//           names to match sldb in case.
//           
//    	     Rong 			Aug 26, 1999
// 	     Add parameter checking and x-handling.
//           Reto Zimmermann            Nov 04, 1999
//           Adapt to new coding guidelines
//------------------------------------------------------------------------------
//
module DW04_shad_reg
  (datain, sys_clk, shad_clk, reset, SI, SE,
   sys_out, shad_out, SO);

  parameter width = 8;
  parameter bld_shad_reg = 0;

  input  [width-1:0] datain;
  input  sys_clk, shad_clk, reset, SI, SE;
  output [width-1:0] sys_out, shad_out;
  output SO;

  reg  [width-1:0] sys_out_int, next_sys_out_int;
  reg  [width-1:0] shad_out_int, next_shad_out_int;
  
  // synopsys translate_off
  

  
 
  initial begin : parameter_check
    integer param_err_flg;

    param_err_flg = 0;
    
 
    
    if ( (width < 1) || (width > 512 ) ) begin
      param_err_flg = 1;
      $display(
	"ERROR: %m :\n  Invalid value (%d) for parameter width (legal range: 1 to 512 )",
	width );
    end
    
    if ( (bld_shad_reg < 0) || (bld_shad_reg > 1 ) ) begin
      param_err_flg = 1;
      $display(
	"ERROR: %m :\n  Invalid value (%d) for parameter bld_shad_reg (legal range: 0 to 1 )",
	bld_shad_reg );
    end
  
  
    if ( param_err_flg == 1) begin
      $display(
        "%m :\n  Simulation aborted due to invalid parameter value(s)");
      $finish;
    end

  end // parameter_check 



  always @ (datain)
    next_sys_out_int = datain;

  
  always @ (sys_out_int or shad_out_int or SE or SI)
  begin : mk_next_sys_out_int

    if (SE === 1'b0)
      next_shad_out_int = sys_out_int;
    
    else if (SE === 1'b1)
      next_shad_out_int = {shad_out_int, SI};
    
    else
      next_shad_out_int = {width{1'bx}};

  end // mk_next_sys_out_int


  always @ (posedge sys_clk or negedge reset)
  begin : sys_clk_register

    if (reset === 1'b0)
      sys_out_int <= {width{1'b0}};

    else if (reset === 1'b1)
      sys_out_int <= next_sys_out_int;

    else
      sys_out_int <= {width{1'bx}};

  end // sys_clk_register


  always @ (posedge shad_clk or negedge reset)
  begin : shad_clk_register

    if (bld_shad_reg) begin

      if (reset === 1'b0)
	shad_out_int <= {width{1'b0}};

      else if (reset === 1'b1)
	shad_out_int <= next_shad_out_int;

      else
	shad_out_int <= {width{1'bx}};

    end
  end // shad_clk_register


  assign sys_out = sys_out_int;
  assign shad_out = shad_out_int;
  assign SO = shad_out_int[width-1];


  
  always @ (sys_clk) begin : sys_clk_monitor 
    if ( (sys_clk !== 1'b0) && (sys_clk !== 1'b1) && ($time > 0) )
      $display( "WARNING: %m :\n  at time = %t, detected unknown value, %b, on sys_clk input.",
                $time, sys_clk );
    end // sys_clk_monitor 
  
  always @ (shad_clk) begin : shad_clk_monitor 
    if ( (shad_clk !== 1'b0) && (shad_clk !== 1'b1) && ($time > 0) )
      $display( "WARNING: %m :\n  at time = %t, detected unknown value, %b, on shad_clk input.",
                $time, shad_clk );
    end // shad_clk_monitor 

    
  // synopsys translate_on

endmodule
