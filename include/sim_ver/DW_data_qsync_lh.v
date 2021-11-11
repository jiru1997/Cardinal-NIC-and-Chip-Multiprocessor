////////////////////////////////////////////////////////////////////////////////
//
//       This confidential and proprietary software may be used only
//     as authorized by a licensing agreement from Synopsys Inc.
//     In the event of publication, the following notice is applicable:
//
//                    (C) COPYRIGHT 2006 - 2016 SYNOPSYS INC.
//                           ALL RIGHTS RESERVED
//
//       The entire notice above must be reproduced on all authorized
//     copies.
//
// AUTHOR:    "Bruce Dean May 18 2006"     
//
// VERSION:   
//
// DesignWare_version: 4da41de2
// DesignWare_release: K-2015.06-DWBB_201506.5.2
//
////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
//
//  ABSTRACT:  quasai synchronous data transfer.
//
//             Parameters:     Valid Values   Default Values
//             ==========      ============   ==============
//             width           1 to 1024      8
//             clk_ratio       2 to 1024      2
//             reg_data_s      0 to 1         1
//             reg_data_d      0 to 1         1
//             tst_mode        0 to 2         0
//
//             Input Ports:    Size    Description
//             ===========     ====    ===========
//             clk_s            1        Source clock
//             rst_s_n          1        Source domain asynch. reset (active low)
//             init_s_n         1        Source domain synch. reset (active low)
//             send_s           1        Source domain send request input
//             data_s           width    Source domain send data input
//             clk_d            1        Destination clock
//             rst_d_n          1        Destination domain asynch. reset (active low)
//             init_d_n         1        Destination domain synch. reset (active low)
//             test             1        Scan test mode select input
//
//
//             Output Ports    Size    Description
//             ============    =====    ===========
//             data_d          width    Destination domain data output
//             data_avail_d    1        Destination domain data update output
//
//
//
//
//
//  MODIFIED:
//
//  4/5/14  RJK  Corrected behavior with use of reg_data_s and reg_data_d parameters
//               (STAR 9000736629)
//
////////////////////////////////////////////////////////////////////////////////
module DW_data_qsync_lh(  clk_s, rst_s_n, init_s_n, send_s, data_s, clk_d, 
                          rst_d_n, init_d_n, data_d, data_avail_d, test);
parameter width      = 8; // RANGE 1 to 1024
parameter clk_ratio  = 2; // RANGE 2 to 1024
parameter reg_data_s = 1; // RANGE 0 to 1
parameter reg_data_d = 1; // RANGE 0 to 1
parameter tst_mode   = 0; // RANGE 0 to 2

  input  clk_s;
  input  rst_s_n;
  input  init_s_n;
  input  send_s;
  input  [width-1:0] data_s;
  
  input  clk_d;
  input  rst_d_n;
  input  init_d_n;

  output data_avail_d;
  output [width-1:0] data_d;

  input  test;
// synopsys translate_off
  
  wire             send_s_x;
  wire             data_d_mux;
  wire             data_d_xvail;
  wire [width-1:0] data_s_snd;
  
  reg  [width-1:0] data_s_reg;
  reg              send_reg;
  reg              data_avail_nreg;
  reg  [width-1:0] data_d_reg;
  reg              data_avail_preg;
  reg              data_avail_xreg;
  reg              data_avl_d;
  reg              data_s_l;        // hold latch signal
  wire             data_s_cc;       // hold latch out


  always @ (clk_s or send_reg) begin : frwd_hold_latch_PROC
    if (clk_s == 1'b0) 
      data_s_l <= send_reg;
  end // frwd_hold_latch_PROC;

  assign  data_s_cc = ((tst_mode == 2) & (test == 1'b1)) ? data_s_l : send_reg;

 always @ ( clk_s or negedge rst_s_n) begin : SRC_DM_SEQ_PROC
    if  (rst_s_n === 1'b0)  begin
      data_s_reg <= {width-1{1'b0}};
      send_reg   <= 1'b0;
    end else if  (rst_s_n === 1'b1)  begin
      if (clk_s === 1'b0) begin
      end else if (clk_s === 1'b1) begin
        if ( init_s_n === 1'b0)  begin
          data_s_reg <= {width-1{ 1'b0}};
          send_reg   <= 1'b0;
        end else if ( init_s_n === 1'b1)  begin
	  if (send_s == 1'b1) begin
	    data_s_reg <= data_s;
	  end
  	  send_reg   <= send_s_x;
        end else begin
          data_s_reg <= {width-1{ 1'bx}};
          send_reg   <= 1'bx;
        end 
      end else begin
        data_s_reg <= {width-1{ 1'bx}};
        send_reg   <= 1'bx;
      end
    end else begin
      data_s_reg <= {width-1{ 1'bx}};
      send_reg   <= 1'bx;
    end 
  end 

  always @ (negedge clk_d or negedge rst_d_n) begin : DST_DM_NEG_SEQ_PROC
    if (rst_d_n === 1'b0) begin
      data_avail_nreg <= 1'b0;
    end else begin
      if (rst_d_n === 1'b1) begin
        if (init_d_n === 1'b0) begin
	  data_avail_nreg <= 1'b0;
	end else begin
	  if (init_d_n ===1'b1) begin
	    data_avail_nreg   <= data_s_cc;
	  end else begin // (init_d_n neither 1 or 0)
	    data_avail_nreg <= 1'bx;
	  end
	end
      end else begin // (rst_d_n neither 0 or 1)
	data_avail_nreg <= 1'bx;
      end
    end
  end

  always @ (posedge clk_d or negedge rst_d_n) begin : DST_DM_POS_SEQ_PROC
    if (rst_d_n === 1'b0 ) begin
       data_d_reg      <= {width-1{1'b0}};
       data_avail_preg <= 1'b0;
       data_avail_xreg <= 1'b0;
       data_avl_d      <= 1'b0;
    end else if (rst_d_n === 1'b1 )  begin
      if (init_d_n === 1'b0 ) begin
	data_d_reg      <= {width-1{1'b0}};
	data_avail_preg <= 1'b0;
	data_avail_xreg <= 1'b0;
	data_avl_d      <= 1'b0;
      end else if (init_d_n === 1'b1 ) begin
	if (data_d_xvail == 1'b1) begin
	  data_d_reg      <= data_s_snd;
	end
	data_avail_preg <= data_s_cc;
	data_avail_xreg <= data_d_mux;
	data_avl_d      <= data_d_xvail;
      end else begin
	data_d_reg      <= {width-1{1'bx}};
	data_avail_preg <= 1'bx;
	data_avail_xreg <= 1'bx;
	data_avl_d      <= 1'bx;
      end
    end else begin
      data_d_reg      <= {width-1{1'bx}};
      data_avail_preg <= 1'bx;
      data_avail_xreg <= 1'bx;
      data_avl_d      <= 1'bx;
    end
  end

assign data_d_mux   = ((clk_ratio == 2)||((tst_mode==1)&&(test==1'b1))) ?
				 data_avail_nreg:data_avail_preg ;
assign data_d       = (reg_data_d == 1 ) ? data_d_reg: data_s_snd;
assign data_avail_d = (reg_data_d == 1 ) ? data_avl_d: data_d_xvail;
assign data_s_snd   = (reg_data_s == 1 ) ? data_s_reg: data_s;
assign data_d_xvail = data_d_mux ^ data_avail_xreg;
assign send_s_x     = send_s ^ send_reg;

// synopsys translate_on
endmodule
