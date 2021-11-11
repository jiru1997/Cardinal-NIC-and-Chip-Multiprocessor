
////////////////////////////////////////////////////////////////////////////////
//
//       This confidential and proprietary software may be used only
//     as authorized by a licensing agreement from Synopsys Inc.
//     In the event of publication, the following notice is applicable:
//
//                    (C) COPYRIGHT 2005 - 2016 SYNOPSYS INC.
//                           ALL RIGHTS RESERVED
//
//       The entire notice above must be reproduced on all authorized
//     copies.
//
// AUTHOR:    Doug Lee         8/19/05
//
// VERSION:   Simulation Architecture
//
// DesignWare_version: 6c91abce
// DesignWare_release: K-2015.06-DWBB_201506.5.2
//
////////////////////////////////////////////////////////////////////////////////

//
// ABSTRACT: Gray Coded Synchronizer Simulation Model
//
//           This converts binary counter values to gray-coded values in the source domain
//           which then gets synchronized in the destination domain.  Once in the destination
//           domain, the gray-coded values are decoded back to binary values and presented
//           to the output port 'count_d'.  In the source domain, two versions of binary
//           counter values, count_s and offset_count_s, are output to give reference to
//           current state of the counters in, relative and absolute terms, respectively.
//
//              Parameters:         Valid Values
//              ==========          ============
//              width               [ 1 to 1024: width of count_s, offset_count_s and count_d ports
//                                    default: 8 ]
//              offset              [ 0 to (2**(width-1) - 1): offset for non integer power of 2
//                                    default: 0 ]
//              reg_count_d         [ 0 or 1: registering of count_d output
//                                    default: 1
//                                    0 = count_d output is unregistered
//                                    1 = count_d output is registered ]
//              f_sync_type         [ 0 to 4: mode of synchronization
//                                    default: 2
//                                    0 = single clock design, no synchronizing stages implemented,
//                                    1 = 2-stage synchronization w/ 1st stage neg-edge & 2nd stage pos-edge capturing,
//                                    2 = 2-stage synchronization w/ both stages pos-edge capturing,
//                                    3 = 3-stage synchronization w/ all stages pos-edge capturing
//                                    4 = 4-stage synchronization w/ all stages pos-edge capturing ]
//              tst_mode            [ 0 to 2: latch insertion for testing purposes
//                                    default: 0
//                                    0 = no hold latch inserted,
//                                    1 = insert hold 'latch' using a neg-edge triggered register
//                                    2 = insert hold 'latch' using active low latch ]
//              verif_en            [ 0 to 3: verification mode
//                                    default: 1
//                                    0 = no sampling errors inserted,
//                                    1 = sampling errors are randomly inserted with 0 or up to 1 destination clock cycle delays
//                                    4 = sampling errors are randomly inserted with 0 or up to 0.5 destination clock cycle delays
//              pipe_delay          [ 0 to 2: pipeline bin2gray result
//                                    default: 0
//                                    0 = only re-timing register of bin2gray result to destination domain
//                                    1 = one additional pipeline stage of bin2gray result to destination domain
//                                    2 = two additional pipeline stages of bin2gray result to destination domain ]
//              reg_count_s         [ 0 or 1: registering of count_s output
//                                    default: 1
//                                    0 = count_s output is unregistered
//                                    1 = count_s output is registered ]
//              reg_offset_count_s  [ 0 or 1: registering of offset_count_s output
//                                    default: 1
//                                    0 = offset_count_s output is unregistered
//                                    1 = offset_count_s output is registered ]
//
//              Input Ports:    Size     Description
//              ===========     ====     ===========
//              clk_s           1 bit    Source Domain Input Clock
//              rst_s_n         1 bit    Source Domain Active Low Async. Reset
//              init_s_n        1 bit    Source Domain Active Low Sync. Reset
//              en_s            1 bit    Source Domain enable that advances binary counter
//              clk_d           1 bit    Destination Domain Input Clock
//              rst_d_n         1 bit    Destination Domain Active Low Async. Reset
//              init_d_n        1 bit    Destination Domain Active Low Sync. Reset
//              test            1 bit    Test input
//
//              Output Ports    Size     Description
//              ============    ====     ===========
//              count_s         M bit    Source Domain binary counter value
//              offset_count_s  M bits   Source Domain binary counter offset value
//              count_d         M bits   Destination Domain binary counter value
//
//                Note: (1) The value of M is equal to the 'width' parameter value
//
//
// MODIFIED:
//
//            8/01/11 DLL    Tied 'init_d_n' input to instance DW_sync to 1'b1 to
//                           disable any type of synchronous reset to it.  Also, used
//                           localparam for OFFSET_UPPER_BOUND to fix lint warning and added
//                           tst_mode=2 capability.
//
//            2/28/08 DLL    Changed behavior of next_count_s_int and next_offset_count_s_int
//                           during init_s_n assertion.  
//                           Addresses STAR#9000450996.
//
//            7/13/09  DLL   Changed all `define declarations to have the
//                           "DW_" prefix and then `undef them at the approprite time.
//
//            11/7/06  DLL   Modified functionality to support f_sync_type = 4
//
//            8/1/06   DLL   Added parameter 'reg_offset_count_s' which allows for registered
//                           or unregistered 'offset_count_s'.
//
//            7/21/06  DLL   Added parameter 'reg_count_s' which allows for registered
//                           or unregistered 'count_s'.
//
//            7/10/06  DLL   Added parameter 'pipe_delay' that allows up to 2 additional
//                           register delays of the binary to gray code result from
//                           the source to destination domain.
//
//
module DW_gray_sync (
    clk_s,
    rst_s_n,
    init_s_n,
    en_s,
    count_s,
    offset_count_s,

    clk_d,
    rst_d_n,
    init_d_n,
    count_d,

    test
    );

