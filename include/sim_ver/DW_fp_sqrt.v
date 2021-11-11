
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
// AUTHOR:    Kyung-Nam Han, Nov. 6, 2006
//
// VERSION:   Verilog Simulation Model for DW_fp_sqrt
//
// DesignWare_version: 4ed00dca
// DesignWare_release: K-2015.06-DWBB_201506.5.2
//
////////////////////////////////////////////////////////////////////////////////

//-----------------------------------------------------------------------------
//
// ABSTRACT: Floating-Point Square Root
//
//              DW_fp_sqrt calculates the floating-point square root
//              while supporting six rounding modes, including four IEEE
//              standard rounding modes.
//
//              parameters      valid values (defined in the DW manual)
//              ==========      ============
//              sig_width       significand f,  2 to 253 bits
//              exp_width       exponent e,     3 to 31 bits
//              ieee_compliance support the IEEE Compliance 
//                              including NaN and denormal expressions.
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
// MODIFIED: 4/25/07, Kyung-Nam Han (z0703-SP2)
//           Corrected DW_fp_sqrt(-0) = -0
//           7/19/10, Kyung-Nam Han (STAR 9000404523, D-2010.03-SP4)
//           Removed bugs with (23,4,1)-configuration
//
//-----------------------------------------------------------------------------

