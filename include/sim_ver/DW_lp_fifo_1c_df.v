////////////////////////////////////////////////////////////////////////////////
//
//       This confidential and proprietary software may be used only
//     as authorized by a licensing agreement from Synopsys Inc.
//     In the event of publication, the following notice is applicable:
//
//                    (C) COPYRIGHT 2009 - 2016 SYNOPSYS INC.
//                           ALL RIGHTS RESERVED
//
//       The entire notice above must be reproduced on all authorized
//     copies.
//
// AUTHOR:    Doug Lee       9/25/09
//
// VERSION:   Verilog Simulation Model
//
// DesignWare_version: ca739159
// DesignWare_release: K-2015.06-DWBB_201506.5.2
//
////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
//
// ABSTRACT: Verilog Simulation Model for Single-clock FIFO with Dynamic Flags
//
//
//           This FIFO incorporates a single-clock FIFO controller with
//           caching and dynamic flags along with a synchronous
//           dual port synchronous RAM.
//
//
//      Parameters     Valid Values   Description
//      ==========     ============   ===========
//      width           1 to 1024     default: 8
//                                    Width of data to/from FIFO
//
//      depth           4 to 1024     default: 8
//                                    Depth of the FIFO (includes RAM, cache, and write re-timing stage)
//
//      mem_mode         0 to 7       default: 3
//                                    Defines where and how many re-timing stages used in RAM:
//                                      0 => no pre or post retiming
//                                      1 => RAM data out (post) re-timing
//                                      2 => RAM read address (pre) re-timing
//                                      3 => RAM data out and read address re-timing
//                                      4 => RAM write interface (pre) re-timing
//                                      5 => RAM write interface and RAM data out re-timing
//                                      6 => RAM write interface and read address re-timing
//                                      7 => RAM write interface, read address, and read address re-timing
//
//      arch_type        0 to 4       default: 1
//                                    Datapath architecture configuration
//                                      0 => no input re-timing, no pre-fetch cache
//                                      1 => no input re-timing, pre-fetch pipeline cache
//                                      2 => input re-timing, pre-fetch pipeline cache
//                                      3 => no input re-timing, pre-fetch register file cache
//                                      4 => input re-timing, pre-fetch register file cache
//
//      af_from_top      0 or 1       default: 1
//                                    Almost full level input (af_level) usage
//                                      0 => the af_level input value represents the minimum 
//                                           number of valid FIFO entries at which the almost_full 
//                                           output starts being asserted
//                                      1 => the af_level input value represents the maximum number
//                                           of unfilled FIFO entries at which the almost_full
//                                           output starts being asserted
//
//      ram_re_ext       0 or 1       default: 0
//                                    Determines the charateristic of the ram_re_n signal to RAM
//                                      0 => Single-cycle pulse of ram_re_n at the read event to RAM
//                                      1 => Extend assertion of ram_re_n while read event active in RAM
//
//      err_mode         0 or 1       default: 0
//                                    Error Reporting Behavior
//                                      0 => sticky error flag
//                                      1 => dynamic error flag
//
//      rst_mode         0 to 3       default: 0
//                                    System Reset Mode which defines the affect of ‘rst_n’ :
//                                      0 => asynchronous reset including clearing the RAM
//                                      1 => asynchronous reset not including clearing the RAM
//                                      2 => synchronous reset including clearing the RAM
//                                      3 => synchronous reset not including clearing the RAM
//
//
//
//      Inputs           Size       Description
//      ======           ====       ===========
//      clk                1        Clock
//      rst_n              1        Asynchronous reset (active low)
//      init_n             1        Synchronous reset (active low)
//      ae_level           N        Almost empty threshold setting (for the almost_empty output)
//      af_level           N        Almost full threshold setting (for the almost_full output)
//      level_change       1        Almost empty and/or almost full level is being changed (active high pulse)
//      push_n             1        Push request (active low)
//      data_in            M        Data input
//      pop_n              1        Pop request (active low)
//
//
//      Outputs          Size       Description
//      =======          ====       ===========
//      data_out           M        Data output
//      word_cnt           N        FIFO word count
//      empty              1        FIFO empty flag
//      almost_empty       1        Almost empty flag (determined by ae_level input)
//      half_full          1        Half full flag
//      almost_full        1        Almost full flag (determined by af_level input)
//      full               1        Full flag
//      error              1        Error flag (overrun or underrun)
//
//
//           Note: M is equal to the "width" parameter
//
//           Note: N is equal to ceil(log2(depth+1))
//
//
//
// MODIFIED:
//
//
//
////////////////////////////////////////////////////////////////////////////////
module DW_lp_fifo_1c_df (
        clk,
        rst_n,
        init_n,
        ae_level,
        af_level,
        level_change,
        push_n,
        data_in,
        pop_n,

        data_out,
        word_cnt,
        empty,
        almost_empty,
        half_full,
        almost_full,
        full,
        error
        );

