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
// AUTHOR:    Alexandre Tenca
//
// VERSION:   Verilog Simulation Model for FP adder - Dec. 2005
//
// DesignWare_version: 51dede9a
// DesignWare_release: K-2015.06-DWBB_201506.5.2
//
////////////////////////////////////////////////////////////////////////////////
//-------------------------------------------------------------------------------
//
// ABSTRACT: Floating-point two-operand Adder
//           Computes the addition of two FP numbers. 
//           The format of the FP numbers is defined by the number of bits 
//           in the significand (sig_width) and the number of bits in the 
//           exponent (exp_width).
//           The total number of bits in the FP number is sig_width+exp_width
//           since the sign bit takes the place of the MS bits in the significand
//           which is always 1 (unless the number is a denormal; a condition 
//           that can be detected testing the exponent value).
//           The output is a FP number and status flags with information about
//           special number representations and exceptions. 
//              parameters      valid values (defined in the DW manual)
//              ==========      ============
//              sig_width       significand size,  2 to 253 bits
//              exp_width       exponent size,     3 to 31 bits
//              ieee_compliance 0 or 1
//
//              Input ports     Size & Description
//              ===========     ==================
//              a               (sig_width + exp_width + 1)-bits
//                              Floating-point Number Input
//              b               (sig_width + exp_width + 1)-bits
//                              Floating-point Number Input
//              rnd             3 bits
//                              rounding mode
//
//              Output ports    Size & Description
//              ===========     ==================
//              z               (sig_width + exp_width + 1) bits
//                              Floating-point Number result
//              status          byte
//                              info about FP results
//
//
// MODIFIED:
//
//-------------------------------------------------------------------------------

module DW_fp_add (a, b, rnd, z, status);
parameter sig_width=23;
parameter exp_width=8;
parameter ieee_compliance=0;

// declaration of inputs and outputs
input  [sig_width + exp_width:0] a,b;
input  [2:0] rnd;
output [sig_width + exp_width:0] z;
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



wire [sig_width+exp_width : 0] z_sim;
wire [7 : 0] status_flags_sim;

// instance of DW_fp_addsub
DW_fp_addsub #(sig_width, exp_width, ieee_compliance) U1
     (.a (a),
      .b (b),
      .rnd (rnd),
      .op (1'b0),
      .z (z_sim),
      .status (status_flags_sim));

assign z = z_sim;
assign status = status_flags_sim;

// synopsys translate_on

endmodule

