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
// AUTHOR:    bruce dean June 26th. 2004
//
// VERSION:   Simulation model
//
// DesignWare_version: 4fe84d81
// DesignWare_release: K-2015.06-DWBB_201506.5.2
//
////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
//----------------------------------------------------------------------------
// ABSTRACT: Generic pulse sychronization block 
//
//
//----------------------------------------------------------------------------
//              Parameters:     Valid Values
//              ==========      ============
//		reg_event       [ 0 => event_d will have combination logic
//				       but latency will be 1 cycle sooner
//				  1 => event_d will be retimed so there will
//				       be no logic between register & port
//				       but event is delayed 1 cycle]
//              f_sync_type     [ 0 = single clock design, no synchronizing stages implemented,
//                                1 = 2-stage synchronization w/ 1st stage neg-edge & 2nd stage pos-edge capturing,
//                                2 = 2-stage synchronization w/ both stages pos-edge capturing,
//                                3 = 3-stage synchronization w/ all stages pos-edge capturing ]
//                                4 = 4-stage synchronization w/ all stages pos-edge capturing ]
//              tst_mode        [ 0 = no hold latch inserted,
//                                1 = insert hold 'latch' using a neg-edge triggered register
//                                2 = insert active-low hold latch ]
//              verif_en        [ 0 = no sampling errors inserted,
//                                1 = sampling errors are randomly inserted with 0 or up to 1 destination clock cycle delays
//                                2 = sampling errors are randomly inserted with 0, 0.5, 1, or 1.5 destination clock cycle delays
//                                3 = sampling errors are randomly inserted with 0, 1, 2, or 3 destination clock cycle delays
//                                4 = sampling errors are randomly inserted with 0 or up to 0.5 destination clock cycle delays ]
//              pulse_mode      [ 0 =>  single clock cycle pulse in produces
//                                      single clock cycle pulse out
//                                1 =>  rising edge transition in produces
//                                2 =>  falling edge transition in produces
//                                      single clock cycle pulse out
//                                3 =>  toggle transition in produces
//                                      single clock cycle pulse out]
///
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
//              event_d         1 bit    Dest Domain Active High Event Signal
//
// MODIFIED: 
//              DLL   9-21-11  Added tst_mode=2 checking and comments (not a functional change)
//
//----------------------------------------------------------------------------
////////////////////////////////////////////////////////////////////////////////
module DW_pulse_sync
            (
             clk_s, 
	     rst_s_n, 
	     init_s_n, 
	     event_s, 
	     clk_d, 
             rst_d_n, 
	     init_d_n,
	     test, 
	     event_d
	     );
 parameter reg_event = 0;	// 0 => event_d will have combination logic
				//       but latency will be 1 cycle sooner
				// 1 => event_d will be retimed so there will
				//       be no logic between register & port
				//       but event is delayed 1 cycle

 parameter f_sync_type = 1;	// 0 - 3
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
 parameter tst_mode = 0;	// 0-2
                                // 0 =>  no latch insertion
				// 1 =>  hold latch using neg edge flop
				// 2 =>  reserved unsupported

 parameter verif_en = 1;        // 0-4
                                // 0 =>  no sampling errors are used
				// 1 =>  random insertion of 0 or upt to 1 dest clk
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
input  event_s;			// event pulse input (active high event)
input  clk_d;			// clock input for destination domain
input  rst_d_n;			// active low async. reset in clk_d domain
input  init_d_n;		// active low sync. reset in clk_d domain
input  test;                    // test  1 bit   Test input
output event_d;			// event pulse output (active high event)

  initial begin
    if ((f_sync_type > 0)&&(f_sync_type < 8))
      $display("Information: *** Instance %m is the DW_pulse_sync Clock Domain Crossing Module ***");
  end

// synopsys translate_off
// Param check
  
 
  initial begin : parameter_check
    integer param_err_flg;

    param_err_flg = 0;
    
  
    if ( (reg_event < 0) || (reg_event > 1) ) begin
      param_err_flg = 1;
      $display(
	"ERROR: %m :\n  Invalid value (%d) for parameter reg_event (legal range: 0 to 1)",
	reg_event );
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

wire       O0I100OO;
reg        O1O10OI0;
reg        OO10OI10;
reg  [1:0] O0OlIO00;
wire       II1lIlI0;
reg        OOO01l10;
reg        O00O000l;
wire       O101lOO0;

  
generate
  if (((f_sync_type&7)>1)&&(tst_mode==2)) begin : GEN_LATCH_frwd_hold_latch_PROC
    reg [1-1:0] OO10OI10;
    always @ (clk_s or O1O10OI0) begin : LATCH_frwd_hold_latch_PROC_PROC

      if (clk_s == 1'b0)

	OO10OI10 = O1O10OI0;


    end // LATCH_frwd_hold_latch_PROC_PROC


    assign O0I100OO = (test==1'b1)? OO10OI10 : O1O10OI0;

  end else begin : GEN_DIRECT_frwd_hold_latch_PROC
    assign O0I100OO = O1O10OI0;
  end
endgenerate

  DW_sync #(1, f_sync_type+8, tst_mode, verif_en) SIM(
	.clk_d(clk_d),
	.rst_d_n(rst_d_n),
	.init_d_n(init_d_n),
	.data_s(O0I100OO),
	.test(test),
	.data_d(II1lIlI0) );
assign O101lOO0 = pulse_mode === 0 ? event_s ^ O1O10OI0 
                   :(pulse_mode === 1? (event_s & ! O00O000l) ^ O1O10OI0  
		   :(pulse_mode === 2? (!event_s & O00O000l) ^ O1O10OI0
                   :(pulse_mode === 3? (event_s ^ O00O000l) ^ O1O10OI0: 1'bx)));
always @ ( posedge clk_s or negedge rst_s_n   ) begin : a1000_PROC
  if(rst_s_n === 1'b0 ) begin
    O1O10OI0 <= 1'b0;
    O00O000l  <= 1'b0;
  end else if(rst_s_n === 1'b1 )  begin
    if(init_s_n === 1'b0 ) begin 
      O1O10OI0 <= 1'b0;
      O00O000l  <= 1'b0;
    end else if(init_s_n === 1'b1 ) begin
      if(event_s === 1'b1) begin 
        O1O10OI0 <= O101lOO0;
        O00O000l  <= event_s;
      end else if(event_s !== 1'b0) begin
        O1O10OI0 <= 1'bx;
        O00O000l  <= 1'bx;
      end else begin
        O1O10OI0 <= O101lOO0;
        O00O000l  <= event_s;
      end
    end else begin
       O1O10OI0 <= 1'bx;
       O00O000l  <= 1'bx;
    end
  end else begin
    O1O10OI0 <= 1'bx;
    O00O000l  <= 1'bx;
  end
end
 always @ ( posedge clk_d or negedge  rst_d_n) begin : a1001_PROC
  if(rst_d_n === 1'b0 )
    O0OlIO00 <= 2'b00;
  else if(rst_d_n === 1'b1 )
    if(init_d_n === 1'b0) 
      O0OlIO00 <= 2'b00;
    else if(init_d_n === 1'b1)
      O0OlIO00 <= {O0OlIO00[0] ^ II1lIlI0, II1lIlI0}; 
    else 
      O0OlIO00 <= 2'bxx;
  else 
    O0OlIO00 <= 2'bxx;
 end
 assign event_d = (reg_event) ? O0OlIO00[1] : O0OlIO00[0] ^ II1lIlI0 ;
 
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
