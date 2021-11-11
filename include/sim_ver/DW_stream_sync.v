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
// AUTHOR:    Doug Lee         12/20/05
//
// VERSION:   Simulation Architecture
//
// DesignWare_version: 651f669e
// DesignWare_release: K-2015.06-DWBB_201506.5.2
//
////////////////////////////////////////////////////////////////////////////////
//
// ABSTRACT: Data Stream Synchronizer Simulation Model
//
//           This synchronizes an incoming data stream from a source domain
//           to a destination domain with a minimum amount of latency.
//
//       Parameters:     Valid Values    Description
//       ==========      ============    ===========
//       width            1 to 1024      default: 8
//                                       Width of data_s and data_d ports
//
//       depth            2 to 256       default: 4
//                                       Depth of FIFO
//
//       prefill_lvl     0 to depth-1    default: 0
//                                       number of FIFO locations filled before
//                                       transferring to destination domain ]
//
//       f_sync_type       0 to 4        default: 2
//                                       Forward Synchronization Type (Source to Destination Domains)
//                                         0 => no synchronization, single clock system
//                                         1 => 2-stage synchronization w/ 1st stage neg-edge & 2nd stage pos-edge capturing
//                                         2 => 2-stage synchronization w/ both stages pos-edge capturing
//                                         3 => 3-stage synchronization w/ all stages pos-edge capturing
//                                         4 => 4-stage synchronization w/ all stages pos-edge capturing
//
//       reg_stat          0 or 1        default: 1
//                                       Register internally calculated status
//                                         0 => don't register internally calculated status
//                                         1 => register internally calculated status
//
//       tst_mode          0 or 2        default: 0
//                                       Insert neg-edge hold latch at front-end of synchronizers during "test"
//                                         0 => no hold latch inserted,
//                                         1 => insert hold 'latch' using a neg-edge triggered register
//                                         2 => insert hold latch using an active low latch
//
//       verif_en          0 to 4        default: 1
//                                       Enable missampling of synchronized signals during simulation
//                                         0 => no sampling errors inserted,
//                                         1 => sampling errors are randomly inserted with 0 or up to 1 destination clock cycle delays
//                                         2 => sampling errors are randomly inserted with 0, 0.5, 1, or 1.5 destination clock cycle delays
//                                         3 => sampling errors are randomly inserted with 0, 1, 2, or 3 destination clock cycle delays
//                                         4 => sampling errors are randomly inserted with 0 or up to 0.5 destination clock cycle delays
//
//       r_sync_type       0 to 4        default: 2
//                                       Reverse Synchronization Type (Destination to Source Domains)
//                                         0 => no synchronization, single clock system
//                                         1 => 2-stage synchronization w/ 1st stage neg-edge & 2nd stage pos-edge capturing
//                                         2 => 2-stage synchronization w/ both stages pos-edge capturing
//                                         3 => 3-stage synchronization w/ all stages pos-edge capturing
//                                         4 => 4-stage synchronization w/ all stages pos-edge capturing
//
//       clk_d_faster      0 to 15       default: 1
//                                       clk_d faster than clk_s by difference ratio
//                                         0        => Either clr_s or clr_d active with the other tied low at input
//                                         1 to 15  => ratio of clk_d to clk_s frequencies plus 1
//
//       reg_in_prog       0 or 1        default: 1
//                                       Register the 'clr_in_prog_s' and 'clr_in_prog_d' Outputs
//                                         0 => unregistered
//                                         1 => registered
//
//       Input Ports:    Size     Description
//       ===========     ====     ===========
//       clk_s           1 bit    Source Domain Input Clock
//       rst_s_n         1 bit    Source Domain Active Low Async. Reset
//       init_s_n        1 bit    Source Domain Active Low Sync. Reset
//       clr_s           1 bit    Source Domain Internal Logic Clear (reset)
//       send_s          1 bit    Source Domain Active High Send Request
//       data_s          N bits   Source Domain Data
//
//       clk_d           1 bit    Destination Domain Input Clock
//       rst_d_n         1 bit    Destination Domain Active Low Async. Reset
//       init_d_n        1 bit    Destination Domain Active Low Sync. Reset
//       clr_d           1 bit    Destination Domain Internal Logic Clear (reset)
//       prefill_d       1 bit    Destination Domain Prefill Control
//
//       test            1 bit    Test input
//
//       Output Ports    Size     Description
//       ============    ====     ===========
//       clr_sync_d      1 bit    Source Domain Clear
//       clr_in_prog_s   1 bit    Source Domain Clear in Progress
//       clr_cmplt_s     1 bit    Soruce Domain Clear Complete (pulse)
//
//       clr_in_prog_d   1 bit    Destination Domain Clear in Progress
//       clr_sync_d      1 bit    Destination Domain Clear (pulse)
//       clr_cmplt_d     1 bit    Destination Domain Clear Complete (pulse)
//       data_avail_d    1 bit    Destination Domain Data Available
//       data_d          N bits   Destination Domain Data
//       prefilling_d    1 bit    Destination Domain Prefillng Status
//
//          Note: (1) The value of N is equal to the 'width' parameter value
//
//
// MODIFIED:
//  07/25/11 DLL  Removed or-ing of 'clr_in_prog_d' with 'init_d_n' that
//                wires to DW_sync 'init_d_n' input port.
//                Added checking and comments for tst_mode = 2.
//
//  10/20/06 DLL  Updated with new version of DW_reset_sync
//
//  11/15/06 DLL  Added 4-stage synchronization capability
//
//  7/13/09  DLL  Changed all `define declarations to have the
//                "DW_" prefix and then `undef them at the approprite time.
//
//
//
module DW_stream_sync (
    clk_s,
    rst_s_n,
    init_s_n,
    clr_s,
    send_s,
    data_s,
    clr_sync_s,
    clr_in_prog_s,
    clr_cmplt_s,

    clk_d,
    rst_d_n,
    init_d_n,
    clr_d,
    prefill_d,
    clr_in_prog_d,
    clr_sync_d,
    clr_cmplt_d,
    data_avail_d,
    data_d,
    prefilling_d,

    test
    );

