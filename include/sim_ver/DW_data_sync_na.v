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
// AUTHOR:    Doug Lee         6/14/05
//
// VERSION:   Simulation Architecture
//
// DesignWare_version: 5e0abc7b
// DesignWare_release: K-2015.06-DWBB_201506.5.2
//
////////////////////////////////////////////////////////////////////////////////
//
// ABSTRACT: Data Bus Synchronizer without acknowledge Simulation Model
//
//
//           This synchronizer passes data values from the source domain to the destination domain.
//           Full feedback hand-shake is NOT used. So there is no busy or done status on in the source domain.
//
//              Parameters:     Valid Values
//              ==========      ============
//              width           [ default : 8
//                                1 to 1024 : width of data_s and data_d ports ]
//              f_sync_type     [ default : 2
//                                0 = single clock design, no synchronizing stages implemented,
//                                1 = 2-stage synchronization w/ 1st stage neg-edge & 2nd stage pos-edge capturing,
//                                2 = 2-stage synchronization w/ both stages pos-edge capturing,
//                                3 = 3-stage synchronization w/ all stages pos-edge capturing,
//                                4 = 4-stage synchronization w/ all stages pos-edge capturing ]
//              tst_mode        [ default : 0
//                                0 = no hold latch inserted,
//                                1 = insert hold 'latch' using a neg-edge triggered register ]
//              verif_en        [ default : 1
//                                0 = no sampling errors inserted,
//                                1 = sampling errors are randomly inserted with 0 or up to 1 destination clock cycle delays
//                                2 = sampling errors are randomly inserted with 0, 0.5, 1, or 1.5 destination clock cycle delays
//                                3 = sampling errors are randomly inserted with 0, 1, 2, or 3 destination clock cycle delays
//                                4 = sampling errors are randomly inserted with 0 or up to 0.5 destination clock cycle delays ]
//              send_mode       [ default: 0 (send_s detection control)
//                                0 = every clock cycle of send_s asserted invokes
//                                    a data transfer to destination domain
//                                1 = rising edge transition of send_s invokes
//                                    a data transfer to destination domain
//                                2 = falling edge transition of send_s invokes
//                                    a data transfer to destination domain
//                                3 = every toggle transition of send_s invokes
//                                    a data transfer to destination domain ]
//
//
//              Input Ports:    Size     Description
//              ===========     ====     ===========
//              clk_s           1 bit    Source Domain Input Clock
//              rst_s_n         1 bit    Source Domain Active Low Async. Reset
//              init_s_n        1 bit    Source Domain Active Low Sync. Reset
//              send_s          1 bit    Source Domain Active High Send Request
//              data_s          N bits   Source Domain Data Input
//              clk_d           1 bit    Destination Domain Input Clock
//              rst_d_n         1 bit    Destination Domain Active Low Async. Reset
//              init_d_n        1 bit    Destination Domain Active Low Sync. Reset
//              test            1 bit    Test input
//
//              Output Ports    Size     Description
//              ============    ====     ===========
//              data_avail_d    1 bit    Destination Domain Data Available Output
//              data_d          N bits   Destination Domain Data Output
//
//                Note: (1) The value of N is equal to the 'width' parameter value
//
//
//
// MODIFIED:
//
//              DLL  11/15/06 Added 4-stage synchronization capability
//
//              DLL  6/12/06  Cleaned up 'to_X01' processing
//
//              DLL  6/8/06   Added send_mode parameter and functionality
//
//
module DW_data_sync_na (
    clk_s,
    rst_s_n,
    init_s_n,
    send_s,
    data_s,
    clk_d,
    rst_d_n,
    init_d_n,
    test,
    data_avail_d,
    data_d
    );

parameter width        = 8;  // RANGE 1 to 1024
parameter f_sync_type  = 2;  // RANGE 0 to 4
parameter tst_mode     = 0;  // RANGE 0 to 1
parameter verif_en     = 1;  // RANGE 0 to 4
parameter send_mode    = 0;  // RANGE 0 to 3

input                   clk_s;         // clock input from source domain
input                   rst_s_n;       // active low asynchronous reset from source domain
input                   init_s_n;      // active low synchronous reset from source domain
input                   send_s;        // active high send request from source domain
input  [width-1:0]      data_s;        // data to be synchronized from source domain
input                   clk_d;         // clock input from destination domain
input                   rst_d_n;       // active low asynchronous reset from destination domain
input                   init_d_n;      // active low synchronous reset from destination domain
input                   test;          // test input
output                  data_avail_d;  // data available to destination domain
output [width-1:0]      data_d;        // data synchronized to destination domain


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
  
    if ( (send_mode < 0) || (send_mode > 3) ) begin
      param_err_flg = 1;
      $display(
	"ERROR: %m :\n  Invalid value (%d) for parameter send_mode (legal range: 0 to 3)",
	send_mode );
    end
  
    if ( param_err_flg == 1) begin
      $display(
        "%m :\n  Simulation aborted due to invalid parameter value(s)");
      $finish;
    end

  end // parameter_check 


  reg                    send_s_int_reg;   // send_s history register
  wire                   send_s_sel;       // conditioned 'send_s' based on 'send_mode'

  reg  [width-1:0]       data_s_hold;
  wire [width-1:0]       next_data_s_hold;

  reg  [width-1:0]       data_d_int;
  wire [width-1:0]       next_data_d_int;
  reg                    data_avail_d_int;
  wire                   next_data_avail_d_int;

  wire                   dw_pulse_sync_event_d;



  initial begin
    if ((f_sync_type > 0)&&(f_sync_type < 8))
      $display("Information: *** Instance %m is the DW_data_sync_na Clock Domain Crossing Module ***");
  end



