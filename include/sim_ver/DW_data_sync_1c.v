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
// AUTHOR:    Doug Lee         5/10/05
//
// VERSION:   Simulation Architecture
//
// DesignWare_version: d5fd5383
// DesignWare_release: K-2015.06-DWBB_201506.5.2
//
////////////////////////////////////////////////////////////////////////////////
//
// ABSTRACT: Single Clock Data Bus Synchronizer Simulation Model
//
//           This synchronizes incoming data into the destination domain
//           with a configurable number of sampling stages and consecutive
//           samples of stable data values.
//
//              Parameters:     Valid Values
//              ==========      ============
//              width           [ 1 to 1024 : width of data_s and data_d ports ]
//              f_sync_type     [ 0 = single clock design, no synchronizing stages implemented,
//                                1 = 2-stage synchronization w/ 1st stage neg-edge & 2nd stage pos-edge capturing,
//                                2 = 2-stage synchronization w/ both stages pos-edge capturing,
//                                3 = 3-stage synchronization w/ all stages pos-edge capturing,
//                                4 = 4-stage synchronization w/ all stages pos-edge capturing ]
//              filt_size       [ 1 to 8 : width of filt_d input port ]
//              tst_mode        [ 0 = no hold latch inserted,
//                                1 = insert hold 'latch' using a neg-edge triggered register ]
//              verif_en        [ 0 = no sampling errors inserted,
//                                1 = sampling errors are randomly inserted with 0 or up to 1 destination clock cycle delays
//                                2 = sampling errors are randomly inserted with 0, 0.5, 1, or 1.5 destination clock cycle delays
//                                3 = sampling errors are randomly inserted with 0, 1, 2, or 3 destination clock cycle delays
//                                4 = sampling errors are randomly inserted with 0 or up to 0.5 destination clock cycle delays ]
//
//              Input Ports:    Size     Description
//              ===========     ====     ===========
//              clk_d           1 bit    Destination Domain Input Clock
//              rst_d_n         1 bit    Destination Domain Active Low Async. Reset
//              init_d_n        1 bit    Destination Domain Active Low Sync. Reset
//              data_s          N bits   Source Domain Data Input
//              filt_d          M bits   Destination Domain filter defining the number of clk_d cycles required to declare stable data
//              test            1 bit    Test input
//
//              Output Ports    Size     Description
//              ============    ====     ===========
//              data_avail_d    1 bit    Destination Domain Data Available Output
//              data_d          N bits   Destination Domain Data Output
//              max_skew_d      M+1 bits Destination Domain maximum skew detected between bits for any data_s bus transition
//
//                Note: (1) The value of M is equal to the 'filt_size' parameter value
//                      (2) The value of N is equal to the 'width' parameter value
//
//
// MODIFIED:
//              DLL  6/14/06  Cleaned up excessive use of 'To_X01' on input signals
//
//              DLL  11/15/06 Added 4-stage synchronization capability
//
//              DLL  3/10/10  Re-wrote to be more robust across different simulators
//                            Addresses STAR#9000378342.
//
//
module DW_data_sync_1c (
    clk_d,
    rst_d_n,
    init_d_n,
    data_s,
    filt_d,
    test,
    data_avail_d,
    data_d,
    max_skew_d
    );

parameter width        = 8;  // RANGE 1 to 1024
parameter f_sync_type  = 2;  // RANGE 0 to 4
parameter filt_size    = 1;  // RANGE 1 to 8
parameter tst_mode     = 0;  // RANGE 0 to 1
parameter verif_en     = 2;  // RANGE 0 to 4

input                   clk_d;         // clock input from destination domain
input                   rst_d_n;       // active low asynchronous reset from destination domain
input                   init_d_n;      // active low synchronous reset from destination domain
input  [width-1:0]      data_s;        // data to be synchronized from source domain
input  [filt_size-1:0]  filt_d;        // filter determining the number of clk_d cycles required to declare stable data to destination domain
input                   test;          // test input
output                  data_avail_d;  // data available to destination domain
output [width-1:0]      data_d;        // data synchronized to destination domain
output [filt_size:0]    max_skew_d;    // maximum skew detected between bits for any data_s bus transition

