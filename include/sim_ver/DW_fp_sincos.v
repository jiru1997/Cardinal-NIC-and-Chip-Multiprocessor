
////////////////////////////////////////////////////////////////////////////////
//
//       This confidential and proprietary software may be used only
//     as authorized by a licensing agreement from Synopsys Inc.
//     In the event of publication, the following notice is applicable:
//
//                    (C) COPYRIGHT 2007 - 2016 SYNOPSYS INC.
//                           ALL RIGHTS RESERVED
//
//       The entire notice above must be reproduced on all authorized
//     copies.
//
// AUTHOR:    Kyung-Nam Han, Aug. 20, 2007
//
// VERSION:   Verilog Simulation Model for DW_fp_sincos
//
// DesignWare_version: 181cbc63
// DesignWare_release: K-2015.06-DWBB_201506.5.2
//
////////////////////////////////////////////////////////////////////////////////

//-----------------------------------------------------------------------------
//
// ABSTRACT: Floating-Point Sine/Cosine Unit
//
//              DW_fp_sincos calculates the floating-point sine/cosine 
//              function. 
//
//              parameters      valid values (defined in the DW manual)
//              ==========      ============
//              sig_width       significand,  2 to 33 bits
//              exp_width       exponent,     3 to 31 bits
//              ieee_compliance support the IEEE Compliance 
//                              including NaN and denormal expressions.
//                              0 - MC (module compiler) compatible
//                              1 - IEEE 754 standard compatible
//              pi_multiple     angle is multipled by pi
//                              0 - sin(x) or cos(x)
//                              1 - sin(pi * x) or cos(pi * x)
//              arch            implementation select
//                              0 - area optimized (default)
//                              1 - speed optimized
//              err_range       error range of the result compared to the
//                              true result. It is effective only when arch = 0
//                              and 1, and ignored when arch = 2
//                              1 - 1 ulp error (default)
//                              2 - 2 ulp error
//
//              Input ports     Size & Description
//              ===========     ==================
//              a               (sig_width + exp_width + 1)-bits
//                              Floating-point Number Input
//              sin_cos         1 bit
//                              Operator Selector
//                              0 - sine, 1 - cosine
//              z               (sig_width + exp_width + 1)-bits
//                              Floating-point Number Output
//              status          8 bits
//                              Status Flags Output
//
// Modified: Kyung-Nam Han 06/03/08
//           Fixed ncVerilog error due to $unsigned at the array index.
//           Kyung-Nam Han 07/23/08
//           Added two new parameters, arch and err_range
//           Kyung-Nam Han 06/16/10 (STAR 9000400674, D-2010.03-SP3)
//           Fixed bugs of DW_fp_sincos when sig_width<=9
//           Kyung-Nam Han 08/10/10 (STAR 9000409629, D-2010.03-SP4)
//           Fixed bugs of (sig_width=23, exp_width=4 and ieee_compliance=1)-
//           parameter
//           Kyung-Nam Han 07/07/15 (STAR 9000921582, K-2015.06-SP1)
//           Bug fix for pi_multiple=0
//-----------------------------------------------------------------------------