parameter width        = 8;  // RANGE 1 to 1024
parameter depth        = 4;  // RANGE 2 to 256
parameter prefill_lvl  = 0;  // RANGE 0 to 255
parameter f_sync_type  = 2;  // RANGE 0 to 4
parameter reg_stat     = 1;  // RANGE 0 to 1
parameter tst_mode     = 0;  // RANGE 0 to 2
parameter verif_en     = 1;  // RANGE 0 to 4
parameter r_sync_type  = 2;  // RANGE 0 to 4
parameter clk_d_faster = 1;  // RANGE 0 to 15
parameter reg_in_prog  = 1;  // RANGE 0 to 1

localparam cnt_depth     = ((depth>16)?((depth>64)?((depth>128)?8:7):((depth>32)?6:5)):((depth>4)?((depth>8)?4:3):((depth>2)?2:1)));
localparam sync_verif_en = (verif_en == 2) ? 4 : (verif_en == 3) ? 1 : verif_en;


input                   clk_s;         // clock input from source domain
input                   rst_s_n;       // active low asynchronous reset from source domain
input                   init_s_n;      // active low synchronous reset from source domain
input                   clr_s;         // active high clear from source domain
input                   send_s;        // active high send request from source domain
input  [width-1:0]      data_s;        // data to be synchronized from source domain
output                  clr_sync_s;    // clear to source domain sequential devices
output                  clr_in_prog_s; // clear in progress status to source domain
output                  clr_cmplt_s;   // clear sequence complete (pulse)

input                   clk_d;         // clock input from destination domain
input                   rst_d_n;       // active low asynchronous reset from destination domain
input                   init_d_n;      // active low synchronous reset from destination domain
input                   clr_d;         // active high clear from destination domain
input                   prefill_d;     // active high prefill control from destination domain
output                  clr_in_prog_d; // clear in progress status to source domain
output                  clr_sync_d;    // clear to destination domain sequential devices (pulse)
output                  clr_cmplt_d;   // clear sequence complete (pulse)
output                  data_avail_d;  // data available to destination domain
output [width-1:0]      data_d;        // data synchronized to destination domain
output                  prefilling_d;  // prefilling status to destination domain

