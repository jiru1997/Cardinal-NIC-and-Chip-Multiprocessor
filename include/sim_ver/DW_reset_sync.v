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
// AUTHOR:    Doug Lee         12/7/05
//
// VERSION:   Simulation Architecture
//
// DesignWare_version: 0044c1ab
// DesignWare_release: K-2015.06-DWBB_201506.5.2
//
////////////////////////////////////////////////////////////////////////////////
//
// ABSTRACT: Reset Sequence Synchronizer Simulation Model
//
//
//           This synchronizer coordinates reset to the source and destination domains which initiated by
//           either domain.
//
//              Parameters:     Valid Values
//              ==========      ============
//              f_sync_type     default: 2
//                              Forward Synchronized Type (Source to Destination Domains)
//                                0 = single clock design, no synchronizing stages implemented,
//                                1 = 2-stage synchronization w/ 1st stage neg-edge & 2nd stage pos-edge capturing,
//                                2 = 2-stage synchronization w/ both stages pos-edge capturing,
//                                3 = 3-stage synchronization w/ all stages pos-edge capturing
//                                4 = 4-stage synchronization w/ all stages pos-edge capturing
//              r_sync_type     default: 2
//                              Reverse Synchronization Type (Destination to Source Domains)
//                                0 = single clock design, no synchronizing stages implemented,
//                                1 = 2-stage synchronization w/ 1st stage neg-edge & 2nd stage pos-edge capturing,
//                                2 = 2-stage synchronization w/ both stages pos-edge capturing,
//                                3 = 3-stage synchronization w/ all stages pos-edge capturing
//                                4 = 4-stage synchronization w/ all stages pos-edge capturing
//              clk_d_faster    default: 1
//                              clk_d faster than clk_s by difference ratio
//                                0        = Either clr_s or clr_d active with the other tied low at input
//                                1 to 15  = ratio of clk_d to clk_s plus 1
//              reg_in_prog     default: 1
//                              Register the 'clr_in_prog_s' and 'clr_in_prog_d' Outputs
//                                0 = unregistered
//                                1 = registered
//              tst_mode        default: 0
//                              Test Mode Setting
//                                0 = no hold latch inserted,
//                                1 = insert hold 'latch' using a neg-edge triggered register
//                                2 = insert hold latch using active low latch
//              verif_en        default: 1
//                              Verification Enable (simulation only)
//                                0 = no sampling errors inserted,
//                                1 = sampling errors are randomly inserted with 0 or up to 1 destination clock cycle delays
//                                2 = sampling errors are randomly inserted with 0, 0.5, 1, or 1.5 destination clock cycle delays
//                                3 = sampling errors are randomly inserted with 0, 1, 2, or 3 destination clock cycle delays
//                                4 = sampling errors are randomly inserted with 0 or up to 0.5 destination clock cycle delays
//
//              Input Ports:    Size     Description
//              ===========     ====     ===========
//              clk_s           1 bit    Source Domain Input Clock
//              rst_s_n         1 bit    Source Domain Active Low Async. Reset
//              init_s_n        1 bit    Source Domain Active Low Sync. Reset
//              clr_s           1 bit    Source Domain Clear Initiated
//              clk_d           1 bit    Destination Domain Input Clock
//              rst_d_n         1 bit    Destination Domain Active Low Async. Reset
//              init_d_n        1 bit    Destination Domain Active Low Sync. Reset
//              clr_d           1 bit    Destination Domain Clear Initiated
//              test            1 bit    Test input
//
//              Output Ports    Size     Description
//              ============    ====     ===========
//              clr_sync_s      1 bit    Source Domain Clear
//              clr_in_prog_s   1 bit    Source Domain Clear in Progress
//              clr_cmplt_s     1 bit    Source Domain Clear Complete (pulse)
//              clr_in_prog_d   1 bit    Destination Domain Clear in Progress
//              clr_sync_d      1 bit    Destination Domain Clear (pulse)
//              clr_cmplt_d     1 bit    Destination Domain Clear Complete (pulse)
//
// MODIFIED:
//              DLL   7-22-11  Add inherent delay to the feedback path in the destination
//                             domain and clr_in_prog_d.  This effectively extends the 
//                             destination domain acive clearing state.
//                             Also, added 'tst_mode = 2' capability.
//
//              DLL  12-2-10   Removed assertions since only ones left were not
//                             relevant any more.  This fix is by-product of investigating
//                             STAR#9000435571.
//
//              DLL   9-5-08   Accommodate sustained "clr_s" and "clr_d" assertion behavior.
//                             Satisfies STAR#9000261751.
//
//              DLL   8-11-08  Filter long pulses of "clr_s" and "clr_d" to one
//                             clock cycle pulses.
//
//              DLL  10-31-06  Added SystemVerilog assertions
//
//              DLL   8-21-06  Added parameters 'r_sync_type', 'clk_d_faster', 'reg_in_prog'.
//                             Added Destination outputs 'clr_in_prog_d' and 'clr_cmplt_d'
//                             and changed Source output 'I0I0O1l1' to 'clr_cmplt_s'.
//
//              DLL   6-14-06  Removed unnecessary To_X01 processing some input signals
//
//              DLL   11-7-06  Modified functionality to support f_sync_type = 4 and
//                             r_sync_type = 4
//
module DW_reset_sync (
    clk_s,
    rst_s_n,
    init_s_n,
    clr_s,
    clr_sync_s,
    clr_in_prog_s,
    clr_cmplt_s,

    clk_d,
    rst_d_n,
    init_d_n,
    clr_d,
    clr_in_prog_d,
    clr_sync_d,
    clr_cmplt_d,

    test
    );

