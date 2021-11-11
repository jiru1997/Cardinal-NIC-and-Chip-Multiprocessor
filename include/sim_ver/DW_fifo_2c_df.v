////////////////////////////////////////////////////////////////////////////////
//
//       This confidential and proprietary software may be used only
//     as authorized by a licensing agreement from Synopsys Inc.
//     In the event of publication, the following notice is applicable:
//
//                    (C) COPYRIGHT 2006 - 2016 SYNOPSYS INC.
//                           ALL RIGHTS RESERVED
//
//       The entire notice above must be reproduced on all authorized
//     copies.
//
// AUTHOR:    Doug Lee       8/31/06
//
// VERSION:   Verilog Simulation Model
//
// DesignWare_version: 185623fa
// DesignWare_release: K-2015.06-DWBB_201506.5.2
//
////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
//
//
// ABSTRACT: Dual clock domain interface FIFO
//
//           Incorporates synchronous pipelined RAM and FIFO controller
//           with caching.  Status flags are dynamically configured.
//
//
//      Parameters     Valid Values   Description
//      ==========     ============   ===========
//      width           1 to 1024     default: 8
//                                    Width of data to/from RAM
//
//      ram_depth       4 to 1024     default: 8
//                                    Depth of the RAM in the FIFO (does not include cache depth)
//
//      mem_mode         0 to 7       default: 3
//                                    Defines where and how many re-timing stages:
//                                      0 => no RAM pre or post retiming
//                                      1 => RAM data out (post) re-timing
//                                      2 => RAM read address (pre) re-timing
//                                      3 => RAM read address (pre) and data out (post) re-timing
//                                      4 => RAM write interface (pre) re-timing
//                                      5 => RAM write interface (pre) and data out (post) re-timing
//                                      6 => RAM write interface (pre) and read address (pre) re-timing
//                                      7 => RAM write interface (pre), read address re-timing (pre), and data out (post) re-timing
//
//      f_sync_type      1 to 4       default: 2
//                                    Mode of forward synchronization (source to destination)
//                                      1 => 2-stage synchronization w/ 1st stage neg-edge & 2nd stage pos-edge capturing,
//                                      2 => 2-stage synchronization w/ both stages pos-edge capturing,
//                                      3 => 3-stage synchronization w/ all stages pos-edge capturing
//                                      4 => 4-stage synchronization w/ all stages pos-edge capturing
//
//      r_sync_type      1 to 4       default: 2
//                                    Mode of reverse synchronization (destination to source)
//                                      1 => 2-stage synchronization w/ 1st stage neg-edge & 2nd stage pos-edge capturing,
//                                      2 => 2-stage synchronization w/ both stages pos-edge capturing,
//                                      3 => 3-stage synchronization w/ all stages pos-edge capturing
//                                      4 => 4-stage synchronization w/ all stages pos-edge capturing
//
//      clk_ratio   -7 to 1, 1 to 7   default: 1
//                                    Rounded quotient between clk_s and clk_d
//                                      1 to 7   => when clk_d rate faster than clk_s rate: round(clk_d rate / clk_s rate)
//                                      -7 to -1 => when clk_d rate slower than clk_s rate: 0 - round(clk_s rate / clk_d rate)
//                                      NOTE: 0 is illegal
//
//      rst_mode         0 or 1       default: 0
//                                    Control Reset of RAM contents
//                                      0 => include resets to clear RAM
//                                      1 => do not include reset to clear RAM
//
//      err_mode         0 or 1       default: 0
//                                    Error Reporting Behavior
//                                      0 => sticky error flag
//                                      1 => dynamic error flag
//
//      tst_mode         0 to 2       default: 0
//                                    Latch insertion for testing purposes
//                                      0 => no hold latch inserted,
//                                      1 => insert hold 'latch' using a neg-edge triggered register
//                                      2 => insert hold latch using active low latch
//
//      verif_en         0 to 4       default: 1
//                                    Verification mode
//                                      0 => no sampling errors inserted,
//                                      1 => sampling errors are randomly inserted with 0 or up to 1 destination clock cycle delays
//                                      2 => sampling errors are randomly inserted with 0, 0.5, 1, or 1.5 destination clock cycle delays
//                                      3 => sampling errors are randomly inserted with 0, 1, 2, or 3 destination clock cycle delays
//                                      4 => sampling errors are randomly inserted with 0 or up to 0.5 destination clock cycle delays
//
//      clr_dual_domain    1          default: 1
//                                    Activity of clr_s and/or clr_d
//                                      0 => either clr_s or clr_d can be activated, but the other must be tied 'low'
//                                      1 => both clr_s and clr_d can be activated
//
//      arch_type        0 or 1       default: 0
//                                    Pre-fetch cache architecture type
//                                      0 => Pipeline style
//                                      1 => Register File style
//
//      Inputs 	         Size	    Description
//      ======	         ====	    ===========
//      clk_s	         1 bit	    Source Domain Clock
//      rst_s_n	         1 bit	    Source Domain Asynchronous Reset (active low)
//      init_s_n         1 bit	    Source Domain Synchronous Reset (active low)
//      clr_s            1 bit      Source Domain Clear to initiate orchestrated reset (active high pulse)
//      ae_level_s       N bits     Source Domain RAM almost empty threshold setting
//      af_level_s       N bits     Source Domain RAM almost full threshold setting
//      push_s_n         1 bit      Source Domain push request (active low)
//      data_s           M bits     Source Domain push data
//
//      clk_d	         1 bit	    Destination Domain Clock
//      rst_d_n	         1 bit	    Destination Domain Asynchronous Reset (active low)
//      init_d_n         1 bit	    Destination Domain Synchronous Reset (active low)
//      clr_d            1 bit      Destination Domain Clear to initiate orchestrated reset (active high pulse)
//      ae_level_d       Q bits     Destination Domain FIFO almost empty threshold setting
//      af_level_d       Q bits     Destination Domain FIFO almost full threshold setting
//      pop_d_n          1 bit      Destination Domain pop request (active low)
//
//      test             1 bit      Test input
//
//      Outputs	         Size	    Description
//      =======	         ====	    ===========
//      clr_sync_s       1 bit      Source Domain synchronized clear (active high pulse)
//      clr_in_prog_s    1 bit      Source Domain orchestrate clearing in progress
//      clr_cmplt_s      1 bit      Source Domain orchestrated clearing complete (active high pulse)
//      fifo_word_cnt_s  Q bits     Source Domain FIFO word count (includes cache)
//      word_cnt_s       N bits     Source Domain RAM only word count
//      fifo_empty_s     1 bit	    Source Domain FIFO Empty Flag
//      empty_s          1 bit	    Source Domain RAM Empty Flag
//      almost_empty_s   1 bit	    Source Domain RAM Almost Empty Flag
//      half_full_s      1 bit	    Source Domain RAM Half Full Flag
//      almost_full_s    1 bit	    Source Domain RAM Almost Full Flag
//      full_s	         1 bit	    Source Domain RAM Full Flag
//      error_s	         1 bit	    Source Domain Error Flag
//
//      clr_sync_d       1 bit      Destination Domain synchronized clear (active high pulse)
//      clr_in_prog_d    1 bit      Destination Domain orchestrate clearing in progress
//      clr_cmplt_d      1 bit      Destination Domain orchestrated clearing complete (active high pulse)
//      data_d           M bits     Destination Domain data out
//      word_cnt_d       Q bits     Destination Domain FIFO word count (includes cache)
//      empty_d	         1 bit	    Destination Domain Empty Flag
//      almost_empty_d   1 bit	    Destination Domain Almost Empty Flag
//      half_full_d      1 bit	    Destination Domain Half Full Flag
//      almost_full_d    1 bit	    Destination Domain Almost Full Flag
//      full_d	         1 bit	    Destination Domain Full Flag
//      error_d	         1 bit	    Destination Domain Error Flag
//
//           Note: M is equal to the width parameter
//
//           Note: N is based on ram_depth:
//                   N = ceil(log2(ram_depth+1))
//
//           Note: Q is based on the mem_mode parameter:
//                   Q = ceil(log2((ram_depth+1)+1)) when mem_mode = 0 or 4
//                   Q = ceil(log2((ram_depth+1)+2)) when mem_mode = 1, 2, 5, or 6
//                   Q = ceil(log2((ram_depth+1)+3)) when mem_mode = 3 or 7
//
//
// MODIFIED:
//
//      8/05/11 DLL  Added tst_mode=2 capability.
//
//     11/20/08 DLL  Added 'arch_type' parameter and checking.
//
//     6/12/08  DLL  Removed extraneous input port "rd_data_d" to address bug
//                   brought up by STAR#9000249604.
//
//    12/11/07  DLL  Changed parameter default values to match between all source files.
//
//		
////////////////////////////////////////////////////////////////////////////////
module DW_fifo_2c_df (
        clk_s,
        rst_s_n,
        init_s_n,
        clr_s,
        ae_level_s,
        af_level_s,
        push_s_n,
	data_s,
  
        clr_sync_s,
        clr_in_prog_s,
        clr_cmplt_s,
        fifo_word_cnt_s,
        word_cnt_s,
        fifo_empty_s,
        empty_s,
        almost_empty_s,
        half_full_s,
        almost_full_s,
        full_s,
        error_s,

        clk_d,
        rst_d_n,
        init_d_n,
        clr_d,
        ae_level_d,
        af_level_d,
        pop_d_n,
  
        clr_sync_d,
        clr_in_prog_d,
        clr_cmplt_d,
        data_d,
        word_cnt_d,
        empty_d,
        almost_empty_d,
        half_full_d,
        almost_full_d,
        full_d,
        error_d,

	test
	);

