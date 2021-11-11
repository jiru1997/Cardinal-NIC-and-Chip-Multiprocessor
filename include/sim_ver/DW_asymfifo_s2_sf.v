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
// AUTHOR:    Jay Zhu		10/07/98
//
// VERSION:   Simulation Architecture
//
// DesignWare_version: 4f63a8af
// DesignWare_release: K-2015.06-DWBB_201506.5.2
//
////////////////////////////////////////////////////////////////////////////////
//-----------------------------------------------------------------------------------
//
// ABSTRACT:  Asymmetric Synchronous, dual clcok with Static Flags
//   	     (FIFO) with static programmable almost empty and almost
//           full flags
//
//		Parameters:	Valid Values
//		==========	============
//		data_in_width	[ 1 to 256]
//		data_out_width	[ 1 to 256]
//                  Note: data_in_width and data_out_width must be
//                        in integer multiple relationship: either
//                              data_in_width = K * data_out_width
//                        or    data_out_width = K * data_in_width
//		depth		[ 4 to 256 ]
//		push_ae_lvl	[ 1 to depth-1 ]
//		push_af_lvl	[ 1 to depth-1 ]
//		pop_ae_lvl	[ 1 to depth-1 ]
//		pop_af_lvl	[ 1 to depth-1 ]
//		err_mode	[ 0 = sticky error flag,
//				  1 = dynamic error flag ]
//		push_sync	[ 1 = single synchronized,
//				  2 = double synchronized,
//				  3 = triple synchronized ]
//		pop_sync	[ 1 = single synchronized,
//				  2 = double synchronized,
//				  3 = triple synchronized ]
//		rst_mode	[ 0 = asynchronous reset RAM & ctlr,
//				  1 = synchronous reset RAM & ctlr,
//				  2 = asynchronous reset ctlr only,
//				  3 = synchronous reset ctlr only ]
//		byte_order	[ 0 = the first byte is in MSBs
//				  1 = the first byte is in LSBs ]
//		
//		Input Ports:	Size	Description
//		===========	====	===========
//		clk_push	1 bit	Push I/F Input Clock
//		clk_pop		1 bit	Pop I/F Input Clock
//		rst_n		1 bit	Active Low Reset
//		push_req_n	1 bit	Active Low Push Request
//              flush_n         1 bit   Flush the partial word into
//                                      the full word memory.  For
//                                      data_in_width<data_out_width
//                                      only
//		pop_req_n	1 bit	Active Low Pop Request
//		data_in		I bits	Push Data input
//
//		Output Ports	Size	Description
//		============	====	===========
//		push_empty	1 bit	Push I/F Empty Flag
//		push_ae		1 bit	Push I/F Almost Empty Flag
//		push_hf		1 bit	Push I/F Half Full Flag
//		push_af		1 bit	Push I/F Almost Full Flag
//		push_full	1 bit	Push I/F Full Flag
//		ram_full	1 bit	Full Flag for RAM
//              part_wd         1 bit   Partial word read flag.  For
//                                      data_in_width<data_out_width
//                                      only
//		push_error	1 bit	Push I/F Error Flag
//		pop_empty	1 bit	Pop I/F Empty Flag
//		pop_ae		1 bit	Pop I/F Almost Empty Flag
//		pop_hf		1 bit	Pop I/F Half Full Flag
//		pop_af		1 bit	Pop I/F Almost Full Flag
//		pop_full	1 bit	Pop I/F Full Flag
//		pop_error	1 bit	Pop I/F Error Flag
//		data_out	O bits	Pop Data output
//
//                Note: the value of I is parameter data_in_width
//		  Note: the value of O is parameter data_out_width
//
//
// MODIFIED:
//
//		RJK  11/29/01	Fixed addr width missmatch for depth of
//				4 (STAR 131712)
//
//-------------------------------------------------------------------------------
//