parameter width       = 8;    // RANGE 1 to 1024
parameter depth       = 8;    // RANGE 4 to 1024
parameter mem_mode    = 3;    // RANGE 0 to 7
parameter arch_type   = 1;    // RANGE 0 to 4
parameter af_from_top = 1;    // RANGE 0 to 1
parameter ram_re_ext  = 0;    // RANGE 0 to 1
parameter err_mode    = 0;    // RANGE 0 to 1
parameter rst_mode    = 0;    // RANGE 0 to 3
   

`define DW_OII101I0     ((mem_mode==0) ? 1 : (((mem_mode==3)||(mem_mode==5)||(mem_mode==7)) ? 3 : 2))
`define DW_I01O10Il             ((arch_type==0) ? depth : ((arch_type==1) || (arch_type==3)) ? (depth - `DW_OII101I0) : (depth - 1 - `DW_OII101I0))
`define DW_l1Il0O11        ((`DW_I01O10Il>256)?((`DW_I01O10Il>4096)?((`DW_I01O10Il>16384)?((`DW_I01O10Il>32768)?16:15):((`DW_I01O10Il>8192)?14:13)):((`DW_I01O10Il>1024)?((`DW_I01O10Il>2048)?12:11):((`DW_I01O10Il>512)?10:9))):((`DW_I01O10Il>16)?((`DW_I01O10Il>64)?((`DW_I01O10Il>128)?8:7):((`DW_I01O10Il>32)?6:5)):((`DW_I01O10Il>4)?((`DW_I01O10Il>8)?4:3):((`DW_I01O10Il>2)?2:1))))
`define DW_OI11llIO             ((depth+1>256)?((depth+1>4096)?((depth+1>16384)?((depth+1>32768)?16:15):((depth+1>8192)?14:13)):((depth+1>1024)?((depth+1>2048)?12:11):((depth+1>512)?10:9))):((depth+1>16)?((depth+1>64)?((depth+1>128)?8:7):((depth+1>32)?6:5)):((depth+1>4)?((depth+1>8)?4:3):((depth+1>2)?2:1))))

input                            clk;           // Clock
input                            rst_n;         // Asynchronous Reset (active low)
input                            init_n;        // Synchronous Reset (active low)
input  [`DW_OI11llIO-1:0]       ae_level;      // FIFO almost empty threshold setting
input  [`DW_OI11llIO-1:0]       af_level;      // FIFO almost full threshold setting
input                            level_change;  // Almost empty and/or almost full level is being changed (active high pulse)
input                            push_n;        // Push request (active low)
input  [width-1:0]               data_in;       // Input data
input                            pop_n;         // Pop request (active low)

output [width-1:0]               data_out;      // FIFO output data
output [`DW_OI11llIO-1:0]       word_cnt;      // RAM only word count
output                           empty;         // FIFO Empty Flag
output                           almost_empty;  // FIFO Almost Empty Flag
output                           half_full;     // FIFO Half Full Flag
output                           almost_full;   // FIFO Almost Full Flag
output                           full;          // FIFO Full Flag
output                           error;         // Error Flag

