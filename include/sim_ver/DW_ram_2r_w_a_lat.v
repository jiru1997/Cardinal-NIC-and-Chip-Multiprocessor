////////////////////////////////////////////////////////////////////////////////
//
//       This confidential and proprietary software may be used only
//     as authorized by a licensing agreement from Synopsys Inc.
//     In the event of publication, the following notice is applicable:
//
//                    (C) COPYRIGHT 1997 - 2016 SYNOPSYS INC.
//                           ALL RIGHTS RESERVED
//
//       The entire notice above must be reproduced on all authorized
//     copies.
//
// AUTHOR:    SS        	Mar 3, 1997
//
// VERSION:   Simulation Architecture
//
// DesignWare_version: f72f8542
// DesignWare_release: K-2015.06-DWBB_201506.5.2
//
////////////////////////////////////////////////////////////////////////////////
//-----------------------------------------------------------------------------------
//
// ABSTRACT:  Three-Port RAM (Latch-Based)
//            (latch memory array)
//
//
//              Parameters:     Valid Values
//              ===========     ============
//              data_width      [ 1 to 256 ]
//              depth           [ 2 to 256 ]
//              rst_mode        [ 0 = asynchronous reset,
//                                1 = no reset ]
//
//              Input Ports:    Description
//              ============    ===========
//              rst_n           Reset (active low)
//              cs_n            Chip Select (active low)
//              wr_n            Write Enable (active low)
//              rd1_addr        Read1 address Bus [ceil( log2(depth) )]
//              rd2_addr        Read2 address Bus [ceil( log2(depth) )]
//              wr_addr         Write address Bus [ceil( log2(depth) )]
//              data_in         Input data [data_width-1:0]
//
//              Output Ports:   Description
//              =============   ===========
//              data_rd1_out    Output data from rd1_addr [data_width-1:0]
//              data_rd2_out    Output data from rd2_addr [data_width-1:0]
//
//      NOTE: This RAM is intended to be used as a scratchpad memory only.
//              For best results keep "depth" and "data_width" less than 65
//              (ie. less than 64 words in RAM) and the overall number of
//              bits less than 256.
//
// MODIFIED:
//			7/25/97	ss		Added conv_to_x task for data_in.
//			11/11/99 RPH	Rewrote for STAR 91151 fix
//              10/18/00  RPH       Rewrote accoding to new guidelines 
//                                  STAR 111067  
//              9/10/14   RJK       Eliminated common async and sync reset coding
//				    style to support VCS NLP
//------------------------------------------------------------------------------

module DW_ram_2r_w_a_lat (rst_n, cs_n, wr_n, rd1_addr, rd2_addr, 
		wr_addr, data_in, data_rd1_out, data_rd2_out);

   parameter data_width = 4;
   parameter depth = 8;
   parameter rst_mode = 1;


// Address width calculation limited to 8 bits (i.e. max depth 256)
`define DW_addr_width  ((depth>16)?((depth>64)?((depth>128)? 8 : 7) : ((depth>32)? 6 : 5)) : ((depth>4)?((depth>8)? 4 : 3) : ((depth>2)? 2 : 1)))
   
   input     wr_n;
   input     rst_n;
   input     cs_n;
   input [data_width-1 : 0] data_in;   // input port description
   input [`DW_addr_width-1 : 0] rd1_addr;
   input [`DW_addr_width-1 : 0] rd2_addr;
   input [`DW_addr_width-1 : 0] wr_addr;


   output [data_width-1 : 0] data_rd1_out; // output port description
   output [data_width-1 : 0] data_rd2_out; // output port description
   
