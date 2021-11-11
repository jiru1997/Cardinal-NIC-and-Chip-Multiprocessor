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
// AUTHOR:    Bruce Dean                 July 9, 2004
//
// VERSION:   Verilog Simulation Model
//
// DesignWare_version: 6dc6767e
// DesignWare_release: K-2015.06-DWBB_201506.5.2
//
////////////////////////////////////////////////////////////////////////////////
//----------------------------------------------------------------------------
// ABSTRACT: Generic pulse sychronization block with acknowledge
//
//
//-----------------------------------------------------------------------------
//
//           pulseack synchronizer 
//
//-----------------------------------------------------------------------------
//              Parameters      Valid Values    Description
//              ==========      ============    ===========
//              reg_event       [ 0/1           register output]
//              reg_ack         [ 0/1           register ack output]
//              f_sync_type     [ 0-4           number && type of flops s->d]
//              r_sync_type     [ 0-4           number && type of flops d-> s]
//              tst_mode        [ 0-2           test mode flop/latch insertion]
//              pulse_mode      [ 0 =>  single clock cycle pulse in produces]
//                                      single clock cycle pulse out
//                                1 =>  rising edge transition in produces
//                                2 =>  falling edge transition in produces
//                                      single clock cycle pulse out
//                                3 =>  toggle transition in produces
//                                      single clock cycle pulse out]
//
//              Input Ports:    Size     Description
//              ===========     ====     ===========
//              clk_s           1 bit    Source Domain Input Clock
//              rst_s_n         1 bit    Source Domain Active Low Async. Reset
//              init_s_n        1 bit    Source Domain Active Low Sync. Reset
//              event_s         1 bit    Source Domain Active High Send Request
//              clk_d           1 bit    Destination Domain Input Clock
//              rst_d_n         1 bit    Destination Domain Active Low Async. Reset
//              init_d_n        1 bit    Destination Domain Active Low Sync. Reset
//              test            1 bit    Test input
//
//              Output Ports    Size     Description
//              ============    ====     ===========
//               ack_s		1 bit	 event pulseack output (active high event)
//               busy_s		1 bit	 event pulseack output (active high event)
//               event_d	1 bit    event pulseack output (active high event)
//-----------------------------------------------------------------------------
////////////////////////////////////////////////////////////////////////////////
module DW_pulseack_sync
            (
             clk_s, 
	     rst_s_n, 
	     init_s_n, 
	     event_s, 
	     ack_s,
	     busy_s,
	     clk_d, 
             rst_d_n, 
	     init_d_n,
	     event_d,
	     test 
	     );
 parameter reg_event   = 1;	// 0 => event_d will have combination logic
				//       but latency will be 1 cycle sooner
				// 1 => event_d will be retimed so there will
				//       be no logic between register & port
				//       but event is delayed 1 cycle
 parameter reg_ack     = 1;	// 0 => ack_s will have combination logic
				//       but latency will be 1 cycle sooner
				// 1 => ack_s will be retimed so there will
				//       be no logic between register & port
				//       but event is delayed 1 cycle
 parameter ack_delay    = 1;	// 0 => ack_s will have combination logic
				//       but latency will be 1 cycle sooner
				// 1 => ack_s will be retimed so there will
				//       be no logic between register & port
				//       but event is delayed 1 cycle
 parameter f_sync_type = 2;	// 0 - 4
				// 0 => single clock design, i.e. clk_d == clk_s
				// 1 => first synchronization in clk_d domain is
				//       done on the negative edge and the rest
				//       on positive edge.  This reduces latency
				//       req. of synchronization slightly but
				//       quicker metastability resolution for
				//       the negative edge sensitive FF. It also
				//       requires the technology library to 
				//       contain an acceptable negative edge 
                                //       sensitive FF.
				// 2 =>  all synchronization in clk_d domain is
				//       done on positive edges - 2 d flops in
				//       destination domain
				// 3 =>  all synchronization in clk_d domain is
				//       done on positive edges - 3 d flops in
				//       destination domain
				// 4 =>  all synchronization in clk_d domain is
				//       done on positive edges - 4 d flops in
				//       destination domain
 parameter r_sync_type = 2;	// 0 - 4
				// 0 => single clock design, i.e. clk_s == clk_s
				// 1 => first synchronization in clk_s domain is
				//       done on the negative edge and the rest
				//       on positive edge.  This reduces latency
				//       req. of synchronization slightly but
				//       quicker metastability resolution for
				//       the negative edge sensitive FF. It also
				//       requires the technology library to 
				//       contain an acceptable negative edge 
                                //       sensitive FF.
				// 2 =>  all synchronization in clk_s domain is
				//       done on positive edges - 2 d flops in
				//       source domain
				// 3 =>  all synchronization in clk_s domain is
				//       done on positive edges - 3 d flops in
				//       source domain
				// 4 =>  all synchronization in clk_s domain is
				//       done on positive edges - 4 d flops in
				//       source domain
 parameter tst_mode     = 0;	// 0-2
                                // 0 =>  no latch insertion
				// 1 =>  hold latch using neg edge flop
				// 2 =>  hold latch using active low latch
 parameter verif_en     = 1;    // 0-4
                                // 0 =>  no sampling errors are used
				// 1 =>  random insertion of 0 or up to 1 dest clk
				// 2 =>  random insertion of 0,0.5,1,or 1.5 dest clk
				// 3 =>  random insertion of 0,1,2,or 3 dest clk
				// 4 =>  random insertion of 0 or up to 0.5 dest clk
 parameter pulse_mode   = 0;    // 0 =>  single clock cycle pulse in produces
                                //       single clock cycle pulse out
                                // 1 =>  rising edge transition in produces
                                // 2 =>  falling edge transition in produces
                                //       single clock cycle pulse out
                                // 3 =>  toggle transition in produces
                                //       single clock cycle pulse out