parameter width               = 8;  // RANGE 1 to 1024
parameter offset              = 0;  // RANGE 0 to (2**(width-1) - 1)
parameter reg_count_d         = 1;  // RANGE 0 to 1
parameter f_sync_type         = 2;  // RANGE 0 to 4
parameter tst_mode            = 0;  // RANGE 0 to 2
parameter verif_en            = 2;  // RANGE 0 to 4
parameter pipe_delay          = 0;  // RANGE 0 to 2
parameter reg_count_s         = 1;  // RANGE 0 to 1
parameter reg_offset_count_s  = 1;  // RANGE 0 to 1

input                   clk_s;           // clock input from source domain
input                   rst_s_n;         // active low asynchronous reset from source domain
input                   init_s_n;        // active low synchronous reset from source domain
input                   en_s;            // enable source domain
output [width-1:0]      count_s;         // binary counter value to source domain
output [width-1:0]      offset_count_s;  // binary counter offset value to source domain

input                   clk_d;           // clock input from destination domain
input                   rst_d_n;         // active low asynchronous reset from destination domain
input                   init_d_n;        // active low synchronous reset from destination domain
output [width-1:0]      count_d;         // binary counter value to destination domain

input                   test;            // test input

// synopsys translate_off
`define DW_MAX_WIDTH 1024
wire [`DW_MAX_WIDTH-1:0]        ONE;
assign ONE = {{`DW_MAX_WIDTH-1{1'b0}},1'b1};
wire [width-1:0]             COUNT_S_INIT_BIN2GRAY;

`define DW_MAX_COUNT_S (((1'b1 << width) - 1) - offset)
`define DW_COUNT_S_INIT offset[width-1:0]
`define DW_OFFSET_COUNT_S_INIT {width{1'b0}}
assign  COUNT_S_INIT_BIN2GRAY = DWF_bin2gray(`DW_COUNT_S_INIT);

localparam [width-1:0]  OFFSET_UPPER_BOUND = (1'b1 << (width - 1)) - 1;




  //-------------------------------------------------------------------------
  // Parameter legality check
  //-------------------------------------------------------------------------
  
 
  initial begin : parameter_check
    integer param_err_flg;

    param_err_flg = 0;
    
  
    if ( (width < 1) || (width > `DW_MAX_WIDTH) ) begin
      param_err_flg = 1;
      $display(
	"ERROR: %m :\n  Invalid value (%d) for parameter width (legal range: 1 to `DW_MAX_WIDTH)",
	width );
    end
  
    if ( (offset < 0) || (offset > OFFSET_UPPER_BOUND) ) begin
      param_err_flg = 1;
      $display(
	"ERROR: %m :\n  Invalid value (%d) for parameter offset (legal range: 0 to OFFSET_UPPER_BOUND)",
	offset );
    end
  
    if ( (reg_count_d < 0) || (reg_count_d > 1) ) begin
      param_err_flg = 1;
      $display(
	"ERROR: %m :\n  Invalid value (%d) for parameter reg_count_d (legal range: 0 to 1)",
	reg_count_d );
    end
  
    if ( ((f_sync_type & 7) < 0) || ((f_sync_type & 7) > 4) ) begin
      param_err_flg = 1;
      $display(
	"ERROR: %m :\n  Invalid value (%d) for parameter (f_sync_type & 7) (legal range: 0 to 4)",
	(f_sync_type & 7) );
    end
  
    if ( (tst_mode < 0) || (tst_mode > 2) ) begin
      param_err_flg = 1;
      $display(
	"ERROR: %m :\n  Invalid value (%d) for parameter tst_mode (legal range: 0 to 2)",
	tst_mode );
    end
  
    if ( (verif_en < 0) || (verif_en > 4) ) begin
      param_err_flg = 1;
      $display(
	"ERROR: %m :\n  Invalid value (%d) for parameter verif_en (legal range: 0 to 4)",
	verif_en );
    end
  
    if ( ((verif_en==2) || (verif_en==3)) ) begin
      param_err_flg = 1;
      $display(
	"ERROR: %m : Illegal parameter value for verif_en.  Values of 2 and 3 not permitted." );
    end
  
    if ( (pipe_delay < 0) || (pipe_delay > 2) ) begin
      param_err_flg = 1;
      $display(
	"ERROR: %m :\n  Invalid value (%d) for parameter pipe_delay (legal range: 0 to 2)",
	pipe_delay );
    end
  
    if ( param_err_flg == 1) begin
      $display(
        "%m :\n  Simulation aborted due to invalid parameter value(s)");
      $finish;
    end

  end // parameter_check 


  reg  [width-1:0]       count_s_int;
  reg  [width-1:0]       offset_count_s_int;
  reg  [width-1:0]       count_d_int;
  reg  [width-1:0]       bin2gray_s;
  reg  [width-1:0]       bin2gray_s_d1;
  reg  [width-1:0]       bin2gray_s_d2;

  wire [width-1:0]       next_count_s_int;
  wire [width-1:0]       next_count_s_adv;
  wire [width-1:0]       next_offset_count_s_int;
  wire [width-1:0]       next_count_d_int;
  wire [width-1:0]       next_bin2gray_s;

  wire [width-1:0]       bin2gray_s_pipe;
  wire [width-1:0]       dw_sync_bin2gray_d;
  wire [width-1:0]       bin2gray_cc;
  reg  [width-1:0]       bin2gray_l;


  // include modeling functions
  `include "DW_bin2gray_function.inc"
  `include "DW_gray2bin_function.inc"



  initial begin
    if ((f_sync_type > 0)&&(f_sync_type < 8))
      $display("Information: *** Instance %m is the DW_gray_sync Clock Domain Crossing Module ***");
  end


  assign next_count_s_adv         = ((count_s_int ^  offset) === `DW_MAX_COUNT_S) ? `DW_COUNT_S_INIT : (count_s_int ^ offset[width-1:0]) + ONE[width-1:0];

  assign next_count_s_int         = (init_s_n == 1'b0) ? `DW_COUNT_S_INIT :
                                      ((en_s === 1'b1) ? next_count_s_adv :
                                        ((en_s === 1'b0) ? (count_s_int ^ offset[width-1:0]) : {width{1'bX}}));
  assign next_offset_count_s_int  = (init_s_n == 1'b0) ? `DW_OFFSET_COUNT_S_INIT :
                                      ((en_s === 1'b1) ? (((count_s_int ^ offset[width-1:0]) === `DW_MAX_COUNT_S) ?
				 		         `DW_OFFSET_COUNT_S_INIT : offset_count_s_int + ONE[width-1:0]) :
						          ((en_s === 1'b0) ? offset_count_s_int : {width{1'bX}}));

  assign next_bin2gray_s = DWF_bin2gray(next_count_s_int);

  assign bin2gray_s_pipe = (pipe_delay == 2) ? bin2gray_s_d2 :
			     (pipe_delay == 1) ? bin2gray_s_d1 : bin2gray_s;

  
  
generate
  if (((f_sync_type&7)>1)&&(tst_mode==2)) begin : GEN_LATCH_hold_latch_PROC
    reg [width-1:0] bin2gray_l;
    always @ (clk_s or bin2gray_s_pipe) begin : LATCH_hold_latch_PROC_PROC

      if (clk_s == 1'b0)

	bin2gray_l = bin2gray_s_pipe;


    end // LATCH_hold_latch_PROC_PROC


    assign bin2gray_cc = (test==1'b1)? bin2gray_l : bin2gray_s_pipe;

  end else begin : GEN_DIRECT_hold_latch_PROC
    assign bin2gray_cc = bin2gray_s_pipe;
  end
endgenerate

  DW_sync #(width, f_sync_type+8, tst_mode, verif_en) SIM(
	.clk_d(clk_d),
	.rst_d_n(rst_d_n),
	.init_d_n(1'b1),
	.data_s(bin2gray_cc),
	.test(test),
	.data_d(dw_sync_bin2gray_d) );

  assign next_count_d_int = DWF_gray2bin(dw_sync_bin2gray_d);

  always @(posedge clk_s or negedge rst_s_n) begin : a1000_PROC
    if (rst_s_n === 1'b0) begin
      count_s_int        <= {width{1'b0}};
      offset_count_s_int <= {width{1'b0}};
      bin2gray_s         <= {width{1'b0}};
      bin2gray_s_d1      <= {width{1'b0}};
      bin2gray_s_d2      <= {width{1'b0}};
    end else if (rst_s_n === 1'b1) begin
      if (init_s_n === 1'b0) begin
        count_s_int        <= {width{1'b0}};
        offset_count_s_int <= {width{1'b0}};
	bin2gray_s         <= {width{1'b0}};
        bin2gray_s_d1      <= {width{1'b0}};
        bin2gray_s_d2      <= {width{1'b0}};
      end else if (init_s_n === 1'b1) begin
        count_s_int        <= next_count_s_int ^ offset;
        offset_count_s_int <= next_offset_count_s_int;
	bin2gray_s         <= next_bin2gray_s ^ COUNT_S_INIT_BIN2GRAY;
	bin2gray_s_d1      <= bin2gray_s;
	bin2gray_s_d2      <= bin2gray_s_d1;
      end else begin
        count_s_int        <= {width{1'bX}};
        offset_count_s_int <= {width{1'bX}};
        bin2gray_s         <= {width{1'bX}};
        bin2gray_s_d1      <= {width{1'bX}};
        bin2gray_s_d2      <= {width{1'bX}};
      end
    end else begin
      count_s_int        <= {width{1'bX}};
      offset_count_s_int <= {width{1'bX}};
      bin2gray_s         <= {width{1'bX}};
      bin2gray_s_d1      <= {width{1'bX}};
      bin2gray_s_d2      <= {width{1'bX}};
    end
  end

  always @(posedge clk_d or negedge rst_d_n) begin : a1001_PROC
    if (rst_d_n === 1'b0) begin
      count_d_int        <= {width{1'b0}};
    end else if (rst_d_n === 1'b1) begin
      if (init_d_n === 1'b0) begin
        count_d_int        <= {width{1'b0}};
      end else if (init_d_n === 1'b1) begin
        count_d_int        <= next_count_d_int;
      end else begin
        count_d_int        <= {width{1'bX}};
      end
    end else begin
      count_d_int        <= {width{1'bX}};
    end
  end

  assign count_s        = (reg_count_s == 1)        ? (count_s_int ^ offset[width-1:0]) : next_count_s_int;
  assign offset_count_s = (reg_offset_count_s == 1) ? offset_count_s_int : next_offset_count_s_int;
  assign count_d        = ((reg_count_d == 1)       ? count_d_int : next_count_d_int) ^ offset[width-1:0];
			  

  
  always @ (clk_d) begin : monitor_clk_d 
    if ( (clk_d !== 1'b0) && (clk_d !== 1'b1) && ($time > 0) )
      $display( "WARNING: %m :\n  at time = %t, detected unknown value, %b, on clk_d input.",
                $time, clk_d );
    end // monitor_clk_d 

`undef DW_MAX_WIDTH
`undef DW_OFFSET_COUNT_S_INIT
`undef DW_COUNT_S_INIT
`undef DW_MAX_COUNT_S

// synopsys translate_on
endmodule
