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
// AUTHOR:    Doug Lee       10/24/09
//
// VERSION:   Verilog Simulation Model
//
// DesignWare_version: 0f3247c7
// DesignWare_release: K-2015.06-DWBB_201506.5.2
//
////////////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////////////
//
//
// ABSTRACT: Dual clock domain interface assymetric FIFO controller Verilog Simulation Model
//
//           Used for assymetric FIFOs with synchronous pipelined RAMs and
//           external caching.  Status flags are dynamically
//           configured.
//
//
//      Parameters     Valid Values   Description
//      ==========     ============   ===========
//      data_s_width    1 to 1024     default: 16
//                                    Width of data_s
//
//      data_d_width    1 to 1024     default: 8
//                                    Width of data_d
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
//      arch_type        0 or 1       default: 0
//                                    Pre-fetch cache architecture type
//                                      0 => Pipeline style
//                                      1 => Register File style
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
//      byte_order       1 to 0       default: 0
//                                      0 => the first byte (or subword) is in MSBs
//                                      1 => the first byte  (or subword)is in LSBs
//
//      flush_value      1 to 0        default: 0 
//                                      0 => fill empty bits of partial word with 0's upon flush
//                                      1 => fill empty bits of partial word with 1's upon flush
//
//      clk_ratio   -7 to 1, 1 to 7   default: 1
//                                    Rounded quotient between clk_s and clk_d
//                                      1 to 7   => when clk_d rate faster than clk_s rate: round(clk_d rate / clk_s rate)
//                                      -7 to -1 => when clk_d rate slower than clk_s rate: 0 - round(clk_s rate / clk_d rate)
//                                      NOTE: 0 is illegal
//
//      ram_re_ext       0 or 1       default: 1
//                                    Determines the charateristic of the ram_re_d_n signal to RAM
//                                      0 => Single-cycle pulse of ram_re_d_n at the read event to RAM
//                                      1 => Extend assertion of ram_re_d_n while read event active in RAM
//
//      err_mode         0 or 1       default: 0
//                                    Error Reporting Behavior
//                                      0 => sticky error flag
//                                      1 => dynamic error flag
//
//      tst_mode         0 or 1       default: 0
//                                    Latch insertion for testing purposes
//                                      0 => no hold latch inserted,
//                                      1 => insert hold 'latch' using a neg-edge triggered register
//                                      2 => insert hold latch using active low latch
//
//        verif_en     0, 1, or 4     Synchronization missampling control (Simulation verification)
//                                    Default value = 1
//                                    0 => no sampling errors modeled,
//                                    1 => when DW_MODEL_MISSAMPLES defined, randomly insert 0 to 1 cycle delay
//                                    4 => when DW_MODEL_MISSAMPLES defined, randomly insert 0 to 0.5 cycle delay
//                                    Note: Use `define DW_MODEL_MISSAMPLES to define the Verilog macro
//                                          that turns on missample modeling in a Verilog HDL file.  Use
//                                          +define+DW_MODEL_MISSAMPLES simulator command line option to turn
//                                          on missample modeleng from the simulator command.
//
//      Inputs           Size       Description
//      ======           ====       ===========
//      clk_s            1 bit      Source Domain Clock
//      rst_s_n          1 bit      Source Domain Asynchronous Reset (active low)
//      init_s_n         1 bit      Source Domain Synchronous Reset (active low)
//      clr_s            1 bit      Source Domain Clear to initiate orchestrated reset (active high pulse)
//      ae_level_s       N bits     Source Domain RAM almost empty threshold setting
//      af_level_s       N bits     Source Domain RAM almost full threshold setting
//      push_s_n         1 bit      Source Domain push request (active low)
//      flush_s_n        1 bit      Source Domain Flush the partial word into the full word memory (active low)
//      data_s           L bits     Source Domain data
//
//      clk_d            1 bit      Destination Domain Clock
//      rst_d_n          1 bit      Destination Domain Asynchronous Reset (active low)
//      init_d_n         1 bit      Destination Domain Synchronous Reset (active low)
//      clr_d            1 bit      Destination Domain Clear to initiate orchestrated reset (active high pulse)
//      ae_level_d       Q bits     Destination Domain FIFO almost empty threshold setting
//      af_level_d       Q bits     Destination Domain FIFO almost full threshold setting
//      pop_d_n          1 bit      Destination Domain pop request (active low)
//      rd_data_d        M bits     Destination Domain read data from RAM
//
//      test             1 bit      Test input
//
//      Outputs          Size       Description
//      =======          ====       ===========
//      clr_sync_s       1 bit      Source Domain synchronized clear (active high pulse)
//      clr_in_prog_s    1 bit      Source Domain orchestrate clearing in progress
//      clr_cmplt_s      1 bit      Source Domain orchestrated clearing complete (active high pulse)
//      wr_en_s_n        1 bit      Source Domain write enable to RAM (active low)
//      wr_addr_s        P bits     Source Domain write address to RAM
//      wr_data_s        M bits     Source Domain write data to RAM
//      inbuf_part_wd_s  1 bit      Source Domain partial word in input buffer flag (meaningful when data_s_width < data_d_width)
//      inbuf_full_s     1 bit      Source domain input buffer full flag (meaningful when data_s_width < data_d_width)
//      fifo_word_cnt_s  Q bits     Source Domain FIFO word count (includes cache)
//      word_cnt_s       N bits     Source Domain RAM only word count
//      fifo_empty_s     1 bit      Source Domain FIFO Empty Flag
//      empty_s          1 bit      Source Domain RAM Empty Flag
//      almost_empty_s   1 bit      Source Domain RAM Almost Empty Flag
//      half_full_s      1 bit      Source Domain RAM Half Full Flag
//      almost_full_s    1 bit      Source Domain RAM Almost Full Flag
//      ram_full_s       1 bit      Source Domain RAM Full Flag
//      push_error_s     1 bit      Source Domain Push Error Flag
//
//      clr_sync_d       1 bit      Destination Domain synchronized clear (active high pulse)
//      clr_in_prog_d    1 bit      Destination Domain orchestrate clearing in progress
//      clr_cmplt_d      1 bit      Destination Domain orchestrated clearing complete (active high pulse)
//      ram_re_d_n       1 bit      Destination Domain Read Enable to RAM (active-low)
//      rd_addr_d        P bits     Destination Domain read address to RAM
//      data_d           R bits     Destination Domain data out
//      outbuf_part_wd_d 1 bit      Destination Domain outbuf partial word popped flag (meaningful when data_s_width > data_d_width)
//      word_cnt_d       Q bits     Destination Domain FIFO word count (includes cache)
//      ram_word_cnt_d   N bits     Destination Domain RAM only word count
//      empty_d          1 bit      Destination Domain Empty Flag
//      almost_empty_d   1 bit      Destination Domain Almost Empty Flag
//      half_full_d      1 bit      Destination Domain Half Full Flag
//      almost_full_d    1 bit      Destination Domain Almost Full Flag
//      full_d           1 bit      Destination Domain Full Flag
//      pop_error_d      1 bit      Destination Domain Pop Error Flag
//
//           Note: L is equal to the data_s_width parameter
//           Note: M is equal to larger of data_s_width and data_d_width
//           Note: R is equal to the data_d_width parameter
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
//
////////////////////////////////////////////////////////////////////////////////
module DW_asymfifoctl_2c_df(
        clk_s,
        rst_s_n,
        init_s_n,
        clr_s,
        ae_level_s,
        af_level_s,
        push_s_n,
        flush_s_n,
        data_s,

        clr_sync_s,
        clr_in_prog_s,
        clr_cmplt_s,
        wr_en_s_n,
        wr_addr_s,
        wr_data_s,
        inbuf_part_wd_s,
        inbuf_full_s,
        fifo_word_cnt_s,
        word_cnt_s,
        fifo_empty_s,
        empty_s,
        almost_empty_s,
        half_full_s,
        almost_full_s,
        ram_full_s,
        push_error_s,

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
        outbuf_part_wd_d,
        word_cnt_d,
        ram_word_cnt_d,
        empty_d,
        almost_empty_d,
        half_full_d,
        almost_full_d,
        full_d,
        pop_error_d,

        test
        );

