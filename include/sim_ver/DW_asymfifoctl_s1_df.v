////////////////////////////////////////////////////////////////////////////////
//
//       This confidential and proprietary software may be used only
//     as authorized by a licensing agreement from Synopsys Inc.
//     In the event of publication, the following notice is applicable:
//
//                    (C) COPYRIGHT 1998 - 2016 SYNOPSYS INC.
//                           ALL RIGHTS RESERVED
//
//       The entire notice above must be reproduced on all authorized
//     copies.
//
// AUTHOR:    Jay Zhu              Nov. 08, 1999
//
// VERSION:   Simulation Architecture
//
// DesignWare_version: 1f1f04ec
// DesignWare_release: K-2015.06-DWBB_201506.5.2
//
////////////////////////////////////////////////////////////////////////////////
//-----------------------------------------------------------------------------------
//
// ABSTRACT:  Asymmetric, Synchronous with Dynamic Flags
//           (FIFO) with dynamic programmable almost empty and almost
//           full flags.
//
//           This FIFO controller designed to interface to synchronous
//           true dual port RAMs.
//
//              Parameters:     Valid Values
//              ==========      ============
//              data_in_width   [ 1 to 256]
//              data_out_width  [ 1 to 256]
//                  Note: data_in_width and data_out_width must be
//                        in integer multiple relationship: either
//                              data_in_width = K * data_out_width
//                        or    data_out_width = K * data_in_width
//              depth           [ 2 to 16777216 ]
//              err_mode        [ 0 = overflow+pointer latched checking
//                                1 = overflow latched checking
//                                2 = overflow unlatched checking ]
//              rst_mode        [ 0 = asynchronous reset,
//                                1 = synchronous reset ]
//              byte_order      [ 0 = the first byte is in MSBs
//                                1 = the first byte is in LSBs ]
//        
//              Input Ports:    Size    Description
//              ===========     ====    ===========
//              clk             1 bit   Input Clock
//              rst_n           1 bit   Active Low Reset
//              push_req_n      1 bit   Active Low Push Request
//              flush_n         1 bit   Flush the partial word into
//                                      the full word memory.  For
//                                      data_in_width<data_out_width
//                                      only
//              pop_req_n       1 bit   Active Low Pop Request
//              diag_n          1 bit   Active Low diagnostic input
//              data_in         L bits  FIFO data to push
//              rd_data         M bits  RAM data input to asymmetric
//                                      FIFO controller
//              ae_level        N bits  Almost Empty level
//              af_thresh       N bits  Almost Full threshold
//
//              Output Ports    Size    Description
//              ============    ====    ===========
//              we_n            1 bit   Active low Write Enable (to RAM)
//              empty           1 bit   Empty Flag
//              almost_empty    1 bit   Almost Empty Flag
//              half_full       1 bit   Half Full Flag
//              almost_full     1 bit   Almost Full Flag
//              full            1 bit   Full Flag
//              ram_full        1 bit   Full Flag for RAM
//              error           1 bit   Error Flag
//              part_wd         1 bit   Partial word read flag.  For
//                                      data_in_width<data_out_width
//                                      only
//              wr_data         M bits  FIFO controller output data
//                                      to RAM
//              wr_addr         N bits  Write Address (to RAM)
//              rd_addr         N bits  Read Address (to RAM)
//              data_out        O bits  FIFO data to pop
//
//                Note: the value of L is parameter data_in_width
//                Note: the value of M is
//                         maximum(data_in_width, data_out_width)
//                Note: the value of N for wr_addr and rd_addr is
//                      determined from the parameter, depth.  The
//                      value of N is equal to:
//                              ceil( log2( depth ) )
//                Note: the value of O is parameter data_out_width
//
//
// MODIFIED:
//	10/06/98 Jay Zhu: STAR 59594
//	11/08/99 Jay Zhu: Rewrote entire sim model for STAR 92843
//      07/13/09 Doug Lee: Changed all `define declarations to have the
//                         "DW_" prefix and then `undef them at the approprite time.
//      08/12/15 RJK Update for compaibility with VCS NLP
//-------------------------------------------------------------------------------

module DW_asymfifoctl_s1_df (clk, rst_n, push_req_n, flush_n, pop_req_n, diag_n,
            data_in, rd_data, ae_level, af_thresh, we_n, empty, almost_empty, 
            half_full, almost_full, full, ram_full, error, part_wd, wr_data, 
            wr_addr, rd_addr, data_out);

 parameter          data_in_width  = 4;
 parameter          data_out_width = 16;
 parameter          depth          = 10;
 parameter          err_mode       = 2;
 parameter          rst_mode       = 1;
 parameter          byte_order     = 0;



