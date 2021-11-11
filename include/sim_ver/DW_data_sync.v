////////////////////////////////////////////////////////////////////////////////
//
//       This confidential and proprietary software may be used only
//     as authorized by a licensing agreement from Synopsys Inc.
//     In the event of publication, the following notice is applicable:
//
//                    (C) COPYRIGHT 2004 - 2016 SYNOPSYS INC.
//                           ALL RIGHTS RESERVED
//
//       The entire notice above must be reproduced on all authorized
//     copies.
//
// AUTHOR:    Bruce Dean 12.4.2005
//
// VERSION:   Verilog Synthesis Model 
//
// DesignWare_version: 378edf9e
// DesignWare_release: K-2015.06-DWBB_201506.5.2
//
////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
//----------------------------------------------------------------------------
// ABSTRACT: data bus synchronizer with ack 
//
//
//----------------------------------------------------------------------------
//----------------------------------------------------------------------------
//              Parameters:     Valid Values
//              ==========      ============
//              width           [ 1 to 1024 : width of data_s and data_d ports ]
//              f_sync_type     [ 0 = single clock design, no synchronizing stages implemented,
//                                1 = 2-stage synchronization w/ 1st stage neg-edge & 2nd stage pos-edge capturing,
//                                2 = 2-stage synchronization w/ both stages pos-edge capturing,
//                                3 = 3-stage synchronization w/ all stages pos-edge capturing ]
//                                4 = 4-stage synchronization w/ all stages pos-edge capturing ]
//              r_sync_type     [ 0 = single clock design, no synchronizing stages implemented,
//                                1 = 2-stage synchronization w/ 1st stage neg-edge & 2nd stage pos-edge capturing,
//                                2 = 2-stage synchronization w/ both stages pos-edge capturing,
//                                3 = 3-stage synchronization w/ all stages pos-edge capturing ]
//                                4 = 4-stage synchronization w/ all stages pos-edge capturing ]
//              tst_mode        [ 0 = no hold latch inserted,
//                                1 = insert hold 'latch' using a neg-edge triggered register
//                                2 = insert active low hold latch ]
//              verif_en        [ 0 = no sampling errors inserted,
//                                1 = sampling errors are randomly inserted with 0 or up to 1 destination clock cycle delays
//                                2 = sampling errors are randomly inserted with 0, 0.5, 1, or 1.5 destination clock cycle delays
//                                3 = sampling errors are randomly inserted with 0, 1, 2, or 3 destination clock cycle delays
//                                4 = sampling errors are randomly inserted with 0 or up to 0.5 destination clock cycle delays ]
//              send_mode       [ 0 to 3 :send pulse event type
//                                0 =  single clock cycle pulse in produces
//                                     single clock cycle pulse out
//                                1 =  rising edge transition in produces
//                                2 =  falling edge transition in produces
//                                     single clock cycle pulse out
//                                3 =  toggle transition in produces
//                                     single clock cycle pulse out
//              Input Ports:    Size     Description
//              ===========     ====     ===========
//              clk_s           1 bit    Source Domain Input Clock
//              rst_s_n         1 bit    Source Domain Active Low Async. Reset
//              init_s_n        1 bit    Source Domain Active Low Sync. Reset
//              send_s          1 bit    Source Domain Active High Send Request
//              data_s          width bits   Source Domain Data Input
//              clk_d           1 bit    Destination Domain Input Clock
//              rst_d_n         1 bit    Destination Domain Active Low Async. Reset
//              init_d_n        1 bit    Destination Domain Active Low Sync. Reset
//              test            1 bit    Test input
//
//              Output Ports    Size     Description
//              ============    ====     ===========
//              full_s          1 bit    Source domain transaction busy output 
//              empty_s         1 bit    Source domain transaction busy output 
//              done_s          1 bit    Source domain transaction done output 
//              data_avail_d    1 bit    Destination Domain Data Available Output
//              data_d          width bits   Destination Domain Data Output
//
//
// MODIFIED:
//
//              DLL   9-22-11  Changed port order of data_avail_d and data_d.
//                             Addresses STAR#9000493519.
//
//              DLL   1-8-10   Fixed STAR#9000366699 regarding improper behavior
//                             of 'error_s' for both 'pend_mode' values (0, 1).
//
//              DLL   6-16-06  Added To_X01 processing to 'data_s'
//
//
//----------------------------------------------------------------------------
////////////////////////////////////////////////////////////////////////////////
module DW_data_sync (
             clk_s,
             rst_s_n,
             init_s_n,
             send_s,
             data_s,
             empty_s,
             full_s,
             done_s,

             clk_d,
             rst_d_n,
             init_d_n,
             data_avail_d,
             data_d,

             test
           );

 parameter width       = 8;
 parameter pend_mode   = 1;
 parameter ack_delay   = 1;
 parameter f_sync_type = 2;
 parameter r_sync_type = 2;
 parameter tst_mode    = 0;
 parameter verif_en    = 1;
 parameter send_mode   = 0;

 input             clk_s;
 input             rst_s_n;
 input             init_s_n;
 input             send_s;
 input [width-1:0] data_s;
 output             full_s;
 output             empty_s;
 output             done_s;
 input             clk_d;
 input             rst_d_n;
 input             init_d_n;
 output             data_avail_d;
 output [width-1:0] data_d;
 input             test;