parameter data_s_width     =  16;  // RANGE 1 to 1024
parameter data_d_width     =  8;   // RANGE 1 to 1024
parameter ram_depth        =  8;   // RANGE 4 to 1024
parameter mem_mode         =  3;   // RANGE 0 to 7
parameter arch_type        =  0;   // RANGE 0 to 1
parameter f_sync_type      =  2;   // RANGE 1 to 4
parameter r_sync_type      =  2;   // RANGE 1 to 4
parameter byte_order       =  0;   // RANGE 0 to 1
parameter flush_value      =  0;   // RANGE 0 to 1
parameter clk_ratio        =  1;   // RANGE -7 to -1, 1 to 7
parameter ram_re_ext       =  1;   // RANGE 0 to 1
parameter err_mode         =  0;   // RANGE 0 to 1
parameter tst_mode         =  0;   // RANGE 0 to 2
parameter verif_en         =  1;   // RANGE 0, 1, or 4






`define DW_OO1O0IO0             (ram_depth+1+(mem_mode%2)+((mem_mode>>1)%2))
`define DW_OI1O0OlO          ((ram_depth>256)?((ram_depth>4096)?((ram_depth>16384)?((ram_depth>32768)?16:15):((ram_depth>8192)?14:13)):((ram_depth>1024)?((ram_depth>2048)?12:11):((ram_depth>512)?10:9))):((ram_depth>16)?((ram_depth>64)?((ram_depth>128)?8:7):((ram_depth>32)?6:5)):((ram_depth>4)?((ram_depth>8)?4:3):((ram_depth>2)?2:1))))
`define DW_O001101O           ((ram_depth+1>256)?((ram_depth+1>4096)?((ram_depth+1>16384)?((ram_depth+1>32768)?16:15):((ram_depth+1>8192)?14:13)):((ram_depth+1>1024)?((ram_depth+1>2048)?12:11):((ram_depth+1>512)?10:9))):((ram_depth+1>16)?((ram_depth+1>64)?((ram_depth+1>128)?8:7):((ram_depth+1>32)?6:5)):((ram_depth+1>4)?((ram_depth+1>8)?4:3):((ram_depth+1>2)?2:1))))
`define DW_llI011O1      ((`DW_OO1O0IO0+1>256)?((`DW_OO1O0IO0+1>4096)?((`DW_OO1O0IO0+1>16384)?((`DW_OO1O0IO0+1>32768)?16:15):((`DW_OO1O0IO0+1>8192)?14:13)):((`DW_OO1O0IO0+1>1024)?((`DW_OO1O0IO0+1>2048)?12:11):((`DW_OO1O0IO0+1>512)?10:9))):((`DW_OO1O0IO0+1>16)?((`DW_OO1O0IO0+1>64)?((`DW_OO1O0IO0+1>128)?8:7):((`DW_OO1O0IO0+1>32)?6:5)):((`DW_OO1O0IO0+1>4)?((`DW_OO1O0IO0+1>8)?4:3):((`DW_OO1O0IO0+1>2)?2:1))))
`define DW_OO010O10 ((data_s_width>=data_d_width)?data_s_width:data_d_width)

input                            clk_s;            // Source Domain Clock
input                            rst_s_n;          // Source Domain Asynchronous Reset (active low)
input                            init_s_n;         // Source Domain Synchronous Reset (active low)
input                            clr_s;            // Source Domain Clear for coordinated reset (active high pulse)
input  [`DW_O001101O-1:0]       ae_level_s;       // Source Domain RAM almost empty threshold setting
input  [`DW_O001101O-1:0]       af_level_s;       // Source Domain RAM almost full threshold setting
input                            push_s_n;         // Source Domain push request (active low)
input                            flush_s_n;        // Source Domain flush partial word (active low)
input  [data_s_width-1:0]        data_s;           // Source Domain push data

output                           clr_sync_s;       // Source Domain synchronized clear (active high pulse)
output                           clr_in_prog_s;    // Source Domain orchestrate clearing in progress (unregistered)
output                           clr_cmplt_s;      // Source Domain orchestrated clearing complete (active high pulse)
output                           wr_en_s_n;        // Source Domain write enable to RAM (active low)
output [`DW_OI1O0OlO-1:0]      wr_addr_s;        // Source Domain write address to RAM
output [`DW_OO010O10-1:0]       wr_data_s;        // Source Domain write data to RAM
output                           inbuf_part_wd_s;  // Source Domain partial word to inbuf (meaningful when data_s_width < data_d_width)
output                           inbuf_full_s;     // Source Domain inbuf Full Flag (meaningful when data_s_width < data_d_width)
output [`DW_llI011O1-1:0]  fifo_word_cnt_s;  // Source Domain FIFO word count (includes cache)
output [`DW_O001101O-1:0]       word_cnt_s;       // Source Domain RAM only word count
output                           fifo_empty_s;     // Source Domain FIFO Empty Flag
output                           empty_s;          // Source Domain RAM Empty Flag
output                           almost_empty_s;   // Source Domain RAM Almost Empty Flag
output                           half_full_s;      // Source Domain RAM Half Full Flag
output                           almost_full_s;    // Source Domain RAM Almost Full Flag
output                           ram_full_s;       // Source Domain RAM Full Flag
output                           push_error_s;     // Source Domain Push Error Flag

input                            clk_d;            // Destination Domain Clock
input                            rst_d_n;          // Destination Domain Asynchronous Reset (active low)
input                            init_d_n;         // Destination Domain Synchronous Reset (active low)
input                            clr_d;            // Destination Domain Clear to initiate orchestrated reset (active high pulse)
input  [`DW_llI011O1-1:0]  ae_level_d;       // Destination Domain FIFO almost empty threshold setting
input  [`DW_llI011O1-1:0]  af_level_d;       // Destination Domain FIFO almost full threshold setting
input                            pop_d_n;          // Destination Domain pop request (active low)
input  [`DW_OO010O10-1:0]       rd_data_d;        // Destination Domain data read from RAM

output                           clr_sync_d;       // Destination Domain synchronized orchestrated clear (active high pulse)
output                           clr_in_prog_d;    // Destination Domain orchestrate clearing in progress (unregistered)
output                           clr_cmplt_d;      // Destination Domain orchestrated clearing complete (active high pulse)
output                           ram_re_d_n;       // Destination Domain Read Enable to RAM (active-low)
output [`DW_OI1O0OlO-1:0]      rd_addr_d;        // Destination Domain read address to RAM
output [data_d_width-1:0]        data_d;           // Destination Domain data out
output                           outbuf_part_wd_d; // Destination Domain outbuf partial word popped flag (meaningful when data_s_width > data_d_width)
output [`DW_llI011O1-1:0]  word_cnt_d;       // Destination Domain FIFO word count (includes cache)
output [`DW_O001101O-1:0]       ram_word_cnt_d;   // Destination Domain RAM only word count
output                           empty_d;          // Destination Domain Empty Flag
output                           almost_empty_d;   // Destination Domain Almost Empty Flag
output                           half_full_d;      // Destination Domain Half Full Flag
output                           almost_full_d;    // Destination Domain Almost Full Flag
output                           full_d;           // Destination Domain Full Flag
output                           pop_error_d;      // Destination Domain Pop Error Flag

input                            test;             // Test input


// synopsys translate_off




// Parameter checking
  
 
  initial begin : parameter_check
    integer param_err_flg;

    param_err_flg = 0;
    
  
    if ( (data_s_width < 1) || (data_s_width > 1024 ) ) begin
      param_err_flg = 1;
      $display(
	"ERROR: %m :\n  Invalid value (%d) for parameter data_s_width (legal range: 1 to 1024 )",
	data_s_width );
    end
  
    if ( (data_d_width < 1) || (data_d_width > 1024 ) ) begin
      param_err_flg = 1;
      $display(
	"ERROR: %m :\n  Invalid value (%d) for parameter data_d_width (legal range: 1 to 1024 )",
	data_d_width );
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
  
    if ( (arch_type < 0) || (arch_type > 1 ) ) begin
      param_err_flg = 1;
      $display(
	"ERROR: %m :\n  Invalid value (%d) for parameter arch_type (legal range: 0 to 1 )",
	arch_type );
    end
  
    if ( ((f_sync_type & 7) < 0) || ((f_sync_type & 7) > 4 ) ) begin
      param_err_flg = 1;
      $display(
	"ERROR: %m :\n  Invalid value (%d) for parameter (f_sync_type & 7) (legal range: 0 to 4 )",
	(f_sync_type & 7) );
    end
  
    if ( ((r_sync_type & 7) < 0) || ((r_sync_type & 7) > 4 ) ) begin
      param_err_flg = 1;
      $display(
	"ERROR: %m :\n  Invalid value (%d) for parameter (r_sync_type & 7) (legal range: 0 to 4 )",
	(r_sync_type & 7) );
    end
  
    if ( (byte_order < 0) || (byte_order > 1 ) ) begin
      param_err_flg = 1;
      $display(
	"ERROR: %m :\n  Invalid value (%d) for parameter byte_order (legal range: 0 to 1 )",
	byte_order );
    end
  
    if ( (flush_value < 0) || (flush_value > 1 ) ) begin
      param_err_flg = 1;
      $display(
	"ERROR: %m :\n  Invalid value (%d) for parameter flush_value (legal range: 0 to 1 )",
	flush_value );
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
  
    if ( param_err_flg == 1) begin
      $display(
        "%m :\n  Simulation aborted due to invalid parameter value(s)");
      $finish;
    end

  end // parameter_check 



// Source Domain interconnects
wire [`DW_OO010O10-1:0]    OOI0O00I;
wire                        O1l01l1O;
wire                        ll10lO1l;
wire                        Ol1l1l1l;
wire                        OlO1010l;
wire                        Il1OO1OO;
wire                        I1Ol0IO0;


// Destination Domain interconnects
wire                        OIl1O0O1;
wire [data_d_width-1:0]     O10ll11O;
wire [`DW_OO010O10-1:0]    O0010l00;
wire                        lOOI1l1O;
wire                        l0I1010O;
wire                        I10O1001;
wire                        I1ll1Ol0;

 

  initial begin
    if ((f_sync_type > 0)&&(f_sync_type < 8))
      $display("Information: *** Instance %m is the DW_fifoctl_2c_df Clock Domain Crossing Module ***");
  end





generate
  if (data_s_width < data_d_width) begin
    DW_asymdata_inbuf #(data_s_width, `DW_OO010O10, err_mode, byte_order, flush_value) U_INBUF (
                        .clk_push(clk_s),
                        .rst_push_n(rst_s_n),
                        .init_push_n(init_s_n & ~clr_in_prog_s),
                        .push_req_n(push_s_n),
                        .data_in(data_s),
                        .flush_n(flush_s_n),
                        .fifo_full(Il1OO1OO),
                        .push_wd_n(ll10lO1l),
                        .data_out(OOI0O00I),
                        .inbuf_full(inbuf_full),
                        .part_wd(O1l01l1O),
                        .push_error(OlO1010l) );

    assign Ol1l1l1l  = ll10lO1l;
    assign wr_data_s         = OOI0O00I;
  
    assign inbuf_part_wd_s   = O1l01l1O;
    assign inbuf_full_s      = inbuf_full;
    assign push_error_s      = OlO1010l;
  end else begin
    assign Ol1l1l1l  = push_s_n;
    assign wr_data_s         = data_s;
  
    assign inbuf_part_wd_s   = 1'b0;
    assign inbuf_full_s      = 1'b1;
    assign push_error_s      = I1Ol0IO0;
  end
endgenerate

  assign ram_full_s        = Il1OO1OO; 


DW_fifoctl_2c_df #(`DW_OO010O10, ram_depth, mem_mode, (f_sync_type + 8), (r_sync_type + 8), clk_ratio, ram_re_ext, err_mode, tst_mode, verif_en, 0, arch_type) U_FIFOCTL (
            .clk_s(clk_s),
            .rst_s_n(rst_s_n),
            .init_s_n(init_s_n),
            .clr_s(clr_s),
            .ae_level_s(ae_level_s),
            .af_level_s(af_level_s),
            .push_s_n(Ol1l1l1l),
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
            .full_s(Il1OO1OO),
            .error_s(I1Ol0IO0),
            .clk_d(clk_d),
            .rst_d_n(rst_d_n),
            .init_d_n(init_d_n),
            .clr_d(clr_d),
            .ae_level_d(ae_level_d),
            .af_level_d(af_level_d),
            .pop_d_n(OIl1O0O1),
            .rd_data_d(rd_data_d),
            .clr_sync_d(clr_sync_d),
            .clr_in_prog_d(clr_in_prog_d),
            .clr_cmplt_d(clr_cmplt_d),
            .ram_re_d_n(ram_re_d_n),
            .rd_addr_d(rd_addr_d),
            .data_d(O0010l00),
            .word_cnt_d(word_cnt_d),
            .ram_word_cnt_d(ram_word_cnt_d),
            .empty_d(empty_d),
            .almost_empty_d(almost_empty_d),
            .half_full_d(half_full_d),
            .almost_full_d(almost_full_d),
            .full_d(full_d),
            .error_d(I1ll1Ol0),
            .test(test)
            );

