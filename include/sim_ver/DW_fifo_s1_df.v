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
// AUTHOR:    Rick Kelly         11/12/99
//
// VERSION:   Verilog Simulation Model
//
// DesignWare_version: 2a073bf2
// DesignWare_release: K-2015.06-DWBB_201506.5.2
//
////////////////////////////////////////////////////////////////////////////////
//-----------------------------------------------------------------------------------
//
// ABSTRACT:  Synchronous with Dynamic Flags
//           programmable almost empty and almost full flags
//
//              Parameters:     Valid Values
//              ==========      ============
//              width           [ 1 to 2048 ]
//              depth           [ 2 to 1024 ]
//              err_mode        [ 0 = sticky error flag w/ ptr check,
//                                1 = sticky error flag (no ptr chk),
//                                2 = dynamic error flag ]
//              reset_mode      [ 0 = asynchronous reset (including RAM),
//                                1 = synchronous reset (including RAM),
//                                2 = asynchronous reset (excluding RAM),
//                                3 = synchronous reset (excluding RAM) ]
//              
//              Input Ports:    Size    Description
//              ===========     ====    ===========
//              clk             1 bit   Input Clock
//              rst_n           1 bit   Active Low Reset
//              push_req_n      1 bit   Active Low Push Request
//              pop_req_n       1 bit   Active Low Pop Request
//              diag_n          1 bit   Active Low diagnostic control
//              ae_level        N bits  Almost Empty Level
//              af_thresh       N bits  Almost Full Threshold
//              data_in         W bits  Push data input
//
//              Output Ports    Size    Description
//              ============    ====    ===========
//              empty           1 bit   Empty Flag
//              almost_empty    1 bit   Almost Empty Flag
//              half_full       1 bit   Half Full Flag
//              almost_full     1 bit   Almost Full Flag
//              full            1 bit   Full Flag
//              error           1 bit   Error Flag
//              data_out        W bits  Pop data output
//
//                Note: the value of N for ae_level and af_thresh is
//                      determined from the parameter, depth.  The
//                      value of N is equal to:
//                              ceil( log2( depth ) )
//              
//
//
// MODIFIED: 
//      07/13/09 Doug Lee: Changed all `define declarations to have the
//                         "DW_" prefix and then `undef them at the approprite time.
//
//		RJK	03/16/11
//		Increased width and depth limits to 2048 & 1024 respectivey.
//		STAR 9000371459
//
//-------------------------------------------------------------------------------
//
module DW_fifo_s1_df (
    clk, rst_n, push_req_n, pop_req_n, diag_n, ae_level, af_thresh, data_in, empty, 
    almost_empty, half_full, almost_full, full, error, data_out );

parameter width  = 8;
parameter depth  = 4;
parameter err_mode  =  0 ;
parameter rst_mode  =  0 ;

`define DW_addr_width ((depth>256)?((depth>4096)?((depth>16384)?((depth>32768)?16:15):((depth>8192)?14:13)):((depth>1024)?((depth>2048)?12:11):((depth>512)?10:9))):((depth>16)?((depth>64)?((depth>128)?8:7):((depth>32)?6:5)):((depth>4)?((depth>8)?4:3):((depth>2)?2:1))))

`define DW_ctl_rst_mode (rst_mode % 2)
`define DW_ram_rst_mode ((rst_mode > 0)? 1 : 0)

 input  clk,  rst_n,  push_req_n,  pop_req_n,  diag_n;
 input [`DW_addr_width-1 : 0] ae_level, af_thresh;
 input [width-1 : 0] data_in;
 output  empty,  almost_empty,  half_full,  almost_full,  full, error;
 output [width-1 : 0 ]  data_out;
 wire clk, rst_n, push_req_n, pop_req_n, diag_n;
 wire empty, almost_empty, half_full, almost_full, full, error;
 wire [width-1 : 0 ]  data_out;
 wire [`DW_addr_width-1 : 0] ram_rd_addr, ram_wr_addr;
 wire ram_rst_n, ram_we_n;
 
    // synopsys translate_off

    
 
  initial begin : parameter_check
    integer param_err_flg;

    param_err_flg = 0;
    
	
	
    if ( (width < 1) || (width > 2048 ) ) begin
      param_err_flg = 1;
      $display(
	"ERROR: %m :\n  Invalid value (%d) for parameter width (legal range: 1 to 2048 )",
	width );
    end
	
    if ( (depth < 2) || (depth > 1024 ) ) begin
      param_err_flg = 1;
      $display(
	"ERROR: %m :\n  Invalid value (%d) for parameter depth (legal range: 2 to 1024 )",
	depth );
    end
	
    if ( (err_mode < 0) || (err_mode > 2 ) ) begin
      param_err_flg = 1;
      $display(
	"ERROR: %m :\n  Invalid value (%d) for parameter err_mode (legal range: 0 to 2 )",
	err_mode );
    end
	
    if ( (rst_mode < 0) || (rst_mode > 3 ) ) begin
      param_err_flg = 1;
      $display(
	"ERROR: %m :\n  Invalid value (%d) for parameter rst_mode (legal range: 0 to 3 )",
	rst_mode );
    end
    
	
    if ( param_err_flg == 1) begin
      $display(
        "%m :\n  Simulation aborted due to invalid parameter value(s)");
      $finish;
    end

  end // parameter_check 



    assign ram_rst_n = (rst_mode < 2)? rst_n : 1'b1;


    DW_fifoctl_s1_df #(depth, err_mode, `DW_ctl_rst_mode) FIFO_CTL(
			.clk(clk),
			.rst_n(rst_n),
			.push_req_n(push_req_n),
			.pop_req_n(pop_req_n),
			.diag_n(diag_n),
			.ae_level(ae_level),
			.af_thresh(af_thresh),
			.empty(empty),
			.almost_empty(almost_empty),
			.half_full(half_full),
			.almost_full(almost_full),
			.full(full),
			.error(error),
			.we_n(ram_we_n),
			.wr_addr(ram_wr_addr),
			.rd_addr(ram_rd_addr)
			);
    
    DW_ram_r_w_s_dff #(width, depth, `DW_ram_rst_mode) FIFO_MEM( 
			.clk(clk),
			.rst_n(ram_rst_n),
			.wr_n(ram_we_n),
			.cs_n(1'b0),
			.rd_addr(ram_rd_addr),
			.wr_addr(ram_wr_addr),
			.data_in(data_in),
			.data_out(data_out)
			);

    // synopsys translate_on
`undef DW_ram_rst_mode
`undef DW_ctl_rst_mode
`undef DW_addr_width

endmodule