DW_pulse_sync #(0, (f_sync_type + 8), tst_mode, verif_en, send_mode) U_PULSE_SYNC (
            .clk_s(clk_s),
            .rst_s_n(rst_s_n),
            .init_s_n(init_s_n),
            .event_s(send_s),
            .clk_d(clk_d),
            .rst_d_n(rst_d_n),
            .init_d_n(init_d_n),
            .test(test),
            .event_d(dw_pulse_sync_event_d)
            );

  assign send_s_sel       = (send_mode == 0) ? ((send_s | (send_s ^ send_s))) :
                              ((send_mode == 1) ? (send_s && !send_s_int_reg) :
                                ((send_mode == 2) ? (!send_s && send_s_int_reg) :
                                  ((send_s ^ send_s_int_reg))));

  assign next_data_s_hold      = (send_s_sel === 1'b1) ? ((data_s | (data_s ^ data_s))) : 
				   (send_s_sel === 1'b0) ? data_s_hold : {width{1'bX}};

  assign next_data_avail_d_int = dw_pulse_sync_event_d;
  assign next_data_d_int       = (next_data_avail_d_int === 1'b1) ? data_s_hold : data_d_int;


  always @(posedge clk_s or negedge rst_s_n) begin : a1000_PROC
    if (rst_s_n === 1'b0) begin
      send_s_int_reg   <= 1'b0;
      data_s_hold      <= {width{1'b0}}; 
    end else if (rst_s_n === 1'b1) begin
      if (init_s_n === 1'b0) begin
        send_s_int_reg   <= 1'b0;
        data_s_hold      <= {width{1'b0}}; 
      end else if (init_s_n === 1'b1) begin
        send_s_int_reg   <= ((send_s | (send_s ^ send_s)));
        data_s_hold      <= next_data_s_hold;
      end else begin
        send_s_int_reg   <= 1'bX;
        data_s_hold      <= {width{1'bX}}; 
      end
    end else begin
      send_s_int_reg   <= 1'bX;
      data_s_hold      <= {width{1'bX}}; 
    end
  end

  always @(posedge clk_d or negedge rst_d_n) begin : a1001_PROC
    if (rst_d_n === 1'b0) begin
      data_d_int       <= {width{1'b0}}; 
      data_avail_d_int <= 1'b0;
    end else if (rst_d_n === 1'b1) begin
      if (init_d_n === 1'b0) begin
        data_d_int       <= {width{1'b0}}; 
        data_avail_d_int <= 1'b0;
      end else if (init_d_n === 1'b1) begin
        data_d_int       <= next_data_d_int;
        data_avail_d_int <= next_data_avail_d_int;
      end else begin
        data_d_int       <= {width{1'bX}};
        data_avail_d_int <= 1'bX;
      end
    end else begin
      data_d_int       <= {width{1'bX}}; 
      data_avail_d_int <= 1'bX;
    end
  end

  assign data_d         = data_d_int;
  assign data_avail_d   = data_avail_d_int;


  reg    [width-1:0]    data_s_hold_clk_d1;
  wire                  data_d_setup_violation;

  always @(posedge clk_d or negedge rst_d_n) begin : a1002_PROC
    if (rst_d_n == 1'b0) begin
      data_s_hold_clk_d1       <= {width{1'b0}}; 
    end else if (init_d_n == 1'b0) begin
      data_s_hold_clk_d1       <= {width{1'b0}}; 
    end else begin
      data_s_hold_clk_d1       <= data_s_hold;
    end
  end

  assign data_d_setup_violation = (f_sync_type != 0) && (data_s_hold !== data_s_hold_clk_d1) && (next_data_avail_d_int) &&
				  init_s_n && rst_s_n && init_d_n && rst_d_n;
  always @(posedge data_d_setup_violation)
      $display($stime,,"%m: WARNING: #### 'data_d' output register setup-time violation.  Captured data_s changes within one clk_d cycle before rising-edge. ####");

  
  always @ (clk_d) begin : monitor_clk_d 
    if ( (clk_d !== 1'b0) && (clk_d !== 1'b1) && ($time > 0) )
      $display( "WARNING: %m :\n  at time = %t, detected unknown value, %b, on clk_d input.",
                $time, clk_d );
    end // monitor_clk_d 

// synopsys translate_on
endmodule
