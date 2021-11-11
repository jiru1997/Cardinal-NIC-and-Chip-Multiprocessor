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
// AUTHOR:    Jay Zhu	Sept 24, 1999
//
// VERSION:   Simulation Architecture
//
// DesignWare_version: 2e8d863a
// DesignWare_release: K-2015.06-DWBB_201506.5.2
//
////////////////////////////////////////////////////////////////////////////////
  //----------------------------------------------------------------------
  // ABSTRACT:  Single-Port Synch Write, Asynch Read RAM (latch based)
  //            legal range:  depth        [ 2 to 256 ]
  //            legal range:  data_width   [ 1 to 256 ]
  //            Input data: data_in[data_width-1:0]
  //            Output data : data_out[data_width-1:0]
  //            Read-write Address: rw_addr[addr_width-1:0]
  //            Write enable (active low): wr_n
  //            Chip select (active low): cs_n
  //            Clock:clk
  //
  //	MODIFIED:
  //	09/24/1999 Jay Zhu - Rewrote for STAR91151
//              10/18/00  RPH       Rewrote accoding to new guidelines 
//                                  STAR 111067 
  //----------------------------------------------------------------------

  module DW_ram_rw_s_lat (clk, cs_n, wr_n, rw_addr, data_in, data_out);

   parameter data_width = 4;
   parameter depth = 8;

`define DW_addr_width ((depth>16)?((depth>64)?((depth>128)?8:7):((depth>32)?6:5)):((depth>4)?((depth>8)?4:3):((depth>2)?2:1)))

   input [data_width-1:0] data_in;
   input [`DW_addr_width-1:0] rw_addr;
   input 		   wr_n;
   input 		   cs_n;
   input 		   clk;

   output [data_width-1:0] data_out;

// synopsys translate_off

   wire [data_width-1:0]   data_in_int;
   reg [data_width-1:0]    mem [depth-1:0];
   integer 		   i;


   function	any_unknown;
      input[`DW_addr_width-1:0] addr;
      integer	bit_idx;
      begin
	 any_unknown = 1'b0;

	 for (bit_idx = `DW_addr_width-1;
	      bit_idx >= 0 && any_unknown==1'b0;
	      bit_idx = bit_idx-1)
	 begin
	    if (addr[bit_idx] !== 1'b0 && addr[bit_idx] !== 1'b1)
	      begin
		 any_unknown = 1'b1;
	      end
	 end
      end
   endfunction

  
 
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


  
    if ( param_err_flg == 1) begin
      $display(
        "%m :\n  Simulation aborted due to invalid parameter value(s)");
      $finish;
    end

  end // parameter_check 


   assign data_out = (rw_addr < depth && cs_n === 1'b0) ? 
		     (any_unknown(rw_addr) ? 
		      {data_width{1'bx}} : mem[rw_addr]) : {data_width{1'b0}};
   
   assign data_in_int = (any_unknown(data_in)) ? {data_width{1'bx}} : data_in;
   
   always @(clk or cs_n or wr_n or rw_addr or data_in_int)
     begin : mk_mem     
	if (clk === 1'b0) begin 
	   if (cs_n === 1'b1) begin
	      // do nothing
	   end
	   else if (cs_n === 1'b0) begin
	      if (wr_n === 1'b0) begin
		 if (any_unknown(rw_addr) == 1'b1) begin
		    for (i = 0; i < depth; i = i + 1) begin
		       mem[i] = {data_width{1'bx}};
		    end 
		 end
		 else begin
		    mem[rw_addr] = data_in_int;
		 end // else: !if(any_unknown(rw_addr) == 1'b1)
	      end // if (wr_n === 1'b0)
	      else if (wr_n === 1'b1) begin
		 // do nothing
	      end
	      else begin
		 if (any_unknown(rw_addr) == 1'b1) begin
		    for (i = 0; i < depth; i = i + 1) begin
		       mem[i] = {data_width{1'bx}};
		    end 
		 end
		 else begin
		    mem[rw_addr] = {data_width{1'bx}};
		 end // else: !if(any_unknown(rw_addr) == 1'b1)
	      end // if (cs_n === 1'b0)
	   end // if (cs_n === 1'b0)
	   else begin
	      if (wr_n === 1'b0) begin
		 if (any_unknown(rw_addr) == 1'b1) begin
		    for (i = 0; i < depth; i = i + 1) begin
		       mem[i] = {data_width{1'bx}};
		    end 
		 end
		 else begin
		    mem[rw_addr] = {data_width{1'bx}};
		 end // else: !if(any_unknown(rw_addr) == 1'b1)
	      end // if (wr_n === 1'b0)
	      else if (wr_n === 1'b1) begin
		 //do nothing
	      end
	      else begin
		 if (any_unknown(rw_addr) == 1'b1) begin
		    for (i = 0; i < depth; i = i + 1) begin
		       mem[i] = {data_width{1'bx}};
		    end 
		 end
		 else begin
		    mem[rw_addr] = {data_width{1'bx}};
		 end // else: !if(any_unknown(rw_addr) == 1'b1)
	      end // else: !if(wr_n === 1'b1)
	   end // if (wr_n === 1'b0)
	end // if (clk === 1'b0)
	else begin
	   // do nothing
	end
     end // block: mk_mem
   
   
  always @ (clk) begin : clk_monitor 
    if ( (clk !== 1'b0) && (clk !== 1'b1) && ($time > 0) )
      $display( "WARNING: %m :\n  at time = %t, detected unknown value, %b, on clk input.",
                $time, clk );
    end // clk_monitor 
// synopsys translate_on
`undef DW_addr_width   
endmodule // DW_ram_rw_s_lat

