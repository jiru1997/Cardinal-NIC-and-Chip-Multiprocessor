////////////////////////////////////////////////////////////////////////////////
//
//       This confidential and proprietary software may be used only
//     as authorized by a licensing agreement from Synopsys Inc.
//     In the event of publication, the following notice is applicable:
//
//                    (C) COPYRIGHT 1999 - 2016 SYNOPSYS INC.
//                           ALL RIGHTS RESERVED
//
//       The entire notice above must be reproduced on all authorized
//     copies.
//
// AUTHOR:    Rick Kelly  12/20/06
//
// VERSION:   Simulation Model
//
// DesignWare_version: 99f0efa3
// DesignWare_release: K-2015.06-DWBB_201506.5.2
//
////////////////////////////////////////////////////////////////////////////////
//----------------------------------------------------------------------
// ABSTRACT:  Synch Write, Asynch Read RAM (Latch based)
//            legal range:  depth        [ 2 to 256 ]
//            legal range:  data_width   [ 1 to 256 ]
//            Input data: data_in[data_width-1:0]
//            Output data : data_out[data_width-1:0]
//            Read Address: rd_addr[addr_width-1:0]
//            Write Address: wr_addr[addr_width-1:0]
//            Write enable (active low): wr_n
//            Chip select (active low): cs_n
//            Clock:clk
//
//	MODIFIED:
//		092499	Jay Zhu		Rewrote for STAR91151
//              10/18/00  RPH       Rewrote accoding to new guidelines 
//                                  STAR 111067  
//		12/20/06  RJK       Rewritten again (STAR 9000156681)
//----------------------------------------------------------------------

module DW_ram_r_w_s_lat (
	clk,
	cs_n,
	wr_n,
	rd_addr,
	wr_addr,
	data_in, 
	data_out);
   
   parameter data_width = 4;
   parameter depth = 8;
   
`define DW_addr_width ((depth>16)?((depth>64)?((depth>128)?8:7):((depth>32)?6:5)):((depth>4)?((depth>8)?4:3):((depth>2)?2:1)))

   input 		   clk;
   input 		   wr_n;
   input 		   cs_n;
   input [`DW_addr_width-1:0] rd_addr;
   input [`DW_addr_width-1:0] wr_addr;
   input [data_width-1:0] data_in;

   output [data_width-1:0] data_out;
   reg    [data_width-1:0] data_out;

// synopsys translate_off
   reg [data_width-1:0]    mem [depth-1:0];
   event mem_written;

  
 
  initial begin : parameter_check
    integer param_err_flg;

    param_err_flg = 0;
    
  
    if ( (data_width < 1) || (data_width > 256) ) begin
      param_err_flg = 1;
      $display(
	"ERROR: %m :\n  Invalid value (%d) for parameter data_width (legal range: 1 to 256)",
	data_width );
    end
  
    if ( (depth < 2) || (depth > 256 ) ) begin
      param_err_flg = 1;
      $display(
	"ERROR: %m :\n  Invalid value (%d) for parameter depth (legal range: 2 to 256 )",
	depth );
    end

  -> mem_written;
  
    if ( param_err_flg == 1) begin
      $display(
        "%m :\n  Simulation aborted due to invalid parameter value(s)");
      $finish;
    end

  end // parameter_check 


  always @ (rd_addr or mem_written) begin : mem_read_PROC
	data_out = (rd_addr < depth)?
		    ((^(rd_addr ^ rd_addr) !== 1'b0) ?  {data_width{1'bx}} : mem[rd_addr])
		  : {data_width{1'b0}};
  end // PROC_mem_read
   
   
  always @(clk or cs_n or wr_n or wr_addr or data_in) begin : mem_write_PROC
    integer  i;

    if ((clk | cs_n | wr_n) !== 1'b1) begin
      if ((^(wr_addr ^ wr_addr) !== 1'b0)) begin
        for (i=0 ; i < depth ; i=i+1)
	  mem[i] = {data_width{1'bx}};
      end else if (wr_addr < depth) begin
	if ((clk | cs_n | wr_n) === 1'b0)
	  mem[wr_addr] = data_in | data_in;
	else
	  mem[wr_addr] = {data_width{1'bx}};
      end
      -> mem_written;
    end
  end // PROC_mem_write
   
  
  always @ (clk) begin : clk_monitor 
    if ( (clk !== 1'b0) && (clk !== 1'b1) && ($time > 0) )
      $display( "WARNING: %m :\n  at time = %t, detected unknown value, %b, on clk input.",
                $time, clk );
    end // clk_monitor 
// synopsys translate_on
`undef DW_addr_width
   
endmodule // DW_ram_r_w_s_lat



