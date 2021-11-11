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
// DesignWare_version: 5053f1c6
// DesignWare_release: K-2015.06-DWBB_201506.5.2
//
////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
//
//
// ABSTRACT: Dual clock domain interface FIFO controller Simulation Model
//
//           Used for FIFOs with synchronous pipelined RAMs. Contains
//           external caching in destination domain.  Status flags are 
//           dynamically configured.
//
//
//      Parameters     Valid Values   Description
//      ==========     ============   ===========
//      width           1 to 1024     default: 8
//                                    Width of data to/from RAM
//
//      ram_depth     4 to 16777216   default: 8
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
//      ram_re_ext       0 or 1       default: 0
//                                    Determines the charateristic of the ram_re_d_n signal to RAM
//                                      0 => Single-cycle pulse of ram_re_d_n at the read event to RAM
//                                      1 => Extend assertion of ram_re_d_n while read event active in RAM
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
//
//      clk_d	         1 bit	    Destination Domain Clock
//      rst_d_n	         1 bit	    Destination Domain Asynchronous Reset (active low)
//      init_d_n         1 bit	    Destination Domain Synchronous Reset (active low)
//      clr_d            1 bit      Destination Domain Clear to initiate orchestrated reset (active high pulse)
//      ae_level_d       Q bits     Destination Domain FIFO almost empty threshold setting
//      af_level_d       Q bits     Destination Domain FIFO almost full threshold setting
//      pop_d_n          1 bit      Destination Domain pop request (active low)
//      rd_data_d        M bits     Destination Domain read data from RAM
//
//      test             1 bit      Test input
//
//      Outputs	         Size	    Description
//      =======	         ====	    ===========
//      clr_sync_s       1 bit      Source Domain synchronized clear (active high pulse)
//      clr_in_prog_s    1 bit      Source Domain orchestrate clearing in progress
//      clr_cmplt_s      1 bit      Source Domain orchestrated clearing complete (active high pulse)
//      wr_en_s_n        1 bit      Source Domain write enable to RAM (active low)
//      wr_addr_s        P bits     Source Domain write address to RAM
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
//      ram_re_d_n       1 bit      Destination Domain Read Enable to RAM (active-low)
//      rd_addr_d        P bits     Destination Domain read address to RAM
//      data_d           M bits     Destination Domain data out
//      word_cnt_d       Q bits     Destination Domain FIFO word count (includes cache)
//      ram_word_cnt_d   N bits     Destination Domain RAM only word count
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
//           Note: P is ceil(log2(ram_depth))
//
//           Note: Q is based on the mem_mode parameter:
//                   Q = ceil(log2((ram_depth+1)+1)) when mem_mode = 0 or 4
//                   Q = ceil(log2((ram_depth+1)+2)) when mem_mode = 1, 2, 5, or 6
//                   Q = ceil(log2((ram_depth+1)+3)) when mem_mode = 3 or 7
//
//
// MODIFIED:
//
//	    DLL - 2/14/13
//	    Corrected problem with "*_tmp" signals in an 'always' block sensitivity list and also getting
//          assigned within the same 'always' block.
//	    (STAR 9000605068)
//
//	    RJK - 3/21/12
//	    Corrected problems with use when depth is greater than 65533
//	    (STAR 9000530636)
//
//	    RJK - 3/20/12
//	    Eliminated width mismatch lint issue (STAR 9000519049)
//  
//          DLL - 8/01/11
//          Removed 'init_s_n_merge' into DW_sync...only use 'init_s_n'.  Also added
//          tst_mode=2 capability.
//
//          DLL - 12/2/10
//          Remove assertions from module since meant for pre-production
//          unit-level testing.
//          This fix addresses STAR#9000435571.
//
//          DLL - 11/15/10
//          Fixed default values for some parameters to match across all
//          source code.
//          This fix addresses STAR#9000429754.
//
//          DLL - 3/17/10
//          Fixed the de-assertion conditions for 'almost_empty_d' and
//          assertion condtions for 'half_full_d', 'almost_full_d', and
//          'full_d'.  This allows blind popping in with data underruns.
//          This fix addresses STAR#9000380664.
//
//          DLL - 3/16/10
//          Apply 'clr_in_prog_d' for synchronous resets to registers
//          instead of 'clr_sync_d' and 'clr_in_prog_s' used instead
//          of 'clr_sync_s'.
//          This fix addresses STAR#9000381235.
//
//          DLL - 11/4/09
//          Changed so that now the cache count includes RAM read in
//          progress state.  A gray-coded vector is used as a result.
//          This fix addresses STAR#9000353986.
//
//          DLL - 10/25/08
//          Added 'arch_type' parameter.
//
//          DLL - 1/23/07
//          Changed default value of ram_re_ext to 0.
//
//		
////////////////////////////////////////////////////////////////////////////////
module DW_fifoctl_2c_df (
        clk_s,
        rst_s_n,
        init_s_n,
        clr_s,
        ae_level_s,
        af_level_s,
        push_s_n,
  
        clr_sync_s,
        clr_in_prog_s,
        clr_cmplt_s,
	wr_en_s_n,
	wr_addr_s,
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
        rd_data_d,
  
        clr_sync_d,
        clr_in_prog_d,
        clr_cmplt_d,
	ram_re_d_n,
	rd_addr_d,
        data_d,
        word_cnt_d,
        ram_word_cnt_d,
        empty_d,
        almost_empty_d,
        half_full_d,
        almost_full_d,
        full_d,
        error_d,

	test
	);

