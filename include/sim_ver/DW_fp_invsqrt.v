
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
// AUTHOR:    Alex Tenca and Kyung-Nam Han, Dec. 5, 2006
//
// VERSION:   Verilog Simulation Model for DW_fp_invsqrt
//
// DesignWare_version: 0b2eee43
// DesignWare_release: K-2015.06-DWBB_201506.5.2
//
////////////////////////////////////////////////////////////////////////////////

//-----------------------------------------------------------------------------
//
// ABSTRACT: Floating-Point Inverse Square Root
//
//              DW_fp_invsqrt calculates the floating-point reciprocal of 
//              a square root. It supports six rounding modes, including 
//              four IEEE standard rounding modes.
//
//              parameters      valid values
//              ==========      ============
//              sig_width       significand f,  2 to 253 bits
//              exp_width       exponent e,     3 to 31 bits
//              ieee_compliance 0 or 1 
//                              support the IEEE Compliance 
//                              including NaN and denormal.
//                              0 - MC (module compiler) compatible
//                              1 - IEEE 754 standard compatible
//
//              Input ports     Size & Description
//              ===========     ==================
//              a               (sig_width + exp_width + 1)-bits
//                              Floating-point Number Input
//              rnd             3 bits
//                              Rounding Mode Input
//              z               (sig_width + exp_width + 1)-bits
//                              Floating-point Number Output
//              status          8 bits
//                              Status Flags Output
//
// Modified:
//   05/05/10 Kyung-Nam Han (STAR 9000391410, D-2010.03-SP2)
//            Fixed that 1/sqrt(-0) = -Inf, and set divide_by_zero flag.
//   07/08/10 Kyung-Nam Han (STAR 9000404527, D-2010.03-SP4)
//            Fixed an error of (23, 4, 1)-configuration
//            when the input is a denormal, output does not show Inf.
//-----------------------------------------------------------------------------

module DW_fp_invsqrt (a, rnd, z, status);

  parameter sig_width = 23;      // RANGE 2 TO 253
  parameter exp_width = 8;       // RANGE 3 TO 31
  parameter ieee_compliance = 0; // RANGE 0 TO 1

  input  [sig_width+exp_width:0] a; 
  input  [2:0] rnd;
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
    
    if ( param_err_flg == 1) begin
      $display(
        "%m :\n  Simulation aborted due to invalid parameter value(s)");
      $finish;
    end

  end // parameter_check 

  //-------------------------------------------------------------------------


function [4-1:0] RND_eval;

  input [2:0] RND;
  input [0:0] Sign;
  input [0:0] L,R,STK;


  begin
  RND_eval[0] = 0;
  RND_eval[1] = R|STK;
  RND_eval[2] = 0;
  RND_eval[3] = 0;
  if ($time > 0)
  case (RND)
    3'b000:
    begin
      RND_eval[0] = R&(L|STK);
      RND_eval[2] = 1;
      RND_eval[3] = 0;
    end
    3'b001:
    begin
      RND_eval[0] = 0;
      RND_eval[2] = 0;
      RND_eval[3] = 0;
    end
    3'b010:
    begin
      RND_eval[0] = ~Sign & (R|STK);
      RND_eval[2] = ~Sign;
      RND_eval[3] = ~Sign;
    end
    3'b011:
    begin
      RND_eval[0] = Sign & (R|STK);
      RND_eval[2] = Sign;
      RND_eval[3] = Sign;
    end
    3'b100:
    begin
      RND_eval[0] = R;
      RND_eval[2] = 1;
      RND_eval[3] = 0;
    end
    3'b101:
    begin
      RND_eval[0] = R|STK;
      RND_eval[2] = 1;
      RND_eval[3] = 1;
    end
    default:
      $display("Error! illegal rounding mode.\n");
  endcase
  end

