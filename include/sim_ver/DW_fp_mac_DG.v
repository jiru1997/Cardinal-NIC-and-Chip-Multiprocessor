
////////////////////////////////////////////////////////////////////////////////
//
//       This confidential and proprietary software may be used only
//     as authorized by a licensing agreement from Synopsys Inc.
//     In the event of publication, the following notice is applicable:
//
//                    (C) COPYRIGHT 2009 - 2016 SYNOPSYS INC.
//                           ALL RIGHTS RESERVED
//
//       The entire notice above must be reproduced on all authorized
//     copies.
//
// AUTHOR:    Kyung-Nam Han, Mar. 9, 2007 (Modified by Alex Tenca October 28, 2009)
//
// VERSION:   Verilog Simulation model for DW_fp_mac_DG
//
// DesignWare_version: b05e8174
// DesignWare_release: K-2015.06-DWBB_201506.5.2
//
////////////////////////////////////////////////////////////////////////////////
//-----------------------------------------------------------------------------
//
// ABSTRACT: Floating-Point MAC (Multiply and Add, a * b + c) with Datapath
//           Gating
//
//              DW_fp_mac_DG calculates the floating-point multiplication and
//              addition (ab + c), while supporting six rounding modes, 
//              including four IEEE standard rounding modes. The DG_ctrl input 
//              controls Datapath Gating.
//
//              parameters      valid values (defined in the DW manual)
//              ==========      ============
//              sig_width       significand size,  2 to 253 bits
//              exp_width       exponent size,     3 to 31 bits
//              ieee_compliance support the IEEE Compliance 
//                              including NaN and denormal expressions.
//                              0 - IEEE 754 compatible without denormal support
//                                  (NaN becomes Infinity, Denormal becomes Zero)
//                              1 - IEEE 754 standard compatible
//                                  (NaN and denormal numbers are supported)
//
//              Input ports     Size & Description
//              ===========     ==================
//              a               (sig_width + exp_width + 1)-bits
//                              Floating-point Number Input
//              b               (sig_width + exp_width + 1)-bits
//                              Floating-point Number Input
//              c               (sig_width + exp_width + 1)-bits
//                              Floating-point Number Input
//              rnd             3 bits
//                              Rounding Mode Input
//              DG_ctrl         Datapath gating control Input
//                              1 bit (default is 1)
//              z               (sig_width + exp_width + 1)-bits
//                              Floating-point Number Output
//              status          8 bits
//                              Status Flags Output
//
//-----------------------------------------------------------------------------


module DW_fp_mac_DG (a, b, c, rnd, DG_ctrl, z, status);

  parameter sig_width = 23;      // RANGE 2 TO 253
  parameter exp_width = 8;       // RANGE 3 TO 31
  parameter ieee_compliance = 0; // RANGE 0 TO 1

  input  [exp_width + sig_width:0] a;
  input  [exp_width + sig_width:0] b;
  input  [exp_width + sig_width:0] c;
  input  [2:0] rnd;
  input  DG_ctrl;
  output [exp_width + sig_width:0] z;
  output [7:0] status;

  // synopsys translate_off


  //-------------------------------------------------------------------------
  // Parameter legality check
  //-------------------------------------------------------------------------
    
 
  initial begin : parameter_check
    integer param_err_flg;

    param_err_flg = 0;
    
      
    if ( (sig_width < 2) || (sig_width > 253) ) begin
      param_err_flg = 1;
      $display(
	"ERROR: %m :\n  Invalid value (%d) for parameter sig_width (legal range: 2 to 253)",
	sig_width );
    end
      
    if ( (exp_width < 3) || (exp_width > 31) ) begin
      param_err_flg = 1;
      $display(
	"ERROR: %m :\n  Invalid value (%d) for parameter exp_width (legal range: 3 to 31)",
	exp_width );
    end
      
    if ( (ieee_compliance < 0) || (ieee_compliance > 1) ) begin
      param_err_flg = 1;
      $display(
	"ERROR: %m :\n  Invalid value (%d) for parameter ieee_compliance (legal range: 0 to 1)",
	ieee_compliance );
    end
    
    if ( param_err_flg == 1) begin
      $display(
        "%m :\n  Simulation aborted due to invalid parameter value(s)");
      $finish;
    end

  end // parameter_check 

  //-------------------------------------------------------------------------

  wire [exp_width + sig_width:0] one;
  wire [exp_width - 1:0] one_exp;
  wire [sig_width - 1:0] one_sig;
  wire [exp_width + sig_width:0] z_int;
  wire [7:0] status_int;

  // integer number 1 with the FP number format
  assign one_exp = ((1 << (exp_width-1)) - 1);
  assign one_sig = 0;
  assign one = {1'b0, one_exp, one_sig}; // fp(1)

  // Simulation Model with DW_fp_dp2(a, b, c, fp(1))

  DW_fp_dp2 #(sig_width, exp_width, ieee_compliance) U1 (
                      .a(a),
                      .b(b),
                      .c(c),
                      .d(one),
                      .rnd(rnd),
                      .z(z_int),
                      .status(status_int) );
  assign z = (DG_ctrl === 1'b1)?z_int:{exp_width+sig_width+1{1'bX}};
  assign status = (DG_ctrl === 1'b1)?status_int:8'bXXXXXXXX;

  // synopsys translate_on
  
endmodule