input  clk_s;			// clock input for source domain
input  rst_s_n;			// active low async. reset in clk_s domain
input  init_s_n;		// active low sync. reset in clk_s domain
input  event_s;			// event pulseack input (active high event)
output ack_s;			// event pulseack output (active high event)
output busy_s;			// event pulseack output (active high event)

input  clk_d;			// clock input for destination domain
input  rst_d_n;			// active low async. reset in clk_d domain
input  init_d_n;		// active low sync. reset in clk_d domain
output event_d;			// event pulseack output (active high event)

input  test;                    // test  1 bit   Test input

  wire   O1l0O00O   ;
  wire   O1O11100      ;
  wire   OlOIIO00        ;
  reg    O11l0OI1     ;
  reg    lO0OOOO1     ;
  reg    I00Il1OI     ;
  wire   Il110011 ;
  reg    II0O10I1  ;
  wire   lOO1I01l  ;
  reg    O011011I    ;
  wire   OI1O0IO0     ;
  reg    OI01IO00    ;
  wire   lOO1O11O  ;
  reg    OOOOOIO0  ;
  reg    O10101lO   ;
  wire   Il001O0O   ;
  wire   O10I11I1  ;
  wire   I1OO10OO  ;
  reg    O1O11IO1  ;
  wire   I110OOOI   ;
  reg    l0Ill11O   ;
  wire   Ol0l101l  ;
  reg    O1IIO1O1  ;
  reg    l0O0l101    ;