generate
  if (data_s_width > data_d_width) begin
    DW_asymdata_outbuf #(`DW_OO010O10, data_d_width, err_mode, byte_order) U_OUTBUF (
                       .clk_pop(clk_d),
                       .rst_pop_n(rst_d_n),
                       .init_pop_n(init_d_n & ~clr_in_prog_d),
                       .pop_req_n(pop_d_n),
                       .data_in(O0010l00),
                       .fifo_empty(empty_d),
                       .pop_wd_n(l0I1010O),
                       .data_out(O10ll11O),
                       .part_wd(lOOI1l1O),
                       .pop_error(I10O1001) );

    assign OIl1O0O1   = l0I1010O;
    assign data_d            = O10ll11O;

    assign pop_error_d       = I10O1001;
    assign outbuf_part_wd_d  = lOOI1l1O;
  end else begin
    assign OIl1O0O1   = pop_d_n;
    assign data_d            = O0010l00;

    assign pop_error_d       = I1ll1Ol0; 
    assign outbuf_part_wd_d  = 1'b0;
  end
endgenerate


  
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

`undef DW_OO010O10
`undef DW_llI011O1
`undef DW_O001101O
`undef DW_OI1O0OlO
`undef DW_OO1O0IO0
// synopsys translate_on
endmodule
