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
// AUTHOR:    Rick Kelly    April 25, 2001
//
// VERSION:   DW_ram_rw_s_dff Verilog Simulation Model
//
// DesignWare_version: c1ff816b
// DesignWare_release: K-2015.06-DWBB_201506.5.2
//
////////////////////////////////////////////////////////////////////////////////
//----------------------------------------------------------------------
// ABSTRACT:  Asynchronous single port RAM (Flip-Flop Based)
//            Depth parameter: depth             [ 2 to 2048 ]
//            Data width parameter: data_width   [ 1 to 1024 ]
//            Reset (active low): rst_n
//            Chip select (active low): cs_n
//            Write enable (active low): wr_n
//	      Test enable (active high): test_mode
//            Test clock: test_clk
//            Read Write Address: rw_addr[addr_width-1:0]
//            Input data: data_in[data_width-1:0]
//            Output data : data_out[data_width-1:0]
//
//	MODIFIED:
//		100599	Jay Zhu		Rewrote for STAR91151/STAR93158
//              10/18/00  RPH       Rewrote accoding to new guidelines 
//                                  STAR 111067   
//              06/27/01  RJK       Rewritten again (STAR 119685)
//              2/18/09   RJK       Corrected default value for rst_mode
//				    STAR 9000294457
//              9/10/14   RJK       Eliminated common async and sync reset coding
//				    style to support VCS NLP
//              5/03/15   RJK       Eliminated "next state evaluation in seq block"
//				    coding style to support VCS NLP
//----------------------------------------------------------------------

  module DW_ram_rw_s_dff (clk, rst_n, cs_n, wr_n,
			  rw_addr, data_in, data_out);

   parameter data_width = 4;
   parameter depth = 8;
   parameter rst_mode = 1;

`define DW_addr_width ((depth>256)?((depth>4096)?((depth>16384)?((depth>32768)?16:15):((depth>8192)?14:13)):((depth>1024)?((depth>2048)?12:11):((depth>512)?10:9))):((depth>16)?((depth>64)?((depth>128)?8:7):((depth>32)?6:5)):((depth>4)?((depth>8)?4:3):((depth>2)?2:1))))

   input     clk;
   input     rst_n;
   input     cs_n;
   input     wr_n;
   input [`DW_addr_width-1:0] rw_addr;
   input [data_width-1:0]  data_in;

   output [data_width-1:0] data_out;

   // synopsys translate_off
   wire [data_width-1:0]   data_in;
   reg [depth*data_width-1:0]    next_mem;
   reg [depth*data_width-1:0]    mem;
  wire [depth*data_width-1:0]    mem_mux;
   

   
  
 
  initial begin : parameter_check
    integer param_err_flg;

    param_err_flg = 0;
    
	    
  
    if ( (data_width < 1) || (data_width > 2048) ) begin
      param_err_flg = 1;
      $display(
	"ERROR: %m :\n  Invalid value (%d) for parameter data_width (legal range: 1 to 2048)",
	data_width );
    end
  
    if ( (depth < 2) || (depth > 1024 ) ) begin
      param_err_flg = 1;
      $display(
	"ERROR: %m :\n  Invalid value (%d) for parameter depth (legal range: 2 to 1024 )",
	depth );
    end
  
    if ( (rst_mode < 0) || (rst_mode > 1 ) ) begin
      param_err_flg = 1;
      $display(
	"ERROR: %m :\n  Invalid value (%d) for parameter rst_mode (legal range: 0 to 1 )",
	rst_mode );
    end

  
    if ( param_err_flg == 1) begin
      $display(
        "%m :\n  Simulation aborted due to invalid parameter value(s)");
      $finish;
    end

  end // parameter_check 

   
   assign mem_mux = mem >> (rw_addr * data_width);

   assign data_out = ((rw_addr ^ rw_addr) !== {`DW_addr_width{1'b0}})? {data_width{1'bx}} : (
				((rw_addr >= depth)||(cs_n==1'b1))? {data_width{1'b0}} :
				   mem_mux[data_width-1 : 0] );
   
   always @ * begin : next_mem_PROC
      integer i, j;
      
   
      next_mem = mem;

      if ((cs_n | wr_n) !== 1'b1) begin
      
	 if ((rw_addr ^ rw_addr) !== {`DW_addr_width{1'b0}}) begin
	    next_mem = {depth*data_width{1'bx}};	

	 end else begin
         
	    if ((rw_addr < depth) && ((wr_n | cs_n) !== 1'b1)) begin
	       for (i=0 ; i < data_width ; i=i+1) begin
		  j = rw_addr*data_width + i;
		  next_mem[j] = ((wr_n | cs_n) == 1'b0)? data_in[i] | 1'b0
					: mem[j];
	       end // for
	    end // if
	 end // if-else
      end // if
   end

generate
 if (rst_mode == 0) begin : GEN_RM_EQ_0
   always @ (posedge clk or negedge rst_n) begin : ar_registers_PROC
      if (rst_n === 1'b0) begin
         mem <= {depth*data_width{1'b0}};
      end else begin
         if ( rst_n === 1'b1) begin
	    mem <= next_mem;
	 end else begin
	    mem <= {depth*data_width{1'bX}};
	 end
      end
   end // ar_registers
 end else begin : GEN_RM_NE_0
   always @ (posedge clk) begin : sr_registers_PROC
      if (rst_n === 1'b0) begin
         mem <= {depth*data_width{1'b0}};
      end else begin
         if ( rst_n === 1'b1) begin
	    mem <= next_mem;
	 end else begin
	    mem <= {depth*data_width{1'bX}};
	 end
      end
   end // sr_registers
 end
endgenerate

    
  always @ (clk) begin : clk_monitor 
    if ( (clk !== 1'b0) && (clk !== 1'b1) && ($time > 0) )
      $display( "WARNING: %m :\n  at time = %t, detected unknown value, %b, on clk input.",
                $time, clk );
    end // clk_monitor 

// synopsys translate_on
`undef DW_addr_width
endmodule // DW_ram_r_w_s_dff