// synopsys translate_off



  //-------------------------------------------------------------------------
  // Parameter legality check
  //-------------------------------------------------------------------------
  
 
  initial begin : parameter_check
    integer param_err_flg;

    param_err_flg = 0;
    
  
    if ( (width < 1) || (width > 1024) ) begin
      param_err_flg = 1;
      $display(
	"ERROR: %m :\n  Invalid value (%d) for parameter width (legal range: 1 to 1024)",
	width );
    end
  
    if ( ((f_sync_type & 7) < 0) || ((f_sync_type & 7) > 4) ) begin
      param_err_flg = 1;
      $display(
	"ERROR: %m :\n  Invalid value (%d) for parameter (f_sync_type & 7) (legal range: 0 to 4)",
	(f_sync_type & 7) );
    end
  
    if ( (filt_size < 1) || (filt_size > 8) ) begin
      param_err_flg = 1;
      $display(
	"ERROR: %m :\n  Invalid value (%d) for parameter filt_size (legal range: 1 to 8)",
	filt_size );
    end
  
    if ( (tst_mode < 0) || (tst_mode > 1) ) begin
      param_err_flg = 1;
      $display(
	"ERROR: %m :\n  Invalid value (%d) for parameter tst_mode (legal range: 0 to 1)",
	tst_mode );
    end
  
    if ( (verif_en < 0) || (verif_en > 4) ) begin
      param_err_flg = 1;
      $display(
	"ERROR: %m :\n  Invalid value (%d) for parameter verif_en (legal range: 0 to 4)",
	verif_en );
    end
  
    if ( param_err_flg == 1) begin
      $display(
        "%m :\n  Simulation aborted due to invalid parameter value(s)");
      $finish;
    end

  end // parameter_check 


  reg  [width-1:0]       data_d_int;
  wire [width-1:0]       next_data_d_int;
  reg                    data_avail_d_int;
  wire                   next_data_avail_d_int;
  reg  [filt_size:0]     max_skew_d_int;
  wire [filt_size:0]     next_max_skew_d_int;

  reg                    counting_state;
  wire                   next_counting_state;
  reg  [filt_size-1:0]   diff_counter;
  wire [filt_size-1:0]   next_diff_counter;
  reg  [filt_size:0]     skew_counter;
  wire [filt_size:0]     next_skew_counter;

  wire                   greater_skew;

  wire                   differ;
  wire [width-1:0]       dw_sync_data_d;
  reg  [width-1:0]       dw_sync_data_d1;

  wire [31:0]            one;

  assign one = {{32-1{1'b0}},1'b1};



  initial begin
    if ((f_sync_type > 0)&&(f_sync_type < 8))
      $display("Information: *** Instance %m is the DW_data_sync_1c Clock Domain Crossing Module ***");
  end


DW_sync #(width, (f_sync_type + 8), tst_mode, verif_en) U_SYNC (
            .clk_d(clk_d),
            .rst_d_n(rst_d_n),
            .init_d_n(init_d_n),
            .data_s(data_s),
            .test(test),
            .data_d(dw_sync_data_d)
            );


  assign differ = dw_sync_data_d !== dw_sync_data_d1;

  assign next_counting_state = (differ == 1'b1)? 1'b1 :
                                 (((differ == 1'b0) && (counting_state == 1'b1) && (diff_counter == filt_d)) ||
                                  ((counting_state == 1'b1) && (filt_d == {filt_size{1'b0}})) ||
                                  (diff_counter > filt_d)) ? 1'b0 :
                                    counting_state;

  assign next_diff_counter = ((diff_counter > filt_d) || 
                              ((counting_state == 1'b1) && (diff_counter == filt_d) && (differ == 1'b0))) ? {filt_size{1'b0}} :
                                (differ == 1'b1) ? one[filt_size-1:0] :
                                  (counting_state == 1'b1) ? diff_counter + one[filt_size-1:0] :
                                    {filt_size{1'b0}};


  assign next_skew_counter = (((counting_state == 1'b0) && (differ == 1'b0)) ||
                              (next_counting_state == 1'b0) || (diff_counter > filt_d)) ? {filt_size+1{1'b0}} :
                                 skew_counter + one[filt_size:0];


  assign next_data_d_int   = (^filt_d === 1'bX) ? {width{1'bX}} : 
			       ( (filt_d === 0) || ((counting_state === 1) &&
				 (diff_counter === filt_d) && (differ === 1'b0)) ) ? dw_sync_data_d : data_d_int;

  assign next_data_avail_d_int = (^filt_d === 1'bX) ? 1'bX :
				   (filt_d === 0) ? differ : ((counting_state === 1'b1) && (diff_counter === filt_d) && (differ === 1'b0));

  assign greater_skew = skew_counter > max_skew_d_int;
  assign next_max_skew_d_int = ((f_sync_type & 7) === 0) ? {(filt_size+1){1'b0}} :
				((differ === 1) && greater_skew) ? skew_counter : max_skew_d_int;

  always @(posedge clk_d or negedge rst_d_n) begin : a1000_PROC
    if (rst_d_n === 1'b0) begin
      dw_sync_data_d1  <= {width{1'b0}};
      counting_state   <= 1'b0;
      data_d_int       <= {width{1'b0}}; 
      data_avail_d_int <= 1'b0;
      max_skew_d_int   <= {filt_size+1{1'b0}};
      diff_counter     <= {filt_size{1'b0}};
      skew_counter     <= {filt_size+1{1'b0}};
    end else if (rst_d_n === 1'b1) begin
      if (init_d_n === 1'b0) begin
        dw_sync_data_d1  <= {width{1'b0}};
        counting_state   <= 1'b0;
        data_d_int       <= {width{1'b0}}; 
        data_avail_d_int <= 1'b0;
        max_skew_d_int   <= {filt_size+1{1'b0}};
        diff_counter     <= {filt_size{1'b0}};
        skew_counter     <= {filt_size+1{1'b0}};
      end else if (init_d_n === 1'b1) begin
        dw_sync_data_d1  <= dw_sync_data_d;
        counting_state   <= next_counting_state;
        data_d_int       <= next_data_d_int;
        data_avail_d_int <= next_data_avail_d_int;
        max_skew_d_int   <= next_max_skew_d_int;
        diff_counter     <= next_diff_counter;
        skew_counter     <= next_skew_counter;
      end else begin
        dw_sync_data_d1  <= {width{1'bX}};
        counting_state   <= 1'bX;
        data_d_int       <= {width{1'bX}};
        data_avail_d_int <= 1'bX;
        max_skew_d_int   <= {filt_size+1{1'bX}};
        diff_counter     <= {filt_size{1'bX}};
        skew_counter     <= {filt_size+1{1'bX}};
      end
    end else begin
      dw_sync_data_d1  <= {width{1'bX}};
      counting_state   <= 1'bX;
      data_d_int       <= {width{1'bX}}; 
      data_avail_d_int <= 1'bX;
      max_skew_d_int   <= {filt_size+1{1'bX}};
      diff_counter     <= {filt_size{1'bX}};
      skew_counter     <= {filt_size+1{1'bX}};
    end
  end

  assign data_d         = data_d_int;
  assign data_avail_d   = data_avail_d_int;
  assign max_skew_d     = max_skew_d_int;

  
  always @ (clk_d) begin : monitor_clk_d 
    if ( (clk_d !== 1'b0) && (clk_d !== 1'b1) && ($time > 0) )
      $display( "WARNING: %m :\n  at time = %t, detected unknown value, %b, on clk_d input.",
                $time, clk_d );
    end // monitor_clk_d 

// synopsys translate_on
endmodule