parameter width            =  8;   // RANGE 1 to 1024
parameter ram_depth        =  8;   // RANGE 4 to 16777216
parameter mem_mode         =  3;   // RANGE 0 to 7
parameter f_sync_type  	   =  2;   // RANGE 1 to 4
parameter r_sync_type	   =  2;   // RANGE 1 to 4
parameter clk_ratio        =  1;   // RANGE -7 to -1, 1 to 7
parameter ram_re_ext       =  0;   // RANGE 0 to 1
parameter err_mode	   =  0;   // RANGE 0 to 1
parameter tst_mode  	   =  0;   // RANGE 0 to 2
parameter verif_en  	   =  1;   // RANGE 0 to 4
parameter clr_dual_domain  =  1;   // RANGE 0 to 1
parameter arch_type	   =  0;   // RANGE 0 to 1
   



`define DW_eff_depth             (ram_depth+1+(mem_mode%2)+((mem_mode>>1)%2))
`define DW_addr_width            ((ram_depth>65536)?((ram_depth>1048576)?((ram_depth>4194304)?((ram_depth>8388608)?24:23):((ram_depth>2097152)?22:21)):((ram_depth>262144)?((ram_depth>524288)?20:19):((ram_depth>131072)?18:17))):((ram_depth>256)?((ram_depth>4096)?((ram_depth>16384)?((ram_depth>32768)?16:15):((ram_depth>8192)?14:13)):((ram_depth>1024)?((ram_depth>2048)?12:11):((ram_depth>512)?10:9))):((ram_depth>16)?((ram_depth>64)?((ram_depth>128)?8:7):((ram_depth>32)?6:5)):((ram_depth>4)?((ram_depth>8)?4:3):((ram_depth>2)?2:1)))))
`define DW_fifo_cnt_width        ((`DW_eff_depth+1>65536)?((`DW_eff_depth+1>16777216)?((`DW_eff_depth+1>268435456)?((`DW_eff_depth+1>536870912)?30:29):((`DW_eff_depth+1>67108864)?((`DW_eff_depth+1>134217728)?28:27):((`DW_eff_depth+1>33554432)?26:25))):((`DW_eff_depth+1>1048576)?((`DW_eff_depth+1>4194304)?((`DW_eff_depth+1>8388608)?24:23):((`DW_eff_depth+1>2097152)?22:21)):((`DW_eff_depth+1>262144)?((`DW_eff_depth+1>524288)?20:19):((`DW_eff_depth+1>131072)?18:17)))):((`DW_eff_depth+1>256)?((`DW_eff_depth+1>4096)?((`DW_eff_depth+1>16384)?((`DW_eff_depth+1>32768)?16:15):((`DW_eff_depth+1>8192)?14:13)):((`DW_eff_depth+1>1024)?((`DW_eff_depth+1>2048)?12:11):((`DW_eff_depth+1>512)?10:9))):((`DW_eff_depth+1>16)?((`DW_eff_depth+1>64)?((`DW_eff_depth+1>128)?8:7):((`DW_eff_depth+1>32)?6:5)):((`DW_eff_depth+1>4)?((`DW_eff_depth+1>8)?4:3):((`DW_eff_depth+1>2)?2:1)))))
`define DW_cnt_width             ((ram_depth+1>65536)?((ram_depth+1>16777216)?((ram_depth+1>268435456)?((ram_depth+1>536870912)?30:29):((ram_depth+1>67108864)?((ram_depth+1>134217728)?28:27):((ram_depth+1>33554432)?26:25))):((ram_depth+1>1048576)?((ram_depth+1>4194304)?((ram_depth+1>8388608)?24:23):((ram_depth+1>2097152)?22:21)):((ram_depth+1>262144)?((ram_depth+1>524288)?20:19):((ram_depth+1>131072)?18:17)))):((ram_depth+1>256)?((ram_depth+1>4096)?((ram_depth+1>16384)?((ram_depth+1>32768)?16:15):((ram_depth+1>8192)?14:13)):((ram_depth+1>1024)?((ram_depth+1>2048)?12:11):((ram_depth+1>512)?10:9))):((ram_depth+1>16)?((ram_depth+1>64)?((ram_depth+1>128)?8:7):((ram_depth+1>32)?6:5)):((ram_depth+1>4)?((ram_depth+1>8)?4:3):((ram_depth+1>2)?2:1)))))
`define DW_cache_inuse_width     (((mem_mode==0)||(mem_mode==4)) ? 1 : (((mem_mode==3)||(mem_mode==7)) ? 3 : 2))
`define DW_cache_inuse_idx_width ((`DW_cache_inuse_width == 1) ? 1 : 2)
`define DW_leftover_cnt          ((ram_depth == (1 << (`DW_cnt_width-1)))? 0 : ((1 << `DW_cnt_width) - (ram_depth[0] ? ram_depth+1 : ram_depth+2)))
`define DW_offset                (`DW_leftover_cnt / 2)
`define DW_ram_depth_2N          ((ram_depth == (1 << (`DW_cnt_width-1)))? 1 : 0)
`define DW_push_gray_sync_delay  (((mem_mode/4) == 1) ? (((f_sync_type & 7) + ((mem_mode/2) % 2) + (mem_mode/4)) <= clk_ratio) : 0)
`define DW_pop_gray_sync_delay   (((`DW_ram_depth_2N == 1) && (((mem_mode/2) % 2) == 1)) ? ((0 - ((r_sync_type & 7) + ((mem_mode/2) % 2) + (mem_mode/4))) >= clk_ratio) : 0)
`define DW_clk_d_faster          ((clr_dual_domain == 1) ? ((clk_ratio > 0) ? (clk_ratio+1) : 1) : 0)
`define DW_gray_verif_en	 ((verif_en==2)?4:((verif_en==3)?1:verif_en))


input                            clk_s;            // Source Domain Clock
input                            rst_s_n;          // Source Domain Asynchronous Reset (active low)
input                            init_s_n;         // Source Domain Synchronous Reset (active low)
input                            clr_s;            // Source Domain Clear for coordinated reset (active high pulse)
input  [`DW_cnt_width-1:0]       ae_level_s;       // Source Domain RAM almost empty threshold setting
input  [`DW_cnt_width-1:0]       af_level_s;       // Source Domain RAM almost full threshold setting
input                            push_s_n;         // Source Domain push request (active low)

output                           clr_sync_s;       // Source Domain synchronized clear (active high pulse)
output                           clr_in_prog_s;    // Source Domain orchestrate clearing in progress (unregistered)
output                           clr_cmplt_s;      // Source Domain orchestrated clearing complete (active high pulse)
output                           wr_en_s_n;        // Source Domain write enable to RAM (active low)
output [`DW_addr_width-1:0]      wr_addr_s;        // Source Domain write address to RAM
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
input  [width-1:0]               rd_data_d;        // Destination Domain data read from RAM

output                           clr_sync_d;       // Destination Domain synchronized orchestrated clear (active high pulse)
output                           clr_in_prog_d;    // Destination Domain orchestrate clearing in progress (unregistered)
output                           clr_cmplt_d;      // Destination Domain orchestrated clearing complete (active high pulse)
output                           ram_re_d_n;       // Destination Domain Read Enable to RAM (active-low)
output [`DW_addr_width-1:0]      rd_addr_d;        // Destination Domain read address to RAM
output [width-1:0]               data_d;           // Destination Domain data out
output [`DW_fifo_cnt_width-1:0]  word_cnt_d;       // Destination Domain FIFO word count (includes cache)
output [`DW_cnt_width-1:0]       ram_word_cnt_d;   // Destination Domain RAM only word count
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
  
    if ( (ram_depth < 4) || (ram_depth > 16777216 ) ) begin
      param_err_flg = 1;
      $display(
	"ERROR: %m :\n  Invalid value (%d) for parameter ram_depth (legal range: 4 to 16777216 )",
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
  
    if ( (ram_re_ext < 0) || (ram_re_ext > 1) ) begin
      param_err_flg = 1;
      $display(
	"ERROR: %m :\n  Invalid value (%d) for parameter ram_re_ext (legal range: 0 to 1)",
	ram_re_ext );
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



// Source domain 'reg' outputs
reg      empty_s_int;
reg      next_empty_s_int;
reg      almost_empty_s_int;
reg      next_almost_empty_s_int;
reg      half_full_s_int;
reg      next_half_full_s_int;
reg      almost_full_s_int;
reg      next_almost_full_s_int;
reg      full_s_int;
reg      next_full_s_int;

// Destination domain internal 'reg' outputs
reg      almost_empty_d_int;
reg      next_almost_empty_d_int;
reg      half_full_d_int;
reg      next_half_full_d_int;
reg      almost_full_d_int;
reg      next_almost_full_d_int;
reg      full_d_int;
reg      next_full_d_int;

// wiring for DW_sync
wire  [`DW_cache_inuse_idx_width-1:0]      cache_census_gray_d_cc;
reg   [`DW_cache_inuse_idx_width-1:0]      cache_census_gray_d_l;

// gray-coded cache census
wire   [`DW_cache_inuse_idx_width-1:0]  cache_census_gray_d;        // Destination Domain no. of active prefetched data in gray code


// Source Domain interconnects
wire                                   wr_en_s;        // Source Domain enable to gray code synchronizer
wire  [`DW_cnt_width-1:0]              wr_ptr_s;       // Source Domain next write pointer (relative to RAM) - unregisterd
wire  [`DW_cnt_width-1:0]              rd_ptr_s;       // Source Domain synchronized read pointer (relative to RAM)
wire  [`DW_cache_inuse_idx_width-1:0]  cache_census_gray_s;  // Source Domain synchronized external cache count (gray code vector)
wire  [`DW_cache_inuse_idx_width-1:0]  cache_census_s;  // Source Domain synchronized external cache count (binary vector)

wire  [`DW_cnt_width-1:0]              wr_addr_s_U_FWD_GRAY;


// Destination Domain interconnects
wire  [`DW_cnt_width-1:0]              wr_ptr_d;       // Destination Domain next write pointer (relative to RAM) - unregisterd
wire  [`DW_cnt_width-1:0]              rd_ptr_d;       // Destination Domain synchronized read pointer (relative to RAM)

wire  [`DW_cnt_width-1:0]              rd_addr_d_U_REV_GRAY;

 
// Source Domain signals
reg   [`DW_fifo_cnt_width-1:0]         fifo_word_cnt_s;       // Source Domain FIFO word count (includes cache)
wire  [`DW_fifo_cnt_width-1:0]         next_fifo_word_cnt_s;  // Source Domain FIFO word count (includes cache)
reg   [`DW_cnt_width-1:0]              word_cnt_s;            // Source Domain RAM only word count
reg   [`DW_cnt_width-1:0]              next_word_cnt_s;       // Source Domain RAM only word count
wire                                   error_s_seen;
reg                                    error_s;               // Source Domain error flag
wire                                   next_error_s;
reg                                    clr_in_prog_s_int;


// Detination Domain signals
reg   [`DW_fifo_cnt_width-1:0]         word_cnt_d;            // Destination Domain FIFO word count (includes cache)
reg   [`DW_fifo_cnt_width-1:0]         next_word_cnt_d;       // Destination Domain FIFO word count (includes cache)
reg   [`DW_cnt_width-1:0]              ram_word_cnt_d;        // Destination Domain RAM only word count
reg   [`DW_cnt_width-1:0]              next_ram_word_cnt_d;   // Destination Domain RAM only word count

reg   [1:0]                            rd_pend_sr_d;          // Destination Domain read pending shift register
reg   [1:0]                            next_rd_pend_sr_d;     // Destination Domain read pending shift register

wire                                   ram_re_d;              // Destination Domain RAM read enable initiated
wire                                   ram_re_d_n;            // Destination Domain RAM read enable to RAM
wire                                   ld_cache;
reg   [2:0]                            inuse_d;
wire  [2:0]                            next_inuse_d;
wire  [width-1:0]                      rd_data_d_int;         // clamp to all zeros when ram_empty and data from RAM not retimed
reg   [width-1:0]                      data_reg_d      [0:`DW_cache_inuse_width-1];
reg   [width-1:0]                      next_data_reg_d [0:`DW_cache_inuse_width-1];

reg   [`DW_cache_inuse_idx_width-1:0]  total_census_d;        // Destination Domain no. of active prefetched data
reg   [`DW_cache_inuse_idx_width-1:0]  next_inuse_d_census;   // Destination Domain no. of inuse_d entries installed
wire                                   next_cache_full_d;

wire                                   ram_empty_d;
reg                                    ram_empty_d_d1_inv;
wire                                   ram_empty_d_d1;
wire                                   ram_empty_d_pipe;
wire                                   cache_full;

wire                                   error_d_seen;
reg                                    error_d;              // Destination Domain error flag
wire                                   next_error_d;
reg                                    clr_in_prog_d_int;

  

  initial begin
    if ((f_sync_type > 0)&&(f_sync_type < 8))
      $display("Information: *** Instance %m is the DW_fifoctl_2c_df Clock Domain Crossing Module ***");
  end


DW_reset_sync #((f_sync_type + 8), (r_sync_type + 8), `DW_clk_d_faster, 0, tst_mode, verif_en) U1 (
            .clk_s(clk_s),
            .rst_s_n(rst_s_n),
            .init_s_n(init_s_n),
            .clr_s(clr_s),
            .clk_d(clk_d),
            .rst_d_n(rst_d_n),
            .init_d_n(init_d_n),
            .clr_d(clr_d),
            .test(test),
            .clr_sync_s(clr_sync_s),
            .clr_in_prog_s(clr_in_prog_s),
            .clr_cmplt_s(clr_cmplt_s),
            .clr_in_prog_d(clr_in_prog_d),
            .clr_sync_d(clr_sync_d),
            .clr_cmplt_d(clr_cmplt_d)
            );


DW_gray_sync #(`DW_cnt_width, `DW_offset, 0, (f_sync_type + 8), tst_mode, `DW_gray_verif_en, `DW_push_gray_sync_delay, 0, 1) U_FWD_GRAY (
            .clk_s(clk_s),
            .rst_s_n(rst_s_n),
            .init_s_n(init_s_n && ~clr_in_prog_s),  
            .en_s(wr_en_s),
            .count_s(wr_ptr_s), 
            .offset_count_s(wr_addr_s_U_FWD_GRAY),
            .clk_d(clk_d), 
            .rst_d_n(rst_d_n), 
            .init_d_n(init_d_n && ~clr_in_prog_d),
            .count_d(wr_ptr_d), 
            .test(test)
            );

DW_gray_sync #(`DW_cnt_width, `DW_offset, 0, (r_sync_type + 8), tst_mode, `DW_gray_verif_en, `DW_pop_gray_sync_delay, 0, 1) U_REV_GRAY (
            .clk_s(clk_d),
            .rst_s_n(rst_d_n),
            .init_s_n(init_d_n && ~clr_in_prog_d),  
            .en_s(ram_re_d),
            .count_s(rd_ptr_d), 
            .offset_count_s(rd_addr_d_U_REV_GRAY),
            .clk_d(clk_s), 
            .rst_d_n(rst_s_n), 
            .init_d_n(init_s_n && ~clr_in_prog_s),
            .count_d(rd_ptr_s), 
            .test(test)
            );



  
generate
  if (((r_sync_type&7)>1)&&(tst_mode==2)) begin : GEN_LATCH_rvs_hold_latch_PROC
    reg [`DW_cache_inuse_idx_width-1:0] cache_census_gray_d_l;
    always @ (clk_d or cache_census_gray_d) begin : LATCH_rvs_hold_latch_PROC_PROC

      if (clk_d == 1'b0)

	cache_census_gray_d_l = cache_census_gray_d;


    end // LATCH_rvs_hold_latch_PROC_PROC


    assign cache_census_gray_d_cc = (test==1'b1)? cache_census_gray_d_l : cache_census_gray_d;

  end else begin : GEN_DIRECT_rvs_hold_latch_PROC
    assign cache_census_gray_d_cc = cache_census_gray_d;
  end
endgenerate

  DW_sync #(`DW_cache_inuse_idx_width, r_sync_type+8, tst_mode, verif_en) U_REV_SYNC(
	.clk_d(clk_s),
	.rst_d_n(rst_s_n),
	.init_d_n(init_s_n),
	.data_s(cache_census_gray_d_cc),
	.test(test),
	.data_d(cache_census_gray_s) );


  always @(posedge clk_s or negedge rst_s_n) begin : reg_clr_in_prog_s_PROC
    if (rst_s_n == 1'b0)
      clr_in_prog_s_int <= 1'b0;
    else
      clr_in_prog_s_int <= clr_in_prog_s;
  end

  always @(wr_ptr_s or rd_ptr_s or word_cnt_s) begin : next_word_cnt_s_PROC
    if (wr_ptr_s >= rd_ptr_s)
      next_word_cnt_s = wr_ptr_s - rd_ptr_s;
    else
      if (wr_ptr_s < rd_ptr_s)
        next_word_cnt_s = wr_ptr_s - rd_ptr_s - `DW_leftover_cnt;
      else
        next_word_cnt_s = {`DW_cnt_width{1'bX}};
  end  // block: next_word_cnt_s_PROC

 
  assign cache_census_s = cache_census_gray_s ^ (cache_census_gray_s >> 1); 

  assign next_fifo_word_cnt_s = next_word_cnt_s + cache_census_s;
   
  assign  fifo_empty_s = (fifo_word_cnt_s === 0) || clr_in_prog_s_int;
  always @(next_word_cnt_s or ae_level_s or af_level_s or clr_in_prog_s) begin : mk_src_flags_PROC
    if (next_word_cnt_s >= 0) begin
      next_empty_s_int         = ~(((next_word_cnt_s == 0) ? 1'b1 : 1'b0) || clr_in_prog_s);
      next_almost_empty_s_int  = ~(((next_word_cnt_s <= ae_level_s) ? 1'b1 : 1'b0) || clr_in_prog_s);
      next_half_full_s_int     = ((next_word_cnt_s < (ram_depth+1)/2) ? 1'b0 : 1'b1) && ~clr_in_prog_s;
      next_almost_full_s_int   = ((next_word_cnt_s < (ram_depth-af_level_s)) ? 1'b0 : 1'b1) && ~clr_in_prog_s;
      next_full_s_int          = ((next_word_cnt_s != ram_depth) ? 1'b0 : 1'b1) && ~clr_in_prog_s;
    end else begin
      next_empty_s_int         = 1'bX;
      next_almost_empty_s_int  = 1'bX;
      next_half_full_s_int     = 1'bX;
      next_almost_full_s_int   = 1'bX;
      next_full_s_int          = 1'bX;
    end // else: if( next_word_cnt_s < 0 )
  end  // block: mk_src_flags


  always @(posedge clk_s or negedge rst_s_n) begin : clk_s_regs_PROC
    if (rst_s_n === 1'b0) begin
      fifo_word_cnt_s    <= {`DW_fifo_cnt_width{1'b0}};
      word_cnt_s         <= {`DW_cnt_width{1'b0}};
      error_s            <= 1'b0;
      empty_s_int        <= 1'b0;
      almost_empty_s_int <= 1'b0;
      half_full_s_int    <= 1'b0;
      almost_full_s_int  <= 1'b0;
      full_s_int         <= 1'b0;
    end else if (rst_s_n === 1'b1) begin
      if ((init_s_n === 1'b0) || (clr_in_prog_s === 1'b1)) begin
        fifo_word_cnt_s    <= {`DW_fifo_cnt_width{1'b0}};
        word_cnt_s         <= {`DW_cnt_width{1'b0}};
        error_s            <= 1'b0;
        empty_s_int        <= 1'b0;
        almost_empty_s_int <= 1'b0;
        half_full_s_int    <= 1'b0;
        almost_full_s_int  <= 1'b0;
        full_s_int         <= 1'b0;
      end else if (init_s_n === 1'b1) begin
        fifo_word_cnt_s    <= next_fifo_word_cnt_s;
        word_cnt_s         <= next_word_cnt_s;
        error_s            <= next_error_s;
        empty_s_int        <= next_empty_s_int;
        almost_empty_s_int <= next_almost_empty_s_int;
        half_full_s_int    <= next_half_full_s_int;
        almost_full_s_int  <= next_almost_full_s_int;
        full_s_int         <= next_full_s_int;
      end else begin
        fifo_word_cnt_s    <= {`DW_fifo_cnt_width{1'bX}};
        word_cnt_s         <= {`DW_cnt_width{1'bX}};
        error_s            <= 1'bX;
        empty_s_int        <= 1'bX;
        almost_empty_s_int <= 1'bX;
        half_full_s_int    <= 1'bX;
        almost_full_s_int  <= 1'bX;
        full_s_int         <= 1'bX;
      end
    end else begin
      fifo_word_cnt_s    <= {`DW_fifo_cnt_width{1'bX}};
      word_cnt_s         <= {`DW_cnt_width{1'bX}};
      error_s            <= 1'bX;
      empty_s_int        <= 1'bX;
      almost_empty_s_int <= 1'bX;
      half_full_s_int    <= 1'bX;
      almost_full_s_int  <= 1'bX;
      full_s_int         <= 1'bX;
    end
  end  // block: clk_s_regs_PROC

// write enable to RAM
  assign  wr_en_s    = ~push_s_n && ~full_s;
  assign  wr_en_s_n  = ~wr_en_s;

// push error
  assign  error_s_seen  = ~push_s_n && full_s;
  assign  next_error_s  = (err_mode == 1) ? error_s_seen : (error_s || error_s_seen);

// Assign Source Domain Outputs
  assign  wr_addr_s        = wr_addr_s_U_FWD_GRAY[`DW_addr_width-1:0];
  assign  empty_s          = ~empty_s_int;
  assign  almost_empty_s   = ~almost_empty_s_int;
  assign  half_full_s      = half_full_s_int;
  assign  almost_full_s    = almost_full_s_int;
  assign  full_s           = full_s_int;




  always @(posedge clk_d or negedge rst_d_n) begin : reg_clr_in_prog_d_PROC
    if (rst_d_n == 1'b0)
      clr_in_prog_d_int <= 1'b0;
    else
      clr_in_prog_d_int <= clr_in_prog_d;
  end

  always @(wr_ptr_d or rd_ptr_d or word_cnt_d) begin : next_ram_word_cnt_d_PROC
    if (wr_ptr_d >= rd_ptr_d)
      next_ram_word_cnt_d = wr_ptr_d - rd_ptr_d;
    else
      if (wr_ptr_d < rd_ptr_d)
        next_ram_word_cnt_d = wr_ptr_d - rd_ptr_d - `DW_leftover_cnt;
      else
        next_ram_word_cnt_d = {`DW_fifo_cnt_width{1'bX}};
  end  // block: next_ram_word_cnt_d_PROC

  assign ram_empty_d  = (ram_word_cnt_d === 0) || clr_in_prog_d_int;
  assign cache_full   = (total_census_d === `DW_cache_inuse_width);

  assign ram_re_d  = ~ram_empty_d && (~pop_d_n || ~cache_full);

  assign ld_cache = ((mem_mode==0) || (mem_mode==4)) ? ram_re_d :
                      ((mem_mode==1) || (mem_mode==2) || (mem_mode==5) || (mem_mode==6)) ? rd_pend_sr_d[0] : rd_pend_sr_d[1];
                      
  always @(ram_re_d or rd_pend_sr_d) begin : next_rd_pend_sr_d_PROC
    if (((mem_mode==3) || (mem_mode==7))) next_rd_pend_sr_d = {rd_pend_sr_d[0], ram_re_d};
    else if (((mem_mode==1) || (mem_mode==2) || (mem_mode==5) || (mem_mode==6))) next_rd_pend_sr_d = {1'b0, ram_re_d};
    else next_rd_pend_sr_d = {2{1'b0}};
  end  // block: next_rd_pend_sr_d_PROC

  // Calculate inuse vector
  assign next_inuse_d[0] = (((mem_mode==0) || (mem_mode==4)) ? (~pop_d_n || ld_cache) :
                             ((ld_cache && ~inuse_d[0]) || (~pop_d_n && ~ld_cache && ~inuse_d[1] && ~inuse_d[2]))) ? ld_cache : inuse_d[0];
  assign next_inuse_d[1] = ((mem_mode==0) || (mem_mode==4)) ? 1'b0 :
                             ((pop_d_n && ld_cache && inuse_d[0] && ~inuse_d[2]) || (~pop_d_n && ~ld_cache && ~inuse_d[2])) ? ld_cache : inuse_d[1];
  assign next_inuse_d[2] = (((mem_mode==1) || (mem_mode==2) || (mem_mode==5) || (mem_mode==6)) || ((mem_mode==0) || (mem_mode==4))) ? 1'b0 :
                             ((~pop_d_n && ~ld_cache) || (pop_d_n && ld_cache && inuse_d[0] && inuse_d[1])) ? ld_cache : inuse_d[2];

  assign ram_empty_d_pipe = ((mem_mode[0] == 0) && (mem_mode[1] == 1)) ? ram_empty_d_d1 : ram_empty_d;
  assign rd_data_d_int    = ((mem_mode[0] == 0) && (ram_empty_d_pipe == 1'b1)) ? {width{1'b0}} : ((rd_data_d | (rd_data_d ^ rd_data_d)));

  // Determine cache data pipeline
  always @(pop_d_n or ld_cache or inuse_d or rd_data_d_int or data_reg_d[0]) begin : next_data_reg_d_PROC
    integer i;
    for (i=0; i<`DW_cache_inuse_width; i=i+1) begin
      if (i == 0) begin
        next_data_reg_d[i]  = ((mem_mode==0) || (mem_mode==4)) ? ((ld_cache && ~inuse_d[i]) || (~pop_d_n && ld_cache && inuse_d[i]) ? rd_data_d_int : data_reg_d[i]) :
                                ((mem_mode==1) || (mem_mode==2) || (mem_mode==5) || (mem_mode==6)) ? (((ld_cache && ~inuse_d[i]) || (~pop_d_n && ld_cache && ~inuse_d[i+1])) ? rd_data_d_int : 
                                                         (~pop_d_n && inuse_d[i+1]) ? data_reg_d[i+1] : data_reg_d[i]) :
                                  ((ld_cache && ~inuse_d[i]) || (~pop_d_n && ld_cache && ~inuse_d[i+1])) ? rd_data_d_int : 
                                    (~pop_d_n && inuse_d[i+1]) ? data_reg_d[i+1] : data_reg_d[i];
      end else if (i == 1) begin
        next_data_reg_d[i]  = ((mem_mode==1) || (mem_mode==2) || (mem_mode==5) || (mem_mode==6)) ? (((pop_d_n && ld_cache && inuse_d[i-1] && ~inuse_d[i]) || 
                                                     (~pop_d_n && ld_cache && inuse_d[i])) ? rd_data_d_int : data_reg_d[i]) :
                                (((pop_d_n && ld_cache && inuse_d[i-1] && ~inuse_d[i]) || 
                                 (~pop_d_n && ld_cache && inuse_d[i] && ~inuse_d[i+1])) ? rd_data_d_int : 
                                     (~pop_d_n && inuse_d[i+1]) ? data_reg_d[i+1] : data_reg_d[i]);
      end else begin  // i=2
        next_data_reg_d[i]  = ((pop_d_n && ld_cache && inuse_d[i-1] && ~inuse_d[i]) || (~pop_d_n && ld_cache && inuse_d[i])) ? rd_data_d_int : data_reg_d[i];
      end
    end  // for-loop
  end  // block: next_data_reg_d_PROC

  always @(next_ram_word_cnt_d or next_inuse_d or next_rd_pend_sr_d) begin : next_word_cnt_d_PROC
     integer    cache_cnt_d;
     integer    rd_pend_cnt_d;
     integer    i;
 
     cache_cnt_d = 0;
     for (i=0; i<`DW_cache_inuse_width; i=i+1) begin
       cache_cnt_d = cache_cnt_d + next_inuse_d[i]; 
     end
     rd_pend_cnt_d   = next_rd_pend_sr_d[0] + next_rd_pend_sr_d[1];
     next_word_cnt_d = next_ram_word_cnt_d + cache_cnt_d + rd_pend_cnt_d;
  end  // block: next_word_cnt_d_PROC

  always @(inuse_d or rd_pend_sr_d) begin : total_census_d_PROC
    integer    i;
      total_census_d = 0;
      for (i=0; i<`DW_cache_inuse_width; i=i+1) begin
        total_census_d = total_census_d + inuse_d[i];
      end // for-loop 
      total_census_d = total_census_d + rd_pend_sr_d[0] + rd_pend_sr_d[1];
  end  // block: total_census_d_PROC

  always @(next_inuse_d) begin : next_inuse_d_census_PROC
    integer    i;
      next_inuse_d_census = 0;
      for (i=0; i<`DW_cache_inuse_width; i=i+1) begin
        next_inuse_d_census = next_inuse_d_census + next_inuse_d[i];
      end // for-loop 
  end  // block: next_inuse_d_census_PROC

  assign next_cache_full_d   = (next_inuse_d_census === `DW_cache_inuse_width);

  assign cache_census_gray_d = total_census_d ^ (total_census_d >> 1); 

  always @(ae_level_d or af_level_d or next_word_cnt_d or clr_in_prog_d or
           next_cache_full_d or next_inuse_d_census or almost_empty_d or 
           half_full_d or almost_full_d or full_d) begin : mk_dest_flags
    if (next_word_cnt_d >= 0) begin
      if (almost_empty_d == 1'b1)
        next_almost_empty_d_int = ~((~((next_word_cnt_d > ae_level_d) &&
                                   ((next_cache_full_d == 1'b1) || (next_inuse_d_census > ae_level_d)))) || clr_in_prog_d);
      else
        next_almost_empty_d_int = ~((next_word_cnt_d <= ae_level_d) || clr_in_prog_d);

      if (half_full_d == 1'b0)
        next_half_full_d_int = ((next_word_cnt_d >= ((`DW_eff_depth+1)/ 2)) && (next_cache_full_d == 1'b1)) && ~clr_in_prog_d;
      else
        next_half_full_d_int = (next_word_cnt_d >= ((`DW_eff_depth+1)/ 2)) && ~clr_in_prog_d;

      if (almost_full_d == 1'b0)
        next_almost_full_d_int = ((next_word_cnt_d >= (`DW_eff_depth-af_level_d)) &&
                                 ((next_cache_full_d == 1'b1) || (next_inuse_d_census >= (`DW_eff_depth-af_level_d)))) && ~clr_in_prog_d;
      else
        next_almost_full_d_int = ((next_word_cnt_d >= (`DW_eff_depth-af_level_d))) && ~clr_in_prog_d;

      if (full_d == 1'b0)
        next_full_d_int = ((next_word_cnt_d == `DW_eff_depth) && (next_cache_full_d == 1'b1)) && ~clr_in_prog_d;
      else
        next_full_d_int = (next_word_cnt_d == `DW_eff_depth) && ~clr_in_prog_d;
    end else begin
      next_almost_empty_d_int  = 1'bx;
      next_half_full_d_int     = 1'bx;
      next_almost_full_d_int   = 1'bx;
      next_full_d_int          = 1'bx;
    end // else: if( word_cnt_d < 0 )
  end  // block: mk_dest_flags

  always @(posedge clk_d or negedge rst_d_n) begin : clk_d_regs_PROC
    integer  i;
    if (rst_d_n === 1'b0) begin
      word_cnt_d         <= {`DW_fifo_cnt_width{1'b0}};
      ram_word_cnt_d     <= {`DW_cnt_width{1'b0}};
      inuse_d            <= {3{1'b0}};
      rd_pend_sr_d       <= {2{1'b0}};
      error_d            <= 1'b0;
      almost_empty_d_int <= 1'b0;
      half_full_d_int    <= 1'b0;
      almost_full_d_int  <= 1'b0;
      full_d_int         <= 1'b0;
      ram_empty_d_d1_inv <= 1'b0;
      for (i=0; i<`DW_cache_inuse_width; i=i+1) begin
        data_reg_d[i]      <= {width{1'b0}};
      end
    end else if (rst_d_n === 1'b1) begin
      if ((init_d_n === 1'b0) || (clr_in_prog_d === 1'b1)) begin
        word_cnt_d         <= {`DW_fifo_cnt_width{1'b0}};
        ram_word_cnt_d     <= {`DW_cnt_width{1'b0}};
        inuse_d            <= {3{1'b0}};
        rd_pend_sr_d       <= {2{1'b0}};
        error_d            <= 1'b0;
        almost_empty_d_int <= 1'b0;
        half_full_d_int    <= 1'b0;
        almost_full_d_int  <= 1'b0;
        full_d_int         <= 1'b0;
        ram_empty_d_d1_inv <= 1'b0;
        for (i=0; i<`DW_cache_inuse_width; i=i+1) begin
          data_reg_d[i]      <= {width{1'b0}};
        end
      end else if (init_d_n === 1'b1) begin
        word_cnt_d         <= next_word_cnt_d;
        ram_word_cnt_d     <= next_ram_word_cnt_d;
        inuse_d            <= next_inuse_d;
        rd_pend_sr_d       <= next_rd_pend_sr_d;
        error_d            <= next_error_d;
        almost_empty_d_int <= next_almost_empty_d_int;
        half_full_d_int    <= next_half_full_d_int;
        almost_full_d_int  <= next_almost_full_d_int;
        full_d_int         <= next_full_d_int;
        ram_empty_d_d1_inv <= ~ram_empty_d;
        for (i=0; i<`DW_cache_inuse_width; i=i+1) begin
          data_reg_d[i]      <= next_data_reg_d[i];
        end
      end else begin
        word_cnt_d         <= {`DW_fifo_cnt_width{1'bX}};
        ram_word_cnt_d     <= {`DW_cnt_width{1'bX}};
        inuse_d            <= {3{1'bX}};
        rd_pend_sr_d       <= {2{1'bX}};
        error_d            <= 1'bX;
        almost_empty_d_int <= 1'bX;
        half_full_d_int    <= 1'bX;
        almost_full_d_int  <= 1'bX;
        full_d_int         <= 1'bX;
        ram_empty_d_d1_inv <= 1'bX;
        for (i=0; i<`DW_cache_inuse_width; i=i+1) begin
          data_reg_d[i]      <= {width{1'bX}};
        end
      end
    end else begin
      word_cnt_d         <= {`DW_fifo_cnt_width{1'bX}};
      ram_word_cnt_d     <= {`DW_cnt_width{1'bX}};
      inuse_d            <= {3{1'bX}};
      rd_pend_sr_d       <= {2{1'bX}};
      error_d            <= 1'bX;
      almost_empty_d_int <= 1'bX;
      half_full_d_int    <= 1'bX;
      almost_full_d_int  <= 1'bX;
      full_d_int         <= 1'bX;
      ram_empty_d_d1_inv <= 1'bX;
      for (i=0; i<`DW_cache_inuse_width; i=i+1) begin
        data_reg_d[i]      <= {width{1'bX}};
      end
    end
  end  // block: clk_d_regs_PROC

  assign ram_empty_d_d1 = ~ram_empty_d_d1_inv;

// Pop error
  assign  error_d_seen  = ~pop_d_n && empty_d;
  assign  next_error_d  = (err_mode == 1) ? error_d_seen : (error_d || error_d_seen);

// Assign Destination Domain Outputs
  assign  rd_addr_d      = rd_addr_d_U_REV_GRAY[`DW_addr_width-1:0];
  assign  data_d         = data_reg_d[0];
  assign  ram_re_d_n     = (((mem_mode==0) || (mem_mode==4)) || (ram_re_ext == 0)) ? ~ram_re_d :
                             (((mem_mode==1) || (mem_mode==2) || (mem_mode==5) || (mem_mode==6))) ? ~ram_re_d && ~rd_pend_sr_d[0] :
                               ~ram_re_d && ~rd_pend_sr_d[0] && ~rd_pend_sr_d[1];
  assign empty_d         = ~inuse_d[0] || clr_in_prog_d_int;
  assign almost_empty_d  = ~almost_empty_d_int;
  assign half_full_d     = half_full_d_int;
  assign almost_full_d   = almost_full_d_int;
  assign full_d          = full_d_int;





    
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
`undef DW_cache_inuse_width
`undef DW_cache_inuse_idx_width
`undef DW_leftover_cnt
`undef DW_offset
`undef DW_ram_depth_2N
`undef DW_push_gray_sync_delay
`undef DW_pop_gray_sync_delay
`undef DW_clk_d_faster

// synopsys translate_on
endmodule