input                   test;          // test input

// synopsys translate_off


  //-------------------------------------------------------------------------
  // Parameter legality check
  //-------------------------------------------------------------------------
  
 
  initial begin : parameter_check
    integer param_err_flg;

    param_err_flg = 0;
    
  
    if ( (depth < 2) || (depth > 256) ) begin
      param_err_flg = 1;
      $display(
	"ERROR: %m :\n  Invalid value (%d) for parameter depth (legal range: 2 to 256)",
	depth );
    end
  
    if ( (prefill_lvl < 0) || (prefill_lvl > depth-1) ) begin
      param_err_flg = 1;
      $display(
	"ERROR: %m :\n  Invalid value (%d) for parameter prefill_lvl (legal range: 0 to depth-1)",
	prefill_lvl );
    end
  
    if ( ((f_sync_type & 7) < 0) || ((f_sync_type & 7) > 4) ) begin
      param_err_flg = 1;
      $display(
	"ERROR: %m :\n  Invalid value (%d) for parameter (f_sync_type & 7) (legal range: 0 to 4)",
	(f_sync_type & 7) );
    end
  
    if ( (reg_stat < 0) || (reg_stat > 1) ) begin
      param_err_flg = 1;
      $display(
	"ERROR: %m :\n  Invalid value (%d) for parameter reg_stat (legal range: 0 to 1)",
	reg_stat );
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
  
    if ( ((r_sync_type & 7) < 0) || ((r_sync_type & 7) > 4) ) begin
      param_err_flg = 1;
      $display(
	"ERROR: %m :\n  Invalid value (%d) for parameter (r_sync_type & 7) (legal range: 0 to 4)",
	(r_sync_type & 7) );
    end
  
    if ( (clk_d_faster < 0) || (clk_d_faster > 15) ) begin
      param_err_flg = 1;
      $display(
	"ERROR: %m :\n  Invalid value (%d) for parameter clk_d_faster (legal range: 0 to 15)",
	clk_d_faster );
    end
  
    if ( (reg_in_prog < 0) || (reg_in_prog > 1) ) begin
      param_err_flg = 1;
      $display(
	"ERROR: %m :\n  Invalid value (%d) for parameter reg_in_prog (legal range: 0 to 1)",
	reg_in_prog );
    end
  
    if ( param_err_flg == 1) begin
      $display(
        "%m :\n  Simulation aborted due to invalid parameter value(s)");
      $finish;
    end

  end // parameter_check 


  wire                   next_data_avail_d_int;
  reg                    data_avail_d_int;
  wire  [width-1:0]      next_data_d_int;
  reg   [width-1:0]      data_d_int;
  wire                   next_prefilling_d_int;
  reg                    prefilling_d_int;

  reg   [width-1:0]      data_mem  [0:depth-1];

  wire  [cnt_depth-1:0]  next_wr_ptr_s;
  reg   [cnt_depth-1:0]  wr_ptr_s;
  wire  [cnt_depth-1:0]  next_rd_ptr_d;
  reg   [cnt_depth-1:0]  rd_ptr_d;

  reg   [cnt_depth-1:0] next_valid_cnt; 
  reg   [cnt_depth-1:0] valid_cnt; 

  wire  [depth-1:0]      next_event_vec_s;
  reg   [depth-1:0]      event_vec_s;
  reg   [depth-1:0]      event_vec_l;
  wire  [depth-1:0]      event_vec_selected;
  wire  [depth-1:0]      dw_sync_event_vec;

  wire                   next_detect_lvl;
  reg                    detect_lvl;

  wire [31:0]            one;
  
  integer   i, idx;

  assign one = 1;


  initial begin
    if ((f_sync_type > 0)&&(f_sync_type < 8))
      $display("Information: *** Instance %m is the DW_stream_sync Clock Domain Crossing Module ***");
  end



DW_reset_sync #((f_sync_type + 8), (r_sync_type + 8), clk_d_faster, reg_in_prog, tst_mode, verif_en) U_RST_SYNC (
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



