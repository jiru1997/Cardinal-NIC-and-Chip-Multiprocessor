////////////////////////////////////////////////////////////////////////////////
//
//       This confidential and proprietary software may be used only
//     as authorized by a licensing agreement from Synopsys Inc.
//     In the event of publication, the following notice is applicable:
//
//                    (C) COPYRIGHT 2010 - 2016 SYNOPSYS INC.
//                           ALL RIGHTS RESERVED
//
//       The entire notice above must be reproduced on all authorized
//     copies.
//
// AUTHOR:    Rick Kelly    Jul. 23, 2010
//
// VERSION:   Verilog Simulation model for DW_lp_cntr_updn_df
//
// DesignWare_version: 9934afc6
// DesignWare_release: K-2015.06-DWBB_201506.5.2
//
////////////////////////////////////////////////////////////////////////////////

//
//
// ABSTRACT: Low Power Up/Down Counter with Dynamic Terminal Count
//
//
//      Parameters     Valid Values   Description
//      ==========     ============   ===========
//      width           2 to 1024     default: 8
//                                    Width of counter
//
//      rst_mode         0 to 1       default: 0
//                                    Defines whether reset is async or sync
//                                      0 => use asynch reset FFs
//                                      1 => use synch reset FFs
//
//      reg_trmcnt       0 to 1       default: 0
//                                    Defines whether term_count_n is registered
//                                      0 => term_count_n is combination
//                                      1 => term_count_n is registered
//
//
//      Inputs         Size       Description
//      ======         ====       ===========
//      clk            1 bit      Positive edge sensitive Clock Input
//      rst_n          1 bit      Reset Inpur (active low)
//      enable         1 bit      Counter Enable Input (active high)
//      up_dn          1 bit      Count direction (0 => down, 1 => up)
//      ld_n           1 bit      Reset (active low)
//      ld_count    width bits    Value to Load into Counter
//      term_val    width bits    Input to Specify the Terminal Count Value
//
//
//      Outputs        Size       Description
//      =======        ====       ===========
//      count       width bits    Counter Output
//      term_count_n   1 bit      Terminal Count Output Flag (active low)
//
//
// Modification history:
//
////////////////////////////////////////////////////////////////////////////////

module DW_lp_cntr_updn_df(
	clk,
	rst_n,
	enable,
	up_dn,
	ld_n,
	ld_count,
	term_val,
	count,
	term_count_n
	);

parameter width     = 8;
parameter rst_mode  = 0;
parameter reg_trmcnt= 0;


input			clk;
input			rst_n;
input			enable;
input			up_dn;
input			ld_n;
input  [width-1 : 0]	ld_count;
input  [width-1 : 0]	term_val;
output [width-1 : 0]	count;
output			term_count_n;

// synopsys translate_off

reg    [width-1 : 0]	count_int;
wire   [width-1 : 0]	count_next;

wire   [width-1 : 0]	count_plus_one;

reg			term_count_n_int;
wire			term_count_n_next;
wire   [width-1 : 0]	one;


  assign one = {{width-1{1'b0}},1'b1};

  assign count_plus_one = (up_dn === 1'b1)? (count_int + one) : 
					((up_dn ===1'b0)? (count_int - one) : {width{1'bx}});
  assign count_next = (ld_n === 1'b1)? ((enable === 1'b1)? count_plus_one :
					  ((enable === 1'b0)? count_int : {width{1'bx}})) :
			((ld_n === 1'b0)? ld_count : {width{1'bx}});

generate if (rst_mode == 0) begin : GEN_1
  always @ (posedge clk or negedge rst_n) begin : registers_async_PROC
    if (rst_n == 1'b0) begin
      count_int <= {width{1'b0}};
      term_count_n_int <= 1'b1;
    end else begin
      count_int <= count_next;
      term_count_n_int <= term_count_n_next;
    end
  end
end else begin
  always @ (posedge clk) begin : registers_sync_PROC
    if (rst_n == 1'b0) begin
      count_int <= {width{1'b0}};
      term_count_n_int <= 1'b1;
    end else begin
      count_int <= count_next;
      term_count_n_int <= term_count_n_next;
    end
  end
end
endgenerate

  assign count = count_int;

generate if (reg_trmcnt == 0) begin : GEN_2
  assign term_count_n = ((^(count_int ^ count_int) !== 1'b0) || (^(term_val ^ term_val) !== 1'b0))? 1'bX :
				((count_int == term_val)? 1'b0 : 1'b1);
  assign term_count_n_next = 1'b1;
end else begin
  assign term_count_n = term_count_n_int;
  assign term_count_n_next = ((ld_n & ~enable)==1'b1)? term_count_n_int :
				((^(count_next ^ count_next) !== 1'b0) || (^(term_val ^ term_val) !== 1'b0))? 1'bX :
				((count_next == term_val)? 1'b0 : 1'b1);
end
endgenerate

// synopsys translate_on

endmodule