endfunction


  `define DW_R_width (sig_width + 2)
  `define DW_EZ_MAX (2 * ((1 << (exp_width-1)) - 1) + 1)

  reg SIGNA;
  reg [exp_width - 1:0] EA;
  reg [exp_width - 1:0] actual_EA;
  reg [sig_width - 1:0] SIGA;
  reg MAX_EXP_A;
  reg ZerSig_A;
  reg Zero_A;
  reg Denorm_A;
  reg NaN_A;
  reg Inf_A;
  reg [sig_width - 1:0] NaN_Sig;
  reg [sig_width - 1:0] Inf_Sig;
  reg [sig_width - 1:0] Zero_Sig;
  reg [(exp_width + sig_width):0] NaN_Reg;
  reg [(exp_width + sig_width):0] Inf_Reg;
  reg [exp_width - 1:0] exp_max;
  reg [sig_width:0] MA;
  reg [sig_width:0] TMP_MA;
  reg [`DW_R_width-1:0] extended_MA;
  reg [9:0] LZ_INA;
  reg [(exp_width + sig_width):0] z_reg;
  reg [8     - 1:0] status_reg;
  reg signed [exp_width+1:0] EZ;
  reg signed [exp_width+1:0] EM;
  wire Sticky;
  reg Round_Bit;
  reg LS_Bit;
  reg STK_Bit;
  reg [`DW_R_width - 1:1] Mantissa;
  reg [`DW_R_width:1] temp_mantissa;
  reg [4 - 1:0] RND_val;
  reg EZ_Zero;
  reg Movf;
  reg [`DW_R_width-1:0] InvSQRT_inp;
  wire [`DW_R_width-1:0] InvSQRT_out;
  reg quarter_input;
  reg sign;

  always @(a or rnd or InvSQRT_out or Sticky) begin : a1000_PROC
    
    SIGNA = a[(exp_width + sig_width)];
    EA = a[((exp_width + sig_width) - 1):sig_width];
    SIGA = a[(sig_width - 1):0];
    status_reg = 0;
    MAX_EXP_A = (EA == ((((1 << (exp_width-1)) - 1) * 2) + 1));
    ZerSig_A = (SIGA == 0);
    LZ_INA = 0;
    exp_max = {(exp_width){1'b1}};
    quarter_input = 0;

    if (ieee_compliance) begin
      Zero_A = (EA == 0) & (ZerSig_A);
      Denorm_A = (EA == 0) & (~ZerSig_A);
      NaN_A = (EA == ((((1 << (exp_width-1)) - 1) * 2) + 1)) & (~ZerSig_A);
      Inf_A = (EA == ((((1 << (exp_width-1)) - 1) * 2) + 1)) & (ZerSig_A);
      NaN_Sig = 1;
      Inf_Sig = 0;
      NaN_Reg = {1'b0, exp_max, NaN_Sig}; 
      Inf_Reg = {1'b0, exp_max, Inf_Sig};

      if (Denorm_A) begin
        MA = {1'b0, a[(sig_width - 1):0]};
      end
      else begin
        MA = {1'b1, a[(sig_width - 1):0]};
      end

    end
    else begin
      Zero_A = (EA == 0);
      Denorm_A = 0;
      NaN_A = 0;
      Inf_A = (EA == ((((1 << (exp_width-1)) - 1) * 2) + 1));
      MA = {1'b1, a[(sig_width - 1):0]};
      NaN_Sig = 0;
      Inf_Sig = 0;
      NaN_Reg = {1'b0, exp_max, NaN_Sig};
      Inf_Reg = {1'b0, exp_max, Inf_Sig};
    end

    sign = Zero_A & SIGNA;
      
    if (NaN_A || (SIGNA && ~Zero_A)) begin
      status_reg[2] = 1;
      z_reg = NaN_Reg;
    end
    else if (Zero_A) begin
      status_reg[7] = 1;
      status_reg[1] = 1;
      z_reg = {sign, Inf_Reg[(exp_width + sig_width) - 1:0]};
    end
    else if (Inf_A) begin
      status_reg[0] = 1;
      z_reg = 0;
    end 

    else begin

      TMP_MA = MA;
      actual_EA = EA - ((1 << (exp_width-1)) - 1);
      if (Denorm_A) begin
        while(MA[sig_width-1] != 1) begin
          MA = MA << 1;
          LZ_INA = LZ_INA + 1;
        end
        if (LZ_INA[0] ^ actual_EA[0]) begin
            MA = MA << 1;
            LZ_INA = LZ_INA + 1;
        end
        extended_MA = {MA,1'b0};
      end
      else begin
          LZ_INA = -1;
          if (actual_EA[0]) begin
              extended_MA = {MA,1'b0};
          end
          else
            extended_MA = {1'b0,MA};
      end
      if ((|extended_MA[`DW_R_width-3:0] == 0) & (extended_MA[`DW_R_width-1] == 0))
        quarter_input = 1;
      
      EM = -(EA - LZ_INA - quarter_input + Denorm_A - ((1 << (exp_width-1)) - 1));
      EZ = EM >> 1;

      InvSQRT_inp = extended_MA;

      if (quarter_input == 1) begin
          Mantissa = 0;
          Mantissa[`DW_R_width-1] = 1;
          Round_Bit = 0;
          LS_Bit = 0;
          STK_Bit = 0;
      end
      else begin
          Mantissa = InvSQRT_out[`DW_R_width - 1:1];
          Round_Bit = InvSQRT_out[0];
          LS_Bit = InvSQRT_out[1];
          STK_Bit = Sticky;
      end

      RND_val = RND_eval(rnd, 1'b0, LS_Bit, Round_Bit, STK_Bit);

      if (RND_val[0] == 1) temp_mantissa = Mantissa + 1;
      else temp_mantissa = Mantissa;

      Mantissa = temp_mantissa[`DW_R_width - 1:1];

      Movf = temp_mantissa[`DW_R_width];
      if (Movf == 1) begin
        EZ = EZ + 1;
        temp_mantissa = temp_mantissa >> 1;
      end

      EZ_Zero = (EZ == 0);

      EZ = EZ + ((1 << (exp_width-1)) - 1);
      
      if (EZ == 0) begin
        status_reg[3] = 1;

        if (Mantissa[`DW_R_width - 2:1] == 0 & EZ[exp_width - 1:0] == 0)
          status_reg[0] = 1;

      end

      status_reg[5] = RND_val[1];

      if (EZ >= `DW_EZ_MAX) begin
        status_reg[1] = 1;
        status_reg[5] = 0;
        EZ = `DW_EZ_MAX;
        Mantissa = 0;
      end

      z_reg = {sign, EZ[exp_width - 1:0], Mantissa[`DW_R_width - 2:1]};
    end
  end

  DW_inv_sqrt #(`DW_R_width)
   U1 ( .a(InvSQRT_inp), .b(InvSQRT_out), .t(Sticky) );

  assign status = status_reg;
  assign z = z_reg;

  `undef DW_R_width
  `undef DW_EZ_MAX

  // synopsys translate_on

endmodule