parameter width            =  8;   // RANGE 1 to 1024
parameter ram_depth        =  8;   // RANGE 4 to 1024
parameter mem_mode         =  3;   // RANGE 0 to 7
parameter f_sync_type  	   =  2;   // RANGE 1 to 4
parameter r_sync_type	   =  2;   // RANGE 1 to 4
parameter clk_ratio        =  1;   // RANGE -7 to -1, 1 to 7
parameter rst_mode         =  0;   // RANGE 0 to 1
parameter err_mode	   =  0;   // RANGE 0 to 1
parameter tst_mode  	   =  0;   // RANGE 0 to 2
parameter verif_en  	   =  1;   // RANGE 0 to 4
parameter clr_dual_domain  =  1;   // RANGE 0 to 1
parameter arch_type        =  0;   // RANGE 0 to 1
   



`define DW_eff_depth             (ram_depth+1+(mem_mode%2)+((mem_mode>>1)%2))
`define DW_addr_width            ((ram_depth>256)?((ram_depth>4096)?((ram_depth>16384)?((ram_depth>32768)?16:15):((ram_depth>8192)?14:13)):((ram_depth>1024)?((ram_depth>2048)?12:11):((ram_depth>512)?10:9))):((ram_depth>16)?((ram_depth>64)?((ram_depth>128)?8:7):((ram_depth>32)?6:5)):((ram_depth>4)?((ram_depth>8)?4:3):((ram_depth>2)?2:1))))
`define DW_fifo_cnt_width        ((`DW_eff_depth+1>256)?((`DW_eff_depth+1>4096)?((`DW_eff_depth+1>16384)?((`DW_eff_depth+1>32768)?16:15):((`DW_eff_depth+1>8192)?14:13)):((`DW_eff_depth+1>1024)?((`DW_eff_depth+1>2048)?12:11):((`DW_eff_depth+1>512)?10:9))):((`DW_eff_depth+1>16)?((`DW_eff_depth+1>64)?((`DW_eff_depth+1>128)?8:7):((`DW_eff_depth+1>32)?6:5)):((`DW_eff_depth+1>4)?((`DW_eff_depth+1>8)?4:3):((`DW_eff_depth+1>2)?2:1))))
`define DW_cnt_width             ((ram_depth+1>256)?((ram_depth+1>4096)?((ram_depth+1>16384)?((ram_depth+1>32768)?16:15):((ram_depth+1>8192)?14:13)):((ram_depth+1>1024)?((ram_depth+1>2048)?12:11):((ram_depth+1>512)?10:9))):((ram_depth+1>16)?((ram_depth+1>64)?((ram_depth+1>128)?8:7):((ram_depth+1>32)?6:5)):((ram_depth+1>4)?((ram_depth+1>8)?4:3):((ram_depth+1>2)?2:1))))
`define DW_adj_ram_depth       ((ram_depth == (1 << (`DW_cnt_width-1)))? ram_depth : ((ram_depth+2) - (ram_depth & 1)))


input                            clk_s;            // Source Domain Clock
input                            rst_s_n;          // Source Domain Asynchronous Reset (active low)
input                            init_s_n;         // Source Domain Synchronous Reset (active low)
input                            clr_s;            // Source Domain Clear for coordinated reset (active high pulse)
input  [`DW_cnt_width-1:0]       ae_level_s;       // Source Domain RAM almost empty threshold setting
input  [`DW_cnt_width-1:0]       af_level_s;       // Source Domain RAM almost full threshold setting
input                            push_s_n;         // Source Domain push request (active low)
input  [width-1:0]               data_s;           // Source Domain push data

output                           clr_sync_s;       // Source Domain synchronized clear (active high pulse)
output                           clr_in_prog_s;    // Source Domain orchestrate clearing in progress (unregistered)
output                           clr_cmplt_s;      // Source Domain orchestrated clearing complete (active high pulse)
output [`DW_fifo_cnt_width-1:0]  fifo_word_cnt_s;  // Source Domain FIFO word count (includes cache)
output [`DW_cnt_width-1:0]       word_cnt_s;       // Source Domain RAM only word count
output                           fifo_empty_s;     // Source Domain FIFO Empty Flag
output                           empty_s;          // Source Domain RAM Empty Flag
output                           almost_empty_s;   // Source Domain RAM Almost Empty Flag
output                           half_full_s;      // Source Domain RAM Half Full Flag
output                           almost_full_s;    // Source Domain RAM Almost Full Flag
output                           full_s;	   // Source Domain RAM Full Flag
output                           error_s;          // Source Domain Error Flag

input                            clk_d;            // Destination Domain Clock
input                            rst_d_n;          // Destination Domain Asynchronous Reset (active low)
input                            init_d_n;         // Destination Domain Synchronous Reset (active low)
input                            clr_d;            // Destination Domain Clear to initiate orchestrated reset (active high pulse)
input  [`DW_fifo_cnt_width-1:0]  ae_level_d;       // Destination Domain FIFO almost empty threshold setting
input  [`DW_fifo_cnt_width-1:0]  af_level_d;       // Destination Domain FIFO almost full threshold setting
input                            pop_d_n;          // Destination Domain pop request (active low)

output                           clr_sync_d;       // Destination Domain synchronized orchestrated clear (active high pulse)
output                           clr_in_prog_d;    // Destination Domain orchestrate clearing in progress (unregistered)
output                           clr_cmplt_d;      // Destination Domain orchestrated clearing complete (active high pulse)
output [width-1:0]               data_d;           // Destination Domain pop data
output [`DW_fifo_cnt_width-1:0]  word_cnt_d;       // Destination Domain FIFO word count (includes cache)
output                           empty_d;          // Destination Domain Empty Flag
output                           almost_empty_d;   // Destination Domain Almost Empty Flag
output                           half_full_d;      // Destination Domain Half Full Flag
output                           almost_full_d;    // Destination Domain Almost Full Flag
output                           full_d;	   // Destination Domain Full Flag
output                           error_d;          // Destination Domain Error Flag

input                            test;             // Test input

// synopsys translate_off




// Parameter checking
  
 
  initial begin : parameter_check
    integer param_err_flg;

    param_err_flg = 0;
    
  
    if ( (width < 1) || (width > 1024 ) ) begin
      param_err_flg = 1;
      $display(
	"ERROR: %m :\n  Invalid value (%d) for parameter width (legal range: 1 to 1024 )",
	width );
    end
  
    if ( (ram_depth < 4) || (ram_depth > 1024 ) ) begin
      param_err_flg = 1;
      $display(
	"ERROR: %m :\n  Invalid value (%d) for parameter ram_depth (legal range: 4 to 1024 )",
	ram_depth );
    end
  
    if ( (mem_mode < 0) || (mem_mode > 7 ) ) begin
      param_err_flg = 1;
      $display(
	"ERROR: %m :\n  Invalid value (%d) for parameter mem_mode (legal range: 0 to 7 )",
	mem_mode );
    end
  
    if ( ((f_sync_type & 7) < 1) || ((f_sync_type & 7) > 4 ) ) begin
      param_err_flg = 1;
      $display(
	"ERROR: %m :\n  Invalid value (%d) for parameter (f_sync_type & 7) (legal range: 1 to 4 )",
	(f_sync_type & 7) );
    end
  
    if ( ((r_sync_type & 7) < 1) || ((r_sync_type & 7) > 4 ) ) begin
      param_err_flg = 1;
      $display(
	"ERROR: %m :\n  Invalid value (%d) for parameter (r_sync_type & 7) (legal range: 1 to 4 )",
	(r_sync_type & 7) );
    end
  
    if ( (clk_ratio < -7) || (clk_ratio == 0) || (clk_ratio > 7) ) begin
      param_err_flg = 1;
      $display(
	"ERROR: %m : Invalid clk_ratio parameter value.  Must be -7 to 1 or 1 to 7.  NOTE: 0 is not legal." );
    end
  
    if ( (rst_mode < 0) || (rst_mode > 1) ) begin
      param_err_flg = 1;
      $display(
	"ERROR: %m :\n  Invalid value (%d) for parameter rst_mode (legal range: 0 to 1)",
	rst_mode );
    end
  
    if ( (err_mode < 0) || (err_mode > 1 ) ) begin
      param_err_flg = 1;
      $display(
	"ERROR: %m :\n  Invalid value (%d) for parameter err_mode (legal range: 0 to 1 )",
	err_mode );
    end
  
    if ( (tst_mode < 0) || (tst_mode > 2 ) ) begin
      param_err_flg = 1;
      $display(
	"ERROR: %m :\n  Invalid value (%d) for parameter tst_mode (legal range: 0 to 2 )",
	tst_mode );
    end
  
    if ( (verif_en < 0) || (verif_en > 4 ) ) begin
      param_err_flg = 1;
      $display(
	"ERROR: %m :\n  Invalid value (%d) for parameter verif_en (legal range: 0 to 4 )",
	verif_en );
    end
  
    if ( (clr_dual_domain < 0) || (clr_dual_domain > 1 ) ) begin
      param_err_flg = 1;
      $display(
	"ERROR: %m :\n  Invalid value (%d) for parameter clr_dual_domain (legal range: 0 to 1 )",
	clr_dual_domain );
    end
  
    if ( (arch_type < 0) || (arch_type > 1 ) ) begin
      param_err_flg = 1;
      $display(
	"ERROR: %m :\n  Invalid value (%d) for parameter arch_type (legal range: 0 to 1 )",
	arch_type );
    end
  
    if ( param_err_flg == 1) begin
      $display(
        "%m :\n  Simulation aborted due to invalid parameter value(s)");
      $finish;
    end

  end // parameter_check 


// Source Domain interconnects
wire                             wr_en_s_n;        // Source Domain write enable to RAM (active low)
wire   [`DW_addr_width-1:0]      wr_addr_s;        // Source Domain write address to RAM

// Destination Domain interconnects
wire                             ram_re_d_n;       // Destination Domain RAM read enable
wire   [`DW_addr_width-1:0]      rd_addr_d;        // Destination Domain read address to RAM
wire   [width-1:0]               rd_data_d;        // Destination Domain data read from RAM

// Merge clear and synchronous reset signals
wire                             init_s_n_merge;
wire                             init_d_n_merge;

// Unconnected (unused) outputs from the FIFO controller and/or RAM
wire   [`DW_cnt_width-1:0]       ram_word_cnt_d_nc;
wire                             data_r_a_nc;


  initial begin
    if ((f_sync_type > 0)&&(f_sync_type < 8))
      $display("Information: *** Instance %m is the _DW_fifo_2c_df_sync_ID Clock Domain Crossing Module ***");
  end


DW_fifoctl_2c_df #(width, ram_depth, mem_mode, (f_sync_type + 8), (r_sync_type + 8), clk_ratio, 0, err_mode,
                    tst_mode, verif_en, clr_dual_domain) U1 (
            .clk_s(clk_s),
            .rst_s_n(rst_s_n),
            .init_s_n(init_s_n),
            .clr_s(clr_s),
            .ae_level_s(ae_level_s),
            .af_level_s(af_level_s),
            .push_s_n(push_s_n),
            .clr_sync_s(clr_sync_s),
            .clr_in_prog_s(clr_in_prog_s),
            .clr_cmplt_s(clr_cmplt_s),
            .wr_en_s_n(wr_en_s_n),
            .wr_addr_s(wr_addr_s),
            .fifo_word_cnt_s(fifo_word_cnt_s),
            .word_cnt_s(word_cnt_s),
            .fifo_empty_s(fifo_empty_s),
            .empty_s(empty_s),
            .almost_empty_s(almost_empty_s),
            .half_full_s(half_full_s),
            .almost_full_s(almost_full_s),
            .full_s(full_s),
            .error_s(error_s),
            .clk_d(clk_d),
            .rst_d_n(rst_d_n),
            .init_d_n(init_d_n),
            .clr_d(clr_d),
            .ae_level_d(ae_level_d),
            .af_level_d(af_level_d),
            .pop_d_n(pop_d_n),
            .rd_data_d(rd_data_d),
            .clr_sync_d(clr_sync_d),
            .clr_in_prog_d(clr_in_prog_d),
            .clr_cmplt_d(clr_cmplt_d),
            .ram_re_d_n(ram_re_d_n),
            .rd_addr_d(rd_addr_d),
            .data_d(data_d),
            .word_cnt_d(word_cnt_d),
            .ram_word_cnt_d(ram_word_cnt_d_nc),
            .empty_d(empty_d),
            .almost_empty_d(almost_empty_d),
            .half_full_d(half_full_d),
            .almost_full_d(almost_full_d),
            .full_d(full_d),
            .error_d(error_d),
            .test(test)
            );

  assign init_s_n_merge   = init_s_n && ~clr_in_prog_s;
  assign init_d_n_merge   = init_d_n && ~clr_in_prog_d;

DW_ram_r_w_2c_dff #(width, `DW_adj_ram_depth,`DW_addr_width, mem_mode, rst_mode) U2 (
            .clk_w(clk_s),
            .rst_w_n(rst_s_n),
            .init_w_n(init_s_n_merge),
            .en_w_n(wr_en_s_n),
            .addr_w(wr_addr_s),
            .data_w(((data_s | (data_s ^ data_s)))),
            .clk_r(clk_d),
            .rst_r_n(rst_d_n),
            .init_r_n(init_d_n_merge),
            .en_r_n(ram_re_d_n),
            .addr_r(rd_addr_d),
            .data_r_a(data_r_a_nc),
            .data_r(rd_data_d)
            );

    
  always @ (clk_s) begin : clk_s_monitor 
    if ( (clk_s !== 1'b0) && (clk_s !== 1'b1) && ($time > 0) )
      $display( "WARNING: %m :\n  at time = %t, detected unknown value, %b, on clk_s input.",
                $time, clk_s );
    end // clk_s_monitor 
    
  always @ (clk_d) begin : clk_d_monitor 
    if ( (clk_d !== 1'b0) && (clk_d !== 1'b1) && ($time > 0) )
      $display( "WARNING: %m :\n  at time = %t, detected unknown value, %b, on clk_d input.",
                $time, clk_d );
    end // clk_d_monitor 


`undef DW_eff_depth
`undef DW_addr_width
`undef DW_fifo_cnt_width
`undef DW_cnt_width
`undef DW_adj_ram_depth

// synopsys translate_on
endmodule