parameter f_sync_type  = 2;  // RANGE 0 to 4
parameter r_sync_type  = 2;  // RANGE 0 to 4
parameter clk_d_faster = 1;  // RANGE 0 to 15
parameter reg_in_prog  = 1;  // RANGE 0 to 1
parameter tst_mode     = 0;  // RANGE 0 to 2
parameter verif_en     = 1;  // RANGE 0 to 4

`define DW_IIOOl10O 2


input                   clk_s;         // clock input from source domain
input                   rst_s_n;       // active low asynchronous reset from source domain
input                   init_s_n;      // active low synchronous reset from source domain
input                   clr_s;         // active high clear from source domain
output                  clr_sync_s;    // clear to source domain sequential devices
output                  clr_in_prog_s; // clear in progress status to source domain
output                  clr_cmplt_s;   // clear sequence complete (pulse)

input                   clk_d;         // clock input from destination domain
input                   rst_d_n;       // active low asynchronous reset from destination domain
input                   init_d_n;      // active low synchronous reset from destination domain
input                   clr_d;         // active high clear from destination domain
output                  clr_in_prog_d; // clear in progress status to source domain
output                  clr_sync_d;    // clear to destination domain sequential devices (pulse)
output                  clr_cmplt_d;   // clear sequence complete (pulse)

input                   test;          // test input

// synopsys translate_off






  //-------------------------------------------------------------------------
  // Parameter legality check
  //-------------------------------------------------------------------------
  
 
  initial begin : parameter_check
    integer param_err_flg;

    param_err_flg = 0;
    
  
    if ( ((f_sync_type & 7) < 0) || ((f_sync_type & 7) > 4) ) begin
      param_err_flg = 1;
      $display(
	"ERROR: %m :\n  Invalid value (%d) for parameter (f_sync_type & 7) (legal range: 0 to 4)",
	(f_sync_type & 7) );
    end
  
    if ( ((r_sync_type & 7) < 0) || ((r_sync_type & 7) > 4) ) begin
      param_err_flg = 1;
      $display(
	"ERROR: %m :\n  Invalid value (%d) for parameter (r_sync_type & 7) (legal range: 0 to 4)",
	(r_sync_type & 7) );
    end
  
    if ( (reg_in_prog < 0) || (reg_in_prog > 1) ) begin
      param_err_flg = 1;
      $display(
	"ERROR: %m :\n  Invalid value (%d) for parameter reg_in_prog (legal range: 0 to 1)",
	reg_in_prog );
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
  
    if ( param_err_flg == 1) begin
      $display(
        "%m :\n  Simulation aborted due to invalid parameter value(s)");
      $finish;
    end

  end // parameter_check 


  wire                      l1O1O100;
  wire                      lOl0I0l1;
  wire                      Il0110O1;

  integer                   O010111l;
  integer                   I01O0111;

  reg                       l1010110;
  wire                      O1111O0O;
  reg                       OOlIO1OO;
  wire                      lll0OO11;
  wire                      I0I0O1l1;

  reg                       lO1O1011;
  wire                      l011lO0l;
  wire                      l00O0lO1;
  wire                      l11Ol01I;
  wire                      OI01IO11;
  reg                       l0Ol100I;

  wire                      l10Ol00O;
  wire                      IOIOOIlO;

  reg                       OOI1001O;
  wire                      O100OIlI;
  reg                       l0IlI00O;
  reg                       IIOOI0Ol;
  reg                       Il1O110I;
  wire                      O1OOO1O0;

  integer                   O0OIl111;
  integer                   OOOOIlO1;

  reg                       OI1IO11l;
  wire                      OlOOO000;
  wire                      IllIlOl0;
  wire                      I0OO1l01;
  reg                       lI1IO1O0;

  wire                      OO001I10;
  reg                       O0III10l;

  wire                      IO00llI0;
  reg                       OOlOO11O;

  integer  OIO10I11;



assign OlOOO000   = (reg_in_prog == 0) ? ((l10Ol00O && !OI1IO11l) ||
                                                (((OOOOIlO1 == 1) && (O0OIl111 == 0)) && l10Ol00O)) :
//                                               (!clr_in_prog_d && l10Ol00O);
                                               (OOOOIlO1 == 1) && (O0OIl111 == 0);
assign IllIlOl0 = (OOOOIlO1 == 0) && (O0OIl111 == 1);
assign I0OO1l01  = (OlOOO000 && !IllIlOl0) ? 1'b1 :
                            (IllIlOl0) ? 1'b0 : lI1IO1O0;



  initial begin
    if ((f_sync_type > 0)&&(f_sync_type < 8))
      $display("Information: *** Instance %m is the DW_reset_sync Clock Domain Crossing Module ***");
  end


DW_pulse_sync #(1, (f_sync_type + 8), tst_mode, verif_en, 1) U_PS_SRC_INIT (
            .clk_s(clk_s),
            .rst_s_n(rst_s_n),
            .init_s_n(init_s_n),
            .event_s(clr_s),
            .clk_d(clk_d),
            .rst_d_n(rst_d_n),
            .init_d_n(init_d_n),
            .test(test),
            .event_d(l1O1O100)
            );


  
generate
  if (((f_sync_type&7)>1)&&(tst_mode==2)) begin : GEN_LATCH_frwd_hold_latch_PROC
    reg [1-1:0] OOlOO11O;
    always @ (clk_s or clr_s) begin : LATCH_frwd_hold_latch_PROC_PROC

      if (clk_s == 1'b0)

	OOlOO11O = clr_s;


    end // LATCH_frwd_hold_latch_PROC_PROC


    assign IO00llI0 = (test==1'b1)? OOlOO11O : clr_s;

  end else begin : GEN_DIRECT_frwd_hold_latch_PROC
    assign IO00llI0 = clr_s;
  end
endgenerate

  DW_sync #(1, f_sync_type+8, tst_mode, verif_en) U_SYNC_CLR_S(
	.clk_d(clk_d),
	.rst_d_n(rst_d_n),
	.init_d_n(init_d_n),
	.data_s(IO00llI0),
	.test(test),
	.data_d(lOl0I0l1) );

assign Il0110O1 = l1O1O100 || lOl0I0l1;



DW_pulse_sync #(1, (r_sync_type + 8), tst_mode, verif_en, 0) U_PS_DEST_INIT (
            .clk_s(clk_d),
            .rst_s_n(rst_d_n),
            .init_s_n(init_d_n),
            .event_s(IOIOOIlO),
            .clk_d(clk_s),
            .rst_d_n(rst_s_n),
            .init_d_n(init_s_n),
            .test(test),
            .event_d(l11Ol01I)
            );

DW_pulse_sync #(0, (f_sync_type + 8), tst_mode, verif_en, 0) U_PS_FB_DEST (
            .clk_s(clk_s),
            .rst_s_n(rst_s_n),
            .init_s_n(init_s_n),
            .event_s(l0Ol100I),
            .clk_d(clk_d),
            .rst_d_n(rst_d_n),
            .init_d_n(init_d_n),
            .test(test),
            .event_d(l00O0lO1)
            );

assign OO001I10  = (l00O0lO1 && l10Ol00O) ? 1'b1 :
                          (!l00O0lO1 && !l10Ol00O && O0III10l) ? 1'b0 :
                            O0III10l; 
assign l011lO0l = (l00O0lO1 && !l10Ol00O && !O0III10l) || 
                        (!l00O0lO1 && !l10Ol00O && O0III10l);

DW_pulse_sync #(0, (r_sync_type + 8), tst_mode, verif_en, 0) U_PS_ACK (
            .clk_s(clk_d),
            .rst_s_n(rst_d_n),
            .init_s_n(init_d_n),
            .event_s(lO1O1011),
            .clk_d(clk_s),
            .rst_d_n(rst_s_n),
            .init_d_n(init_s_n),
            .test(test),
            .event_d(I0I0O1l1)
            );

  always @(l11Ol01I or I0I0O1l1 or O010111l) begin : a1000_PROC
    if (l11Ol01I && ~I0I0O1l1) begin
      if (O010111l === `DW_IIOOl10O)
        I01O0111 = O010111l;
      else
        I01O0111 = O010111l + 1;
    end else if (~l11Ol01I && I0I0O1l1) begin
      if (O010111l === 0)
        I01O0111 = O010111l;
      else
        I01O0111 = O010111l - 1;
    end else begin
      I01O0111 = O010111l;
    end
  end

  assign O1111O0O = (I01O0111 > 0); 

  assign lll0OO11   = I0I0O1l1 && ((O010111l === 1) && (I01O0111 === 0));

  assign l10Ol00O              = Il0110O1 || clr_d;
  assign IOIOOIlO       = l10Ol00O && !lI1IO1O0;

  assign O100OIlI = (OOOOIlO1 > 0);

  assign OI01IO11    = l011lO0l & ~IOIOOIlO;


  always @(IOIOOIlO or lO1O1011 or O0OIl111) begin : a1001_PROC
    if (IOIOOIlO && ~lO1O1011) begin
      if (O0OIl111 === `DW_IIOOl10O)
        OOOOIlO1 = O0OIl111;
      else
        OOOOIlO1 = O0OIl111 + 1;
    end else if (~IOIOOIlO && lO1O1011) begin
      if (O0OIl111 === 0)
        OOOOIlO1 = O0OIl111;
      else
        OOOOIlO1 = O0OIl111 - 1;
    end else begin
      OOOOIlO1 = O0OIl111;
    end
  end

  assign O1OOO1O0   = ~OOI1001O && l0IlI00O;


  always @(posedge clk_s or negedge rst_s_n) begin : a1002_PROC
    if (rst_s_n === 1'b0) begin
      O010111l          <= 0;
      l0Ol100I  <= 1'b0;
      l1010110  <= 1'b0;
      OOlIO1OO    <= 1'b0;
    end else if (rst_s_n === 1'b1) begin
      if (init_s_n === 1'b0) begin
        O010111l          <= 0;
        l0Ol100I  <= 1'b0;
        l1010110  <= 1'b0;
        OOlIO1OO    <= 1'b0;
      end else if (init_s_n === 1'b1) begin
        O010111l          <= I01O0111;
        l0Ol100I  <= l11Ol01I;
        l1010110  <= O1111O0O;
        OOlIO1OO    <= lll0OO11;
      end else begin
        O010111l          <= -1;
        l0Ol100I  <= 1'bX;
        l1010110  <= 1'bX;
        OOlIO1OO    <= 1'bX;
      end
    end else begin
      O010111l          <= -1;
      l0Ol100I  <= 1'bX;
      l1010110  <= 1'bX;
      OOlIO1OO    <= 1'bX; 
    end
  end

  always @(posedge clk_d or negedge rst_d_n) begin : a1003_PROC
    if (rst_d_n === 1'b0) begin
      OI1IO11l      <= 1'b0;
      lI1IO1O0           <= 1'b0;
      O0OIl111            <= 0;
      OOI1001O    <= 1'b0;
      l0IlI00O <= 1'b0;
      lO1O1011            <= 1'b0;
      IIOOI0Ol       <= 1'b0;
      Il1O110I      <= 1'b0;
      O0III10l             <= 1'b0;
    end else if (rst_d_n === 1'b1) begin
      if (init_d_n === 1'b0) begin
        OI1IO11l      <= 1'b0;
        lI1IO1O0           <= 1'b0;
        O0OIl111            <= 0;
        OOI1001O    <= 1'b0;
        l0IlI00O <= 1'b0;
        lO1O1011            <= 1'b0;
        IIOOI0Ol       <= 1'b0;
        Il1O110I      <= 1'b0;
        O0III10l             <= 1'b0;
      end else if (init_d_n === 1'b1) begin
        OI1IO11l      <= l10Ol00O;
        lI1IO1O0           <= I0OO1l01;
        O0OIl111            <= OOOOIlO1;
        OOI1001O    <= O100OIlI;
        l0IlI00O <= OOI1001O;
        lO1O1011            <= l011lO0l;
        IIOOI0Ol       <= OI01IO11;
        Il1O110I      <= O1OOO1O0;
        O0III10l             <= OO001I10;
      end else begin
        OI1IO11l      <= 1'bX;
        lI1IO1O0           <= 1'bX;
        O0OIl111            <= -1;
        OOI1001O    <= 1'bX;
        l0IlI00O <= 1'bX;
        lO1O1011            <= 1'bX;
        IIOOI0Ol       <= 1'bX;
        Il1O110I      <= 1'bX;
        O0III10l             <= 1'bX;
      end
    end else begin
      OI1IO11l      <= 1'bX;
      lI1IO1O0           <= 1'bX;
      O0OIl111            <= -1;
      OOI1001O    <= 1'bX;
      l0IlI00O <= 1'bX;
      lO1O1011            <= 1'bX;
      IIOOI0Ol       <= 1'bX;
      Il1O110I      <= 1'bX; 
      O0III10l             <= 1'bX;
    end
  end

  assign clr_sync_s      = l11Ol01I;
  assign clr_cmplt_s     = OOlIO1OO;
  assign clr_in_prog_s   = (reg_in_prog == 0) ? O1111O0O : l1010110;
  assign clr_in_prog_d   = (reg_in_prog == 0) ? OOI1001O : l0IlI00O;
  assign clr_sync_d      = IIOOI0Ol;
  assign clr_cmplt_d     = Il1O110I;


  
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
`undef DW_IIOOl10O
endmodule
