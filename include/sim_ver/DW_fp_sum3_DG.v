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
// AUTHOR:    Alexandre F. Tenca  January 2010
//
// VERSION:   Verilog Simulation Model - FP SUM3 with DG
//
// DesignWare_version: 7fbfc557
// DesignWare_release: K-2015.06-DWBB_201506.5.2
//
////////////////////////////////////////////////////////////////////////////////
//-------------------------------------------------------------------------------
//
// ABSTRACT: Three-operand Floating-point Adder (SUM3) with Datapath gating
//           Computes the addition of three FP numbers. The format of the FP
//           numbers is defined by the number of bits in the significand 
//           (sig_width) and the number of bits in the exponent (exp_width).
//           The outputs are a FP number and status flags with information 
//           about special number representations and exceptions. 
//           A DG_ctrl port controls if the component has its inputs isolated
//           of not. When this input is '1' the component behaves as the 
//           DW_fp_sum3.
//
//              parameters      valid values (defined in the DW manual)
//              ==========      ============
//              sig_width       significand size,  2 to 253 bits
//              exp_width       exponent size,     3 to 31 bits
//              ieee_compliance 0 or 1 (default 0)
//              arch_type       0 or 1 (default 0)
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
//                              rounding mode
//              DG_ctrl         1 bit
//                              Datapath gating control (1 - normal operation)
//
//              Output ports    Size & Description
//              ===========     ==================
//              z               (sig_width + exp_width + 1) bits
//                              Floating-point Number -> a+b+c
//              status          byte
//                              info about FP result
//
// MODIFIED:
//-------------------------------------------------------------------------------

module DW_fp_sum3_DG (a, b, c, rnd, DG_ctrl, z, status);
parameter sig_width=23;             // RANGE 2 to 253 bits
parameter exp_width=8;              // RANGE 3 to 31 bits
parameter ieee_compliance=0;        // RANGE 0 or 1           
parameter arch_type=0;              // RANGE 0 or 1           

// declaration of inputs and outputs
input  [sig_width+exp_width:0] a,b,c;
input  [2:0] rnd;
input  DG_ctrl;
output [7:0] status;
output [sig_width+exp_width:0] z;

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
  
    if ( (arch_type < 0) || (arch_type > 1) ) begin
      param_err_flg = 1;
      $display(
	"ERROR: %m :\n  Invalid value (%d) for parameter arch_type (legal range: 0 to 1)",
	arch_type );
    end
  
    if ( param_err_flg == 1) begin
      $display(
        "%m :\n  Simulation aborted due to invalid parameter value(s)");
      $finish;
    end

  end // parameter_check 


wire [7:0] OO1O0I00;
wire [sig_width+exp_width:0] OlII1100;

  // Instance of DW_fp_sum3
  DW_fp_sum3 #(sig_width, exp_width, ieee_compliance, arch_type)
          U1 ( .a(a), .b(b), .c(c), .rnd(rnd), .z(OlII1100), .status(OO1O0I00) );

  // Simulate gating functionality
  assign z = (DG_ctrl !== 1'b1)?{sig_width+exp_width+1{1'bX}} : OlII1100;
  assign status = (DG_ctrl !== 1'b1)?{8'bXXXXXXXX} : OO1O0I00;

// synopsys translate_on  

endmodule