module DW_asymfifo_s2_sf (
	clk_push,
	clk_pop,
	rst_n,
	push_req_n,
	flush_n,
	pop_req_n,
	data_in,
    	push_empty,
	push_ae,
	push_hf,
	push_af,
	push_full,
	ram_full,
	part_wd,
	push_error, 
	pop_empty,
	pop_ae,
	pop_hf,
	pop_af,
	pop_full,
	pop_error,
	data_out);

parameter data_in_width = 8;
parameter data_out_width = 8;
parameter depth = 8 ;
parameter push_ae_lvl = 2 ;
parameter push_af_lvl = 2 ;
parameter pop_ae_lvl = 2 ;
parameter pop_af_lvl = 2 ;
parameter err_mode = 0 ;
parameter push_sync = 2 ;
parameter pop_sync = 2 ;
parameter rst_mode = 1 ;
parameter byte_order = 0 ;

input  clk_push;
input  clk_pop;
input  rst_n;
input  push_req_n;
input  flush_n;
input  pop_req_n;
input  [(data_in_width-1):0]  data_in;

output  push_empty;
output  push_ae;
output  push_hf;
output  push_af;
output  push_full;
output  ram_full;
output  part_wd;
output  push_error;
output  pop_empty;
output  pop_ae;
output  pop_hf;
output  pop_af;
output  pop_full;
output  pop_error;
output  [(data_out_width-1):0]  data_out;


// synopsys translate_off

wire tie_low;
wire mem_rst_n;

