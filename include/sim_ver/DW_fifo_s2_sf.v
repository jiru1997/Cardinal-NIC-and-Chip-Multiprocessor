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
// AUTHOR:    Rajeev Huralikoppi       11/10/97
//
// VERSION:   Simulation Architecture
//
// DesignWare_version: 239a9605
// DesignWare_release: K-2015.06-DWBB_201506.5.2
//
////////////////////////////////////////////////////////////////////////////////
//-----------------------------------------------------------------------------------
//
// ABSTRACT:  Synchronous, dual clcok with Static Flags
//           static programmable almost empty and almost full flags
//
//           This FIFO controller designed to interface to synchronous
//           true dual port RAMs.
//
//    Parameters: Valid Values
//    ==========  ============
//    width   [ 1 to 256 ]
//    depth   [ 4 to 256 ]
//    push_ae_lvl [ 1 to depth-1 ]
//    push_af_lvl [ 1 to depth-1 ]
//    pop_ae_lvl  [ 1 to depth-1 ]
//    pop_af_lvl  [ 1 to depth-1 ]
//    err_mode  [ 0 = sticky error flag,
//          1 = dynamic error flag ]
//    push_sync [ 1 = single synchronized,
//          2 = double synchronized,
//          3 = triple synchronized ]
//    pop_sync  [ 1 = single synchronized,
//          2 = double synchronized,
//          3 = triple synchronized ]
//    rst_mode  [ 0 = asynchronous reset,
//          1 = synchronous reset ]
//
//    Input Ports:  Size  Description
//    =========== ====  ===========
//    clk_push  1 bit Push I/F Input Clock
//    clk_pop   1 bit Pop I/F Input Clock
//    rst_n   1 bit Active Low Reset
//    push_req_n  1 bit Active Low Push Request
//    pop_req_n 1 bit Active Low Pop Request
//    data_in   M bits  input data
//
//    Output Ports  Size  Description
//    ============  ====  ===========
//    push_empty  1 bit Push I/F Empty Flag
//    push_ae   1 bit Push I/F Almost Empty Flag
//    push_hf   1 bit Push I/F Half Full Flag
//    push_af   1 bit Push I/F Almost Full Flag
//    push_full 1 bit Push I/F Full Flag
//    push_error  1 bit Push I/F Error Flag
//    pop_empty 1 bit Pop I/F Empty Flag
//    pop_ae    1 bit Pop I/F Almost Empty Flag
//    pop_hf    1 bit Pop I/F Half Full Flag
//    pop_af    1 bit Pop I/F Almost Full Flag
//    pop_full  1 bit Pop I/F Full Flag
//    pop_error 1 bit Pop I/F Error Flag
//    data_out   M bits  output data
//
// MODIFIED:   11/11/99     RPH   Rewrote as hierarchical model
//
//             11/29/01     RJK   Fixed lower bound depth versus
//                                address width problem (STAR 131712)
//
//              5/21/03     RJK   Added new ports on instance of DW_fifoctl_s2_sf
//				  (STAR 169066)
//
//              1/10/14     RJK   Corrected default value of pop_sync parameter.
//				  (STAR 9000688940)
//
//             10/29/14     RJK   Corrected description of err_mode values
//				  (STAR 9000732052)
//
//-------------------------------------------------------------------------

module DW_fifo_s2_sf(clk_push, clk_pop, rst_n, push_req_n, pop_req_n,
                        data_in, 
                        push_empty, push_ae, push_hf, push_af, push_full,
                        push_error, pop_empty, pop_ae, pop_hf, pop_af,
                        pop_full, pop_error, data_out);
   
parameter width = 8;
parameter depth = 8;
parameter push_ae_lvl = 2;
parameter push_af_lvl = 2;
parameter pop_ae_lvl = 2;
parameter pop_af_lvl = 2;
parameter err_mode = 0;
parameter push_sync = 2;
parameter pop_sync = 2;
parameter rst_mode = 0;

input clk_push, clk_pop, rst_n, push_req_n, pop_req_n;
input [width-1 : 0] data_in;

output push_empty, push_ae, push_hf, push_af, push_full;
output push_error, pop_empty, pop_ae, pop_hf, pop_af, pop_full, pop_error;
output [width-1 : 0] data_out;