// synopsys translate_off
   wire [data_width-1:0]   data_in;
   wire [data_width-1:0]   data_in_int;
   reg [data_width-1:0]    mem [depth-1:0];
   
   integer 		   i;
   
   function	any_unknown;
      input[`DW_addr_width-1:0] addr;
      integer	bit_idx;
      begin
	 any_unknown = 1'b0;

	 for (bit_idx = `DW_addr_width-1;
	      bit_idx >= 0 && any_unknown === 1'b0;
	      bit_idx=bit_idx-1)
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

    

  assign data_rd1_out = rd1_addr < depth ? 
		     (any_unknown(rd1_addr) ? 
		      {data_width{1'bx}} : mem[rd1_addr]) : {data_width{1'b0}};
  assign data_rd2_out = rd2_addr < depth ? 
		     (any_unknown(rd2_addr) ? 
		      {data_width{1'bx}} : mem[rd2_addr]) : {data_width{1'b0}};
   
   assign data_in_int = (any_unknown(data_in)) ? {data_width{1'bx}} : data_in;
   
generate
  if (rst_mode == 0) begin : GEN_RM_EQ_0
   always @(cs_n or wr_n or wr_addr or data_in_int or rst_n)
     begin : mk_ar_mem
	if (rst_n === 1'b0) begin
	   for (i = 0; i < depth; i = i + 1) begin
	      mem[i] = {data_width{1'b0}};
	   end 
	end
	else if (rst_n === 1'b1) begin
	   if (cs_n === 1'b0) begin
	      if (wr_n === 1'b0) begin
		 if (any_unknown(wr_addr) == 1'b1) begin
		    for (i = 0; i < depth; i = i + 1) begin
		       mem[i] = {data_width{1'bx}};
		    end 
		 end
		 else begin
		    mem[wr_addr] = data_in_int;
		 end // else: !if(any_unknown(wr_addr) == 1'b1)
	      end // if (cs_n === 1'b0)
	      else if(wr_n === 1'b1) begin
		 // do nothing
	      end
	      else begin
		 if (any_unknown(wr_addr) == 1'b1) begin
		    for (i = 0; i < depth; i = i + 1) begin
		       mem[i] = {data_width{1'bx}};
		    end 
		 end
		 else begin
		    mem[wr_addr] = {data_width{1'bx}};
		 end // else: !if(any_unknown(wr_addr) == 1'b1)
	      end
	   end // if (cs_n === 1'b0)
	   else if (cs_n === 1'b1) begin
	      // do nothing
	   end
	   else begin
	      if (any_unknown(wr_addr) == 1'b1) begin
		 for (i = 0; i < depth; i = i + 1) begin
		    mem[i] = {data_width{1'bx}};
		 end 
	      end
	      else begin
		 mem[wr_addr] = data_in_int;
	      end // else: !if(any_unknown(wr_addr) == 1'b1)
	   end // else: !if(cs_n === 1'b1)
	end // if (rst_n === 1'b1)
	else begin
	   for (i = 0; i < depth; i = i + 1) begin
	      mem[i] = {data_width{1'bx}};
	   end 
	end // else: !if(rst_n === 1'b1)
     end // block: mk_ar_mem
  end else begin : GEN_RM_NE_0
   always @(cs_n or wr_n or wr_addr or data_in_int)
     begin : mk_nr_mem
	   if (cs_n === 1'b0) begin
	      if (wr_n === 1'b0) begin
		 if (any_unknown(wr_addr) == 1'b1) begin
		    for (i = 0; i < depth; i = i + 1) begin
		       mem[i] = {data_width{1'bx}};
		    end 
		 end
		 else begin
		    mem[wr_addr] = data_in_int;
		 end // else: !if(any_unknown(wr_addr) == 1'b1)
	      end // if (cs_n === 1'b0)
	      else if(wr_n === 1'b1) begin
		 // do nothing
	      end
	      else begin
		 if (any_unknown(wr_addr) == 1'b1) begin
		    for (i = 0; i < depth; i = i + 1) begin
		       mem[i] = {data_width{1'bx}};
		    end 
		 end
		 else begin
		    mem[wr_addr] = {data_width{1'bx}};
		 end // else: !if(any_unknown(wr_addr) == 1'b1)
	      end
	   end // if (cs_n === 1'b0)
	   else if (cs_n === 1'b1) begin
	      // do nothing
	   end
	   else begin
	      if (any_unknown(wr_addr) == 1'b1) begin
		 for (i = 0; i < depth; i = i + 1) begin
		    mem[i] = {data_width{1'bx}};
		 end 
	      end
	      else begin
		 mem[wr_addr] = data_in_int;
	      end // else: !if(any_unknown(wr_addr) == 1'b1)
	   end // else: !if(cs_n === 1'b1)
     end // block: mk_nr_mem
  end
endgenerate
// synopsys translate_on
`undef DW_addr_width
endmodule // DW_ram_2r_w_a_lat;