wire                             OOO1O0OI;
wire                             IOl01l1O;
wire                             OO0I1l00;
wire   [`DW_l1Il0O11-1:0]  OOIO101I;
wire   [width-1:0]               OOl0O110;
wire   [width-1:0]               Ol00Ol11;
wire                             ll0O10OI;
wire   [`DW_l1Il0O11-1:0]  IOOOll11;
wire                             II1O1O01;

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
  
    if ( (depth < 4) || (depth > 1024 ) ) begin
      param_err_flg = 1;
      $display(
	"ERROR: %m :\n  Invalid value (%d) for parameter depth (legal range: 4 to 1024 )",
	depth );
    end
  
    if ( (mem_mode < 0) || (mem_mode > 7 ) ) begin
      param_err_flg = 1;
      $display(
	"ERROR: %m :\n  Invalid value (%d) for parameter mem_mode (legal range: 0 to 7 )",
	mem_mode );
    end
  
    if ( (arch_type < 0) || (arch_type > 4 ) ) begin
      param_err_flg = 1;
      $display(
	"ERROR: %m :\n  Invalid value (%d) for parameter arch_type (legal range: 0 to 4 )",
	arch_type );
    end
  
    if ( (af_from_top < 0) || (af_from_top > 1) ) begin
      param_err_flg = 1;
      $display(
	"ERROR: %m :\n  Invalid value (%d) for parameter af_from_top (legal range: 0 to 1)",
	af_from_top );
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
  
    if ( (rst_mode < 0) || (rst_mode > 3 ) ) begin
      param_err_flg = 1;
      $display(
	"ERROR: %m :\n  Invalid value (%d) for parameter rst_mode (legal range: 0 to 3 )",
	rst_mode );
    end
  
    if ( (arch_type===0 && mem_mode!==0) ) begin
      param_err_flg = 1;
      $display(
	"ERROR: %m : Invalid parameter combination: when arch_type=0, mem_mode must be 0" );
    end
  
    if ( (arch_type>=3 && mem_mode===0) ) begin
      param_err_flg = 1;
      $display(
	"ERROR: %m : Invalid parameter combination: when arch_type is 3 or 4, mem_mode must be > 0" );
    end
  
    if ( (`DW_I01O10Il<2) ) begin
      param_err_flg = 1;
      $display(
	"ERROR: %m : Invalid parameter combination of arch_type and mem_mode settings causes depth of RAM to be < 2" );
    end
  
    if ( param_err_flg == 1) begin
      $display(
        "%m :\n  Simulation aborted due to invalid parameter value(s)");
      $finish;
    end

  end // parameter_check 



assign OOO1O0OI  = ((rst_mode/2)) ? 1'b1 : rst_n;
assign IOl01l1O = ((rst_mode/2)) ? (init_n & rst_n) : init_n;


DW_lp_fifoctl_1c_df #(width, depth, mem_mode, arch_type, af_from_top, ram_re_ext, err_mode) U1 (
            .clk(clk),
            .rst_n(OOO1O0OI),
            .init_n(IOl01l1O),
            .ae_level(ae_level),
            .af_level(af_level),
            .level_change(level_change),
            .push_n(push_n),
            .data_in(data_in),
            .ram_we_n(OO0I1l00),
            .wr_addr(OOIO101I),
            .wr_data(OOl0O110),
            .word_cnt(word_cnt), 
            .empty(empty),
            .almost_empty(almost_empty),
            .half_full(half_full), 
            .almost_full(almost_full),
            .full(full),
            .error(error),
            .pop_n(pop_n),
            .rd_data(Ol00Ol11),
            .ram_re_n(ll0O10OI),
            .rd_addr(IOOOll11),
            .data_out(data_out)
            );


DW_ram_r_w_2c_dff #(width, `DW_I01O10Il,`DW_l1Il0O11, mem_mode, (rst_mode%2)) U2 (
            .clk_w(clk),
            .rst_w_n(OOO1O0OI),
            .init_w_n(IOl01l1O),
            .en_w_n(OO0I1l00),
            .addr_w(OOIO101I),
            .data_w(OOl0O110),
            .clk_r(clk),
            .rst_r_n(OOO1O0OI),
            .init_r_n(IOl01l1O),
            .en_r_n(ll0O10OI),
            .addr_r(IOOOll11),
            .data_r_a(II1O1O01),
            .data_r(Ol00Ol11)
            );

    
  always @ (clk) begin : clk_monitor 
    if ( (clk !== 1'b0) && (clk !== 1'b1) && ($time > 0) )
      $display( "WARNING: %m :\n  at time = %t, detected unknown value, %b, on clk input.",
                $time, clk );
    end // clk_monitor 


`undef DW_I01O10Il
`undef DW_l1Il0O11 
`undef DW_OI11llIO   
`undef DW_OII101I0   
// synopsys translate_on
endmodule