`define DW_addr_width ((depth>4096)? ((depth>262144)? ((depth>2097152)? ((depth>8388608)? 24:((depth> 4194304)? 23:22)):((depth>1048576)? 21:((depth>524288)? 20:19))):((depth>32768)? ((depth>131072)?  18:((depth>65536)? 17:16)):((depth>16384)? 15:((depth>8192)? 14:13)))):((depth>64)? ((depth>512)?  ((depth>2048)? 12:((depth>1024)? 11:10)):((depth>256)? 9:((depth>128)? 8:7))):((depth>8)? ((depth> 32)? 6:((depth>16)? 5:4)):((depth>4)? 3:((depth>2)? 2:1)))))

`define DW_max_width ((data_in_width>data_out_width)?data_in_width:data_out_width)

`define DW_K ((data_in_width>data_out_width)?(data_in_width/data_out_width):(data_out_width/data_in_width))



input				clk;
input				rst_n;
input				push_req_n;
input				flush_n;
input				pop_req_n;
input				diag_n;
input[data_in_width-1:0]     	data_in;
input[`DW_max_width-1:0]        rd_data;
input[`DW_addr_width-1:0]	ae_level;
input[`DW_addr_width-1:0]	af_thresh;

output				we_n;
output				empty;
output				almost_empty;
output				half_full;
output				almost_full;
output				full;
output				ram_full;
output				error;
output				part_wd;
output[data_out_width-1:0]	data_out;
output[`DW_max_width-1:0]	wr_data;
output[`DW_addr_width-1:0]	wr_addr;
output[`DW_addr_width-1:0]	rd_addr;


// synopsys translate_off

wire				we_n;
wire				empty;
wire				almost_empty;
wire				half_full;
wire				almost_full;
wire				full;
wire				ram_full;
wire				error;
wire				part_wd;
wire[`DW_addr_width-1:0]	ae_level;
wire[`DW_addr_width-1:0]	af_thresh;
reg[data_out_width-1:0]     	data_out;
reg[`DW_max_width-1:0]         	wr_data;
wire[`DW_addr_width-1:0]        wr_addr;
wire[`DW_addr_width-1:0]        rd_addr;



`define	DW_input_buf_width	((data_in_width<data_out_width)?(data_out_width-data_in_width):1)
`define	DW_input_buf_width_1 ((2*data_in_width<data_out_width)?(data_out_width-2*data_in_width):1)