// synopsys translate_off

  
 
  initial begin : parameter_check
    integer param_err_flg;

    param_err_flg = 0;
    
  
    if ( (width < 1) || (width > 1024) ) begin
      param_err_flg = 1;
      $display(
	"ERROR: %m :\n  Invalid value (%d) for parameter width (legal range: 1 to 1024)",
	width );
    end
  
    if ( (pend_mode < 0) || (pend_mode > 1) ) begin
      param_err_flg = 1;
      $display(
	"ERROR: %m :\n  Invalid value (%d) for parameter pend_mode (legal range: 0 to 1)",
	pend_mode );
    end
  
    if ( (ack_delay < 0) || (ack_delay > 1) ) begin
      param_err_flg = 1;
      $display(
	"ERROR: %m :\n  Invalid value (%d) for parameter ack_delay (legal range: 0 to 1)",
	ack_delay );
    end
  
    if ( (f_sync_type < 0) || (f_sync_type > 4) ) begin
      param_err_flg = 1;
      $display(
	"ERROR: %m :\n  Invalid value (%d) for parameter f_sync_type (legal range: 0 to 4)",
	f_sync_type );
    end
  
    if ( (r_sync_type < 0) || (r_sync_type > 4) ) begin
      param_err_flg = 1;
      $display(
	"ERROR: %m :\n  Invalid value (%d) for parameter r_sync_type (legal range: 0 to 4)",
	r_sync_type );
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

  reg  [width-1:0] O011010I;
  reg  [width-1:0] llOO0101;
  wire [width-1:0] O0O10O00;
  reg  [width-1:0] l0110OO0;
  reg  lOI100lO;
  reg  O00001O0;
  reg  I01O0lOO;
  wire I011Ol00;
  reg  O101Ol1O;
  reg  I0lI11lO;
  wire OIOIO1O1;
  wire O00l0011;
  reg  O1OlII11;
  reg  l111I0OO;
  wire O0OO0110;
  wire III00Il0;
  wire lIlOOOl0;
  wire O01O1IO1;
  reg  I011I0II;
  wire Olll01IO;
  reg  O1Ol0011;
  wire IOl0O1l1;
  wire OO10O111;
  reg  O0OOO1IO;
  wire l1111OlO;
  reg  O0llOO1l;
  wire IOl0l101;
  reg  O01Ol0lO;
  wire I1I011O1;
  wire                lO1IO01I;
  assign  lO1IO01I  = pend_mode[0];                       



  initial begin
    if ((f_sync_type > 0)&&(f_sync_type < 8))
      $display("Information: *** Instance %m is the DW_data_sync_na Clock Domain Crossing Module ***");
  end


  DW_pulseack_sync #(0, 0, ack_delay, f_sync_type, r_sync_type, tst_mode, verif_en, 0)
    U1 ( 
        .clk_s(clk_s), 
        .rst_s_n(rst_s_n), 
        .init_s_n(init_s_n), 
        .event_s(O01O1IO1), 
        .clk_d(clk_d), 
        .rst_d_n(rst_d_n), 
        .init_d_n(init_d_n), 
        .test(test), 
        .busy_s(I011Ol00), 
        .ack_s(OIOIO1O1), 
        .event_d(O00l0011) 
        );
  
  always @ (posedge clk_s or negedge rst_s_n) begin : src_pos_reg_PROC
    if  (rst_s_n === 1'b0)  begin
      O011010I <= {width{1'b0}};
      l0110OO0 <= {width{1'b0}};
      I01O0lOO   <= 1'b0;
      O101Ol1O   <= 1'b0;
      O01Ol0lO   <= 1'b0;
      I011I0II     <= 1'b0;
      O1Ol0011     <= 1'b0;
    end else if (rst_s_n === 1'b1) begin
      if (init_s_n === 1'b0)  begin
        O011010I <= {width{ 1'b0}};
        l0110OO0 <= {width{ 1'b0}};
        I01O0lOO   <= 1'b0;
        O101Ol1O   <= 1'b0;
        O01Ol0lO   <= 1'b0;
        I011I0II     <= 1'b0;
        O1Ol0011     <= 1'b0;
      end else if (init_s_n === 1'b1)  begin
        if(O0OO0110 === 1'b1) 
          O011010I <= O0O10O00;
	else if (O0OO0110 === 1'b0)
          O011010I <= O011010I;
        else     
          O011010I <= {width{1'bx}};
        if(III00Il0 === 1'b1) 
          l0110OO0 <= ((data_s | (data_s ^ data_s)));
        else if(III00Il0 === 1'b0)
          l0110OO0 <= l0110OO0;
	else
          l0110OO0 <= {width{1'bx}};
	I01O0lOO   <= send_s;
        O101Ol1O   <= l1111OlO;
        O01Ol0lO   <= I1I011O1;
        I011I0II     <= Olll01IO;
        O1Ol0011     <= IOl0O1l1;
      end else begin
        O011010I <= {width{ 1'bx}};
        l0110OO0 <= {width{ 1'bx}};
        I01O0lOO   <= 1'bx;
        O101Ol1O   <= 1'bx;
        O01Ol0lO   <= 1'bx;
        I011I0II     <= 1'bx;
        O1Ol0011     <= 1'bx;
      end
    end else begin
      O011010I <= {width{1'bx}};
      l0110OO0 <= {width{1'bx}};
      I01O0lOO   <= 1'bx;
      O101Ol1O   <= 1'bx;
      O01Ol0lO   <= 1'bx;
      I011I0II     <= 1'bx;
      O1Ol0011     <= 1'bx;
    end
  end 

   always @ (posedge clk_d or negedge rst_d_n) begin : dest_pos_reg_PROC
    if (rst_d_n === 1'b0 ) begin
       llOO0101     <= {width{1'b0}};
       O0llOO1l <= 0;
    end else if (rst_d_n === 1'b1) begin
      if (init_d_n === 1'b0 ) begin
        llOO0101     <= {width{1'b0}};
        O0llOO1l <= 0;
      end else if (init_d_n === 1'b1) begin
        if (IOl0l101 === 1'b1) 
          llOO0101   <= O011010I;
	else if (IOl0l101 === 1'b0)
          llOO0101   <=  llOO0101;       
	else
          llOO0101   <= {width{1'bx}};
	O0llOO1l <= IOl0l101;
      end else begin
        llOO0101     <= {width{1'bx}};
        O0llOO1l <= 1'bx;
      end
    end else begin
       llOO0101     <= {width{1'bx}};
       O0llOO1l <= 1'bx;
    end
  end
 
  assign Olll01IO   = (pend_mode == 0) ?
                          (O01O1IO1 & ~ I011Ol00) | (I011I0II & ~ OIOIO1O1) :
                          ((O01O1IO1 & ~ I011Ol00) | (I011I0II & ~ OIOIO1O1) 
                           | (OIOIO1O1 & O1Ol0011) | (O1Ol0011 & ~ I011I0II));
  assign IOl0O1l1   = (lIlOOOl0 & ~ O1Ol0011 & I011I0II) 
                        | (O1Ol0011 & ~ OIOIO1O1 & I011I0II)
                        | (lIlOOOl0 & OIOIO1O1 & I011I0II); 
  assign I1I011O1   = (pend_mode === 1) ? ((I011I0II & IOl0O1l1) & ~OIOIO1O1):lIlOOOl0 | Olll01IO;
  assign l1111OlO   = (pend_mode === 1) ? (lIlOOOl0 | O01O1IO1) | (~OIOIO1O1 & O101Ol1O) | (OIOIO1O1 & O1Ol0011) : lIlOOOl0 | Olll01IO;
  assign O0OO0110   = (pend_mode === 1)?(lIlOOOl0 & ~ I011I0II & ~ O101Ol1O) 
                       | (OIOIO1O1 & O1Ol0011)
  		       | (~ I011I0II & O1Ol0011 & ~ OIOIO1O1):lIlOOOl0 & ~ I011Ol00;
  assign O01O1IO1      = (pend_mode === 1)?((lIlOOOl0 & ~ I011I0II) 
                       | (I011I0II & ~ I011Ol00)):lIlOOOl0; 
  assign III00Il0   = l1111OlO & lIlOOOl0;
  assign O0O10O00 = (pend_mode === 1) ?  (O1Ol0011 === 1'b1) ? l0110OO0 : ((data_s | (data_s ^ data_s))) : ((data_s | (data_s ^ data_s)));
  assign lIlOOOl0    = (send_mode === 0)?send_s :((send_mode === 1)?(send_s && !I01O0lOO):( (send_mode === 2)?(! send_s && I01O0lOO):((send_s ^ I01O0lOO))));

  assign OO10O111 = OIOIO1O1;
  assign IOl0l101 = O00l0011;

  assign data_avail_d = O0llOO1l;
  assign data_d       = llOO0101;
  assign done_s       = OO10O111;
  assign empty_s      = O101Ol1O;
  assign full_s       = O01Ol0lO;
 
  always @ (clk_d) begin : monitor_clk_d 
    if ( (clk_d !== 1'b0) && (clk_d !== 1'b1) && ($time > 0) )
      $display( "WARNING: %m :\n  at time = %t, detected unknown value, %b, on clk_d input.",
                $time, clk_d );
    end // monitor_clk_d 
 
  always @ (clk_s) begin : monitor_clk_s 
    if ( (clk_s !== 1'b0) && (clk_s !== 1'b1) && ($time > 0) )
      $display( "WARNING: %m :\n  at time = %t, detected unknown value, %b, on clk_s input.",
                $time, clk_s );
    end // monitor_clk_s 
// synopsys translate_on
endmodule
