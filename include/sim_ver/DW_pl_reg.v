////////////////////////////////////////////////////////////////////////////////
//
//       This confidential and proprietary software may be used only
//     as authorized by a licensing agreement from Synopsys Inc.
//     In the event of publication, the following notice is applicable:
//
//                    (C) COPYRIGHT 2007 - 2016 SYNOPSYS INC.
//                           ALL RIGHTS RESERVED
//
//       The entire notice above must be reproduced on all authorized
//     copies.
//
// AUTHOR:    Rick Kelly      May 2, 2007
//
// VERSION:   Verilog Simulation Model
//
// DesignWare_version: c17dcf7a
// DesignWare_release: K-2015.06-DWBB_201506.5.2
//
////////////////////////////////////////////////////////////////////////////////
//
// ABSTRACT: Pipeline register with parameter control for width, pipe stages
//		as well as non-retimable input or output register
//
//		Register are individually enabled by separate bits of the
//		enable input bus.
//
//
//              Parameters:     Valid Values
//              ==========      ============
//              width           [ > 0 ]
//              in_reg          [ 0 = no fixed input register
//				  1 = fixed (not retimable) input register ]
//              stages          [ > 0 ]
//              out_reg         [ 0 = no fixed output register
//				  1 = fixed (not retimable) output register ]
//              rst_mode        [ 0 = asynchronous reset,
//                                1 = synchronous reset ]
//		
//		Input Ports:	Size	Description
//		===========	====	===========
//		clk		1 bit	Input Clock
//		rst_n		1 bit	Active Low Reset
//		enable	       EW bits	Active High Enable Bus
//		data_in		width	Data input port
//
//		Output Ports	Size	Description
//		============	====	===========
//		data_out	width	Data output port
//
//	where :  EW = min(1, in_reg + stages + out_reg - 1)
//
// MODIFIED: 
//
//      RJK 01/10/13  Updated coding to use standard sequential block
//                    coding without intermediate signals (using V2K
//                    generate blocks to differentiate async from sync
//                    reset modes).  (STAR 9000589609)
//
////////////////////////////////////////////////////////////////////////////////-

module DW_pl_reg ( clk, rst_n, enable,
		    data_in, data_out);

parameter width = 8;	// NATURAL
parameter in_reg = 0;   // RANGE 0 to 1
parameter stages = 4;	// NATURAL
parameter out_reg = 0;  // RANGE 0 to 1
parameter rst_mode = 0;	// RANGE 0 to 1

localparam en_msb = (stages-1+in_reg+out_reg < 1)? 0 : (stages+in_reg+out_reg-2);

input			clk;		// clock input
input			rst_n;		// active low reset input
input  [en_msb : 0]	enable;		// active high enable input bus
input  [width-1 : 0]	data_in;	// input data bus

output [width-1 : 0]	data_out;	// output data bus

//synopsys translate_off

reg    [width-1 : 0]	pipe_regs [0 : en_msb];



generate
 if (rst_mode == 0) begin : REG1_ASYNC_RST
  always @ (posedge clk or negedge rst_n) begin : PROC_registers
    integer i;

    if (rst_n === 1'b0) begin
      for (i=0 ; i <= en_msb ; i=i+1) begin
	pipe_regs[i] <= {width{1'b0}};
      end
    end else if (rst_n === 1'b1) begin
      for (i=0 ; i <= en_msb ; i=i+1) begin
        if (enable[i] === 1'b1)
	  pipe_regs[i] <= (i == 0)? (data_in | (data_in ^ data_in)) : pipe_regs[i-1];
	else if (enable[i] !== 1'b0)
	  pipe_regs[i] <= ((pipe_regs[i] ^ ((i == 0)? (data_in | (data_in ^ data_in)) : pipe_regs[i-1]))
			      & {width{1'bx}}) ^ pipe_regs[i];
      end
    end else begin
      for (i=0 ; i <= en_msb ; i=i+1) begin
	pipe_regs[i] <= {width{1'bx}};
      end
    end
  end
 end else begin : REG1_SYNC_RST
  always @ (posedge clk) begin : PROC_registers
    integer i;

    if (rst_n === 1'b0) begin
      for (i=0 ; i <= en_msb ; i=i+1) begin
	pipe_regs[i] <= {width{1'b0}};
      end
    end else if (rst_n === 1'b1) begin
      for (i=0 ; i <= en_msb ; i=i+1) begin
        if (enable[i] === 1'b1)
	  pipe_regs[i] <= (i == 0)? (data_in | (data_in ^ data_in)) : pipe_regs[i-1];
	else if (enable[i] !== 1'b0)
	  pipe_regs[i] <= ((pipe_regs[i] ^ ((i == 0)? (data_in | (data_in ^ data_in)) : pipe_regs[i-1]))
			      & {width{1'bx}}) ^ pipe_regs[i];
      end
    end else begin
      for (i=0 ; i <= en_msb ; i=i+1) begin
	pipe_regs[i] <= {width{1'bx}};
      end
    end
  end
 end
endgenerate


  assign data_out = (in_reg+stages+out_reg == 1)? (data_in | (data_in ^ data_in)) : pipe_regs[en_msb];


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
  
    if ( (stages < 1) || (stages > 1024) ) begin
      param_err_flg = 1;
      $display(
	"ERROR: %m :\n  Invalid value (%d) for parameter stages (legal range: 1 to 1024)",
	stages );
    end
  
    if ( (in_reg < 0) || (in_reg > 1) ) begin
      param_err_flg = 1;
      $display(
	"ERROR: %m :\n  Invalid value (%d) for parameter in_reg (legal range: 0 to 1)",
	in_reg );
    end
  
    if ( (out_reg < 0) || (out_reg > 1) ) begin
      param_err_flg = 1;
      $display(
	"ERROR: %m :\n  Invalid value (%d) for parameter out_reg (legal range: 0 to 1)",
	out_reg );
    end
  
    if ( (in_reg!=0) && (out_reg!=0) ) begin
      param_err_flg = 1;
      $display(
	"ERROR: %m : \n  Invalid configuration of DW_pl_reg - 'in_reg' and 'out_reg' parameters can't both be non-zero" );
    end
  
    if ( (rst_mode < 0) || (rst_mode > 1) ) begin
      param_err_flg = 1;
      $display(
	"ERROR: %m :\n  Invalid value (%d) for parameter rst_mode (legal range: 0 to 1)",
	rst_mode );
    end
  
    if ( param_err_flg == 1) begin
      $display(
        "%m :\n  Simulation aborted due to invalid parameter value(s)");
      $finish;
    end

  end // parameter_check 



  
  always @ (clk) begin : monitor_clk 
    if ( (clk !== 1'b0) && (clk !== 1'b1) && ($time > 0) )
      $display( "WARNING: %m :\n  at time = %t, detected unknown value, %b, on clk input.",
                $time, clk );
    end // monitor_clk 

// synopsys translate_on

endmodule