module DW_fp_sincos (a, sin_cos, z, status);

  parameter sig_width = 23;      // RANGE 2 TO 33
  parameter exp_width = 8;       // RANGE 3 TO 31
  parameter ieee_compliance = 0; // RANGE 0 TO 1
  parameter pi_multiple = 1;     // RANGE 0 TO 1
                                 // pi_multiple = 1, sincos(pi * x)
                                 // pi_multiple = 0, sincos(x)
  parameter arch = 0;            // RANGE 0 TO 1
  parameter err_range = 1;       // RANGE 1 TO 2

  // for internal use
  parameter rcp_margin_bit   = 5;
  parameter round_nearest_pi = 1;


  localparam in_margin = (pi_multiple) ? 0 : 1;
  localparam sig_width_new = sig_width + rcp_margin_bit;
  localparam ma_rcp_pi_width = 2 * sig_width + rcp_margin_bit + 2;
  localparam err_range_new = (pi_multiple) ? err_range : 1;
 
  input  [sig_width + exp_width:0] a;
  input  sin_cos;                // sin_cos = 0, sin(x)
                                 // sin_cos = 1, cos(x)
  output [sig_width + exp_width:0] z;
  output [7:0] status;

  // synopsys translate_off


  //-------------------------------------------------------------------------
  // Parameter legality check
  //-------------------------------------------------------------------------
    
 
  initial begin : parameter_check
    integer param_err_flg;

    param_err_flg = 0;
    
      
    if ( (sig_width < 2) || (sig_width > 33) ) begin
      param_err_flg = 1;
      $display(
	"ERROR: %m :\n  Invalid value (%d) for parameter sig_width (legal range: 2 to 33)",
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
      
    if ( (pi_multiple < 0) || (pi_multiple > 1) ) begin
      param_err_flg = 1;
      $display(
	"ERROR: %m :\n  Invalid value (%d) for parameter pi_multiple (legal range: 0 to 1)",
	pi_multiple );
    end
      
    if ( (arch < 0) || (arch > 1) ) begin
      param_err_flg = 1;
      $display(
	"ERROR: %m :\n  Invalid value (%d) for parameter arch (legal range: 0 to 1)",
	arch );
    end
      
    if ( (err_range < 1) || (err_range > 2) ) begin
      param_err_flg = 1;
      $display(
	"ERROR: %m :\n  Invalid value (%d) for parameter err_range (legal range: 1 to 2)",
	err_range );
    end
      
    if ( (rcp_margin_bit < 0) || (rcp_margin_bit > 32) ) begin
      param_err_flg = 1;
      $display(
	"ERROR: %m :\n  Invalid value (%d) for parameter rcp_margin_bit (legal range: 0 to 32)",
	rcp_margin_bit );
    end
      
    if ( (round_nearest_pi < 0) || (round_nearest_pi > 1) ) begin
      param_err_flg = 1;
      $display(
	"ERROR: %m :\n  Invalid value (%d) for parameter round_nearest_pi (legal range: 0 to 1)",
	round_nearest_pi );
    end
    
    if ( param_err_flg == 1) begin
      $display(
        "%m :\n  Simulation aborted due to invalid parameter value(s)");
      $finish;
    end

  end // parameter_check 

  //-------------------------------------------------------------------------

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
  reg [sig_width + in_margin:0] MA_PI;
  reg [sig_width + in_margin:0] MA_IN;
  reg [9:0] LZ_INA;
  reg [(exp_width + sig_width):0] z_reg;
  reg [7:0] status_reg;
  reg signed [exp_width+1:0] EZ;
  reg signed [exp_width+1:0] EM;
  reg signed [exp_width+1:0] EM_PI;
  reg signed [exp_width+1:0] EM_Neg;
  reg [98:0] recip_pi_value;
  reg [sig_width + rcp_margin_bit:0] recip_pi;
  reg [ma_rcp_pi_width - 1:0] MA_RCP_PI;
  reg [sig_width + in_margin:0] SINCOS_IN;
  reg [sig_width:0] NORM_IN;
  reg [sig_width:0] NORM_IN_PRE;
  reg [sig_width + 1:0] SINCOS_OUT_r;
  reg [sig_width + 1:0] t1;
  reg [sig_width + 1:0] t2;
  reg SIGNOUT;

  wire [sig_width + 1:0] SINCOS_OUT;
  wire [sig_width + 1 + in_margin:0] SINCOS_OUT_NEW;
  wire [sig_width + 1:0] SINCOS_OUT_OLD;

  // Fixed-point SINCOS

  DW_sincos #(sig_width + 1 + in_margin, sig_width + 2 + in_margin, arch, err_range) U2 (
    .A(SINCOS_IN),
    .SIN_COS(sin_cos),
    .WAVE(SINCOS_OUT_NEW)
  );

  assign SINCOS_OUT = SINCOS_OUT_NEW[sig_width + 1 + in_margin:in_margin];

  always @(SINCOS_OUT) begin : a1000_PROC
    t1 = SINCOS_OUT;
  end

  always @(t1 or a or sin_cos) begin : a1001_PROC
    
    t2 = t1;
    SINCOS_OUT_r = t1;

    SIGN = a[sig_width + exp_width];

    EA = a[(exp_width + sig_width) - 1:sig_width];
    SIGA = a[(sig_width - 1):0];
    MAX_EXP_A = (EA == ((1 << (exp_width-1)) - 1) * 2 + 1);

    status_reg = 0;
    InfSig_A = (SIGA == 0);
    LZ_INA = 0;
    NORM_IN = SINCOS_OUT_r[sig_width:0];

    recip_pi_value = 99'b101000101111100110000011011011100100111001000100000101010010100111111100001001110101011111010001111;

    recip_pi = recip_pi_value[98:98 - sig_width - rcp_margin_bit];

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
      MA = {1'b1, a[(sig_width - 1):0]};

      Zero_A = (EA == 0);
      Denorm_A = 0;
      NaN_Sig = 0;
      Inf_Sig = 0;
      NaN_Reg = {1'b0, {(exp_width){1'b1}}, NaN_Sig};
      Inf_Reg = {SIGN, {(exp_width){1'b1}}, Inf_Sig};
    end

    if (MAX_EXP_A) begin
      status_reg[2] = 1;
      z_reg = NaN_Reg;
    end
    else if (Zero_A) begin
      if (sin_cos == 0) begin
        status_reg[0] = 1;
        z_reg = {a[(exp_width + sig_width)], {(sig_width + exp_width){1'b0}}};
      end
      else begin
        z_reg = {2'b0, {(exp_width - 1){1'b1}}, {(sig_width){1'b0}}};
      end
    end
    
    else begin

      if (Denorm_A) begin
        while(MA[sig_width] != 1) begin
          MA = MA << 1;
          LZ_INA = LZ_INA + 1;
        end
      end

      EM = $signed({2'b0, EA}) - $signed({1'b0, LZ_INA}) + $signed({1'b0, Denorm_A}) - $signed({3'b0, {(exp_width - 1){1'b1}}});

      MA_RCP_PI = MA * recip_pi;
   
      if (MA_RCP_PI[ma_rcp_pi_width - 1]) begin
        EM_PI = EM + 1;
      end
      else begin
        MA_RCP_PI = MA_RCP_PI << 1;
        EM_PI = EM;
      end

      if (pi_multiple == 0) begin
        EM = $signed(EM_PI) - $signed(2);
      end

      EM_Neg = -EM;

      if (EM >= 0) begin
        MA_RCP_PI = MA_RCP_PI << EM;
        MA = MA << EM;
      end
      else begin
        MA_RCP_PI = MA_RCP_PI >> EM_Neg;
        MA = MA >> EM_Neg;
      end

      if (round_nearest_pi) begin
        MA_PI = MA_RCP_PI[ma_rcp_pi_width - 1:ma_rcp_pi_width - (sig_width + 1 + in_margin)] + MA_RCP_PI[ma_rcp_pi_width - (sig_width + 1 + in_margin) - 1];
      end
      else begin
        MA_PI = MA_RCP_PI[ma_rcp_pi_width - 1:ma_rcp_pi_width - (sig_width + 1 + in_margin)];
      end

      if (pi_multiple) begin
        MA_IN = MA;
      end
      else begin
        MA_IN = MA_PI;
      end

      SINCOS_IN = MA_IN;

      if (sin_cos) begin
        SIGNOUT = SINCOS_OUT[sig_width + 1];         // cos(-x) = cos(x)
      end
      else begin
        SIGNOUT = SINCOS_OUT[sig_width + 1] ^ SIGN;  // sin(-x) = -sin(x)
      end

      if (SINCOS_OUT[sig_width + 1]) begin
        NORM_IN = ~SINCOS_OUT[sig_width:0] + 1;
      end
      else begin
        NORM_IN = SINCOS_OUT[sig_width:0];
      end

      NORM_IN_PRE = NORM_IN;

      EZ = $signed({1'b0, {(exp_width - 1){1'b1}}});

      if (NORM_IN[sig_width:1] == 0) begin
        EZ = 0;
        status_reg[0] = 1;
        NORM_IN = 0;
      end
      else begin
        while (NORM_IN[sig_width] == 0) begin
          EZ = EZ - $signed(2'b01);
          NORM_IN = NORM_IN << 1;
        end
      end

      if (sig_width > ((1 << (exp_width-1)) - 1)) begin
        if (ieee_compliance) begin
          if (EZ <= 0) begin
            EZ = 0;
            NORM_IN = NORM_IN_PRE << (((1 << (exp_width-1)) - 1) - 1);
          end
        end
        else begin // ieee_compliance == 0
          if (EZ <= 0) begin
            EZ = 0;
            NORM_IN = 0;
          end
        end
      end

      if (EZ == 0) begin
        status_reg[3] = 1;

        if (ieee_compliance == 0) begin
          NORM_IN = 0;
          status_reg[0] = 1;
        end

      end

      status_reg[5] = 1;

      z_reg = {SIGNOUT, EZ[exp_width - 1:0], NORM_IN[sig_width - 1:0]};
    end
  end

  assign status = status_reg;
  assign z = z_reg;

  // synopsys translate_on

endmodule