always @(posedge clk_s or negedge rst_s_n) begin : a1001_PROC
  if (rst_s_n == 1'b0) begin
    for (idx = 0; idx < depth; idx = idx + 1) begin
      data_mem[idx] <= {width{1'b0}};
    end
  end else begin
    if (!init_s_n || clr_in_prog_s) begin
      for (idx = 0; idx < depth; idx = idx + 1) begin
        data_mem[idx] <= {width{1'b0}};
      end
    end else begin
      if (send_s === 1'b1)
        data_mem[wr_ptr_s] <= data_s;
      else if (send_s === 1'b0)
        data_mem[wr_ptr_s] <= data_mem[wr_ptr_s];
      else
        data_mem[wr_ptr_s] <= {width{1'bX}};
    end
  end

  if ((wr_ptr_s ^ wr_ptr_s) !== {cnt_depth{1'b0}}) begin
    for (idx = 0; idx < depth; idx = idx + 1) begin
      data_mem[idx] <= {width{1'bX}};
    end
  end
end 

assign next_wr_ptr_s  = (send_s === 1'b1) ? ((wr_ptr_s === depth-1) ? {cnt_depth{1'b0}} : wr_ptr_s + one[cnt_depth-1:0]) :
                          (send_s === 1'b0) ?  wr_ptr_s : {cnt_depth{1'bX}};

assign  next_event_vec_s = (send_s === 1'b1) ? {event_vec_s[depth-2:0], ~event_vec_s[depth-1]} : 
			     (send_s === 1'b0) ? event_vec_s : {depth{1'bX}};


  
generate
  if (((f_sync_type&7)>1)&&(tst_mode==2)) begin : GEN_LATCH_hold_latch_PROC
    reg [depth-1:0] event_vec_l;
    always @ (clk_s or event_vec_s) begin : LATCH_hold_latch_PROC_PROC

      if (clk_s == 1'b0)

	event_vec_l = event_vec_s;


    end // LATCH_hold_latch_PROC_PROC


    assign event_vec_selected = (test==1'b1)? event_vec_l : event_vec_s;

  end else begin : GEN_DIRECT_hold_latch_PROC
    assign event_vec_selected = event_vec_s;
  end
endgenerate

  DW_sync #(depth, f_sync_type+8, tst_mode, sync_verif_en) U_SYNC(
	.clk_d(clk_d),
	.rst_d_n(rst_d_n),
	.init_d_n(init_d_n),
	.data_s(event_vec_selected),
	.test(test),
	.data_d(dw_sync_event_vec) );

always @(dw_sync_event_vec or next_valid_cnt or rd_ptr_d) begin : a1002_PROC
  next_valid_cnt = {cnt_depth{1'b0}};
  for (i = 0; i < depth; i = i + 1) begin
    if (rd_ptr_d > i) begin
      next_valid_cnt = next_valid_cnt + (dw_sync_event_vec[i] === ~detect_lvl);
    end else begin
      next_valid_cnt = next_valid_cnt + (dw_sync_event_vec[i] === detect_lvl);
    end
    if (dw_sync_event_vec[i] === 1'bX)
      next_valid_cnt = {cnt_depth{1'b0}};
  end
end


assign next_rd_ptr_d = next_data_avail_d_int ? ((rd_ptr_d === depth-1) ? {cnt_depth{1'b0}} : (rd_ptr_d + one[cnt_depth-1:0])) :
                          rd_ptr_d;

assign next_detect_lvl = (next_data_avail_d_int && (next_rd_ptr_d === {cnt_depth{1'b0}})) ?
                           ~detect_lvl : detect_lvl;


assign next_prefilling_d_int = ((prefill_d === 1'bX) || (prefilling_d_int === 1'bX)) ? 1'bX : 
			  	 (prefill_lvl == 0) ? 1'b0 :
                                   ((prefill_d === 1'b1) && (prefill_lvl > (reg_stat ? valid_cnt : next_valid_cnt))) ? 1'b1 :
                                     (prefill_lvl <= (reg_stat ? valid_cnt : next_valid_cnt)) ? 1'b0 : prefilling_d_int;

assign next_data_avail_d_int = ((dw_sync_event_vec[rd_ptr_d] === 1'bX) || (next_prefilling_d_int === 1'bX)) ? 1'bX : 
				 (next_prefilling_d_int === 1'b0) && (detect_lvl === dw_sync_event_vec[rd_ptr_d]) ? 1'b1 : 1'b0;

assign next_data_d_int       = (next_data_avail_d_int === 1'bX) ? {width{1'bX}} :
				 (next_data_avail_d_int === 1'b1) ? data_mem[rd_ptr_d] : data_d_int;


  always @(posedge clk_s or negedge rst_s_n) begin : a1003_PROC
    if (rst_s_n === 1'b0) begin
      wr_ptr_s        <= {cnt_depth{1'b0}};
      event_vec_s     <= {depth{1'b0}};
    end else if (rst_s_n === 1'b1) begin
      if ((init_s_n === 1'b0) || (clr_in_prog_s === 1'b1)) begin
        wr_ptr_s        <= {cnt_depth{1'b0}};
        event_vec_s     <= {depth{1'b0}};
      end else if (init_s_n === 1'b1) begin
        wr_ptr_s        <= next_wr_ptr_s;
        event_vec_s     <= next_event_vec_s;
      end else begin
        wr_ptr_s        <= {cnt_depth{1'bX}};
        event_vec_s     <= {depth{1'bX}};
      end
    end else begin
      wr_ptr_s        <= {cnt_depth{1'bX}};
      event_vec_s     <= {depth{1'bX}};
    end
  end

  always @(posedge clk_d or negedge rst_d_n) begin : a1004_PROC
    if (rst_d_n === 1'b0) begin
      rd_ptr_d           <= {cnt_depth{1'b0}};
      valid_cnt          <= {cnt_depth{1'b0}};
      detect_lvl         <= 1'b1;
      data_avail_d_int   <= 1'b0;
      data_d_int         <= {width{1'b0}};
      prefilling_d_int   <= 1'b0;
    end else if (rst_d_n === 1'b1) begin
      if ((init_d_n === 1'b0) || (clr_in_prog_d === 1'b1)) begin
        rd_ptr_d           <= {cnt_depth{1'b0}};
        valid_cnt          <= {cnt_depth{1'b0}};
        detect_lvl         <= 1'b1;
        data_avail_d_int   <= 1'b0;
        data_d_int         <= {width{1'b0}};
        prefilling_d_int   <= 1'b0;
      end else if (init_d_n === 1'b1) begin
        rd_ptr_d           <= next_rd_ptr_d;
        valid_cnt          <= next_valid_cnt;
        detect_lvl         <= next_detect_lvl;
        data_avail_d_int   <= next_data_avail_d_int;
        data_d_int         <= next_data_d_int;
        prefilling_d_int   <= next_prefilling_d_int;
      end else begin
        rd_ptr_d           <= {cnt_depth{1'bX}};
        valid_cnt          <= {cnt_depth{1'bX}};
        detect_lvl         <= 1'bX;
        data_avail_d_int   <= 1'bX;
        data_d_int         <= {width{1'bX}};
        prefilling_d_int   <= 1'bX;
      end
    end else begin
      rd_ptr_d           <= {cnt_depth{1'bX}};
      valid_cnt          <= {cnt_depth{1'bX}};
      detect_lvl         <= 1'bX;
      data_avail_d_int   <= 1'bX;
      data_d_int         <= {width{1'bX}};
      prefilling_d_int   <= 1'bX;
    end
  end

  assign data_avail_d    = data_avail_d_int;
  assign data_d          = data_d_int;
  assign prefilling_d    = prefilling_d_int;


  
  always @ (clk_s) begin : monitor_clk_s 
    if ( (clk_s !== 1'b0) && (clk_s !== 1'b1) && ($time > 0) )
      $display( "WARNING: %m :\n  at time = %t, detected unknown value, %b, on clk_s input.",
                $time, clk_s );
    end // monitor_clk_s 
  
  always @ (clk_d) begin : monitor_clk_d 
    if ( (clk_d !== 1'b0) && (clk_d !== 1'b1) && ($time > 0) )
      $display( "WARNING: %m :\n  at time = %t, detected unknown value, %b, on clk_d input.",
                $time, clk_d );
    end // monitor_clk_d 

// synopsys translate_on
endmodule