// synopsys translate_off  
  
 
  initial begin : parameter_check
    integer param_err_flg;

    param_err_flg = 0;
    
  
    if ( (reg_event < 0) || (reg_event > 1) ) begin
      param_err_flg = 1;
      $display(
	"ERROR: %m :\n  Invalid value (%d) for parameter reg_event (legal range: 0 to 1)",
	reg_event );
    end
  
    if ( (reg_ack < 0) || (reg_ack > 1) ) begin
      param_err_flg = 1;
      $display(
	"ERROR: %m :\n  Invalid value (%d) for parameter reg_ack (legal range: 0 to 1)",
	reg_ack );
    end
  
    if ( (ack_delay < 0) || (ack_delay > 1) ) begin
      param_err_flg = 1;
      $display(
	"ERROR: %m :\n  Invalid value (%d) for parameter ack_delay (legal range: 0 to 1)",
	ack_delay );
    end
  
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
  
    if ( (pulse_mode < 0) || (pulse_mode > 3) ) begin
      param_err_flg = 1;
      $display(
	"ERROR: %m :\n  Invalid value (%d) for parameter pulse_mode (legal range: 0 to 3)",
	pulse_mode );
    end
  
    if ( param_err_flg == 1) begin
      $display(
        "%m :\n  Simulation aborted due to invalid parameter value(s)");
      $finish;
    end

  end // parameter_check 



  initial begin
    if ((f_sync_type > 0)&&(f_sync_type < 8))
      $display("Information: *** Instance %m is the DW_pulseack_sync Clock Domain Crossing Module ***");
  end


  always @(posedge clk_s or negedge rst_s_n ) begin : a1000_PROC
    if  (rst_s_n === 1'b0)  begin
      l0Ill11O  <= 1'b0;
      I00Il1OI    <= 1'b0;
      O1O11IO1 <= 1'b0;
      OI01IO00   <= 1'b0;
    end else if  (rst_s_n === 1'b1)  begin
      if ( init_s_n === 1'b0)  begin
        l0Ill11O  <= 1'b0;
        I00Il1OI    <= 1'b0;
        O1O11IO1 <= 1'b0;
        OI01IO00   <= 1'b0;
      end else if ( init_s_n === 1'b1)  begin
        l0Ill11O    <= I110OOOI;
        OI01IO00     <= event_s;
        I00Il1OI      <= Il110011;
        O1O11IO1   <= I1OO10OO;
	II0O10I1   <= lOO1I01l;
      end else begin
        l0Ill11O  <= 1'bx;
        I00Il1OI    <= 1'bx;
        O1O11IO1 <= 1'bx;
        OI01IO00   <= 1'bx;
      end
    end else begin
      l0Ill11O  <= 1'bx;
      I00Il1OI    <= 1'bx;
      O1O11IO1 <= 1'bx;
      OI01IO00   <= 1'bx;
    end
  end
  
  always @(posedge clk_d or negedge rst_d_n) begin : a1001_PROC
    if (rst_d_n === 1'b0 ) begin
      O011011I   <= 1'b0;
      OOOOOIO0 <= 1'b0;
    end else if (rst_d_n === 1'b1 ) begin
      if (init_d_n === 1'b0 ) begin
        O011011I   <= 1'b0;
        OOOOOIO0 <= 1'b0;
      end else if (init_d_n === 1'b1 ) begin
        O011011I   <= Il001O0O;
        OOOOOIO0 <= O1l0O00O;
      end else begin
        O011011I   <= 1'bx;
        OOOOOIO0 <= 1'bx;
      end
    end else begin
      O011011I   <= 1'bx;
      OOOOOIO0 <= 1'bx;
    end
  end //always;

  
generate
  if (((f_sync_type&7)>1)&&(tst_mode==2)) begin : GEN_LATCH_frwd_hold_latch_PROC
    reg [1-1:0] O1IIO1O1;
    always @ (clk_s or l0Ill11O) begin : LATCH_frwd_hold_latch_PROC_PROC

      if (clk_s == 1'b0)

	O1IIO1O1 = l0Ill11O;


    end // LATCH_frwd_hold_latch_PROC_PROC


    assign Ol0l101l = (test==1'b1)? O1IIO1O1 : l0Ill11O;

  end else begin : GEN_DIRECT_frwd_hold_latch_PROC
    assign Ol0l101l = l0Ill11O;
  end
endgenerate

  DW_sync #(1, f_sync_type+8, tst_mode, verif_en) UF(
	.clk_d(clk_d),
	.rst_d_n(rst_d_n),
	.init_d_n(init_d_n),
	.data_s(Ol0l101l),
	.test(test),
	.data_d(Il001O0O) );

  
generate
  if (((r_sync_type&7)>1)&&(tst_mode==2)) begin : GEN_LATCH_rvs_hold_latch_PROC
    reg [1-1:0] O10101lO;
    always @ (clk_d or lOO1O11O) begin : LATCH_rvs_hold_latch_PROC_PROC

      if (clk_d == 1'b0)

	O10101lO = lOO1O11O;


    end // LATCH_rvs_hold_latch_PROC_PROC


    assign O10I11I1 = (test==1'b1)? O10101lO : lOO1O11O;

  end else begin : GEN_DIRECT_rvs_hold_latch_PROC
    assign O10I11I1 = lOO1O11O;
  end
endgenerate

  DW_sync #(1, r_sync_type+8, tst_mode, verif_en) UR(
	.clk_d(clk_s),
	.rst_d_n(rst_s_n),
	.init_d_n(init_s_n),
	.data_s(O10I11I1),
	.test(test),
	.data_d(I1OO10OO) );		
  assign I110OOOI = (pulse_mode === 0 ) ? l0Ill11O  ^ (event_s && ! I00Il1OI)
                         :(pulse_mode === 1  ? l0Ill11O ^ (! I00Il1OI &(event_s & ! OI01IO00))
			 :(pulse_mode === 2  ?  l0Ill11O ^ (! I00Il1OI &(OI01IO00 & !event_s))
			 : l0Ill11O ^ (! I00Il1OI & (event_s ^ OI01IO00))));
  assign O1l0O00O   = Il001O0O  ^ O011011I; 
  assign lOO1I01l  = ((O1O11IO1 ^ I1OO10OO));
  assign Il110011 = I1OO10OO ^ I110OOOI ;
  assign O1O11100      = (reg_event === 1) ? OOOOOIO0 : O1l0O00O;
  assign OlOIIO00        = (reg_ack === 1) ? II0O10I1   : lOO1I01l;
  assign lOO1O11O  = ack_delay === 1 ? O011011I : Il001O0O;
  assign busy_s         = I00Il1OI;
  assign ack_s          = OlOIIO00;
  assign event_d        = O1O11100;
  
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