module DW_fp_sqrt (a, rnd, z, status);

  parameter sig_width = 23;      // RANGE 2 TO 253
  parameter exp_width = 8;       // RANGE 3 TO 31
  parameter ieee_compliance = 0; // RANGE 0 TO 1

  input  [sig_width + exp_width:0] a;
  input  [2:0] rnd;
  output [sig_width + exp_width:0] z;
  output [7:0] status;

  // synopsys translate_off


  parameter width = 2 * sig_width + 4;

  `define RND_Width  4
  `define RND_Inc  0
  `define RND_Inexact  1
  `define RND_HugeInfinity  2
  `define RND_TinyminNorm  3
  `define R_width (sig_width + 2)
  
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

  //-----------------------------------------------------
  // Usage: rnd_val = rnd_eval(rnd,Sign,L,R,stk);
  // rnd_val has 4 bits:
  // rnd_val[rnd_Inc]
  // rnd_val[rnd_Inexact]
  // rnd_val[rnd_HugeInfinity]
  // rnd_val[rnd_TinyminNorm]
  //----------------------------------------------------
  // Rounding increment equations
  // MODE | Equation   | Description
  // ------------------------------------------------
  // even | R&(L|stk)  | IEEE round to nearest (even)
  // zero | 0          | IEEE round to zero
  // +inf | S'&(R|stk) | IEEE round to positive infinity
  // -inf | S&(R|stk)  | IEEE round to negative infinity
  // up   | R          | round to nearest (up)
  // away | (R|stk)    | round away from zero
  //----------------------------------------------------

  function [`RND_Width-1:0] rnd_eval;
  
    input [2:0] rnd;
    input [0:0] Sign;
    input [0:0] L,R,stk;

    begin
      rnd_eval[`RND_Inc] = 0;
      rnd_eval[`RND_Inexact] = R|stk;
      rnd_eval[`RND_HugeInfinity] = 0;
      rnd_eval[`RND_TinyminNorm] = 0;
      
      if ($time > 0)
      begin
        case (rnd)
          3'b000:
          begin
            // round to nearest (even)
            rnd_eval[`RND_Inc] = R&(L|stk);
            rnd_eval[`RND_HugeInfinity] = 1;
            rnd_eval[`RND_TinyminNorm] = 0;
          end
          3'b001:
          begin
            // round to zero
            rnd_eval[`RND_Inc] = 0;
            rnd_eval[`RND_HugeInfinity] = 0;
            rnd_eval[`RND_TinyminNorm] = 0;
          end
          3'b010:
          begin
            // round to positive infinity
            rnd_eval[`RND_Inc] = ~Sign & (R|stk);
            rnd_eval[`RND_HugeInfinity] = ~Sign;
            rnd_eval[`RND_TinyminNorm] = ~Sign;
          end
          3'b011:
          begin
            // round to negative infinity
            rnd_eval[`RND_Inc] = Sign & (R|stk);
            rnd_eval[`RND_HugeInfinity] = Sign;
            rnd_eval[`RND_TinyminNorm] = Sign;
          end
          3'b100:
          begin
            // round to nearest (up)
            rnd_eval[`RND_Inc] = R;
            rnd_eval[`RND_HugeInfinity] = 1;
            rnd_eval[`RND_TinyminNorm] = 0;
          end
          3'b101:
          begin
            // round away form 0
            rnd_eval[`RND_Inc] = R|stk;
            rnd_eval[`RND_HugeInfinity] = 1;
            rnd_eval[`RND_TinyminNorm] = 1;
          end
          default:
          begin
            $display("Error! illegal rounding mode.\n");
            $display("a : %b", a);
            $display("rnd : %b", rnd);
          end
        endcase
      end
    end
  endfunction

  reg SIGN;
  reg [exp_width - 1:0] EA;
  reg [sig_width - 1:0] SIGA;
  reg MAX_EXP_A;
  reg InfSig_A;
  reg Zero_A;
  reg Denorm_A;
  reg [sig_width - 1:0] NaN_Sig;
  reg [sig_width - 1:0] Inf_Sig;
  reg [(exp_width + sig_width):0] NaN_Reg;
  reg [(exp_width + sig_width):0] Inf_Reg;
  reg [sig_width:0] MA;
  reg [2 * sig_width + 3:0] Sqrt_in;
  reg [sig_width:0] TMP_MA;
  reg [9:0] LZ_INA;
  reg [`R_width - 1:0] MZ;
  reg [2 * `R_width - 1:0] Square;
  reg [`R_width:0] REMAINDER;
  reg [(exp_width + sig_width):0] z_reg;
  reg [8     - 1:0] status_reg;
  reg signed [exp_width+2:0] EZ;
  reg signed [exp_width+1:0] EM;
  reg Sticky;
  reg Round_Bit;
  reg Guard_Bit;
  reg [`R_width - 1:1] Mantissa;
  reg [`RND_Width - 1:0] RND_val;
  reg [`R_width:1] temp_mantissa;
  reg Movf;
  reg NegInput;

  `include "DW_sqrt_function.inc"

  always @(a or rnd) begin : a1000_PROC
    
    SIGN = 0;
    EA = a[((exp_width + sig_width) - 1):sig_width];
    SIGA = a[(sig_width - 1):0];
    status_reg = 0;
    MAX_EXP_A = (EA == ((((1 << (exp_width-1)) - 1) * 2) + 1));
    InfSig_A = (SIGA == 0);
    LZ_INA = 0;
 
    // Zero and Denormal
    if (ieee_compliance) begin
      Zero_A = (EA == 0) & (SIGA == 0);
      Denorm_A = (EA == 0) & (SIGA != 0);
      NaN_Sig = 1;
      Inf_Sig = 0;
      NaN_Reg = {1'b0, {(exp_width){1'b1}}, NaN_Sig}; 
      Inf_Reg = {SIGN, {(exp_width){1'b1}}, Inf_Sig};

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
      MA = {1'b1, a[(sig_width - 1):0]};
      NaN_Sig = 0;
      Inf_Sig = 0;
      NaN_Reg = {SIGN, {(exp_width){1'b1}}, NaN_Sig};
      Inf_Reg = {SIGN, {(exp_width){1'b1}}, Inf_Sig};
    end

    NegInput = ~Zero_A & a[(exp_width + sig_width)];
    if (ieee_compliance && MAX_EXP_A && ~InfSig_A || NegInput) begin
      status_reg[2] = 1;
      z_reg = NaN_Reg;
    end
    else if (MAX_EXP_A) begin
      if (ieee_compliance == 0) begin
        status_reg[1] = 1;
      end

      if (Zero_A) begin
        status_reg[2] = 1;
        z_reg = NaN_Reg;
      end
      else begin
        status_reg[1] = 1;
        z_reg = Inf_Reg;
      end
    end
    else if (Zero_A) begin
      status_reg[0] = 1;
      z_reg = {a[(exp_width + sig_width)], {(sig_width + exp_width){1'b0}}};
    end
    
    // Normal & Denormal Inputs
    else begin

      // Denormal Check
      TMP_MA = MA;
      if (Denorm_A) begin
        while(MA[sig_width] != 1) begin
          MA = MA << 1;
          LZ_INA = LZ_INA + 1;
        end
      end

      // Exponent Calculation
      EM = EA - LZ_INA + Denorm_A - ((1 << (exp_width-1)) - 1);
      EZ = $signed(EM[exp_width + 1:1]);

      // Adjust Exponent Bias
      EZ = EZ + ((1 << (exp_width-1)) - 1);

      // Square Root Operation
      if (EM[0] == 0) begin
        Sqrt_in = {MA, {(sig_width + 2){1'b0}}};
      end
      else begin
        Sqrt_in = {MA, {(sig_width + 3){1'b0}}};
      end
      MZ = DWF_sqrt_uns(Sqrt_in);
      Square = MZ * MZ;
      REMAINDER = Sqrt_in - Square;
   
      Sticky = (REMAINDER == 0) ? 0 : 1;

      if (ieee_compliance == 1 && (EZ == 0 || EZ < 0)) begin
        Sticky = Sticky | MZ[0];
        MZ = MZ >> 1;
      end

      Mantissa = MZ[`R_width - 1:1];
      Round_Bit = MZ[0];
      Guard_Bit = MZ[1];

      // Rounding Operation
      RND_val = rnd_eval(rnd, 1'b0, Guard_Bit, Round_Bit, Sticky);

      // Round Addition
      if (RND_val[`RND_Inc] == 1) temp_mantissa = Mantissa + 1;
      else temp_mantissa = Mantissa;

      Movf = temp_mantissa[`R_width];
      if (Movf == 1) begin
        EZ = EZ + 1;
        temp_mantissa = temp_mantissa >> 1;
      end

      Mantissa = temp_mantissa[`R_width - 1:1];

      //
      // Tiny
      //
      if (EZ == 0) begin
        status_reg[3] = 1;

        if (Mantissa[`R_width - 2:1] == 0 & EZ[exp_width - 1:0] == 0)
          status_reg[0] = 1;

      end

      status_reg[5] = RND_val[`RND_Inexact];

      if (ieee_compliance == 1 && (EZ < 0)) begin
        if (((1 << (exp_width-1)) - 1) < 2 * sig_width + 1) begin
          Mantissa = Mantissa >> -EZ;
        end

        EZ = 0;
      end

      // Reconstruct the FP number
      z_reg = {1'b0, EZ[exp_width - 1:0], Mantissa[`R_width - 2:1]};
    end
  end

  assign status = status_reg;
  assign z = z_reg;

  `undef RND_Width
  `undef RND_Inc
  `undef RND_Inexact
  `undef RND_HugeInfinity
  `undef RND_TinyminNorm
  `undef R_width

  // synopsys translate_on

endmodule
