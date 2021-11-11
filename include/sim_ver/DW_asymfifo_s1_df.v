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
// AUTHOR:    Jay Zhu              November 8, 1999
//
// VERSION:   Simulation Architecture
//
// DesignWare_version: ddabe857
// DesignWare_release: K-2015.06-DWBB_201506.5.2
//
////////////////////////////////////////////////////////////////////////////////
//-----------------------------------------------------------------------------------
//
// ABSTRACT:  Asymmetric Synchronous with Dynamic Flags
//           (FIFO) with dynamic programmable almost empty and almost
//           full flags.
//
//           This FIFO designed to interface to synchronous
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
//              depth           [ 2 to 256 ]
//              err_mode        [ 0 = dynamic error flag,
//                                1 = sticky error flag ]
//              rst_mode        [ 0 = asynchronous reset including RAM,
//                                1 = synchronous reset including RAM,
//                                2 = asynchronous reset excluding RAM,
//                                3 = asynchronous reset excluding RAM]
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
//              ae_level        N bits  Almost Empty level
//              af_thresh       N bits  Almost Full threshold
//
//              Output Ports    Size    Description
//              ============    ====    ===========
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
//      06/03/02 RPH      Removed effective depth (STAR 145251)
//      07/13/09 Doug Lee: Changed all `define declarations to have the
//                         "DW_" prefix and then `undef them at the approprite time.
//-------------------------------------------------------------------------------

module DW_asymfifo_s1_df (clk, rst_n, push_req_n, flush_n, pop_req_n, diag_n,
            data_in, ae_level, af_thresh, empty, almost_empty, half_full, 
            almost_full, full, ram_full, error, part_wd, data_out);

parameter          data_in_width  = 4;
parameter          data_out_width = 16;
parameter          depth          = 10;
parameter          err_mode       = 2;
parameter          rst_mode       = 1;
parameter          byte_order     = 0;

`define DW_addr_width ((depth>16)?((depth>64)?((depth>128)?8:7):((depth>32)?6:5)):((depth>4)?((depth>8)?4:3):((depth>2)?2:1)))
input  				clk;
input				rst_n;
input				push_req_n;
input				flush_n;
input				pop_req_n;
input				diag_n;
input[data_in_width-1:0]	data_in;
input[`DW_addr_width-1:0]	ae_level;
input[`DW_addr_width-1:0]	af_thresh;

output				empty;
output				almost_empty;
output				half_full;
output				almost_full;
output				full;
output				ram_full;
output				error;
output				part_wd;
output[data_out_width-1:0]	data_out;

// synopsys translate_off

wire  				clk;
wire				rst_n;
wire				push_req_n;
wire				flush_n;
wire				pop_req_n;
wire				diag_n;
wire[data_in_width-1:0]		data_in;
wire[`DW_addr_width-1:0]	ae_level;
wire[`DW_addr_width-1:0]	af_thresh;

wire				empty;
wire				almost_empty;
wire				half_full;
wire				almost_full;
wire				full;
wire				ram_full;
wire				error;
wire				part_wd;
wire[data_out_width-1:0]	data_out;


`define DW_ctl_rst_mode (rst_mode%2)
`define DW_mem_rst_mode ((rst_mode+2)/3)
`define DW_ram_width (data_in_width>data_out_width?data_in_width:data_out_width)

wire				tie_low;
wire				we_n;
wire				mem_rst_n;
wire[`DW_ram_width-1:0]		wr_data;
wire[`DW_ram_width-1:0]		rd_data;
wire[`DW_addr_width-1:0]	wr_addr;
wire[`DW_addr_width-1:0]	rd_addr;


DW_asymfifoctl_s1_df
	#(data_in_width, data_out_width, depth, err_mode,
			`DW_ctl_rst_mode, byte_order)
	U1(
		.clk(clk),
		.rst_n(rst_n),
		.push_req_n(push_req_n),
		.flush_n(flush_n),
		.pop_req_n(pop_req_n),
		.diag_n(diag_n),
		.data_in(data_in),
		.ae_level(ae_level),
		.af_thresh(af_thresh),
		.rd_data(rd_data),
		.we_n(we_n),
		.empty(empty),
		.almost_empty(almost_empty),
		.half_full(half_full),
		.almost_full(almost_full),
		.full(full),
		.ram_full(ram_full),
		.error(error),
		.part_wd(part_wd),
		.wr_data(wr_data),
		.wr_addr(wr_addr),
		.rd_addr(rd_addr),
		.data_out(data_out)
		);


assign mem_rst_n  = ( (rst_mode < 2 ) ? rst_n  : ( 1'b1 ));

DW_ram_r_w_s_dff
	#(`DW_ram_width, depth, `DW_mem_rst_mode )
	    u2 (
		.clk(clk),
		.rst_n(mem_rst_n),
		.cs_n(tie_low),
		.wr_n(we_n),
		.rd_addr(rd_addr),
		.wr_addr(wr_addr),
		.data_in(wr_data),
		.data_out(rd_data)
		);

 assign  tie_low  = 1'b0 ;


`undef DW_ram_width
`undef DW_mem_rst_mode
`undef DW_ctl_rst_mode
// synopsys translate_on
`undef DW_addr_width
endmodule
