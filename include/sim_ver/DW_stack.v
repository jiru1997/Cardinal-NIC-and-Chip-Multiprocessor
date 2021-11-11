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
// AUTHOR:    ST                 Oct., 1997
//
// VERSION:   Simulation Architecture
//
// DesignWare_version: 286c7bc0
// DesignWare_release: K-2015.06-DWBB_201506.5.2
//
////////////////////////////////////////////////////////////////////////////////
//-----------------------------------------------------------------------------------
//
// ABSTRACT:  Stack
//           This LIFO's operation is based on Synchronous single-port ram
//   
//           width : legal range is 1 to 256
//           depth : legal range is 2 to 256
//           err_mode : legal range is 0 to 1
//           rst_mode : legal range is 0 to 3
//   
//           Input data : data_in[width-1:0]
//           Output data : data_out[width-1:0]
//   
//           push request (active low) : push_req_n
//           pop request (active low) : pop_req_n
//           reset (active low) : rst_n
//           flags (active high) : full, empty, error
//   
//   
// MODIFIED:
//   10/08/1998	Jay Zhu, STAR 59741
//   10/27/1999 Reto Zimmermann, rewrite (hierarchical model)
//
//-------------------------------------------------------------------------------
//
module DW_stack (clk, rst_n, push_req_n, pop_req_n, data_in,
		 full, empty, error, data_out);

  parameter width = 8;
  parameter depth = 4;
  parameter err_mode = 0;
  parameter rst_mode = 0;

  `define DW_addr_width ((depth>4096)? ((depth>262144)? ((depth>2097152)? ((depth>8388608)? 24 : ((depth> 4194304)? 23 : 22)) : ((depth>1048576)? 21 : ((depth>524288)? 20 : 19))) : ((depth>32768)? ((depth>131072)?  18 : ((depth>65536)? 17 : 16)) : ((depth>16384)? 15 : ((depth>8192)? 14 : 13)))) : ((depth>64)? ((depth>512)?  ((depth>2048)? 12 : ((depth>1024)? 11 : 10)) : ((depth>256)? 9 : ((depth>128)? 8 : 7))) : ((depth>8)? ((depth> 32)? 6 : ((depth>16)? 5 : 4)) : ((depth>4)? 3 : ((depth>2)? 2 : 1)))))

  input  [width-1:0] data_in;
  input  clk, rst_n, push_req_n, pop_req_n;
  output [width-1:0] data_out;
  output full, empty, error;
 
  `define ctl_rst_mode (rst_mode % 2)
  `define mem_rst_mode ((rst_mode == 0)? 0 : 1)
  
  wire 	 we_n, mem_rst_n;
  wire   [`DW_addr_width-1 : 0] rd_addr, wr_addr;
 
 
  
 
  initial begin : parameter_check
    integer param_err_flg;

    param_err_flg = 0;
    

    
    if ( (width < 1) || (width > 256 ) ) begin
      param_err_flg = 1;
      $display(
	"ERROR: %m :\n  Invalid value (%d) for parameter width (legal range: 1 to 256 )",
	width );
    end
    
    if ( (depth < 2) || (depth > 256 ) ) begin
      param_err_flg = 1;
      $display(
	"ERROR: %m :\n  Invalid value (%d) for parameter depth (legal range: 2 to 256 )",
	depth );
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
 
  
    if ( param_err_flg == 1) begin
      $display(
        "%m :\n  Simulation aborted due to invalid parameter value(s)");
      $finish;
    end

  end // parameter_check 



  DW_stackctl #(depth, err_mode, `ctl_rst_mode) 
    ctl (.clk(clk), .rst_n(rst_n), .push_req_n(push_req_n), .pop_req_n(pop_req_n), 
	 .we_n(we_n), .full(full), .empty(empty), .error(error), 
	 .wr_addr(wr_addr), .rd_addr(rd_addr));

  assign mem_rst_n = (rst_mode < 2)? rst_n : 1'b1;

  DW_ram_r_w_s_dff #(width, depth, `mem_rst_mode) 
    mem (.clk(clk), .rst_n(mem_rst_n), .cs_n(1'b0), .wr_n(we_n), 
	 .rd_addr(rd_addr), .wr_addr(wr_addr), .data_in(data_in), .data_out(data_out));

`undef DW_addr_width  
endmodule