`define DW_effective_depth (depth==4?4:(depth==8?8:(depth==16?16:(depth==32?32:(depth==64?64:(depth==128?128:(depth==256?256:(depth+2-(depth %2)))))))))
`define DW_addr_width  ((depth>16)?((depth>64)?((depth>128)?8:7):((depth>32)?6:5)):((depth>4)?((depth>8)?4:3):((depth>2)?2:1)))
`define DW_count_width ((depth+1>256)?((depth+1>4096)?((depth+1>16384)?((depth+1>32768)?16:15):((depth+1>8192)?14:13)):((depth+1>1024)?((depth+1>2048)?12:11):((depth+1>512)?10:9))):((depth+1>16)?((depth+1>64)?((depth+1>128)?8:7):((depth+1>32)?6:5)):((depth+1>4)?((depth+1>8)?4:3):((depth+1>2)?2:1))))
`define DW_ctl_rst_mode (rst_mode%2 )
`define DW_mem_rst_mode ((rst_mode+2)/ 3 )

   
// synopsys translate_off

wire [`DW_addr_width-1 : 0] wr_addr;
wire [`DW_addr_width-1 : 0] rd_addr;

wire [`DW_count_width-1 : 0] unused_pop_count;
wire [`DW_count_width-1 : 0] unused_push_count;

wire tie_low, we_n;
wire mem_rst_n;
   
  
 
  initial begin : parameter_check
    integer param_err_flg;

    param_err_flg = 0;
    
	    
  
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
  
    if ( (width < 1) || (width > 256 ) ) begin
      param_err_flg = 1;
      $display(
	"ERROR: %m :\n  Invalid value (%d) for parameter width (legal range: 1 to 256 )",
	width );
    end
  
    if ( (depth < 4) || (depth > 256 ) ) begin
      param_err_flg = 1;
      $display(
	"ERROR: %m :\n  Invalid value (%d) for parameter depth (legal range: 4 to 256 )",
	depth );
    end


  
    if ( param_err_flg == 1) begin
      $display(
        "%m :\n  Simulation aborted due to invalid parameter value(s)");
      $finish;
    end

  end // parameter_check 

    
   assign mem_rst_n  = ( (rst_mode < 2 ) ? rst_n  : ( 1'b1 ));
   assign  tie_low  = 1'b0 ;
   
    // Instance of DW_fifo_s2_sf
   DW_fifoctl_s2_sf #( 
		       depth, 
		       push_ae_lvl,
		       push_af_lvl, 
		       pop_ae_lvl,
		       pop_af_lvl,
		       err_mode, 
		       push_sync, 
		       pop_sync,  
		       `DW_ctl_rst_mode)
      U1 ( 
	  .clk_push(clk_push), 
	  .clk_pop(clk_pop), 
	  .rst_n(rst_n), 
	  .push_req_n(push_req_n), 
	  .pop_req_n(pop_req_n), 
	  .push_empty(push_empty), 
	  .push_ae(push_ae),
	  .push_hf(push_hf), 
	  .push_af(push_af), 
	  .push_full(push_full), 
	  .push_error(push_error), 
	  .pop_empty(pop_empty), 
	  .pop_ae(pop_ae), 
	  .pop_hf(pop_hf), 
	  .pop_af(pop_af), 
	  .pop_full(pop_full), 
	  .pop_error(pop_error),
	  .we_n(we_n),
	  .wr_addr(wr_addr), 
	  .rd_addr(rd_addr),
	  .push_word_count(unused_push_count),
	  .pop_word_count(unused_pop_count),
	  .test(1'b0) );

 // Instance of DW_ram_r_w_s_dff
     DW_ram_r_w_s_dff #(
			width, 
			`DW_effective_depth, 
			`DW_mem_rst_mode)
	   U2 ( 
		.clk(clk_push), 
	       .rst_n(mem_rst_n), 
	       .cs_n(tie_low), 
	       .wr_n(we_n), 
	       .rd_addr(rd_addr), 
	       .wr_addr(wr_addr), 
	       .data_in(data_in), 
	       .data_out(data_out) );

`undef DW_effective_depth
`undef DW_addr_width
`undef DW_ctl_rst_mode
`undef DW_mem_rst_mode

// synopsys translate_on

endmodule