`define DW_effective_depth (depth==4?4:(depth==8?8:(depth==16?16:(depth==32?32:(depth==64?64:(depth==128?128:(depth==256?256:(depth+2-(depth %2)))))))))
`define DW_ram_width (data_in_width>data_out_width?data_in_width:data_out_width)
`define DW_addr_width  ((depth>128)?8:((depth>64)?7:(((depth>32)?6:((depth>16)?5:((depth>8)?4:(depth>4)?3:2))))))

`define DW_ctl_rst_mode (rst_mode%2 )
`define DW_mem_rst_mode ((rst_mode+2)/ 3 )

wire	[`DW_addr_width-1:0] rd_addr;
wire	[`DW_addr_width-1:0] wr_addr;
wire	[`DW_ram_width-1:0]  rd_data;
wire	[`DW_ram_width-1:0]  wr_data;
wire	we_n;

   
 
  initial begin : parameter_check
    integer param_err_flg;

    param_err_flg = 0;
    

   
    if ( (data_in_width < 1) || (data_in_width > 256 ) ) begin
      param_err_flg = 1;
      $display(
	"ERROR: %m :\n  Invalid value (%d) for parameter data_in_width (legal range: 1 to 256 )",
	data_in_width );
    end
   
    if ( (data_out_width < 1) || (data_out_width > 256 ) ) begin
      param_err_flg = 1;
      $display(
	"ERROR: %m :\n  Invalid value (%d) for parameter data_out_width (legal range: 1 to 256 )",
	data_out_width );
    end
   
    if ( (depth < 4) || (depth > 256) ) begin
      param_err_flg = 1;
      $display(
	"ERROR: %m :\n  Invalid value (%d) for parameter depth (legal range: 4 to 256)",
	depth );
    end
   
    if ( (push_ae_lvl < 1) || (push_ae_lvl > depth-1 ) ) begin
      param_err_flg = 1;
      $display(
	"ERROR: %m :\n  Invalid value (%d) for parameter push_ae_lvl (legal range: 1 to depth-1 )",
	push_ae_lvl );
    end
   
    if ( (push_af_lvl < 1) || (push_af_lvl > depth-1 ) ) begin
      param_err_flg = 1;
      $display(
	"ERROR: %m :\n  Invalid value (%d) for parameter push_af_lvl (legal range: 1 to depth-1 )",
	push_af_lvl );
    end
   
    if ( (pop_ae_lvl < 1) || (pop_ae_lvl > depth-1 ) ) begin
      param_err_flg = 1;
      $display(
	"ERROR: %m :\n  Invalid value (%d) for parameter pop_ae_lvl (legal range: 1 to depth-1 )",
	pop_ae_lvl );
    end
   
    if ( (pop_af_lvl < 1) || (pop_af_lvl > depth-1 ) ) begin
      param_err_flg = 1;
      $display(
	"ERROR: %m :\n  Invalid value (%d) for parameter pop_af_lvl (legal range: 1 to depth-1 )",
	pop_af_lvl );
    end
   
    if ( (push_sync < 1) || (push_sync > 3 ) ) begin
      param_err_flg = 1;
      $display(
	"ERROR: %m :\n  Invalid value (%d) for parameter push_sync (legal range: 1 to 3 )",
	push_sync );
    end
   
    if ( (pop_sync < 1) || (pop_sync > 3 ) ) begin
      param_err_flg = 1;
      $display(
	"ERROR: %m :\n  Invalid value (%d) for parameter pop_sync (legal range: 1 to 3 )",
	pop_sync );
    end
   
    if ( (err_mode < 0) || (err_mode > 1 ) ) begin
      param_err_flg = 1;
      $display(
	"ERROR: %m :\n  Invalid value (%d) for parameter err_mode (legal range: 0 to 1 )",
	err_mode );
    end
   
    if ( (rst_mode < 0) || (rst_mode > 3 ) ) begin
      param_err_flg = 1;
      $display(
	"ERROR: %m :\n  Invalid value (%d) for parameter rst_mode (legal range: 0 to 3 )",
	rst_mode );
    end
   
    if ( (byte_order < 0) || (byte_order > 1 ) ) begin
      param_err_flg = 1;
      $display(
	"ERROR: %m :\n  Invalid value (%d) for parameter byte_order (legal range: 0 to 1 )",
	byte_order );
    end

   
    if ( param_err_flg == 1) begin
      $display(
        "%m :\n  Simulation aborted due to invalid parameter value(s)");
      $finish;
    end

  end // parameter_check 

     
DW_asymfifoctl_s2_sf 	#(
	data_in_width, data_out_width, depth, push_ae_lvl, push_af_lvl,
	pop_ae_lvl, pop_af_lvl, err_mode, push_sync, pop_sync,
	`DW_ctl_rst_mode, byte_order )
   u1 (
	.clk_push(clk_push),
	.clk_pop(clk_pop),
	.rst_n(rst_n),
	.push_req_n(push_req_n),
	.flush_n(flush_n),
	.pop_req_n(pop_req_n),
	.data_in(data_in),
	.rd_data(rd_data),
	.we_n(we_n),
	.push_empty(push_empty),
	.push_ae(push_ae),
	.push_hf(push_hf),
	.push_af(push_af),
	.push_full(push_full),
	.ram_full(ram_full),
	.part_wd(part_wd),
	.push_error(push_error),
	.pop_empty(pop_empty),
	.pop_ae(pop_ae),
	.pop_hf(pop_hf),
	.pop_af(pop_af),
	.pop_full(pop_full),
	.pop_error(pop_error),
	.wr_data(wr_data),
	.wr_addr(wr_addr),
	.rd_addr(rd_addr),
	.data_out(data_out));

assign mem_rst_n  = ( (rst_mode < 2 ) ? rst_n  : ( 1'b1 ));

DW_ram_r_w_s_dff 	#(`DW_ram_width, `DW_effective_depth, `DW_mem_rst_mode )
    u2 (
	.clk(clk_push),
	.rst_n(mem_rst_n),
	.cs_n(tie_low),
	.wr_n(we_n),
	.rd_addr(rd_addr),
	.wr_addr(wr_addr),
	.data_in(wr_data),
	.data_out(rd_data));

 assign  tie_low  = 1'b0 ;

`undef DW_effective_depth
`undef DW_ram_width
`undef DW_addr_width
`undef DW_ctl_rst_mode
`undef DW_mem_rst_mode

// synopsys translate_on
endmodule