wire[`DW_max_width-1:0]		wr_data_int;
wire				ram_pop_n;
reg				out_ram_pop_n;
wire				ram_error;
reg				wrap_error;
reg				wrap_error_nxt;
reg				part_wd_KS;
reg				part_wd_KS_nxt;
reg[`DW_input_buf_width-1:0] 	KS_input_buf_LSBs;
reg[`DW_input_buf_width-1:0] 	KS_input_buf_LSBs_nxt;
reg[data_in_width-1:0]		KS_input_buf_MSBs;
wire				ram_empty;
wire				ram_full_int;
reg				wrap_full;
wire				wrap_full_nxt;
wire				ram_push_n;
reg				ram_push_act_n;
reg				wrap_push_act_n;
integer				in_buf_byte_n;
integer				in_buf_byte_n_nxt;
integer				i;
integer				bit_idx;
integer				byte_idx;
integer				out_byte_idx;
integer				out_byte_idx_nxt;




 
  initial begin : parameter_check
    integer param_err_flg;

    param_err_flg = 0;
    

	
    if ( (data_in_width < 1) || (data_in_width > 256) ) begin
      param_err_flg = 1;
      $display(
	"ERROR: %m :\n  Invalid value (%d) for parameter data_in_width (legal range: 1 to 256)",
	data_in_width );
    end
	
    if ( (data_out_width < 1) || (data_out_width > 256) ) begin
      param_err_flg = 1;
      $display(
	"ERROR: %m :\n  Invalid value (%d) for parameter data_out_width (legal range: 1 to 256)",
	data_out_width );
    end
	
    if ( (depth < 2) || (depth > 16777216) ) begin
      param_err_flg = 1;
      $display(
	"ERROR: %m :\n  Invalid value (%d) for parameter depth (legal range: 2 to 16777216)",
	depth );
    end
	
    if ( (err_mode < 0) || (err_mode > 2) ) begin
      param_err_flg = 1;
      $display(
	"ERROR: %m :\n  Invalid value (%d) for parameter err_mode (legal range: 0 to 2)",
	err_mode );
    end
	
    if ( (rst_mode < 0) || (rst_mode > 1) ) begin
      param_err_flg = 1;
      $display(
	"ERROR: %m :\n  Invalid value (%d) for parameter rst_mode (legal range: 0 to 1)",
	rst_mode );
    end
	
    if ( (byte_order < 0) || (byte_order > 1) ) begin
      param_err_flg = 1;
      $display(
	"ERROR: %m :\n  Invalid value (%d) for parameter byte_order (legal range: 0 to 1)",
	byte_order );
    end
	
	if(data_in_width/data_out_width >= 1 &&
		(data_in_width/data_out_width)*data_out_width !==
			data_in_width)
	begin
	  $display(
		"Error: data_in_width (%d) is not multiple times of data_out_width (%d) in DW_asymfifoctl_s1_df.",
		data_in_width, data_out_width);
	end
	
	if(data_out_width/data_in_width >= 1 &&
		(data_out_width/data_in_width)*data_in_width !==
			data_out_width)
	begin
	  $display(
		"Error: data_out_width (%d) is not multiple times of data_in_width (%d) in DW_asymfifoctl_s1_df.",
		data_out_width, data_in_width);
	end


    if ( param_err_flg == 1) begin
      $display(
        "%m :\n  Simulation aborted due to invalid parameter value(s)");
      $finish;
    end

  end // parameter_check 




  always @ (clk) begin : clk_monitor
    if ( (clk !== 1'b0) && (clk !== 1'b1) && ($time > 0) )
      $display( "WARNING: %m :\n  at time = %t, detected unknown value, %b, on clk input.",
                $time, clk );
    end // clk_monitor


DW_fifoctl_s1_df #(depth, err_mode, rst_mode)
	U_K1(	.clk(clk), .rst_n(rst_n),
		.push_req_n(ram_push_n), .pop_req_n(ram_pop_n),
		.diag_n(diag_n),
		.ae_level(ae_level), .af_thresh(af_thresh),
		.we_n(we_n),
		.empty(ram_empty), .almost_empty(almost_empty),
		.half_full(half_full), .almost_full(almost_full),
		.full(ram_full_int),
		.error(ram_error),
		.wr_addr(wr_addr),
		.rd_addr(rd_addr)
		);

assign	ram_push_n = (data_in_width<data_out_width)?ram_push_act_n :
			push_req_n;

assign	ram_pop_n = (data_in_width<=data_out_width)?
				pop_req_n : out_ram_pop_n;

assign	part_wd = (data_in_width<data_out_width)?part_wd_KS:1'b0;

assign	error = (data_in_width<data_out_width)?
			(ram_error|wrap_error):ram_error;



generate
  if (rst_mode == 0) begin : GEN_RM_EQ_0
always@(posedge clk or negedge rst_n)
begin

	if(data_in_width < data_out_width)
	begin
	  if (rst_n === 1'b0)
	  begin
	    part_wd_KS <= 1'b0;
	    wrap_error <= 1'b0;
	    KS_input_buf_LSBs <= {`DW_input_buf_width{1'b0}};
	    wrap_full <= 1'b0;
	    in_buf_byte_n <= 0;
	  end

	  else if (rst_n === 1'b1)
	  begin
	    part_wd_KS <= part_wd_KS_nxt;
	    wrap_error <= (err_mode===0||err_mode===1)?
		(wrap_error_nxt|wrap_error):wrap_error_nxt;
	    KS_input_buf_LSBs <= KS_input_buf_LSBs_nxt;
	    wrap_full <= wrap_full_nxt;
	    in_buf_byte_n <= in_buf_byte_n_nxt;
	  end

	  else
	  begin
	    part_wd_KS <= 1'bX;
	    wrap_error <= 1'bX;
	    KS_input_buf_LSBs <= {`DW_input_buf_width{1'bX}};
	    wrap_full <= 1'bX;
	    in_buf_byte_n <= -1;
	  end
	end

	else if(data_in_width > data_out_width)
	begin
	  if (rst_n === 1'b0)
	  begin
	    wrap_error <= 1'b0;
	    out_byte_idx <= 0;
	  end
	  
	  else if (rst_n === 1'b1)
	  begin
	    wrap_error <= (err_mode===0||err_mode===1)?
		(wrap_error_nxt|wrap_error):wrap_error_nxt;
	    out_byte_idx <= out_byte_idx_nxt;
	  end
	  
	  else
	  begin
	    wrap_error <= 1'bX;
	    out_byte_idx <= -1;
	  end
	  
	end

end
  end else begin : GEN_RM_NE_0
always@(posedge clk)
begin

	if(data_in_width < data_out_width)
	begin
	  if (rst_n === 1'b0)
	  begin
	    part_wd_KS <= 1'b0;
	    wrap_error <= 1'b0;
	    KS_input_buf_LSBs <= {`DW_input_buf_width{1'b0}};
	    wrap_full <= 1'b0;
	    in_buf_byte_n <= 0;
	  end

	  else if (rst_n === 1'b1)
	  begin
	    part_wd_KS <= part_wd_KS_nxt;
	    wrap_error <= (err_mode===0||err_mode===1)?
		(wrap_error_nxt|wrap_error):wrap_error_nxt;
	    KS_input_buf_LSBs <= KS_input_buf_LSBs_nxt;
	    wrap_full <= wrap_full_nxt;
	    in_buf_byte_n <= in_buf_byte_n_nxt;
	  end

	  else
	  begin
	    part_wd_KS <= 1'bX;
	    wrap_error <= 1'bX;
	    KS_input_buf_LSBs <= {`DW_input_buf_width{1'bX}};
	    wrap_full <= 1'bX;
	    in_buf_byte_n <= -1;
	  end
	end

	else if(data_in_width > data_out_width)
	begin
	  if (rst_n === 1'b0)
	  begin
	    wrap_error <= 1'b0;
	    out_byte_idx <= 0;
	  end
	  
	  else if (rst_n === 1'b1)
	  begin
	    wrap_error <= (err_mode===0||err_mode===1)?
		(wrap_error_nxt|wrap_error):wrap_error_nxt;
	    out_byte_idx <= out_byte_idx_nxt;
	  end
	  
	  else
	  begin
	    wrap_error <= 1'bX;
	    out_byte_idx <= -1;
	  end
	  
	end

end
  end
endgenerate


assign wr_data_int = (data_in_width >= data_out_width) ?
		data_in : {KS_input_buf_MSBs, KS_input_buf_LSBs};


always@(wr_data_int)
begin

	if(data_in_width >= data_out_width || byte_order === 1)
	begin
	  wr_data = wr_data_int;
	end
	else
	begin
	  for (i = 0; i<`DW_K; i=i+1)
	    for (bit_idx = 0;
		 bit_idx < data_in_width;
		 bit_idx = bit_idx+1)
	      wr_data[i*data_in_width+bit_idx] = 
	      	wr_data_int[(`DW_K-1-i)*data_in_width+bit_idx];
	end
end


always@(rd_data or out_byte_idx)
begin

	if(data_in_width <= data_out_width)
	begin
	  data_out = rd_data;
	end
	else
	begin
	  if(out_byte_idx>=0 && out_byte_idx<`DW_K)
	  begin
	    if(byte_order === 1)
	      byte_idx = out_byte_idx;
	    else
	      byte_idx = `DW_K-1-out_byte_idx;
	    for (bit_idx = 0;
		 bit_idx < data_out_width;
		 bit_idx = bit_idx+1)
	      data_out[bit_idx] = 
			rd_data[byte_idx*data_out_width+bit_idx];
	  end
	  else
	    data_out = {data_out_width{1'bX}};
	end
end


assign	ram_full = ram_full_int;

assign	full = (data_in_width<data_out_width)?(wrap_full & ram_full_int)
			: ram_full_int;

assign	wrap_full_nxt = (in_buf_byte_n_nxt===`DW_K-1)?1'b1 :
		(0<=in_buf_byte_n_nxt && in_buf_byte_n_nxt<`DW_K-1)?1'b0 :
			1'bX;

assign	empty = ram_empty;


always @(ram_full_int or in_buf_byte_n or push_req_n or pop_req_n
		or flush_n or data_in or KS_input_buf_LSBs
		or part_wd_KS)
begin
	if(data_in_width<data_out_width)
	begin
	  if(((ram_full_int===1'b1)?0:((ram_full_int===1'b0)?0:1)) || ((flush_n===1'b1)?0:((flush_n===1'b0)?0:1)) ||
	     ((push_req_n===1'b1)?0:((push_req_n===1'b0)?0:1)) || ((pop_req_n===1'b1)?0:((pop_req_n===1'b0)?0:1)) ||
	     in_buf_byte_n<0)
	  begin
	    wrap_error_nxt = 1'bX;
	    ram_push_act_n = 1'bX;
	    wrap_push_act_n = 1'bX;
	    in_buf_byte_n_nxt = -1;
	    part_wd_KS_nxt = 1'bX;
	    KS_input_buf_LSBs_nxt = {`DW_input_buf_width{1'bX}};
	    KS_input_buf_MSBs = {data_in_width{1'bX}};
	  end
	  else
	  begin
	    if(ram_full_int===1'b1 && (
		(in_buf_byte_n === `DW_K-1 && push_req_n===1'b0) ||
		(in_buf_byte_n > 0 && flush_n === 1'b0)))
	      wrap_error_nxt = pop_req_n;
	    else
	      wrap_error_nxt = 1'b0;

	    if ((in_buf_byte_n === `DW_K-1 && push_req_n===1'b0) ||
		(in_buf_byte_n > 0 && flush_n === 1'b0))
	      ram_push_act_n = (ram_full_int===1'b1)?pop_req_n:1'b0;
	    else
	      ram_push_act_n = 1'b1;

	    if(ram_push_act_n===1'b0 && flush_n === 1'b1)
	      KS_input_buf_MSBs = data_in;
	    else
	      KS_input_buf_MSBs = {data_in_width{1'b0}};

	    if(ram_full_int===1'b1 &&
		in_buf_byte_n === `DW_K-1 && push_req_n===1'b0)
	      wrap_push_act_n = pop_req_n;
	    else
	      wrap_push_act_n = push_req_n;

	    if(ram_push_act_n === 1'b0)
	    begin
	      if(flush_n === 1'b0 && push_req_n===1'b0)
	      begin
	        in_buf_byte_n_nxt = 1;
		part_wd_KS_nxt = 1'b1;
		KS_input_buf_LSBs_nxt = (`DW_K>2)?
		    {{`DW_input_buf_width_1{1'b0}}, data_in}:
		    data_in;
	      end
	      else
	      begin
	        in_buf_byte_n_nxt = 0;
		part_wd_KS_nxt = 1'b0;
		if(flush_n === 1'b0)
		begin
		   for(bit_idx = `DW_input_buf_width-1;
		       bit_idx >= data_in_width;
		       bit_idx = bit_idx-1)
		      KS_input_buf_LSBs_nxt[bit_idx] = 1'b0;
		end
		else
	          KS_input_buf_LSBs_nxt = {`DW_input_buf_width{1'b0}};
	      end
	    end
	    else
	    begin
	      if (wrap_push_act_n === 1'b0)
	      begin
		in_buf_byte_n_nxt = in_buf_byte_n + 1;
		part_wd_KS_nxt = 1'b1;
		for(bit_idx=`DW_input_buf_width-1;
		    bit_idx>=0;
		    bit_idx=bit_idx-1)
		  if(bit_idx<in_buf_byte_n*data_in_width)
		    KS_input_buf_LSBs_nxt[bit_idx] = KS_input_buf_LSBs[bit_idx];
		  else if(bit_idx>=(in_buf_byte_n+1)*data_in_width)
		    KS_input_buf_LSBs_nxt[bit_idx] = 1'b0;
		  else
		    KS_input_buf_LSBs_nxt[bit_idx] =
			data_in[bit_idx-in_buf_byte_n*data_in_width];
	      end
	      else
	      begin
		in_buf_byte_n_nxt = in_buf_byte_n;
		part_wd_KS_nxt = part_wd_KS;
		KS_input_buf_LSBs_nxt = KS_input_buf_LSBs;
	      end
	    end
	  end
	end

end


always@(ram_empty or pop_req_n or out_byte_idx)
begin
	if(data_in_width>data_out_width)
	begin
	  if(((ram_empty===1'b1)?0:((ram_empty===1'b0)?0:1)) || ((pop_req_n===1'b1)?0:((pop_req_n===1'b0)?0:1)) ||
	     out_byte_idx < 0)
	  begin
	    out_ram_pop_n = 1'bX;
	    out_byte_idx_nxt = -1;
	  end

	  else
	  begin

	    if(pop_req_n === 1'b0 && ram_empty === 1'b0)
	    begin
	      out_byte_idx_nxt = (out_byte_idx+1) % `DW_K;
	    end

	    else
	      out_byte_idx_nxt = out_byte_idx;
	    end
	    out_ram_pop_n = (out_byte_idx===`DW_K-1||out_byte_idx_nxt===0)
				?pop_req_n:1'b1;
	  end

end

`undef DW_input_buf_width_1
`undef DW_input_buf_width
// synopsys translate_on
`undef DW_K
`undef DW_max_width
`undef DW_addr_width

endmodule
